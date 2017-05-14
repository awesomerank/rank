defmodule Rank.Integration do
  use ExUnit.Case, async: false

  setup do
    on_exit fn ->
      Redix.command!(:redix, ["FLUSHDB"])
      File.rm_rf!("test/files/tmp/lists")
    end
  end

  test "parse meta and child readmes" do
    assert Rank.Parsers.Meta.parse
    reference_index = File.read!("test/files/tmp/lists/index.md")
    output_index = File.read!("test/files/output/index.md")
    assert reference_index == output_index
    [
      "dypsilon/frontend-dev-bookmarks.md",
      "h4cc/awesome-elixir.md",
      "jondot/awesome-react-native.md"
    ]
    |> Enum.each(fn(readme) ->
      reference_readme = File.read!("test/files/tmp/lists/#{readme}")
      output_readme = File.read!("test/files/output/#{readme}")
      assert reference_readme == output_readme
    end)
  end
end
