require 'colorize'

module Provider
  class Helm
    def initialize config=nil, runner
      @config = config
      @test_only = config==nil
      @runner = runner
    end

    def deploy
      app_deployed = @runner.repo_command "helm list |grep #{@config.app_name}"
      if app_deployed
        @runner.repo_command "helm upgrade #{@config.app_name} @config.helm.helm_dir
      end
    end
  end
end
