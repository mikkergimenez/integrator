#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.expand_path("#{File.dirname(__FILE__)}/src")) unless $LOAD_PATH.include?(File.expand_path("#{File.dirname(__FILE__)}/src"))

require 'colorize'
require 'json'
require 'net/http'
require 'optparse'
require 'resolv-replace'
require 'slack-notifier'
require 'test_platform'
require 'integrator'
require 'options'

options = get_options

full_platform_names = {
  'k'          => 'kubernetes',
  'kubernetes' => 'kubernetes',
  'e'          => 'ecs',
  'ecs'        => 'ecs',
  'n'          => 'nomad',
  'nomad'      => 'nomad',
}

if options[:run_test_platform]
  TestPlatform.new(full_platform_names[options[:test_platform]]).run
  exit(0)
end

if options[:force_build]
  puts "Forcing deployment of application: #{options[:forced_build_name]}"
end

i = Integrator.new(
  provider=options[:provider],
  force_build=options[:force_build],
  forced_build_name=options[:forced_build_name],
  flag_cleanup_dir=options[:flag_cleanup_dir],
  children_only=options[:children_only],
  flag_skip_tests=options[:flag_skip_tests]
)

i.run()
