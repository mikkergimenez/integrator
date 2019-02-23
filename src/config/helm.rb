#
# Config for Environment Variables
#
class ConfigHelm
  def initialize environment, full_config
    @helm_config = full_config['helm']
    @environment = environment
  end

  def helm_dir
    return @helm_config["directory"] || "helm-chart"
  end
end
