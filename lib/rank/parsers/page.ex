defmodule Rank.Parsers.Page do
  @moduledoc """
  Parse Awesome Readme
  """

  @doc """
  Parse Markdown-formatted Awesome List
  """
  def parse([line | tail], state \\ nil, categories \\ []) do
    {state, result} = parse_line(state, line)
    cond do
      is_nil(result) ->
        parse(tail, state, categories)
      state == :contents ->
        parse(tail, state, [result | categories])
      state == :category && !Enum.member?(categories, result) ->
        []
      result ->
        [{state, result} | parse(tail, state, categories)]
    end

  end
  def parse([], _state, _categories) do
    []
  end

  defp parse_line(nil, "## Contents") do
    {:contents, nil}
  end
  defp parse_line(nil, _) do
    {nil, nil}
  end
  # `- [Platforms](#platforms)`
  defp parse_line(:contents = state, <<"- [", category::binary>>) do
    [category_name, _link] = String.split(category, "]", parts: 2)
    {state, category_name}
  end
  defp parse_line(state, "") do
    {state, nil}
  end
  defp parse_line(state, <<"## ", category_name::binary>>) when state in [:contents, :link, :sublink] do
    {:category, category_name}
  end
  defp parse_line(state, <<"- ", link::binary>>) when state in [:category, :link, :sublink] do
    {:link, parse_markdown_link(link)}
  end
  defp parse_line(state, <<"\t- ", link::binary>>) when state in [:link, :sublink] do
    {:sublink, parse_markdown_link(link)}
  end

  defp parse_markdown_link(link) do
    [_link, name, url] = Regex.run(~r/\[(.*)\]\((.*)\)/, link)
    {name, url}
  end
end
