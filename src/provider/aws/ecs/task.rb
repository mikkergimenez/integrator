require 'aws-sdk'

module Provider
  module AWS
    class ECSTask
      def initialize client, config
        @client = client
        @config = config
      end

      #
      # The number of cpu units reserved for the container. A container instance has 1,024 cpu units for every CPU core. This parameter specifies the minimum amount of CPU to reserve for a container, and containers share unallocated CPU units with other containers on the instance with the same ratio as their allocated amount. This parameter maps to CpuShares in the Create a container section of the Docker Remote API and the --cpu-shares option to docker run.
      #
      def cpu_limit
        128
      end

      def docker_tag
        @config.docker.tag
      end

      def exists?(task_definition_name)
        tasks = @client.list_tasks(
          cluster: @config.ecs.cluster_name,
          family: task_definition_name
        )

        return tasks.task_arns.length > 0
      end

      #
      # Memory hard limit in mb
      #
      def memory
        @config.ecs.memory || 2048
      end

      #
      # Memory soft limit in MB
      #
      def memory_reservation
        @config.ecs.memory_reservation || 1024
      end

      def traefik_labels
        {
          'traefik.frontend.rule'         => "Host:#{@config.dns.hostname}",
          'traefik.frontend.entryPoints'  => 'http,https'
        }
      end

      def docker_labels
        labels = {}

        if @config.load_balancing.enabled
          if @config.load_balancing.provider == 'traefik'
            labels = labels.merge(traefik_labels)
          end
        end

        labels
      end

      def host_port
        @config.load_balancing.host_port
      end

      def port_mappings
        return [] unless @config.load_balancing.enabled || @config.ecs.expose_docker_ports || @config.ecs.port_mappings
        if @config.load_balancing.enabled
          return [{
            container_port: @config.docker.container_port,
            host_port: host_port,
            protocol: 'tcp', # accepts tcp, udp
          }]
        elsif @config.ecs.expose_docker_ports == "directly"
          port_mappings = []
          @config.docker.container_port.each do |p|
            port_mappings.push({
              container_port: p,
              host_port: p,
              protocol: 'tcp'
            })
          end
          return port_mappings
        else
          port_mappings = []
          return port_mappings unless defined?(@config.ecs.port_mappings)
          return @config.ecs.port_mappings.each do |cp, hp|
            port_mappings.push({
              container_port: cp,
              host_port: hp,
              protocol: 'tcp'
            })
          end
          return port_mappings
        end
      end

      def register(task_definition_name)
        @client.register_task_definition({
          family: task_definition_name,
          container_definitions: [{
            name: task_definition_name,
            image: docker_tag,
            cpu: cpu_limit,
            memory: memory,
            memory_reservation: memory_reservation,
            environment: @config.env_vars.name_value_pair(),
            port_mappings: port_mappings,
            docker_labels: docker_labels,
          }],
          placement_constraints: @config.ecs.constraints.map { |c| {type: c.keys()[0], expression: c.values()[0]}  }
        })
      end
    end
  end
end
