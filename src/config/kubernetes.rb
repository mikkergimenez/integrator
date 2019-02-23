class Config
  class Kubernetes
    def initialize(full_config, app_name)
      puts 'Getting Docker Config from: '
      p full_config
      @app_name = app_name
      @kubernetes_config = full_config['kubernetes']
      @full_config = full_config
    end

    def replicas
      begin
        @kubernetes_config['replicas']
      rescue
        puts "kubernetes.replicas must be set for a Kubernetes deploy"
      end
    end
  end
end
