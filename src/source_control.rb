class SourceControl
  @user = nil
  @pass = nil
  @uri = nil
  @org
  def connect_to_bitbucket
    @user          = ENV["BITBUCKET_USERNAME"]
    @pass          = ENV["BITBUCKET_PASSWORD"]

    @uri           = URI('https://api.bitbucket.org/1.0/user/repositories')

    @authentication = "basic_auth"

    puts "Polling Bitbucket, because BITBUCKET_USERNAME and BITBUCKET_PASSWORD environment variables are set."

  end

  def connect_to_gitlab
    @token          = ENV["GITLAB_PA_TOKEN"]
    @authentication = "Private-Token"

    @uri  = URI('https://gitlab.com/api/v4/users/mikkergp/projects') # Fix
    puts "Polling Gitlab, because GITLAB_PA_TOKEN environment variables is set."

  end

  def connect_to_github
    # Placeholder to connect to github.
    @user = ENV["GITHUB_USERNAME"]
    @pass = ENV["GITHUB_PASSWORD"]

    @authentication = "basic_auth"

    @uri  = URI('https://api.github.com/user/repos')

    puts "Polling Github, because GITHUB_USERNAME and GITHUB_PASSWORD environment variables are set."

  end

  def connect
    if ENV["GITLAB_PA_TOKEN"]
      connect_to_gitlab
    elsif ENV["GITHUB_USERNAME"] && ENV["GITHUB_PASSWORD"]
      connect_to_github
    elsif ENV["BITBUCKET_USERNAME"] && ENV["BITBUCKET_PASSWORD"]
      connect_to_bitbucket
    end

    if ((@user.nil? or @pass.nil?) and @token.nil?) or @uri.nil?
      raise Exception.new("Can't Connect to Source Control.  Please set the relevant environment variables.")
    end

    req           = Net::HTTP::Get.new(@uri)

    req[@authentication] = @token if @authentication != "Private-Token"
    req.basic_auth @user, @pass   if @authentication == "basic_auth"

    http          = Net::HTTP.new(@uri.hostname, @uri.port)
    http.use_ssl  = true
    [req, http]
  end

end
