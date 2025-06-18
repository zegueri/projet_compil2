#!/bin/sh
set -e
for t in tests/*.txt; do
  echo "== $t =="
  ./logic_interpreter "$t"
  echo
done
