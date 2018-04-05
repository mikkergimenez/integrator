require 'spec_helper'
require 'config'
require 'repo'

RSpec.describe Dependencies do
  it "creates new object" do
    checkout_dir = "/tmp"
    config = Config.new checkout_dir
    runner = ShellRunner.new checkout_dir
    dependencies = Dependencies.new(config, runner)

    expect(dependencies).to be_an_instance_of(Dependencies)
  end
end
