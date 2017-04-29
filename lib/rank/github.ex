defmodule Rank.Github do
  @moduledoc """
  Github API calls
  """

  require Logger
  import Rank.Parsers.Meta, only: [is_meta?: 2]
  alias Rank.Cache

  def parse_readme(owner, repo) do
    Tentacat.Contents.readme(owner, repo, client())
    |> Map.get("content")
    |> :base64.decode
    |> String.split("\n")
    |> log_count
    |> Enum.map(fn(line) -> embed_stargasers(line, is_meta?(owner, repo)) end)
    |> Enum.join("\n")
  end

  defp embed_stargasers(line, is_meta) do
    line
    |> run_regex
    |> embed_stargazer(is_meta)
  end

  defp log_count(lines) do
    Logger.debug("#{Enum.count(lines)} lines")
    lines
  end

  def run_regex(line) do
    if result = Regex.run(~r/(.*)\[(.*)\]\(https:\/\/github.com\/([^\/]+)\/([^\/]+)\/?\)(.*)/, line) do
      result
    else
      line
    end
  end

  defp embed_stargazer([_line, prefix, name, owner, repo, description], is_meta) do
    stargasers = get_stargazers_count(owner, repo)
    link = if is_meta do
      Logger.debug("Parsing child list: #{name} (#{path(owner, repo)})#{description}")
      contents = Rank.Github.parse_readme(owner, repo)
      File.mkdir!(owner)
      path = Enum.join([path(owner, repo), "md"], ".")
      File.write!(path, contents)
      path
    else
      "https://github.com/#{owner}/#{repo}"
    end
    "#{prefix}[#{name}](#{link})#{stars_to_s(stargasers)}#{description}"
  end
  defp embed_stargazer(line, _is_meta), do: line

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
    Path.join(owner, repo)
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
