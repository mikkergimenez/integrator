class HelmChart
  def initialize app_name, config, runner
    @app_name = app_name
    @config   = config
    @runner   = runner
  end

  def install_tiller
    @runner.repo_command "helm init"
  end

  def run_command helm_chart_name
    @helm_app_name = helm_chart_name.split("/")[1]
    @runner.repo_command "helm install --name #{app_name}-#{helm_app_name} #{helm_chart_name}"
  end

  def deploy
    install_tiller
    @config.each do |helm_chart|
      run_command helm_chart
    end
  end
end

module TestDependencies
  class HelmChart
    def self.check runner
      result = runner.repo_command("helm version", echo: false)
      if result
        return true, "Helm is authenticated"
      else
        return false, "Helm is not authenticated, update ~/.kube/config"
      end
    end
  end
end
