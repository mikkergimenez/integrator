require 'yaml'

require 'config/dns'
require 'config/docker'
require 'config/ecs'
require 'config/environment'
require 'config/load_balancing'

#
# This class loads the YAML config
#
class Config
  attr_reader :full_config, :deploy

  class DeployConfig
    def initialize full_config
      @full_config = full_config
    end

    def method
      @full_config["deploy"]["method"]
    end

    def job_file
      @full_config["deploy"]["job_file"]
    end
  end


  def initialize(repo_dir)
    if File.exist? "#{repo_dir}/integrator.yml"
      @full_config = YAML.load_file("#{repo_dir}/integrator.yml")
    elsif File.exist? "#{repo_dir}/integrator.yaml"
      @full_config = YAML.load_file("#{repo_dir}/integrator.yaml")
    elsif File.exist? "#{repo_dir}/Gemfile"
      @language = 'ruby'
    elsif File.exist? "#{repo_dir}/requirements.txt"
      @language = 'python'
    end
    @deploy = DeployConfig.new @full_config

    puts "No integrator.yml found" if @full_config.nil?

  end

  def pre_build
    @full_config["pre_build"]["command"]
  end

  def test_command
    return @full_config["test"]["command"] if @full_config["test"]["command"]
    return 'rake test'      if language == 'ruby'
    return 'go test ./...'  if language == 'go'
  end

  def language
    @full_config["language"]
  end

  def test
    @full_config["test"]
  end

  def dns
    @dns      ||= ConfigDNS.new 'production', @full_config
  end

  def load_balancing
    @lbc      ||= ConfigLoadBalancing.new @full_config
  end

  def ecs
    @ecs      ||= ConfigECS.new @full_config
  end

  def env_vars
    @env_vars ||= ConfigEnvironment.new 'production', @full_config
  end

  def docker
    @docker   ||= ConfigDocker.new @full_config
  end
end
