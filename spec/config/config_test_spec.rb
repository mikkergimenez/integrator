require 'config'
require_relative '../mocks/repo_obj'

RSpec.describe Config do
  it "tests that the test section works" do
    working_stub = YAML.load_file("spec/mocks/working_stub.yaml") if File.exist? "spec/mocks/working_stub.yaml"

    repo = Repo.new REPO_OBJ, "gitlab"

    config = Config.new(repo)

    config.overwrite_config(working_stub)

    expect(config.test.script).to eq("working_stub_script.sh")
  end
end
