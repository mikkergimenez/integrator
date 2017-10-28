require 'aws-sdk'
require 'aws/ecs/task'

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
        @ecs = Aws::ECS::Client.new(region: 'us-east-1')
        @config = config
      end

      def deploy cluster_name, service_name, task_definition
        instance_count = 2

        tdn = register_task_definition(task_definition) unless task_exists?(task_definition)

        return create_service(service_name, tdn, instance_count) unless service_exists?(service_name)
        update_service(service_name, tdn, instance_count)
      end

      def register_task_definition
        task = Deploy::AWS::ECSTask.new @client, @config
        task.register(@config.ecs.name)

        return task_definition_name

      end

      def create_service(service_name, task_definition_name, instance_count)
        resp = @ecs.create_service({
          cluster: @config.ecs.cluster,
          desired_count: @config.ecs.desired_count,
          service_name: @config.ecs.service_name,
          task_definition: @config.ecs.task_definition_name,
        })
      end

      def update_service()
        @ecs.update_service({
            desired_count: @config.ecs.desired_count,
            service_name: @config.ecs.service_name,
            task_definition_name: @config.ecs.task_definition_name
        })
      end

      def service_exists?

      end

      def run_task

      end

    end
  end
end
