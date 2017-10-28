module AWS
  class ECR
    def initialize
      raise ECS_ENV_VARS_NOT_SET_EXCEPTION unless ENV["AWS_ACCESS_KEY_ID"].is_a?(String) && ENV["AWS_SECRET_ACCESS_KEY"].is_a?(String)
      @client = Aws::ECR::Client.new(region: 'us-east-1')
    end

    def check_for_or_create_repo image_name
      @client.create_repository({
        repository_name: image_name,
      })
    end
  end
end
