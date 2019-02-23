class Tester

  def initialize shell_runner
    @shell_runner = shell_runner
  end

  def run config, checkout_dir
    puts "Running tests against #{@name}"
    $LOAD_PATH.unshift(File.expand_path(checkout_dir)) unless $LOAD_PATH.include?(File.expand_path(checkout_dir))

    if config.pre_test
      @shell_runner.repo_command(config.pre_test)
    end

    unless config.script
      puts "No tests to run"
      return true
    end
    test_outcome = @shell_runner.repo_command(config.script)

    puts "Test Outcome #{test_outcome}"
    test_outcome
  end
end
