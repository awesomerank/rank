defmodule Rank.Parsers.Custom.Elixir do
  @moduledoc """
  Temporary (?) implementation for Elixir list
  Copypaste from `Page` with fixes

  Throwing out resources for now
  """

  def parse([line | tail], state \\ nil, categories \\ []) do
    {state, result} = parse_line(state, line)
    cond do
      state == :end ->
        []
      is_nil(result) ->
        parse(tail, state, categories)
      state == :contents ->
        parse(tail, state, [result | categories])
      result ->
        [{state, result} | parse(tail, state, categories)]
    end
  end
  def parse([], _state, _categories) do
    []
  end

  defp parse_line(nil, <<"- [Awesome Elixir", _::binary>>) do
    {:contents, nil}
  end
  defp parse_line(nil, _) do
    {nil, nil}
  end
  # `- [Platforms](#platforms)`
  defp parse_line(:contents = state, <<"    - [", category::binary>>) do
    [category_name, _link] = String.split(category, "]", parts: 2)
    {state, category_name}
  end
  defp parse_line(state, "") do
    {state, nil}
  end
  defp parse_line(:contents, <<"- ", _::binary>>) do
    {:skip, nil}
  end
  defp parse_line(state, <<"## ", category_name::binary>>) when state in [:skip, :contents, :link, :sublink] do
    {:category, category_name}
  end
  defp parse_line(:skip, _) do
    {:skip, nil}
  end
  defp parse_line(:category, <<"*", description::binary>>) do
    [description, _] = String.split(description, "*")
    {:description, description}
  end
  defp parse_line(state, <<"* ", link::binary>>) when state in [:description, :category, :link, :sublink] do
    {:link, parse_link(link)}
  end
  defp parse_line(:link, "# Resources") do
    {:end, nil}
  end

  defp parse_link(link) do
    IO.puts link
    [_link, name, url, description] = Regex.run(~r/\[(.*)\]\((.*)\) - (.*)/, link)
    {name, url, description}
  end
end
