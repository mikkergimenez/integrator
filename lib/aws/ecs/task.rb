module Deploy
  module AWS
    class ECSTask
      def initialize client, config
        @ecs = client
        @config = config
      end

      #
      # The number of cpu units reserved for the container. A container instance has 1,024 cpu units for every CPU core. This parameter specifies the minimum amount of CPU to reserve for a container, and containers share unallocated CPU units with other containers on the instance with the same ratio as their allocated amount. This parameter maps to CpuShares in the Create a container section of the Docker Remote API and the --cpu-shares option to docker run.
      #
      def cpu_limit
        512
      end

      def docker_image
        @config.docker.image
      end

      #
      # Memory hard limit in mb
      #
      def memory
        2048
      end

      #
      # Memory soft limit in MB
      #
      def memory_reservation
        1024
      end

      def register task_definition_name
        @ecs.register_task_definition({
          family: task_definition_name,
          container_definitions: [{
            name: task_definition_name,
            image: docker_image,
            cpu: cpu_limit,
            memory: memory,
            memory_reservation: memory_reservation,
          }]
        })
      end
    end
  end
end
