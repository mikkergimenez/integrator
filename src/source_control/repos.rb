# Repos manages a list of repos in memory for the app to check against
# Runs buils when an app has been updated

require 'source_control/repo'

class Repos
  @repos = []

  def self.get(repo_obj, provider)
    list.each do |item|
      next if item.slug != repo_obj["slug"]
      return item
    end
    repo = Repo.new repo_obj, provider
    @repos.push(repo)
    repo
  end

  private

  def self.list
    @repos
  end

end
