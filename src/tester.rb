module Tester
  def self.run config, checkout_dir
    puts "Running tests against #{@name}"
    $LOAD_PATH.unshift(File.expand_path(checkout_dir)) unless $LOAD_PATH.include?(File.expand_path(checkout_dir))
    unless config.test_command
      puts "No tests to run"
      return true
    end
    @runner.repo_command(config.test_command)
  end
end
