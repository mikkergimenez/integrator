#    {"scm"=>"git", "has_wiki"=>false, "last_updated"=>"2015-12-09T15:34:43.949", "no_forks"=>false, "created_on"=>"2015-11-01T00:08:06.784", "owner"=>"mikkergp", "logo"=>"https://bitbucket.org/mikkergp/writebetter/avatar/32/?ts=1449671683", "email_mailinglist"=>"", "is_mq"=>false, "size"=>1340218, "read_only"=>false, "fork_of"=>nil, "mq_of"=>nil, "state"=>"available", "utc_created_on"=>"2015-10-31 23:08:06+00:00", "website"=>"", "description"=>"", "has_issues"=>false, "is_fork"=>false, "slug"=>"writebetter", "is_private"=>true, "name"=>"writebetter", "language"=>"javascript", "utc_last_updated"=>"2015-12-09 14:34:43+00:00", "no_public_forks"=>true, "creator"=>nil, "resource_uri"=>"/1.0/repositories/mikkergp/writebetter"}
require 'builder'
require 'fileutils'

require 'git'
require 'rake'

class Repo
  attr_accessor :name, :last_updated, :created_on, :logo, :slug

  @trigger_build = false

  def initialize(repo_obj)
    @repo_obj = repo_obj
    @created_on = repo_obj['created_on']
    @name = repo_obj['name']
    @owner = repo_obj['owner']
    @logo = repo_obj['logo']
    @last_updated = repo_obj['last_updated']
    @slug = repo_obj['slug']
  end

  def build current_last_updated
    uri = "#{@owner}@bitbucket.org:#{@owner}/#{@name}.git"

    builder = Builder.new uri, @name
    builder.build

    @last_updated = current_last_updated

  end

  def trigger_build?
    @trigger_build
  end

  def done_building
    @trigger_build = false
  end

  def trigger_build
    @trigger_build = true
  end

  def been_updated? current_last_updated
    @last
    return last_updated != current_last_updated
  end

end
