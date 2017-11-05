DEFAULT_CONTAINER_INSTANCES = 2

class ConfigECS
  def initialize full_config
    @ecs_config = full_config['ecs']
  end
  def service_name
    return @ecs_config["service_name"] if @ecs_config["service_name"]
    return @ecs_config["name"] if @ecs_config["name"]
    raise "No service name Specified, add ecs: service_name: to your integrator.yaml"
  end

  def task_definition_name
    return @ecs_config["task_definition_name"] if @ecs_config["task_definition_name"]
    return @ecs_config["task_definition"] if @ecs_config["task_definition"]
    return @ecs_config["name"] if @ecs_config["name"]
    raise "No task definition name Specified add ecs: task_definition_name: to your integrator.yaml"
  end

  def cluster_name
    return @ecs_config["cluster"] if @ecs_config["cluster"]
    return @ecs_config["cluster_name"] if @ecs_config["cluster_name"]
    raise "No cluster specified, add ecs: cluster_name: to your integrator.yaml"
  end

  def desired_count
    return @ecs_config["desired_count"] if @ecs_config["desired_count"]
    return @ecs_config["container_instances"] if @ecs_config["container_instances"]
    return @ecs_config["instances"] if @ecs_config["instances"]
    DEFAULT_CONTAINER_INSTANCES
  end

  def memory_reservation
    return @ecs_config['memory_reservation']
  end

  def memory
    return @ecs_config['memory']
  end
end
