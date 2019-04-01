require 'config'

require 'source_control/repos'
require 'source_control/main'

class Integrator

  def initialize provider=nil, force_build=false, forced_build_name=nil, flag_cleanup_dir=false, children_only=nil
    @build_triggered    = false

    @children_only      = children_only

    @flag_cleanup_dir   = flag_cleanup_dir

    @force_build        = force_build
    @forced_build_name  = forced_build_name

    @provider           = provider
    @repos              = get_repos(provider)
  end

  #
  # Run starts a loop
  #
  def run
    while true
      run_loop()
    end
  end

  private
    #
    # run a build if it was forced.
    #
    def run_forced_build forced_build_name
      run_build
      @ran_forced = true
    end

    #
    # Start a build job.
    #
    def run_build local_repo
      config = Config.extract_config(local_repo)

      job = Job.new(
        config: config,
        local_repo: local_repo,
        updated: local_repo.last_updated,
        flag_cleanup_dir: @flag_cleanup_dir,
      )

      job.trigger() unless @children_only

      puts "Starting #{config.children.count} child builds"
      config.children.each do |child|
        child_config = Config.extract_config(local_repo, child)
        jobc = Job.new(
          config: child_config,
          local_repo: local_repo,
          updated: local_repo.last_updated,
          flag_cleanup_dir: @flag_cleanup_dir
        )
        jobc.trigger()
      end
      @build_triggered = true

      job.cleanup()
    end

    #
    # Check if a repo is ready, and if it is, run the build.
    #
    def process_repo repo
      local_repo = Repos.get(repo, @provider)
      if local_repo.ready?(force_build: @force_build, forced_build_name: @forced_build_name)
        run_build(local_repo)
        @force_build = false
      end
    end

    #
    # Get all of the repos from source control.
    #
    def get_repos provider
      sc = SourceControl.new
      req, http, provider = sc.connect(provider)
      resp = http.request(req)

      @provider = provider
      puts "Got Repos from #{@provider}"
      return JSON.parse(resp.body)
    end

    #
    # run_loop runs a loop looking at all the repos in your provider and
    # starting a build on any repos that have changed.
    #
    def run_loop
      repos = get_repos(@provider)
      repos.each do |repo|
        process_repo(repo)
      end

      puts "Checked #{repos.length} and no build triggered" unless @build_triggered
      sleep 10
    end
end
