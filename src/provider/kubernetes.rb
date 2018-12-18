require 'kubeclient'

module Provider
  class Kubernetes

    def kube_config
      return ENV['KUBECONFIG'] || File.expand_path('~/.kube/config')
    end

    def client
      config = Kubeclient::Config.read(self.kube_config)
      context = config.context
      # or to use a specific context, by name:

      Kubeclient::Client.new(
        context.api_endpoint,
        context.api_version,
        ssl_options: context.ssl_options,
        auth_options: context.auth_options
      )
    end

    def test
      k = self.client

      if k.discover
        return "Connected to Kubernetes Server at #{k.api_endpoint.to_s}"
      else
        return "Couldn't Connect to Kubernetes Instance"
      end
    end
  end
end
