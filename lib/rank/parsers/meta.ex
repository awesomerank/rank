defmodule Rank.Parsers.Meta do
  @moduledoc """
  Parser for list of awesome lists
  """

  require Logger
  alias Rank.Github

  @owner "sindresorhus"
  @repo "awesome"

  @doc """
  Parse Awesome Meta
  """
  def parse do
    Logger.debug("Parsing meta")
    contents = Github.parse_readme(@owner, @repo)
    File.write("lists/index.md", contents)
  end

  def path do
    Path.join(@owner, @repo)
  end

  def is_meta?(owner, repo) do
    owner == @owner && repo == @repo
  end
end
