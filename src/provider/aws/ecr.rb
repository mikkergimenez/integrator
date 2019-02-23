require 'aws-sdk'

module Provider
  module AWS
    class ECR
      def initialize
        raise ECS_ENV_VARS_NOT_SET_EXCEPTION unless ENV["AWS_ACCESS_KEY_ID"].is_a?(String) && ENV["AWS_SECRET_ACCESS_KEY"].is_a?(String)
        @client = Aws::ECR::Client.new(region: 'us-east-1')
      end

      def check_for_or_create_repo image_name
        return create_repo(image_name) unless repo_exists?(image_name)
        puts "Found Repo #{image_name}"
      end

      private
      def create_repo image_name
        puts "Creating Repo #{image_name}"
        @client.create_repository({
          repository_name: image_name,
        })
      end

      def repo_exists? image_name
        begin
          repos = @client.describe_repositories(
            repository_names: [image_name]
          )
        rescue
          return false
        end
        return repos.repositories.length > 0
      end
    end
  end
end
