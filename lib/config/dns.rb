class ConfigDNS
  def initialize environment, full_config
    @dns_config = full_config['dns']
    @environment = environment
  end

  def hostname
    @dns_config[@environment]['hostname']
  end

  def name
    @dns_config[@environment]['hostname']
  end

end
