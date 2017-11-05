require 'colorize'
require 'config'
require 'runner'
require 'deployer'
require 'aws/ecr'

#
# The "Builder" object runs through the process of testing, building and
# deploying an application
#
class Builder
  @config = nil

  def initialize(repo_uri, name)
    @g = nil
    @uri = repo_uri
    @name = name
    @runner = Runner.new checkout_dir
  end

  def checkout
    puts "Working with #{@g}"
    if @g
      puts 'Pulling latest '
      @g.pull # I don't think this pull is working
    else
      begin
        puts "Checking out #{@uri}"
        @g = Git.clone(@uri, @name, path: checkout_path)
      rescue Git::GitExecuteError
        cleanup
        puts "Checking out #{@uri}"
        @g = Git.clone(@uri, @name, path: checkout_path)
      end
    end
  end

  def cleanup
    puts "Cleaning up Build Directory #{checkout_dir}"
    FileUtils.rm_rf(checkout_dir)
  end

  def config
    @config ||= Config.new checkout_dir
  end


  def build
    puts ''
    checkout

    install_dependencies
    test_outcome = run_tests
    puts "Test Outcome #{test_outcome}"
    if test_outcome
      pre_build
      run_build
      push_build
      deploy
    else
      notifier = Slack::Notifier.new ENV["SLACK_HOOK_URL"]
      notifier.ping  "Tests failed for repo #{@name}"
    end
  end

  def install_dependencies
    # Make sure that `gem install nio4r -v '2.1.0'` succeeds before bundling.
    if config.language == "go"
      @runner.repo_command "go get"
    elsif config.language == "ruby"
      @runner.repo_command "bundle package" # --gemfile=#{checkout_dir}/Gemfile
    end
  end

  def pre_build
    @runner.repo_command(config.pre_build) if config.pre_build
  end

  def run_build
    puts "Pushing Container #{config.docker.tag}"
    @runner.repo_command "docker build -t #{config.docker.tag} ."
  end

  def push_build
    if config.docker.tag.include?("dkr.ecr")
      aws_ecr = AWS::ECR.new
      aws_ecr.check_for_or_create_repo config.docker.image
    end
    push_results = @runner.repo_command "docker push #{config.docker.tag}"
    unless push_results
      puts "\nPush Failed".red
      if config.docker.registry.include?("dkr.ecr")
        matchdata = config.docker.registry.match(/[0-9]{12}\.dkr\.ecr\.(.*).amazonaws.com.*/)

        puts "If the following docker push does not work, try logging into ECR "
        puts "Using: aws ecr get-login --no-include-email --region #{matchdata[1]} (pipe to bash to execute)"
      end
    end
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

  def run_tests
    puts "Running tests against #{@name}"
    $LOAD_PATH.unshift(File.expand_path(checkout_dir)) unless $LOAD_PATH.include?(File.expand_path(checkout_dir))
    unless config.test_command
      puts "No tests to run"
      return true
    end
    @runner.repo_command(config.test_command)
  end

  private

  def checkout_path
    '/tmp/checkout'
  end

  def checkout_dir
    "/tmp/checkout/#{@name}"
  end


end
