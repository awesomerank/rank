defmodule Rank.Store do
  @write_prefix Application.get_env(:rank, :write_prefix)

  def write_index(contents) do
    File.mkdir_p!(index_folder())
    index_folder()
    |> Path.join("index.md")
    |> File.write!(contents)
  end

  def write_readme(owner, repo, contents) do
    path = readme_path(owner, repo)
    File.mkdir_p!(lists_dir(owner))
    File.write!(path, contents)
    path
  end

  defp index_folder do
    @write_prefix
    |> Path.join("lists")
  end

  defp lists_dir(owner) do
    Path.join(index_folder(), owner)
  end

  defp readme_path(owner, repo) do
    Enum.join([Path.join(lists_dir(owner), repo), "md"], ".")
  end
end
