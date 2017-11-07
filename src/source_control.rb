class SourceControl
  @user = nil
  @pass = nil
  @uri = nil
  @org
  def connect_to_bitbucket
    @user          = ENV["BITBUCKET_USERNAME"]
    @pass          = ENV["BITBUCKET_PASSWORD"]

    @uri           = URI('https://api.bitbucket.org/1.0/user/repositories')

    puts "Polling Bitbucket, because BITBUCKET_USERNAME and BITBUCKET_PASSWORD environment variables are set."

  end

  def connect_to_github
    # Placeholder to connect to github.
    @user = ENV["GITHUB_USERNAME"]
    @pass = ENV["GITHUB_PASSWORD"]


    @uri = URI('https://api.github.com/user/repos')

    puts "Polling Github, because GITHUB_USERNAME and GITHUB_PASSWORD environment variables are set."

  end

  def connect
    connect_to_bitbucket  unless ENV["BITBUCKET_USERNAME"].nil? || ENV["BITBUCKET_PASSWORD"].nil?
    connect_to_github     unless ENV["GITHUB_USERNAME"].nil?    || ENV["GITHUB_PASSWORD"].nil?

    if @user.nil? or @pass.nil? or @uri.nil?
      raise Exception.new("Can't Connect to Source Control.  Please set the relevant environment variables.")
    end

    req           = Net::HTTP::Get.new(@uri)
    req.basic_auth @user, @pass

    http          = Net::HTTP.new(@uri.hostname, @uri.port)
    http.use_ssl  = true
    [req, http]
  end

end
