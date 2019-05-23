require 'provider/aws/ecs'
require 'provider/kubernetes'
require 'provider/helm'

module Deploy
  class Deployer
    def initialize(config, runner)
      @config = config
      @runner = runner
    end
  end

  class Nomad < Deployer
    def deploy
      @runner.repo_command "nomad run config/nomad.job"
    end

    def start
      deploy
    end
  end

  #
  # Deploys to Amazon's ECS Service
  #
  class ECS < Deployer
    def deploy
      aws_ecs = AWS::ECS.new @config
      aws_ecs.deploy
    end

    def print_deploy_info
      aws_ecs = AWS::ECS.new @config
      aws_ecs.print_deploy_info
    end

    def start
      deploy
    end
  end

  #
  # Deploys to Kubernetes Service
  #
  class Kubernetes < Deployer
    def deploy
      kubernetes = Provider::Kubernetes.new @config
      kubernetes.deploy
    end

    def print_deploy_info
      kubernetes = Provider::Kubernetes.new @config
      kubernetes.print_deploy_info
    end

    def start
      deploy
    end
  end

  #
  # Deploys to Helm Service
  #
  class Helm < Deployer
    def deploy
      helm = Provider::Helm.new @config, @runner
      helm.deploy
    end

    def print_deploy_info
      helm = Provider::Helm.new @config, @runner
      helm.print_deploy_info
    end

    def start
      deploy
    end
  end

  class S3cmd < Deployer
    def deploy
      @runner.repo_command "aws s3 sync #{@config.s3.files} s3://#{@config.s3.endpoint}  --delete --only-show-errors"
    end

    def print_deploy_info
      "Deploying with s3cmd"
    end

    def start
      deploy
    end
  end

  DEFAULT_CLASS = Deployer
  DEPLOY_CLASSES = {
    'nomad'      => Nomad,
    'ecs'        => ECS,
    'kubernetes' => Kubernetes,
    'helm'       => Helm,
    's3cmd'      => S3cmd
 }

  def self.for(provider: nil, config: nil, runner: nil)
    puts "Creating new Deployer"
    puts config
    puts runner
    puts "Now really creating it:"
    (DEPLOY_CLASSES[provider] || DEFAULT_CLASS).new(config, runner)
  end
end
