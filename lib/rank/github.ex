defmodule Rank.Github do
  @moduledoc """
  Github API calls
  """

  require Logger
  alias Rank.Cache

  def parse_readme(owner, repo) do
    Tentacat.Contents.readme(owner, repo, client())
    |> Map.get("content")
    |> :base64.decode
    |> String.split("\n")
    |> Enum.map(&embed_stargasers/1)
    |> Enum.join("\n")
  end

  defp embed_stargasers(line) do
    line
    |> run_regex
    |> embed_stargazer
  end

  def run_regex(line) do
    if result = Regex.run(~r/(.*)\[(.*)\]\(https:\/\/github.com\/([^\/]+)\/([^\/]+)\/?\)(.*)/, line) do
      result
    else
      line
    end
  end

  defp embed_stargazer([_line, prefix, name, owner, repo, description]) do
    stargasers = get_stargazers_count(owner, repo)
    "#{prefix}[#{name}](https://github.com/#{owner}/#{repo})#{stars_to_s(stargasers)}#{description}"
  end
  defp embed_stargazer(line), do: line

  defp stars_to_s(nil), do: ""
  defp stars_to_s(stargazers) do
    " (#{stargazers})"
  end

  def get_stargazers_count(owner, repo) do
    get_cached_path(owner, repo)
    |> parse_stargazers
  end

  defp get_cached_path(owner, repo) do
    Cache.get!(path(owner, repo)) || get_repo_info!(owner, repo)
  end

  defp path(owner, repo) do
    Enum.join([owner, repo], "/")
  end

  defp get_repo_info!(owner, repo) do
    Logger.debug("Getting repo info for #{path(owner, repo)}")
    info = Tentacat.Repositories.repo_get(owner, repo, client())
    :timer.sleep(1000) # TODO: make smarter expiration based on time spent in request
    Cache.put!(path(owner, repo), info)
  end

  defp parse_stargazers(%{"stargazers_count" => stargazers}) do
    stargazers
  end
  defp parse_stargazers(_), do: nil

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
