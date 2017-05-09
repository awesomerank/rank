defmodule Rank.GithubApi.Sandbox do
  require Logger

  @readme_prefix "test/files/github/readme"

  def readme(owner, repo) do
    File.read!(readme_path(owner, repo))
  end

  def repo_get(owner, repo) do
    Tentacat.Repositories.repo_get(owner, repo, client())
  end

  defp client do
    if token = System.get_env("AW_TOKEN") do
      Tentacat.Client.new(%{
        access_token: token
      })
    else
      Logger.warn("Using unauthorized Github access. Export AW_TOKEN to raise limits.")
      Tentacat.Client.new
    end
  end

  defp path(owner, repo) do
    Path.join(owner, repo)
  end

  def readme_path(owner, repo) do
    Path.join([
      @readme_prefix,
      path(owner, repo),
      "readme.md"
    ])
  end
end
