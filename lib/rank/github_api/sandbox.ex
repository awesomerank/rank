defmodule Rank.GithubApi.Sandbox do
  require Logger

  @readme_prefix "test/files/github/readme"
  @repo_prefix "test/files/github/repo"
  @redirect_error {301, %{
      "documentation_url" => "https://developer.github.com/v3/#http-redirects",
      "message" => "Moved Permanently",
      "url" => "https://api.github.com/repositories/53809858"
    }
  }

  # exact copy from Rank.GithubApi.Tentacat
  def readme(owner, repo) do
    readme_get(owner, repo)
    |> extract_readme
  end

  # exact copy from Rank.GithubApi.Tentacat
  defp extract_readme(%{"content" => content}) do
    :base64.decode(content)
    |> String.split("\n")
  end
  defp extract_readme(_error), do: []

  defp readme_get(owner, repo) do
    %{
      "content" => readme_path(owner, repo) |> File.read! |> :base64.encode
    }
  end

  # use repo_get_record instead to get and record real Github repo data
  def repo_get("candelibas", "awesome-ionic2") do
    @redirect_error
  end
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
