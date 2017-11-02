class Runner
  def initialize checkout_dir
    @checkout_dir = checkout_dir
  end

  def repo_command command_string
    puts "\nRunning #{command_string} in #{@checkout_dir}"
    Dir.chdir(@checkout_dir) do
      IO.popen('ls -la') { |io| io.read }
      if command_string.include?(".sh")
        system "./#{command_string}"
      else
        system command_string
      end
    end
  end
end
