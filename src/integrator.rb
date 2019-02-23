require 'source_control/repos'
require 'source_control/main'

class Integrator

  def initialize provider=nil, force_build=false, forced_build_name=nil, flag_cleanup_dir=false
    @build_triggered = false

    @flag_cleanup_dir  = flag_cleanup_dir

    @force_build       = force_build
    @forced_build_name = forced_build_name

    @provider = provider
    @repos = get_repos(provider)
  end

  def run_forced_build forced_build_name
    run_build
    @ran_forced = true
  end

  def run_build local_repo
    job = Job.new(local_repo: local_repo, updated: local_repo.last_updated, flag_cleanup_dir: @flag_cleanup_dir)

    job.trigger()
    @build_triggered = true

    job.cleanup()
  end


  def process_repo repo
    local_repo = Repos.get(repo, @provider)
    if local_repo.ready?(force_build: @force_build, forced_build_name: @forced_build_name)
      run_build(local_repo)
      @force_build = false
    end
  end

  def get_repos provider
    sc = SourceControl.new
    req, http, provider = sc.connect(provider)
    resp = http.request(req)

    @provider = provider
    return JSON.parse(resp.body)
  end

  def run_loop
    repos = get_repos(@provider)
    repos.each do |repo|
      process_repo(repo)
    end

    puts "Checked #{repos.length} and no build triggered" unless @build_triggered
    sleep 10
  end

  def run
    while true
      run_loop()
    end
  end
end
