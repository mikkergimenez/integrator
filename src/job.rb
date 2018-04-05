require 'config'
require 'shell_runner'

require 'steps/build'
require 'steps/dependencies'
require 'steps/deploy'
require 'steps/tester'

class Job

  def initialize local_repo: nil, updated: nil
    @local_repo = local_repo
    @updated    = updated

    @shell_runner = ShellRunner.new checkout_dir
    @uri = @local_repo.uri
    @name = @local_repo.name


    @tester = Tester.new @shell_runner
  end

  def checkout_dir
    @local_repo.checkout_dir
  end

  def cleanup
    puts "Cleaning up Build Directory #{checkout_dir}"
    FileUtils.rm_rf(checkout_dir)
  end

  def config
    @config ||= Config.new checkout_dir
  end

  def deploy
    puts "Deploying App"
    deployer = Deploy.for(
      deploy_method: config.deploy.method,
      config: config,
      runner: @runner
    )
    deployer.start
  end

  def install_dependencies
    @dependencies = Dependencies.new config, @shell_runner
    @dependencies.install
  end

  def job_pipeline
    checkout_dir = @local_repo.checkout
    install_dependencies

    if @tester.run config, checkout_dir
      @build = Build.new config, @local_repo.name, @shell_runner, @local_repo.uri
      @build.pre
      @build.run
      @build.push
      @build.post
      deploy
    else
      notifier = Slack::Notifier.new ENV["SLACK_HOOK_URL"]
      notifier.ping  "Tests failed for repo #{@name}"
    end

    @local_repo.last_updated = @updated

  end

  def trigger
    puts "#{@local_repo.name} last Updated: #{@local_repo.last_updated}"
    puts "Triggering build for repo: #{@local_repo.name}"
    notifier = Slack::Notifier.new ENV["SLACK_HOOK_URL"]
    notifier.ping  "#{@local_repo.name} last Updated: #{@local_repo.last_updated}\nTriggering build for repo: #{@local_repo.name}"

    begin
      job_pipeline
    rescue StandardError => e
      puts "\n"
      puts "Build Failed: ".red
      puts e
      puts e.backtrace
      puts "\n\n\n"
    end

    puts "Job complete, going back to cycle"
  end

end
