defmodule Rank.CacheTest do
  use ExUnit.Case, async: false

  alias Rank.Cache

  setup do
    on_exit fn ->
      Redix.command!(:redix, ["FLUSHDB"])
    end
  end

  defp command(command) do
    Redix.command!(:redix, command)
  end

  test "ttl" do
    ttls = (1..10)
    |> Enum.map(fn(_index) ->
      Cache.ttl
    end)
    |> Enum.sort
    first_ttl = List.first(ttls)
    last_ttl = List.last(ttls)
    assert first_ttl / last_ttl >= 3/5
  end

  test "get missing key" do
    refute Cache.get!("missing_key")
  end

  test "put key and get it, check ttl" do
    key = "key"
    data = "data"
    assert Cache.put!(key, data)
    assert Cache.get!(key) == data
    ttl = command(["TTL", key])
    assert ttl > Cache.ttl / 2 # very simple test with random ttls
  end

  test "put and get map" do
    key = "key"
    data = %{"key" => "value"}
    assert Cache.put!(key, data)
    assert Cache.get!(key) == data
  end
end
