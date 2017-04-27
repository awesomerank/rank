defmodule Rank.Parsers.Custom.Ruby do
  @moduledoc """
  Temporary (?) implementation for Ruby list
  Copypaste from `Elixir` with fixes

  Throwing out Sesources and Resources for now
  """

  def parse([line | tail], state \\ nil, categories \\ []) do
    {state, result} = parse_line(state, line)
    cond do
      state == :end ->
        []
      is_nil(result) ->
        parse(tail, state, categories)
      state == :contents ->
        [{state, result} | parse(tail, state, [result | categories])]
      result ->
        [{state, result} | parse(tail, state, categories)]
    end
  end
  def parse([], _state, _categories) do
    []
  end

  defp parse_line(nil, "* [Awesome Ruby](#awesome-ruby)") do
    {:contents, nil}
  end
  defp parse_line(nil, _) do
    {nil, nil}
  end
  defp parse_line(:contents = state, <<"  * [", category::binary>>) do
    [category_name, link] = String.split(category, "]", parts: 2)
    {state, {category_name, link}}
  end
  defp parse_line(state, "") do
    {state, nil}
  end
  defp parse_line(:contents, <<"* ", _::binary>>) do
    {:skip, nil}
  end
  defp parse_line(state, <<"## ", category_name::binary>>) when state in [:skip, :contents, :link, :sublink] do
    {:category, category_name}
  end
  defp parse_line(:skip, _) do
    {:skip, nil}
  end
  defp parse_line(state, <<"* [", link::binary>>) when state in [:category, :link, :sublink] do
    {:link, parse_link(link)}
  end
  defp parse_line(state, <<"* ", link_subcategory::binary>>) when state in [:category, :link, :sublink] do
    {:link_subcategory, link_subcategory}
  end
  defp parse_line(state, <<"  * [", link::binary>>) when state in [:link_subcategory, :sublink] do
    {:sublink, parse_link(link)}
  end
  defp parse_line(:link, "# Services and Apps") do
    {:end, nil}
  end
  # For awesome-ruby, threw off line of description after link (temporary ?)
  # * [Parallel](https://github.com/grosser/parallel) - Run any code in parallel Processes (> use all CPUs) or Threads (> speedup blocking operations).
  # Best suited for map-reduce or e.g. parallel downloads/uploads.
  defp parse_line(:link, _) do
    {:skip, nil}
  end
  # Skip deep subcategories and sublinks. Doesn't fit into current model. Need re-do?
  #  * Formatters
  #    * [Emoji-RSpec](https://github.com/cupakromer/emoji-rspec) - Custom Emoji Formatters for RSpec.
  #    * [Fuubar](https://github.com/thekompanee/fuubar) - The instafailing RSpec progress bar formatter.
  #    * [Nyan Cat](https://github.com/mattsears/nyan-cat-formatter) - Nyan Cat inspired RSpec formatter!
  defp parse_line(:sublink, _) do
    {:skip, nil}
  end

  defp parse_link(link) do
    [_link, name, url, description] = Regex.run(~r/(.*)\]\((.*)\) - (.*)/, link)
    {name, url, description}
  end
end
