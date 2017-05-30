#!/bin/sh

mix meta.parse && \
mv lists/index.md ../awesomerank.github.io/index.md && \
cp -rp lists ../awesomerank.github.io/ && \
(cd ../awesomerank.github.io/ && git add . && git commit -m "Update lists" && git push)
