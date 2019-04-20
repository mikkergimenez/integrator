#    {"scm"=>"git", "has_wiki"=>false, "last_updated"=>"2015-12-09T15:34:43.949", "no_forks"=>false, "created_on"=>"2015-11-01T00:08:06.784", "owner"=>"mikkergp", "logo"=>"https://bitbucket.org/mikkergp/writebetter/avatar/32/?ts=1449671683", "email_mailinglist"=>"", "is_mq"=>false, "size"=>1340218, "read_only"=>false, "fork_of"=>nil, "mq_of"=>nil, "state"=>"available", "utc_created_on"=>"2015-10-31 23:08:06+00:00", "website"=>"", "description"=>"", "has_issues"=>false, "is_fork"=>false, "slug"=>"writebetter", "is_private"=>true, "name"=>"writebetter", "language"=>"javascript", "utc_last_updated"=>"2015-12-09 14:34:43+00:00", "no_public_forks"=>true, "creator"=>nil, "resource_uri"=>"/1.0/repositories/mikkergp/writebetter"}
require 'fileutils'

require 'git'
require 'job'
require 'rake'

class Repo
  attr_accessor :name, :created_on, :logo, :slug, :ran_forced, :g

  # @trigger_build = false
  def initialize(repo_obj, provider)
    @g               = nil
    @ran_forced      = false
    @provider        = provider
    @repo_obj        = repo_obj
    puts repo_obj.to_json
    @created_on      = repo_obj['created_on']
    @name            = repo_obj['name'] || repo_obj[:name]
    @owner           = repo_obj['owner'] || repo_obj[:owner]
    @logo            = repo_obj['logo'] || repo_obj[:logo]
    @slug            = repo_obj['slug'] || repo_obj[:slug]
    @last_updated_at = repo_obj["last_updated"] || repo_obj[:last_updated]
  end

  def checkout
    if @g
      puts 'Pulling latest '
      @g.pull # I don't think this pull is working
    else
      begin
        if File.exist?(checkout_dir)

          @g = Git.open(checkout_dir, :log => Logger.new("/tmp/integrator_log"))
          @g.reset_hard("HEAD")
          @g.pull
        else
          @g = Git.clone(uri, @name, :path => checkout_path)
          puts "Checked out #{uri}"
        end
        puts @g
      rescue Git::GitExecuteError => e
        puts e
      end
    end

    "/tmp/checkout/#{@name}"
  end

  def set_last_updated last_updated_at
    @last_updated_at = last_updated_at
  end

  def last_updated
    return @repo_obj["last_activity_at"] if @provider == "gitlab"
    @last_updated_at
  end

  def latest_sha
    return @g.branches["master"].gcommit.sha
  end

  def checkout_dir
    "/tmp/checkout/#{@name}"
  end

  def uri
    @name.chomp("/") if @name.end_with?("/")
    return @repo_obj["ssh_url_to_repo"] if @provider == "gitlab"
    return "git@github.com:#{@owner}/#{@name}.git" if @provider == "github"
    return "https://#{@owner}:#{ENV["BITBUCKET_PASSWORD"]}@bitbucket.org/#{@owner}/#{@name}.git" if @provider == "bitbucket"
  end

  def ready? force_build: false, forced_build_name: nil
    if force_build && @name == forced_build_name
      puts "Build found, building #{forced_build_name}"
      return true
    end

    return true if been_updated? last_updated
    return false
  end

  def been_updated? current_last_updated
    return false unless current_last_updated
    return last_updated != current_last_updated
  end

  private
  def checkout_path
    '/tmp/checkout'
  end
end
