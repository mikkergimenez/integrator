require 'aws-sdk'
require 'provider/aws/ecs/task'

ECS_ENV_VARS_NOT_SET_EXCEPTION = 'In order to use the ECS Plugin, Please ensure the AWS_ACCES_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables are set'

module Deploy
  module AWS
    #
    # The AWS::ECS Class Wraps the aws-sdk for ECS, allowing deploys to
    # ECS.
    #
    class ECS
      def initialize config
        raise ECS_ENV_VARS_NOT_SET_EXCEPTION unless ENV["AWS_ACCESS_KEY_ID"].is_a?(String) && ENV["AWS_SECRET_ACCESS_KEY"].is_a?(String)
        @ecs_client = Aws::ECS::Client.new(region: 'us-east-1')
        @config = config
      end

      def deploy
        cluster_name = @config.ecs.cluster_name
        service_name = @config.ecs.service_name
        task_definition = @config.ecs.task_definition_name

        puts "Deploying to ECS...".green
        instance_count = @config.ecs.desired_count

        tdn = register_task_definition(task_definition)

        return create_service(service_name, tdn, instance_count) unless service_exists?(service_name)
        update_service(service_name, tdn, instance_count)
      end

      def register_task_definition task_definition_name
        task = Deploy::AWS::ECSTask.new @ecs_client, @config
        task.register(task_definition_name)

        return task_definition_name

      end

      def create_service(service_name, task_definition_name, instance_count)
        resp = @ecs_client.create_service({
          cluster: @config.ecs.cluster_name,
          desired_count: @config.ecs.desired_count,
          service_name: @config.ecs.service_name,
          task_definition: task_definition_name,
        })
      end

      def update_service(service_name, task_definition_name, instance_count)
        @ecs_client.update_service({
            cluster: @config.ecs.cluster_name,
            desired_count: instance_count,
            service: service_name,
            task_definition: task_definition_name
        })

        puts "Updated Service #{service_name} on ECS"
      end

      def service_exists? service_name
        resp = @ecs_client.describe_services(
          cluster: @config.ecs.cluster_name,
          services: [service_name]
        )

        return true unless resp.failures[0]
      end

      def task_exists?(task_definition)
        task = Deploy::AWS::ECSTask.new @ecs_client, @config
        return task.exists?(task_definition)
      end

      def run_task

      end

    end
  end
end
