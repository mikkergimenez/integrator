#
# Config for Environment Variables
#
class ConfigHelm
  def initialize environment, full_config
    @helm_config = full_config['helm']
    @environment = environment
  end

  def dir
    return @helm_config["directory"] || "helm-chart"
  end
end
