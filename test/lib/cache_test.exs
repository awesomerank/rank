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

  test "get missing key" do
    refute Cache.get!("missing_key")
  end

  test "put key and get it, check ttl" do
    key = "key"
    data = "data"
    assert Cache.put!(key, data)
    assert Cache.get!(key) == data
    ttl = command(["TTL", key])
    assert ttl == Cache.ttl
  end

  test "put and get map" do
    key = "key"
    data = %{"key" => "value"}
    assert Cache.put!(key, data)
    assert Cache.get!(key) == data
  end
end
