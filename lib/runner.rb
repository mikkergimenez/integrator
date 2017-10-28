class Runner
  def initialize checkout_dir
    @checkout_dir = checkout_dir
  end

  def repo_command command_string
    puts "Running #{command_string} in #{@checkout_dir}"
    Dir.chdir(@checkout_dir) do
      IO.popen('ls -la') { |io| io.read }
      system command_string
    end
  end
end
