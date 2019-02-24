#
# Config for Environment Variables
#
class ConfigS3
  def initialize environment, full_config
    @s3_config   = full_config['s3']
    @environment = environment
    @logger      = Logger.new(STDERR)
  end

  def endpoint
    return @s3_config["endpoint"] || @logger.error("S3 Config requires an endpoint")
  end

  def files
    return @s3_config["files"] || @logger.error("S3 Config requires files to upload")
  end
end
