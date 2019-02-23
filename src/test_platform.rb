require 'provider/kubernetes'

class TestPlatform

  def initialize platform
    @platform = platform
  end

  def run
    puts "Testing platform #{@platform}"
    if @platform == "kubernetes"
      prov = Provider::Kubernetes.new
    end

    # if @platform == "ecs"
    #   prov = Provider::AWS::ECS.new
    # end
    #
    puts prov.test
  end

end
