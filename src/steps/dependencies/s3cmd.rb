module TestDependencies
  class S3CMD
    def self.check runner
      result = runner.repo_command "aws sts get-caller-identity"
      puts result
      if result
        return true, "AWS authentication ready for s3cmd"
      else
        return false, "AWS authentication variables not set "
      end
    end
  end
end
