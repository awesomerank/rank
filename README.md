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
- Generate Awesome List again, now with stargazers count
- Add parsers for Ruby, Golang, Rust, Javascript.
- Generate Meta page for existing parsers.
- Put everything on Github Pages, commit after each build (use schedule and API).
- Add tests.
- Add instructions for writting new parsers, including test template
(output is standartized)
- Put resulting site to its own domain (probably within github.io, but maybe own domain).
- Establish periodic builds (own computer or separate build server or Linode host).
- First release (?)
- Sort by stargazers.
- Add other activity marks, "recent activity" for example.
- Top 10 (or 20, or 50, or maybe even 100) packages for entire list.
