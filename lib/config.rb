require 'yaml'
require 'config/docker'

#
# This class loads the YAML config
#
class Config
  attr_reader :full_config, :language, :deploy

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
    @full_config["pre_build"]["comand"]
  end

  def test_command
    @full_config["test"]["command"]
  end

  def language
    @full_config["language"]
  end

  def test
    @full_config["test"]
  end

  def ecs
    @ecs ||= Config::ECS.new @full_config
  end

  def docker
    @docker ||= Docker.new @full_config
  end
end
