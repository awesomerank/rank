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
- Add "clock" icon cNy (icon, number, y) - number of years outdated.
Note it in header and footer.
- Attach header and footer to generated awesome lists. Put origin into it.
- Establish periodic builds, commit after each build (use schedule and API).
- Add tests.
- Add "fork me on github" with link to builder.
- Put builds to own computer or separate build server or Linode host.
- First release (?)
- Look closely at already starred repos (for example https://github.com/jondot/awesome-react-native) and way they starred (https://github.com/jondot/jill)
- Add external link icon to external links.
- Smart timeouts for Github API
- Use timestamp to check if saved list is old and owerwrite it
- Sort by stargazers.
- Add other activity marks, "recent activity" for example.
- Top 10 (or 20, or 50, or maybe even 100) packages for entire list.
- Subscribe to lists repositories changes
- Use stream to save meta
