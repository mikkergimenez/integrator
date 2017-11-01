#
# Configuration settings for docker builds
#
class ConfigDocker
  def initialize(full_config)
    puts 'Getting Docker Config from: '
    p full_config
    @docker_config = full_config['docker']
  end

  def container_port
    @docker_config['container_port']
  end

  def tag
    "#{@docker_config['registry']}/#{@docker_config['image']}"
  end

  def registry
    @docker_config['registry']
  end

  def image
    @docker_config['image']
  end
end
