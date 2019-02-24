require 'config'
require 'tools/shell_runner'

require 'steps/build'
require 'steps/dependencies'
require 'steps/deploy'
require 'steps/supporting_services'
require 'steps/tester'

class Job

  def initialize config: nil, local_repo: nil, updated: nil, flag_cleanup_dir: false
    @config             = config
    @local_repo         = local_repo

    @updated          = updated
    @flag_cleanup_dir = flag_cleanup_dir

    puts "Running job in Working Directory: #{config.working_directory}"
    @shell_runner = ShellRunner.new config.working_directory
    @uri          = @local_repo.uri
    @name         = @local_repo.name


    @tester       = Tester.new @shell_runner
  end

  def checkout_dir
    @local_repo.checkout_dir
  end

  def cleanup
    if @flag_cleanup_dir
      puts "Cleaning up Build Directory #{checkout_dir}"
      FileUtils.rm_rf(checkout_dir)
    end
  end

  def deploy
    puts "------ Deploying supporting services ----- "
    deploy_supporting_services

    puts "------ Deploying App ----- "
    deployer = Deploy.for(
      provider: @config.deploy.provider,
      config: @config,
      runner: @shell_runner
    )

    begin
      deployer.start
    rescue Exception => e
      puts e
      puts @config.deploy.provider
      puts @config
      puts @shell_runner
      puts e.backtrace
    end
  end

  def install_dependencies
    @dependencies = Dependencies.new @config, @shell_runner
    @dependencies.install
  end

  def deploy_supporting_services
    @supporting_services = SupportingServices.new @local_repo.name, @config, @shell_runner
    @supporting_services.deploy
  end

  #
  # Here is the main pipelines
  #
  def job_pipeline
    checkout_dir = @local_repo.checkout
    install_dependencies

    if @tester.run @config, checkout_dir
      @build = Build.new @config, @local_repo.name, @shell_runner, @local_repo.uri
      @build.print_summary @local_repo.latest_sha
      @build.pre
      @build.run
      @build.push
      @build.post
      deploy
    else
      notifier = Slack::Notifier.new ENV["SLACK_HOOK_URL"]
      notifier.ping  "Tests failed for repo #{@name}"
    end

    @local_repo.set_last_updated(@updated)

  end

  def trigger
    puts "#{@local_repo.name} last Updated: #{@local_repo.last_updated}"
    puts "Triggering build for repo: #{@local_repo.name} in dir #{@config.working_directory}"
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
