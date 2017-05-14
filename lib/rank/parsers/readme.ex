defmodule Rank.Parsers.Readme do
  require Logger
  alias Rank.Github
  alias Rank.Store
  alias Rank.Parsers.Meta
  alias Rank.Parsers.Readme

  def parse(owner, repo) do
    Github.get_readme(owner, repo)
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

  defp log_count(lines) do
    Logger.debug("#{Enum.count(lines)} lines")
    lines
  end

  defp embed_ranks(line, is_meta) do
    line
    |> run_regex
    |> Github.get_data
    |> embed_github_data(is_meta)
  end

  defp replace_html_locals(line, owner, repo) do
    Regex.replace(~r/href="([^#:]+\.(?:md|jpg|png|html|txt))"/, line, fn _, link ->
      "href=\"#{Github.external_path(owner, repo)}/#{link}\""
    end)
  end

  defp replace_markdown_locals(line, owner, repo) do
    if !Meta.is_meta?(owner, repo) do
      Regex.replace(~r/\(([^#:\(\)\.]+\.(?:md|jpg|png|html|txt))\)/, line, fn _, link ->
        "(#{Github.external_path(owner, repo)}/#{link})"
      end)
    else
      line
    end
  end

  defp attach_layout(contents, owner, repo) do
    template("header.md", owner, repo) <>
      contents <>
      template("tail.md", owner, repo)
  end

  def run_regex(line) do
    if result = Regex.run(~r/(.*)\[([^★]+)\]\(https:\/\/github.com\/([^\/\?]+)\/([^\/\?]+)\/?\)(.*)/, line) do
      result
    else
      line
    end
  end

  defp embed_github_data([nil, line | _tail], _is_meta), do: line
  defp embed_github_data([github_data, _line, prefix, name, owner, repo, description], is_meta) do
    if is_meta, do: Logger.debug("Parsing child list: #{name} (#{Github.path(owner, repo)})#{description}")
    # we are parsing meta, but child is not meta (avoid infinite recursion when meta links itself)
    # TODO: check timestamp, overwrite if old. Must be same timestamp as in Cache @ttl
    link = if is_meta && !Meta.is_meta?(owner, repo) && !Store.readme_exists?(owner, repo) do
      contents = Readme.parse(owner, repo)
      Store.write_readme(owner, repo, contents)
    else
      Github.path(owner, repo)
    end
    "#{prefix}[#{name}#{Github.data_to_s(github_data)}](#{link})#{description}"
  end
  defp embed_github_data(line, _is_meta), do: line

  defp template(filename, owner, repo) do
    template = [:code.priv_dir(:rank), "static", "templates", filename]
    |> Path.join
    |> File.read!
    Regex.replace(~r/\$origin/, template, Github.path(owner, repo))
  end
end
