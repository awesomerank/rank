# Rank

## Data to handle

Hierarcy:
- Meta
  - MetaCategory
    - List (github only)
      - Category
        - Link (mostly github)
          - SubLink (as above but one level deeper)

## Run

To run code manually:

```elixir
Rank.Github.get_readme("h4cc", "awesome-elixir")
|> Rank.Parsers.Custom.Elixir.parse
|> Enum.filter(fn({type, _}) -> type == :link end)
|> Enum.each(fn({_, {_, link, _}}) -> IO.puts("#{DateTime.utc_now}, #{link}"); Rank.Github.get_stargazers_count(link); end)
```

## TODO
- Run parsed links list through to get stars for every github link.
- Generate Awesome List again, now with stargazers count, sort by them
- First release (?)
- Add other activity marks, "recent activity" for example.
