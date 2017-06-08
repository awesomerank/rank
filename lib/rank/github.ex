defmodule Rank.Github do
  @moduledoc """
  Github API calls
  """
  defstruct [:stargazers_count, :idle_years]

  require Logger
  alias Rank.Cache

  @github_api Application.get_env(:rank, :github_api)

  def get_readme(owner, repo) do
    @github_api.readme(owner, repo)
  end

  def url(owner, repo) do
    "https://github.com/#{owner}/#{repo}"
  end

  def external_path(owner, repo) do
    Path.join([url(owner, repo), "blob", "master"])
  end

  def get_data([_line, _prefix, _name, owner, repo, _description] = regex_results) do
    stargazers = get_ranks(owner, repo)
    [stargazers | regex_results]
  end
  def get_data(line), do: line

  def data_to_s(%__MODULE__{stargazers_count: stargazers, idle_years: idle_years}) do
    Enum.join([stargazers_to_s(stargazers), idle_years_to_s(idle_years)])
  end

  defp stargazers_to_s(stargazers) do
    " ★#{stargazers}"
  end

  defp idle_years_to_s(idle_years) when idle_years > 0 do
    " ⏳#{idle_years}Y"
  end
  defp idle_years_to_s(_idle_years), do: ""

  def get_ranks(owner, repo) do
    get_cached_path(owner, repo)
    |> parse_data
  end

  defp get_cached_path(owner, repo) do
    Cache.get!(path(owner, repo)) || get_repo_info!(owner, repo)
  end

  def path(owner, repo) do
    Path.join(owner, repo)
  end

  defp get_repo_info!(owner, repo) do
    Logger.debug("Getting repo info for #{path(owner, repo)}")
    info = @github_api.repo_get(owner, repo)
    :timer.sleep(700) # TODO: make smarter expiration based on time spent in request
    Cache.put!(path(owner, repo), info)
  end

  defp parse_data(%{"stargazers_count" => stargazers_count, "pushed_at" => pushed_at}) do
    %__MODULE__{
      stargazers_count: stargazers_count,
      idle_years: Timex.diff(Timex.now, Timex.parse!(pushed_at, "{ISO:Extended:Z}"), :years)
    }
  end
  defp parse_data(_), do: nil
end
