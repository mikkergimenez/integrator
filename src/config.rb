require 'yaml'

require 'config/dns'
require 'config/docker'
require 'config/ecs'
require 'config/environment'
require 'config/helm'
require 'config/kubernetes'
require 'config/load_balancing'
require 'config/s3'
require 'tools/logger'
#
# This class loads the YAML config
#
class Config
  attr_reader :full_config

  def self.extract_config(local_repo, child="")
    self.new local_repo, child
  end

  module Scriptable
    def script
      return @full_config[@key]["script"] if @full_config[@key]
      false
    end

    def env
      return @full_config[@key]["env"] if @full_config[@key]
      false
    end
  end

  class DeployConfig
    def initialize full_config
      @full_config = full_config
    end

    def provider
      @full_config["deploy"]["provider"]
    end

    def job_file
      @full_config["deploy"]["job_file"]
    end
  end


  class BuildConfig
    include Config::Scriptable
    attr_reader :full_config, :key

    def initialize full_config
      @full_config = full_config
      @key = "build"
    end

    def method
      puts @full_config
      @full_config["build"]["method"]
    end
  end

  class TestConfig
    include Config::Scriptable
    attr_reader :full_config, :key

    def initialize full_config
      @full_config = full_config
      @key = "test"
    end

    def dependencies
      if @full_config["test"]["deps"] and @full_config["test"]["dependencies"]
        Logger.warning("test.deps in yaml file will override test.dependencies")
      end
      return @full_config["test"]["deps"] || @full_config["test"]["dependencies"] || Array.new
    end

  end

  class PreTestConfig
    attr_reader :full_config, :key

    include Config::Scriptable
    def initialize full_config
      @full_config = full_config
      @key = "pre_test"
    end
  end

  def app_name
    return full_config[:app_name] if full_config[:app_name]
    return @repo.name
  end

  def full_config
    return @overwritten_config if @overwritten_config
    return YAML.load_file("#{@repo_dir}/#{@child_dir}integrator.yml") if File.exist? "#{@repo_dir}/#{@child_dir}integrator.yml"
    return YAML.load_file("#{@repo_dir}/integrator.yaml") if File.exist? "#{@repo_dir}/integrator.yaml"
  end

  def overwrite_config config
    @overwritten_config = config
  end

  def initialize(repo, child_dir="")
    @repo_dir           = repo.checkout_dir
    @repo               = repo
    @child_dir          = child_dir
    @overwritten_config = nil

    @logger             = Logger.new(STDERR)

    @logger.warn "No integrator.yml found" if full_config.nil?
  end

  def children
    return full_config["children"] if full_config["children"]
    return []
  end

  def working_directory
    return @repo.checkout_dir + "/" + @child_dir
  end

  def pre_build
    begin
      return full_config["pre_build"]["script"]
    rescue
      puts "No Pre-Build Step"
      return nil
    end
  end

  def install_command
    begin
      return full_config["install"]["script"] if full_config["install"] && full_config["install"]["script"]
    rescue
      abort("install.command not set, dumping full_config: " + full_config.to_json())
    end
    return "go get"         if language == "go"
    return "bundle package" if language == "ruby"
    return "npm install"    if language == "node"
  end

  def test_command
    return full_config["test"]["script"] if full_config["test"] && full_config["test"]["script"]
    return 'rake test'      if language == 'ruby'
    return 'go test ./...'  if language == 'go'
    return 'npm test'       if language == 'node'
    return nil              if language == "docker"
  end

  def language
    begin
      full_config["language"] if full_config["language"]
    rescue
      abort("full_config.languge, dumping full_config: " + full_config.to_json())
    end
    'ruby'    if File.exist? "#{@repo_dir}/Gemfile"
    'python'  if File.exist? "#{@repo_dir}/requirements.txt"
    'python'  if File.exist? "#{@repo_dir}/setup.py"
    'go'      if File.exist? "#{@repo_dir}/main.go"
    'node'    if File.exist? "#{@repo_dir}/package.json"
  end

  def git_sha
    if @repo.g
      return @repo.g.object('HEAD').sha[0..7]
    else
      return 'latest'
    end
  end

  def script; @script end

  def helm_charts
    return full_config[:helm_charts]
  end

  def build
    @build    ||= BuildConfig.new   full_config
  end

  def deploy
    @deploy   ||= DeployConfig.new  full_config
  end
  def test
    @test     ||= TestConfig.new    full_config
  end

  def pre_test
    @pre_test ||= PreTestConfig.new full_config
  end

  def helm
    @helm       ||= ConfigHelm.new 'production', full_config
  end

  def dns
    @dns        ||= ConfigDNS.new 'production', full_config
  end

  def load_balancing
    @lbc        ||= ConfigLoadBalancing.new full_config
  end

  def kubernetes
    @kubernetes ||= Config::Kubernetes.new full_config, app_name
  end

  def ecs
    @ecs        ||= ConfigECS.new full_config
  end

  def s3
    @s3         ||= ConfigS3.new 'production', full_config
  end

  def env_vars
    @env_vars   ||= ConfigEnvironment.new 'production', full_config
  end

  def docker
    @docker     ||= ConfigDocker.new full_config, app_name, git_sha
  end
end
