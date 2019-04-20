require 'colorize'

module Provider
  class Helm
    def initialize config=nil, runner
      @config = config
      @test_only = config==nil
      @runner = runner
    end

    def print_deploy_info
      puts "Using Helm Directory: #{@config.helm.dir}"
    end

    def deploy
      app_deployed = @runner.repo_command "helm list |grep #{@config.app_name}"
      if app_deployed
        helm_command = "helm upgrade #{@config.app_name} #{@config.helm.dir} --set image.tag=#{@config.git_sha}"
        Logger.section "Deploying helm chart using command #{helm_command} "
        @runner.repo_command helm_command
      end
    end
  end
end
