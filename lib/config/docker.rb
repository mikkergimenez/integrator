
#
# Configuration settings for docker builds
#
class Docker
  def initialize(full_config)
    puts 'Getting Docker Config from: '
    p full_config
    @docker_config = full_config['docker']
  end

  def tag
    return "#{@docker_config['registry']}/#{@docker_config['image']}"
  end

  def registry
    return @docker_config['registry']
  end

  def image
    return @docker_config['image']
  end
end
