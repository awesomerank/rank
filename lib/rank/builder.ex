defmodule Rank.Builder do
  @moduledoc """
  Builds Markdown page from data sequence
  """

  def build(data) do
    data
    |> enrich
  end

  defp enrich(data) do
    data
    |> Enum.map(&add_stargazers/1)
    |> Enum.map(&to_markdown/1)
    |> Enum.join("\n")
  end

  defp add_stargazers({:link, {_name, url, _description} = link_data}) do
    stargasers = Rank.Github.get_stargazers_count(url)
    {:link, Tuple.append(link_data, stargasers)}
  end
  defp add_stargazers({_category, _} = item), do: item

  defp to_markdown({:contents, _category}) do
    ""
  end
  defp to_markdown({:category, name}) do
    "\n## #{name}"
  end
  defp to_markdown({:description, description}) do
    "*#{description}*\n"
  end
  defp to_markdown({:link, {name, url, description, _stargazers}}) do
    "* [#{name}](#{url}) - #{description}"
  end
end
