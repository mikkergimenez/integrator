#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.expand_path("#{File.dirname(__FILE__)}/src")) unless $LOAD_PATH.include?(File.expand_path("#{File.dirname(__FILE__)}/src"))

require 'colorize'
require 'json'
require 'net/http'
require 'optparse'
require 'repos'
require 'resolv-replace'
require 'slack-notifier'
require 'source_control'
require 'job'

def get_options
  retval = {}
  retval[:force_build] = false
  retval[:forced_build_name] = ''
  retval[:provider] = ''

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: integrator.rb [options]"

    # Optional argument; multi-line description.

    opts.on("-p", "--provider [PROVIDER]", "One of 'gitlab', 'github', or 'bitbucket'.") do |provider|
      retval[:provider] = provider
      unless ["gitlab", "github", "bitbucket"].include? provider
        abort("Provider(-p) must be one of 'gitlab', 'github' or 'bitbucket'")
      end
    end

    opts.on("-f", "--force [BUILD_NAME]", "Forces a build on repo with name BUILD_NAME") do |build|
      retval[:force_build] = true
      retval[:forced_build_name] = build
    end
  end.parse!

  retval
end

options = get_options

sc = SourceControl.new
req, http, provider = sc.connect(options[:provider])


while true
  build_triggered = false

  resp = http.request(req)

  repos = JSON.parse(resp.body)

  repos.each do |repo|
    local_repo = Repos.get(repo, provider)

    if options[:force_build]
      if local_repo.name == options[:forced_build_name]
        puts "Build found, building #{options[:forced_build_name]}"
        job = Job.new(
          local_repo: local_repo,
          updated: repo["last_updated"]
        )

        job.trigger()
        build_triggered = true
        options[:force_build] = false

        job.cleanup()
      end
    end

    if local_repo.been_updated? local_repo.last_updated()
      job = Job.new(
        local_repo: local_repo,
        updated: repo["last_updated"]
      )
      job.trigger()
      build_triggered = true

      job.cleanup()
    end
  end

  puts "Checked #{repos.length} and no build triggered" unless build_triggered
  sleep 10

end
