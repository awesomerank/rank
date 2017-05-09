defmodule Rank.Parsers.Meta do
  @moduledoc """
  Parser for list of awesome lists
  """

  require Logger
  alias Rank.Parsers.Readme

  @owner "sindresorhus"
  @repo "awesome"

  @doc """
  Parse Awesome Meta
  """
  def parse do
    Logger.debug("Parsing meta")
    Readme.parse(@owner, @repo)
    |> Rank.Store.write_index
  end

  def path do
    Path.join(@owner, @repo)
  end

  def is_meta?(owner, repo) do
    owner == @owner && repo == @repo
  end
end
