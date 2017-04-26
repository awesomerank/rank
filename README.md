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
md = Rank.Github.get_readme("h4cc", "awesome-elixir")
|> Rank.Parsers.Custom.Elixir.parse
|> Rank.Builder.build
File.write "result.md", md
```

## TODO
- Run parsed links list through to get stars for every github link.
- Generate Awesome List again, now with stargazers count, sort by them
- First release (?)
- Add other activity marks, "recent activity" for example.
- Top 10 (or 20, or 50, or maybe even 100) packages for entire list.
