#
# Configuration settings for docker builds
#
class ConfigDocker
  def initialize(full_config, app_name)
    @app_name = app_name
    @docker_config = full_config['docker'] || {}
    @full_config = full_config
  end

  def container_port
    @docker_config['container_port']
  end

  def full_image
    "#{@docker_config['registry']}/#{image}"
  end

  def image
    @docker_config['image'] || @app_name
  end

  def tag
    abort("docker.registry must be set to deploy with docker") unless @docker_config.is_a?(Hash) && @docker_config['registry']
    "#{@docker_config['registry']}/#{image}"
  end

  def registry
    @docker_config['registry']
  end

  def image
    @docker_config['image'] || @app_name
  end
end
