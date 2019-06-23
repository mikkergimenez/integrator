require 'artii'
require 'colorize'
require 'config'
require 'steps/deploy'
require 'provider/aws/ecr'

#
# The "Builder" object runs through the process of testing, building and
# deploying an application
#
class Build
  def initialize(config, name, runner, repo_uri)
    @config = config
    @name = name
    @runner = runner
    @uri = repo_uri
  end

  def print_summary latest_sha
    a = Artii::Base.new :font => 'slant'
    puts "*********************************************************************"
    puts a.asciify(@config.app_name)

    puts "Deploy Provider:     #{@config.deploy.provider}"
    puts "Deploy Job File:     #{@config.deploy.job_file}"
    puts "Deploy Method:       #{@config.build.method}"
    puts "Deploy Build Script: #{@config.build.command}"

    puts "Build Language: #{@config.language}"
    puts "Build Method: #{@config.build.method}"
    puts "Deploying SHA: #{latest_sha}"
    puts "Deploying to: #{@config.deploy.provider}"

    deployer = Deploy.for(
      provider: @config.deploy.provider,
      config: @config,
      runner: @shell_runner
    )
    deployer.print_deploy_info

    puts "*********************************************************************"
  end

  def pre
    @runner.repo_command(@config.pre_build) if @config.pre_build
  end

  def run

    puts "Building app with method #{@config.build.method}"
    return @runner.repo_command "docker build -t #{@config.docker.tag} ." if @config.build.method == "docker"
    return @runner.repo_command @config.build.command if @config.build.method == "command"
    raise Exception("No valid config build method found")
  end

  def post

  end

  def push
    return unless @config.build.method == "docker"
    if @config.docker.tag.include?("dkr.ecr")
      aws_ecr = Provider::AWS::ECR.new
      aws_ecr.check_for_or_create_repo @config.docker.image
    end
    push_results = @runner.repo_command "docker push #{@config.docker.tag}"
    unless push_results
      puts "\nPush Failed".red
      if @config.docker.registry.include?("dkr.ecr")
        matchdata = @config.docker.registry.match(/[0-9]{12}\.dkr\.ecr\.(.*).amazonaws.com.*/)

        puts "If the above docker push failed, use: "
        puts "Use: aws ecr get-login --no-include-email --region #{matchdata[1]} (pipe to bash to execute)"
      end
    end
  end

  private

end
