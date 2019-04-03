require 'bundler'

class ShellRunner
  def initialize checkout_dir
    @checkout_dir = checkout_dir
  end

  def run_repo_command command_string
    Bundler.with_clean_env do
      IO.popen('ls -la') { |io| io.read }
      result = system "#{command_string}"
      exit unless result
    end
  end

  def repo_command command_string
    puts "\nRunning #{command_string} in #{@checkout_dir}"
    Dir.chdir(@checkout_dir) do
      if command_string.kind_of?(String)
        run_repo_command command_string
      else
        command_string.each do |cmd|
          run_repo_command cmd
        end
      end
    end
  end
end
