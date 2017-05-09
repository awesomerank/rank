defmodule Rank.Store do
  @write_prefix Application.get_env(:rank, :write_prefix)

  def write_index(contents) do
    index_folder = @write_prefix
    |> Path.join("lists")
    File.mkdir_p!(index_folder)
    index_folder
    |> Path.join("index.md")
    |> File.write!(contents)
  end
end
