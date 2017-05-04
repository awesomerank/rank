defmodule Rank.Github do
  @moduledoc """
  Github API calls
  """
  defstruct [:stargazers_count, :idle_years]

  require Logger
  alias Rank.Parsers.Meta
  alias Rank.Cache
  alias Rank.Github

  @skip_save [
    Meta.path
  ]

  def parse_readme(owner, repo) do
    Tentacat.Contents.readme(owner, repo, client())
    |> Map.get("content")
    |> :base64.decode
    |> String.split("\n")
    |> log_count
    |> Enum.map(fn(line) ->
      line
      |> embed_ranks(Meta.is_meta?(owner, repo))
      |> replace_html_locals(owner, repo)
      |> replace_markdown_locals(owner, repo)
    end)
    |> Enum.join("\n")
    |> attach_layout(owner, repo)
  end

  defp attach_layout(contents, owner, repo) do
    template("header.md", owner, repo) <>
      contents <>
      template("tail.md", owner, repo)
  end

  defp template(filename, owner, repo) do
    template = [:code.priv_dir(:rank), "static", "templates", filename]
    |> Path.join
    |> File.read!
    Regex.replace(~r/\$origin/, template, github_path(owner, repo))
  end

  defp replace_html_locals(line, owner, repo) do
    Regex.replace(~r/href="([^#:]+\.(?:md|jpg|png|html|txt))"/, line, fn _, link ->
      "href=\"#{github_external_path(owner, repo)}/#{link}\""
    end)
  end

  defp replace_markdown_locals(line, owner, repo) do
    if !Meta.is_meta?(owner, repo) do
      Regex.replace(~r/\(([^#:\(\)\.]+\.(?:md|jpg|png|html|txt))\)/, line, fn _, link ->
        "(#{github_external_path(owner, repo)}/#{link})"
      end)
    else
      line
    end
  end

  defp github_path(owner, repo) do
    "https://github.com/#{owner}/#{repo}"
  end

  defp github_external_path(owner, repo) do
    Path.join([github_path(owner, repo), "blob", "master"])
  end

  defp embed_ranks(line, is_meta) do
    line
    |> run_regex
    |> get_github_data
    |> embed_github_data(is_meta)
  end

  defp log_count(lines) do
    Logger.debug("#{Enum.count(lines)} lines")
    lines
  end

  def run_regex(line) do
    if result = Regex.run(~r/(.*)\[([^★]+)\]\(https:\/\/github.com\/([^\/\?]+)\/([^\/\?]+)\/?\)(.*)/, line) do
      result
    else
      line
    end
  end

  defp get_github_data([_line, _prefix, _name, owner, repo, _description] = regex_results) do
    stargazers = get_stargazers_count(owner, repo)
    [stargazers | regex_results]
  end
  defp get_github_data(line), do: line

  defp embed_github_data([nil, line | _tail], _is_meta), do: line
  defp embed_github_data([github_data, _line, prefix, name, owner, repo, description], is_meta) do
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
      github_path(owner, repo)
    end
    "#{prefix}[#{name}#{github_data_to_s(github_data)}](#{link})#{description}"
  end
  defp embed_github_data(line, _is_meta), do: line

  defp github_data_to_s(%Github{stargazers_count: stargazers, idle_years: idle_years}) do
    Enum.join([stargazers_to_s(stargazers), idle_years_to_s(idle_years)])
  end

  defp stargazers_to_s(stargazers) do
    " ★#{stargazers}"
  end

  defp idle_years_to_s(idle_years) when idle_years > 0 do
    " ⏳#{idle_years}Y"
  end
  defp idle_years_to_s(_idle_years), do: ""

  def can_save?(owner, repo) do
    !Enum.member?(@skip_save, path(owner, repo))
  end

  def get_stargazers_count(owner, repo) do
    get_cached_path(owner, repo)
    |> parse_github_data
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

  defp parse_github_data(%{"stargazers_count" => stargazers_count, "pushed_at" => pushed_at}) do
    %Github{
      stargazers_count: stargazers_count,
      idle_years: Timex.diff(Timex.now, Timex.parse!(pushed_at, "{ISO:Extended:Z}"), :years)
    }
  end
  defp parse_github_data(_), do: nil

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
