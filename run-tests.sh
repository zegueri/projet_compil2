#!/bin/sh
set -e

# build interpreter if needed
make

# run every test file in alphabetical order
for t in $(ls tests/*.txt | sort); do
  echo "== $t =="
  ./logic_interpreter "$t" || true
  echo
done
