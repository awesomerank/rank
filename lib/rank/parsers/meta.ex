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
    Github.get_readme(@owner, @repo)
    |> Rank.Parsers.Page.parse
  end
end
