#
# Config For Load Balancer
#
class ConfigLoadBalancing

  def initialize full_config
    @full_config = full_config
    @lb_config = full_config['load_balancing']
  end

  def enabled
    @lb_config != nil
  end

  def method
    @lb_config['method']
  end

  def provider
    @lb_config['provider']
  end

  def entry_points
    @lb_config['entry_points'] || "http,https"
  end

  def host_port
    @lb_config['host_port'] || 0
  end
end
