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

```bash
mix meta.parse
```

## Deploy

Create user, generate ssh keys, and put it as deploy keys to
`awesomerank.github.io` repository.

Copy both `rank` and `awesomerank.github.io` into this user homedir and
establish periodic builds with crontab.
```
00 12 * * * $HOME/rank/build_and_deploy.sh 2>&1
```

## TODO
- Link to index from every page (breadcrumbs?).
- Add "fork me on github" with link to builder.
- Add Google analytics.
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
- Use templates from Phoenix to wrap contents.
- Add description of stars and clocks to header and footer.
- Do not localize lists without links to github.
- Drop icons from parsed lists (build passed, awesome link, etc.)
