require 'colorize'
require 'kubeclient'
require 'provider/kubernetes/deployment'

module Provider
  class Kubernetes
    def initialize config=nil
      @config = config
      @test_only = config==nil
    end

    def config
      Kubeclient::Config.read(self.kube_config)
    end

    def context
      config.context
    end

    def apps_endpoint
      # return [context.api_endpoint, 'api'].join('/')
      return [context.api_endpoint, 'apis/apps'].join('/')
    end

    def extensions_endpoint
      return [context.api_endpoint, 'apis/extensions'].join('/')
    end

    def kube_config
      return ENV['KUBECONFIG'] || File.expand_path('~/.kube/config')
    end

    def client
      if @test_only
        endpoint = context.api_endpoint
      else
        endpoint = apps_endpoint
      end

      Kubeclient::Client.new(
        endpoint,
        "v1", # context.api_version,
        ssl_options: context.ssl_options,
        auth_options: context.auth_options
      )
    end

    def default_client
      Kubeclient::Client.new(
        context.api_endpoint,
        "v1", # context.api_version,
        ssl_options: context.ssl_options,
        auth_options: context.auth_options
      )
    end

    def extensions_client
      Kubeclient::Client.new(
        extensions_endpoint,
        "v1beta1", # context.api_version,
        ssl_options: context.ssl_options,
        auth_options: context.auth_options
      )
    end

    def deploy
      puts "Should Connect to: https://c4e9810a-d0bf-4dfb-baa8-37b9d65fcfe5.k8s.ondigitalocean.com/apis/extensions/v1beta1/namespaces/default/deployments"
      puts self.extensions_client.get_deployments(namespace: "default")
      deployment = Provider::Kubernetes::Deployment.new @config
      deploy = Kubeclient::Resource.new(deployment.generate_yaml)
      puts JSON.pretty_generate(deploy)
      puts "Should POST to: https://c4e9810a-d0bf-4dfb-baa8-37b9d65fcfe5.k8s.ondigitalocean.com/apis/apps/v1/namespaces/default/deployments"
      begin
        self.client.create_deployment(deploy)
      rescue
        puts "Create Deployment Failed, do you have a namespace configured?"
      end

    end

    def print_deploy_info
      puts "Using Kubernetes Config: #{kube_config}"
      puts "Posting to Apps Endpoint: #{apps_endpoint}"
    end

    def test
      k = self.client
      ks = self.extensions_client
      begin
        if k.discover
          puts "Connected to Kubernetes Server at #{k.api_endpoint.to_s}".green
          if ks.discover
            return "Connected to Kubernetes Server at #{ks.api_endpoint.to_s}".green
          else
            return "Couldn't Connect to Kubernetes Instance".red
          end

        else
          return "Couldn't Connect to Kubernetes Instance".red
        end

      rescue Kubeclient::HttpError => e
        puts String(e).red
        puts "You might need to update your kube config."
      rescue e
        puts String(e).red
      end
    end
  end
end
