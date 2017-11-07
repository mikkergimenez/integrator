class Job

  def initialize local_repo: nil, updated: nil
    @local_repo = local_repo
    @updated    = updated

  end

  def trigger
    puts "#{@local_repo.name} last Updated: #{@local_repo.last_updated}"
    puts "Triggering build for repo: #{@local_repo.name}"
    notifier = Slack::Notifier.new ENV["SLACK_HOOK_URL"]
    notifier.ping  "#{@local_repo.name} last Updated: #{@local_repo.last_updated}\nTriggering build for repo: #{@local_repo.name}"

    begin
      @local_repo.build @updated
    rescue StandardError => e
      puts "\n"
      puts "Build Failed: ".red
      puts e
      puts e.backtrace
      puts "\n\n\n"
    end

    puts "Job complete, going back to cycle"
  end

end
