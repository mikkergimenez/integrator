require 'yaml'

require 'config/dns'
require 'config/docker'
require 'config/ecs'
require 'config/environment'
require 'config/kubernetes'
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

    def provider
      @full_config["deploy"]["provider"]
    end

    def job_file
      @full_config["deploy"]["job_file"]
    end
  end

  def app_name
    return full_config[:app_name] if full_config[:app_name]
    return @repo.name
  end

  def full_config
    return @overwritten_config if @overwritten_config
    return YAML.load_file("#{@repo_dir}/integrator.yml") if File.exist? "#{@repo_dir}/integrator.yml"
    return YAML.load_file("#{@repo_dir}/integrator.yaml") if File.exist? "#{@repo_dir}/integrator.yaml"
  end

  def overwrite_config config
    @overwritten_config = config
  end

  def initialize(repo)
    @repo_dir           = repo.checkout_dir
    @repo               = repo

    @overwritten_config = nil

    @deploy             = DeployConfig.new full_config

    puts "No integrator.yml found" if full_config.nil?

  end

  def pre_build
    begin
      return full_config["pre_build"]["command"]
    rescue
      puts "No Pre-Build Step"
      return nil
    end
  end

  def install_command
    begin
      return full_config["install"]["command"] if full_config["install"] && full_config["install"]["command"]
    rescue
      abort("install.command not set, dumping full_config: " + full_config.to_json())
    end
    return "go get"         if language == "go"
    return "bundle package" if language == "ruby"
    return "npm install"    if language == "node"
  end

  def test_command
    return full_config["test"]["command"] if full_config["test"] && full_config["test"]["command"]
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
    puts @repo
    require 'pry'
    binding.pry
  end

  def test
    full_config["test"]
  end

  def pre_test
    full_config["pre_test"]
  end

  def script; @script end

  def helm_charts
    return full_config[:helm_charts]
  end

  def helm
    @helm       ||= ConfigHelm.new 'production'
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

  def env_vars
    @env_vars   ||= ConfigEnvironment.new 'production', full_config
  end

  def docker
    @docker     ||= ConfigDocker.new full_config, app_name
  end
end
