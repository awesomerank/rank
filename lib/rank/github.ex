defmodule Rank.Github do
  @moduledoc """
  Github API calls
  """

  def get_readme(owner, repo) do
    Tentacat.Contents.readme(owner, repo)
    |> Map.get("content")
    |> :base64.decode
    |> String.split("\n")
  end

  def get_stargazers_count(<<"https://github.com/", path::binary>>) do
    [owner, repo] = String.split(path, "/")
    %{"stargazers_count" => stargazers} = Tentacat.Repositories.repo_get(owner, repo)
    stargazers
  end
end
