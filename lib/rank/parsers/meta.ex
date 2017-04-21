defmodule Rank.Parsers.Meta do
  @moduledoc """
  Parser for list of awesome lists
  """

  @owner "sindresorhus"
  @repo "awesome"

  def parse do
    Tentacat.Contents.readme(@owner, @repo)
    |> Map.get("content")
    |> :base64.decode
  end
end
