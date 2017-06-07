defmodule Rank.GithubApi.Tentacat do
  require Logger

  def readme(owner, repo) do
    readme_get(owner, repo)
    |> extract_readme
  end

  defp extract_readme(%{"content" => content}) do
    :base64.decode(content)
    |> String.split("\n")
  end
  defp extract_readme(_error), do: []

  defp readme_get(owner, repo) do
    Tentacat.Contents.readme(owner, repo, client())
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
end
