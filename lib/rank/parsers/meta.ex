defmodule Rank.Parsers.Meta do
  @moduledoc """
  Parser for list of awesome lists
  """

  @owner "sindresorhus"
  @repo "awesome"

  @doc """
  Parse Awesome Meta
  """
  def parse do
    Tentacat.Contents.readme(@owner, @repo)
    |> Map.get("content")
    |> :base64.decode
    |> String.split("\n")
    |> Rank.Parsers.Page.parse
  end
end
