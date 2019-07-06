class SourceControl
  @user = nil
  @pass = nil
  @uri = nil
  @org
  def connect_to_bitbucket auto=false
    @user          = ENV["BITBUCKET_USERNAME"]
    @pass          = ENV["BITBUCKET_PASSWORD"]

    @uri           = URI("https://api.bitbucket.org/2.0/repositories/#{@user}?pagelen=100")

    @authentication = "basic_auth"

    puts "Polling Bitbucket, because BITBUCKET_USERNAME and BITBUCKET_PASSWORD environment variables are set." if auto

  end

  def connect_to_gitlab auto=false
    @token          = ENV["GITLAB_PA_TOKEN"]
    @user           = ENV["GITLAB_USERNAME"]
    @authentication = "Private-Token"

    @uri  = URI("https://gitlab.com/api/v4/users/#{@username}/projects?private_token=#{@token}") # Fix
  end

  def connect_to_github auto=false
    # Placeholder to connect to github.
    @user = ENV["GITHUB_USERNAME"]
    @pass = ENV["GITHUB_PASSWORD"]

    @authentication = "basic_auth"

    @uri  = URI('https://api.github.com/user/repos')

    if ((@user.nil? or @pass.nil?) and @token.nil?) or @uri.nil?
      abort("Can't Connect to Github.  Please set GITHUB_USERNAME & GITHUB_PASSWORD.")
    end

    puts "Polling Github, because GITHUB_USERNAME and GITHUB_PASSWORD environment variables are set." if auto

  end

  def request http, req
    return http.request(req)
  end

  def parse provider, resp
    body = JSON.parse(resp.body)

    if provider == "bitbucket"
      return body["values"]
    end
    return body
  end

  def connect provider
    if provider

      connect_to_gitlab if provider == "gitlab"
      connect_to_github if provider == "github"
      connect_to_bitbucket if provider == "bitbucket"
    else
      if ENV["GITLAB_PA_TOKEN"] && ENV["GITLAB_USERNAME"]
        puts "Connecting to Gitlab"
        connect_to_gitlab(true)
        provider = "gitlab"
      elsif ENV["GITHUB_USERNAME"] && ENV["GITHUB_PASSWORD"]
        puts "Connecting to Github"
        connect_to_github(true)
        provider = "github"
      elsif ENV["BITBUCKET_USERNAME"] && ENV["BITBUCKET_PASSWORD"]
        puts "Connecting to Bitbucket"
        connect_to_bitbucket(true)
        provider = "bitbucket"
      end
    end

    if ((@user.nil? or @pass.nil?) and @token.nil?) or @uri.nil?
      raise Exception.new("Can't Connect to Source Control.  Please set the relevant environment variables.")
    end

    req           = Net::HTTP::Get.new(@uri)

    req[@authentication] = @token if @authentication != "Private-Token"
    req.basic_auth @user, @pass   if @authentication == "basic_auth"

    http          = Net::HTTP.new(@uri.hostname, @uri.port)
    http.use_ssl  = true
    [req, http, provider]
  end

end
