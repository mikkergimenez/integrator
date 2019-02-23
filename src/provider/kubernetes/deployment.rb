module Provider
  class Kubernetes
    class Deployment
      @@apiVersion = "apps/v1beta1"

      def initialize config
        @config = config
      end

      def generate_yaml
        obj = Hash.new


        obj["apiVersion"] = @@apiVersion
        obj["kind"] = "Deployment"
        obj["metadata"] = {
          "name" => "#{@config.app_name}-deployment",
          "namespace" => "default",
        }
        obj["spec"] = {
          "selector" => {
            "matchLabels" => {
              "app" => @config.app_name
            }
          },
          "replicas" => @config.kubernetes.replicas,
          "template" => {
            "metadata" => {
              "labels" => {
                "app" => @config.app_name
              }
            },
            "spec" => {
              "imagePullSecrets" => [
                  {
                    "name" => "regcred"
                  }
              ],
              "containers" => [
                {
                  "name" => @config.app_name,
                  "image" => @config.docker.full_image,
                  "ports" => [
                    {
                      "containerPort" => @config.docker.container_port
                    }
                  ]
                }
              ]
            }
          }
        }

        return obj
      end
    end
  end
end
