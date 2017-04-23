defmodule Rank.Github do
  @moduledoc """
  Github API calls
  """

  def get_readme(owner, repo) do
    Tentacat.Contents.readme(owner, repo)
    |> Map.get("content")
    |> :base64.decode
    |> String.split("\n")
  end
end
