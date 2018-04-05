require 'colorize'
require 'config'
require 'aws/ecr'

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


  def pre
    @runner.repo_command(@config.pre_build) if @config.pre_build
  end

  def run
    puts "Pushing Container #{@config.docker.tag}"
    @runner.repo_command "docker build -t #{@config.docker.tag} ."
  end

  def post

  end

  def push
    if @config.docker.tag.include?("dkr.ecr")
      aws_ecr = AWS::ECR.new
      aws_ecr.check_for_or_create_repo @config.docker.image
    end
    push_results = @runner.repo_command "docker push #{@config.docker.tag}"
    unless push_results
      puts "\nPush Failed".red
      if @config.docker.registry.include?("dkr.ecr")
        matchdata = @config.docker.registry.match(/[0-9]{12}\.dkr\.ecr\.(.*).amazonaws.com.*/)

        puts "If the following docker push does not work, try logging into ECR "
        puts "Using: aws ecr get-login --no-include-email --region #{matchdata[1]} (pipe to bash to execute)"
      end
    end
  end

  private

end
