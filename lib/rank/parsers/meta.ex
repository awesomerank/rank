defmodule Rank.Parsers.Meta do
  @moduledoc """
  Parser for list of awesome lists
  """

  alias Rank.Github

  @owner "sindresorhus"
  @repo "awesome"

  @doc """
  Parse Awesome Meta
  """
  def parse do
    Github.parse_readme(@owner, @repo)
  end
end
