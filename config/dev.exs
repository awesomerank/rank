use Mix.Config

config :rank, redis_database: 7

config :rank, github_api: Rank.GithubApi.Tentacat

config :rank, :write_prefix, ""
