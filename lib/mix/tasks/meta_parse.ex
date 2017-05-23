defmodule Mix.Tasks.Meta.Parse do
  use Mix.Task

  def run(_opts) do
    Mix.Task.run "app.start", []

    Rank.Parsers.Meta.parse
  end
end
