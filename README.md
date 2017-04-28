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
md = Rank.Github.parse_readme("h4cc", "awesome-elixir")
File.write "result.md", md
```

## TODO
- Construct Meta parser, run individual parsers from it. Save Markdown for each page.
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
