defmodule Rank.Github do
  @moduledoc """
  Github API calls
  """

  require Logger
  import Rank.Parsers.Meta, only: [is_meta?: 2]
  alias Rank.Cache

  # Lists that contain other lists locally. Can't save them, only link
  @skip_save [
    "dypsilon/frontend-dev-bookmarks"
  ]

  def parse_readme(owner, repo) do
    Tentacat.Contents.readme(owner, repo, client())
    |> Map.get("content")
    |> :base64.decode
    |> String.split("\n")
    |> log_count
    |> Enum.map(fn(line) -> embed_stargazers(line, is_meta?(owner, repo)) end)
    |> Enum.join("\n")
  end

  defp embed_stargazers(line, is_meta) do
    line
    |> run_regex
    |> get_stargazers
    |> embed_stargazer(is_meta)
  end

  defp log_count(lines) do
    Logger.debug("#{Enum.count(lines)} lines")
    lines
  end

  def run_regex(line) do
    if result = Regex.run(~r/(.*)\[([^★]+)\]\(https:\/\/github.com\/([^\/]+)\/([^\/]+)\/?\)(.*)/, line) do
      result
    else
      line
    end
  end

  defp get_stargazers([_line, _prefix, _name, owner, repo, _description] = regex_results) do
    stargazers = get_stargazers_count(owner, repo)
    [stargazers | regex_results]
  end
  defp get_stargazers(line), do: line

  defp embed_stargazer([nil, line | _tail], _is_meta), do: line
  defp embed_stargazer([stargazers, _line, prefix, name, owner, repo, description], is_meta) do
    if is_meta, do: Logger.debug("Parsing child list: #{name} (#{path(owner, repo)})#{description}")
    link = if is_meta && can_save?(owner, repo) do
      lists_dir = Path.join("lists", owner)
      path = Enum.join([Path.join(lists_dir, repo), "md"], ".")
      # TODO: check timestamp, overwrite if old. Must be same timestamp as in Cache @ttl
      if !File.exists?(path) do
        File.mkdir_p!(lists_dir)
        contents = Rank.Github.parse_readme(owner, repo)
        File.write!(path, contents)
      end
      path
    else
      "https://github.com/#{owner}/#{repo}"
    end
    "#{prefix}[#{name}#{stars_to_s(stargazers)}](#{link})#{description}"
  end
  defp embed_stargazer(line, _is_meta), do: line

  defp stars_to_s(nil), do: ""
  defp stars_to_s(stargazers) do
    " ★#{stargazers}"
  end

  def can_save?(owner, repo) do
    !Enum.member?(@skip_save, path(owner, repo))
  end

  def get_stargazers_count(owner, repo) do
    get_cached_path(owner, repo)
    |> parse_stargazers
  end

  defp get_cached_path(owner, repo) do
    Cache.get!(path(owner, repo)) || get_repo_info!(owner, repo)
  end

  defp path(owner, repo) do
    Path.join(owner, repo)
  end

  defp get_repo_info!(owner, repo) do
    Logger.debug("Getting repo info for #{path(owner, repo)}")
    info = Tentacat.Repositories.repo_get(owner, repo, client())
    :timer.sleep(700) # TODO: make smarter expiration based on time spent in request
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
