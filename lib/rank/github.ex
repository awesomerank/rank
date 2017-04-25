defmodule Rank.Github do
  @moduledoc """
  Github API calls
  """

  require Logger

  def get_readme(owner, repo) do
    Tentacat.Contents.readme(owner, repo, client())
    |> Map.get("content")
    |> :base64.decode
    |> String.split("\n")
  end

  def get_stargazers_count(<<"https://github.com/", path::binary>>) do
    [owner, repo] = String.split(path, "/")
    %{"stargazers_count" => stargazers} = Tentacat.Repositories.repo_get(owner, repo, client())
    stargazers
  end

  def client do
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
