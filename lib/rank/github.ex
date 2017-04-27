defmodule Rank.Github do
  @moduledoc """
  Github API calls
  """

  require Logger
  alias Rank.Cache

  def get_readme(owner, repo) do
    Tentacat.Contents.readme(owner, repo, client())
    |> Map.get("content")
    |> :base64.decode
    |> String.split("\n")
  end

  def get_stargazers_count(<<"https://github.com/", path::binary>>) do
    if path |> parse_path |> check_path do
      path
      |> get_cached_path
      |> parse_stargazers
    else
      nil
    end
  end
  def get_stargazers_count(_), do: nil

  defp get_cached_path(nil), do: nil
  defp get_cached_path(path) do
    Cache.get!(path) || get_repo_info!(path)
  end

  defp parse_path(path) do
    Regex.run(~r/^([^\/]+)\/([^\/]+)/, path)
  end

  defp check_path([_path, _owner, _repo]), do: true
  defp check_path(_), do: false

  # TODO: tests for cases "repo/owner", "repo/owner/"
  defp get_repo_info!(path) do
    [_path, owner, repo] = parse_path(path)
    info = Tentacat.Repositories.repo_get(owner, repo, client())
    :timer.sleep(1000) # TODO: make smarter expiration based on time spent in request
    Cache.put!(path, info)
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
