defmodule Rank.Cache do
  @moduledoc """
  Simple Redis cache
  """

  @ttl 60 * 60 * 24 * 7

  def get(key) do
    Redix.command!(:redix, ["GET", key])
    |> decode
  end

  defp decode(nil), do: nil
  defp decode(data), do: Poison.decode!(data)

  def put(key, map) do
    data = Poison.encode!(map)
    commands = [
      ["MULTI"],
      ["SET", key, data],
      ["EXPIRE", key, @ttl],
      ["EXEC"]
    ]
    {:ok, _} = Redix.pipeline(:redix, commands)
    map
  end
end
