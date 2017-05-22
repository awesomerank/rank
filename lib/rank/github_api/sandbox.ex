defmodule Rank.GithubApi.Sandbox do
  require Logger

  @readme_prefix "test/files/github/readme"
  @repo_prefix "test/files/github/repo"

  def readme(owner, repo) do
    File.read!(readme_path(owner, repo))
  end

  # use repo_get_record instead to get and record real Github repo data
  def repo_get(owner, repo) do
    @repo_prefix
    |> Path.join(owner)
    |> repo_path(repo)
    |> File.read!
    |> Poison.decode!
  end
  def repo_get_record(owner, repo) do
    info = Rank.GithubApi.Tentacat.repo_get(owner, repo)
    data = info |> Poison.encode!(pretty: true)
    dir = Path.join(@repo_prefix, owner)
    File.mkdir_p(dir)
    File.write!(repo_path(dir, repo), data)
    info
  end

  defp path(owner, repo) do
    Path.join(owner, repo)
  end

  defp readme_path(owner, repo) do
    Path.join([
      @readme_prefix,
      path(owner, repo),
      "readme.md"
    ])
  end

  defp repo_path(dir, repo) do
    Enum.join([path(dir, repo), "json"], ".")
  end
end
