use Mix.Config

config :rank, redis_database: 8

config :rank, github_api: Rank.GithubApi.Sandbox

config :rank, :write_prefix, "test/files/tmp"
