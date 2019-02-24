
def get_options
  retval = {}
  retval[:force_build] = false
  retval[:forced_build_name] = ''
  retval[:provider] = nil

  retval[:verbose] = false

  retval[:run_test_platform] = false
  retval[:test_platform] = ''

  opt_parser = OptionParser.new do |opts|
    opts.banner = "Usage: integrator.rb [options]"

    # Optional argument; multi-line description.

    opts.on("-t", "--test [PLATFORM]", "One of '[e]cs', '[k]ubernetes', or '[n]omad'.") do |platform|
      retval[:run_test_platform] = true
      retval[:test_platform] = platform
      unless ["ecs", "kubernetes", "nomad", "e", "k", "n"].include? platform
        abort("Platform(-t) must be one of '[e]cs', '[k]ubernetes', or '[n]omad'")
      end
    end

    opts.on("-o", "--children-only", "Only run child jobs") do |children_only|
      retval[:children_only] = true
    end

    opts.on("-v", "--verbose", "Verbose logging options") do |verbose|
      retval[:verbose] = true
    end

    opts.on("-b", "--build [BUILD_NAME_FILTER]", "Only runs command against a certain repo") do |build|
      retval[:build_name_filter] = build
    end

    opts.on("-c", "--cleanup_dir", "Clean up build directory after run.  Preserve Disk Space, but slow down successive builds because the repo is not cached.") do |verbose|
      retval[:flag_cleanup_dir] = true
    end

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
