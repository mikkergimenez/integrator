#
# Config for Environment Variables
#
class ConfigEnvironment
  def initialize environment, full_config
    @env_config = full_config['env_vars']
    @environment = environment
  end

  def hash
    return @env_config
  end

  def name_value_pair
    pair_list = []

    @env_config[@environment].each do |k, v|
      pair_list.push(
        name: k,
        value: v
      )
    end

    pair_list
  end

end
