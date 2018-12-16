require 'provider/aws/ecs'
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

    def start
      deploy
    end
  end


  DEFAULT_CLASS = Deployer
  DEPLOY_CLASSES = {
    'nomad' => Nomad,
    'ecs'   => ECS }

  def self.for(deploy_method: nil, config: nil, runner: nil)
    (DEPLOY_CLASSES[deploy_method] || DEFAULT_CLASS).new(config, runner)
  end
end
