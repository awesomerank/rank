defmodule Rank.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @redis_database Application.get_env(:rank, :redis_database)

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Rank.Worker.start_link(arg1, arg2, arg3)
      # worker(Rank.Worker, [arg1, arg2, arg3]),
      worker(Redix, [[database: @redis_database], [name: :redix]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rank.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
