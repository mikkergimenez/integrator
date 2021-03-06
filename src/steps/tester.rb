require 'steps/dependencies/mongodb'
require 'steps/dependencies/s3cmd'
require 'steps/supporting_services/helm_chart'

DEPENDENCIES = {
  'mongodb' => TestDependencies::MongoDB,
  'helm' => TestDependencies::HelmChart,
  's3cmd' => TestDependencies::S3CMD
}

class Tester
  def initialize config, shell_runner
    @shell_runner = shell_runner
    @config = config
  end

  def run_pre_checks
    retval = true

    @config.test.dependencies.each do |dependency|
      ok, message = DEPENDENCIES[dependency].check @shell_runner
      Logger.check(ok, message)
      retval = false if ok == false
    end

    return retval
  end

  def run config, checkout_dir
    Logger.section "Running tests against directory #{checkout_dir}"
    $LOAD_PATH.unshift(File.expand_path(checkout_dir)) unless $LOAD_PATH.include?(File.expand_path(checkout_dir))

    if config.pre_test.command
      @shell_runner.repo_command(config.pre_test.command)
    end

    unless config.test.command
      puts "No tests to run".red
      return true
    end

    test_outcome = @shell_runner.repo_command(config.test.command)

    puts "Test Outcome #{test_outcome}"
    test_outcome
  end
end
