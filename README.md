[![Build Status](https://api.travis-ci.org/awesomerank/rank.svg?branch=master)](https://travis-ci.org/awesomerank/rank)

# Rank

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

### Ideas

- Top 10 (or 20, or 50, or maybe even 100) packages for entire list.
- Sort by stargazers.

### Improvements

- Link to index from every page (breadcrumbs?).
- Add external link icon to external links.
- Look closely at already starred repos (for example https://github.com/jondot/awesome-react-native) and way they starred (https://github.com/jondot/jill)
- Smart timeouts for Github API
- Add other activity marks, "recent activity" for example.
- Subscribe to lists repositories changes
- Use stream to save meta
- Use templates from Phoenix to wrap contents.
- Add description of stars and clocks to header and footer.
- Do not localize lists without links to github.
- Drop icons from parsed lists (build passed, awesome link, etc.)
- Remove old lists (removed from meta or ignored).
