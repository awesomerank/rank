defmodule Rank.GithubApi.Tentacat do
  require Logger

  def readme(owner, repo) do
    Tentacat.Contents.readme(owner, repo, client())
    |> Map.get("content")
    |> :base64.decode
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
