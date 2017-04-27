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

  defp add_stargazers({state, {_name, url, _description} = link_data}) when state in [:link, :sublink] do
    stargasers = Rank.Github.get_stargazers_count(url)
    {:link, Tuple.append(link_data, stargasers)}
  end
  defp add_stargazers({_category, _} = item), do: item

  defp to_markdown({:contents, {category, link}}) do
    "- [#{category}]#{link}"
  end
  defp to_markdown({:category, name}) do
    "\n## #{name}"
  end
  defp to_markdown({:description, description}) do
    "*#{description}*\n"
  end
  defp to_markdown({:link, {name, url, description, stargazers}}) do
    "* [#{name}](#{url})#{stars_to_s(stargazers)} - #{description}"
  end
  defp to_markdown({:link_subcategory, name}) do
    "* #{name}"
  end
  defp to_markdown({:sublink, link}) do
    "  #{to_markdown({:link, link})}"
  end

  defp stars_to_s(nil), do: ""
  defp stars_to_s(stargazers) do
    " (#{stargazers})"
  end
end
