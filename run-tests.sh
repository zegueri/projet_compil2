#!/bin/sh
set -e

# construit l'interpréteur si nécessaire
make

# exécute tous les tests par ordre alphabétique
for t in $(ls tests/*.txt | sort); do
  echo "== $t =="
  ./logic_interpreter "$t" || true
  echo
done
