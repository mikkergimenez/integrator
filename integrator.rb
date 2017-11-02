#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.expand_path("#{File.dirname(__FILE__)}/lib")) unless $LOAD_PATH.include?(File.expand_path("#{File.dirname(__FILE__)}/lib"))

require 'colorize'
require 'json'
require 'net/http'
require 'optparse'
require 'repos'
require 'resolv-replace'
require 'slack-notifier'

def connect_to_source_control
  user          = ENV["BITBUCKET_USERNAME"]
  pass          = ENV["BITBUCKET_PASSWORD"]

  uri           = URI('https://api.bitbucket.org/1.0/user/repositories')

  puts "Polling Bitbucket, because BITBUCKET_USERNAME and BITBUCKET_PASSWORD are set."

  req           = Net::HTTP::Get.new(uri)
  req.basic_auth user, pass

  http          = Net::HTTP.new(uri.hostname, uri.port)
  http.use_ssl  = true
  [req, http]
end

def get_options
  options = {}
  options[:force_build] = false
  options[:forced_build_name] = ''

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: example.rb [options]"

    # Optional argument; multi-line description.

    opts.on("-f", "--force [BUILD_NAME]", "Forces a build on repo with name BUILD_NAME") do |build|
      options[:force_build] = true
      options[:forced_build_name] = build
    end
  end.parse!

  options
end

def trigger_build repo, last_updated
  puts "#{repo.name} last Updated: #{repo.last_updated}"
  puts "Triggering build for repo: #{repo.name}"
  notifier = Slack::Notifier.new ENV["SLACK_HOOK_URL"]
  notifier.ping  "#{repo.name} last Updated: #{repo.last_updated}\nTriggering build for repo: #{repo.name}"
  begin
    repo.build last_updated
  rescue Exception => e
    puts "\n"
    puts "Build Failed: ".red
    puts e
    puts e.backtrace
    puts "\n\n\n"
  end
  puts "Done Building, going back to cycle"
end

req, http = connect_to_source_control
options   = get_options

while true
  build_triggered = false

  resp = http.request(req)

  repos = JSON.parse(resp.body)
  repos.each do |repo|
    local_repo = Repos.get(repo)

    if options[:force_build]
      if local_repo.name == options[:forced_build_name]
        trigger_build(local_repo, repo["last_updated"])
        build_triggered = true
        options[:force_build] = false
      end
    end

    if local_repo.been_updated? repo["last_updated"]
      trigger_build(local_repo, repo["last_updated"])
      build_triggered = true
    end
  end

  puts "Checked #{repos.length} and no build triggered" unless build_triggered
  sleep 10

end
