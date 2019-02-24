require 'spec_helper'
require 'job'
require 'source_control/repo'

RSpec.describe Job do
  it "sums the prices of its line items" do
    repo_obj = {
      name: 'repo'
    }
    local_repo = Repo.new(repo_obj, "bitbucket")
    config = Config.extract_config(local_repo, child="")
    job = Job.new(config: config, local_repo: local_repo, updated: Time.now)

    expect(job).to be_an_instance_of(Job)
  end
end
