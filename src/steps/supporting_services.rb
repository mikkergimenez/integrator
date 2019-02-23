class SupportingServices
  def initialize app_name, config, runner
    @app_name = app_name
    @config   = config
    @runner   = runner
  end

  def deploy
    if @config.helm_charts
      helm_chart = HelmChart.new @app_name, @config[:helm_charts], @runner
      helm_chart.deploy()
    end
  end
end
