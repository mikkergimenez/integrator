class Dependencies
  def initialize config, runner
    @config = config
    @runner = runner
  end

  def install
    # Make sure that `gem install nio4r -v '2.1.0'` succeeds before bundling.
    @runner.repo_command @config.install_command
  end
end
