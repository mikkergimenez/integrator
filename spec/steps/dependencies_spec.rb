require 'spec_helper'
require 'config'
require 'source_control/repo'

repo_obj = {"id"=>1111111, "description"=>"Gitlab App Description", "name"=>"gitlab_app", "name_with_namespace"=>"integrator / gitlab_app", "path"=>"gitlab_app", "path_with_namespace"=>"integrator/gitlab_app", "created_at"=>"2018-07-08T02:52:23.971Z", "default_branch"=>"master", "tag_list"=>[], "ssh_url_to_repo"=>"git@gitlab.com:integrator/gitlab_app.git", "http_url_to_repo"=>"https://gitlab.com/integrator/gitlab_app.git", "web_url"=>"https://gitlab.com/integrator/gitlab_app", "readme_url"=>"https://gitlab.com/integrator/gitlab_app/blob/master/README.md", "avatar_url"=>nil, "star_count"=>0, "forks_count"=>0, "last_activity_at"=>"2018-08-03T04:07:54.695Z", "namespace"=>{"id"=>3333333, "name"=>"integrator", "path"=>"integrator", "kind"=>"user", "full_path"=>"integrator", "parent_id"=>nil}, "_links"=>{"self"=>"https://gitlab.com/api/v4/projects/1111111", "issues"=>"https://gitlab.com/api/v4/projects/1111111/issues", "merge_requests"=>"https://gitlab.com/api/v4/projects/1111111/merge_requests", "repo_branches"=>"https://gitlab.com/api/v4/projects/1111111/repository/branches", "labels"=>"https://gitlab.com/api/v4/projects/1111111/labels", "events"=>"https://gitlab.com/api/v4/projects/1111111/events", "members"=>"https://gitlab.com/api/v4/projects/1111111/members"}, "archived"=>false, "visibility"=>"private", "owner"=>{"id"=>2222222, "name"=>"integrator", "username"=>"integrator", "state"=>"active", "avatar_url"=>"https://secure.gravatar.com/avatar/00000000000000000000000000000000?s=80&d=identicon", "web_url"=>"https://gitlab.com/integrator"}, "resolve_outdated_diff_discussions"=>false, "container_registry_enabled"=>true, "issues_enabled"=>true, "merge_requests_enabled"=>true, "wiki_enabled"=>true, "jobs_enabled"=>true, "snippets_enabled"=>true, "shared_runners_enabled"=>true, "lfs_enabled"=>true, "creator_id"=>2222222, "import_status"=>"none", "open_issues_count"=>0, "public_jobs"=>true, "ci_config_path"=>nil, "shared_with_groups"=>[], "only_allow_merge_if_pipeline_succeeds"=>false, "request_access_enabled"=>false, "only_allow_merge_if_all_discussions_are_resolved"=>false, "printing_merge_request_link_enabled"=>true, "merge_method"=>"merge", "permissions"=>{"project_access"=>{"access_level"=>40, "notification_level"=>3}, "group_access"=>nil}, "mirror"=>false}

RSpec.describe Dependencies do
  it "creates new object" do
    repo = Repo.new repo_obj, "gitlab"
    config = Config.new repo
    runner = ShellRunner.new repo.checkout_dir
    dependencies = Dependencies.new(config, runner)

    expect(dependencies).to be_an_instance_of(Dependencies)
  end
end
