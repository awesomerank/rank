defmodule Rank.Cache do
  @moduledoc """
  Simple Redis cache

  Encodes and decodes maps
  """

  @ttl 60 * 60 * 24 * 7 # 7 days
  @jitter 0.25

  # random ttl to avoid all keys expiring at once
  def ttl do
    low_ttl = @ttl * (1 - @jitter) |> round
    high_ttl = @ttl * (1 + @jitter) |> round
    Enum.random(low_ttl..high_ttl)
  end

  def get!(key) do
    Redix.command!(:redix, ["GET", key])
    |> decode
  end

  defp decode(nil), do: nil
  defp decode(data) do
    case Poison.decode(data) do
      {:ok, result} ->
        result
      {:error, _} ->
        data
    end
  end

  def put!(key, data) when is_binary(data) do
    commands = [
      ["MULTI"],
      ["SET", key, data],
      ["EXPIRE", key, @ttl],
      ["EXEC"]
    ]
    {:ok, _} = Redix.pipeline(:redix, commands) # TODO: check EXPIRE set
  end
  def put!(key, data) when is_map(data) do
    put!(key, Poison.encode!(data))
    data
  end
  def put!(key, data) when is_tuple(data) do
    string = inspect(data)
    put!(key, string)
    string
  end
end
