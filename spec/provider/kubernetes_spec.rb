require 'spec_helper'
require 'provider/kubernetes'

RSpec.describe Provider::Kubernetes do
  it "can create a new object" do
    pk = Provider::Kubernetes.new

    expect(pk).to be_an_instance_of(Provider::Kubernetes)
  end
end
