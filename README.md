# Interpréteur logique

Ce dépôt contient un interpréteur minimal permettant de définir et de manipuler des fonctions booléennes. Celles-ci peuvent être décrites par une formule ou directement par leur table de vérité.

## Compilation

Lancez `make` à la racine du projet pour obtenir l'exécutable `logic_interpreter`.

```sh
make
```

## Utilisation

Sans argument, l'interpréteur fonctionne en mode interactif. Il est également possible de lui fournir un fichier de commandes en paramètre.

```sh
./logic_interpreter             # mode interactif
./logic_interpreter commandes.txt   # lecture depuis un fichier
```

Les commandes reconnues sont :

- `define` – définir une fonction à partir d'une formule ou d'une table
- `list` – afficher la liste des fonctions connues
- `varlist <nom>` – afficher les variables utilisées par la fonction
- `table <nom>` – afficher la table de vérité d'une fonction
- `eval <nom> at <valeurs>` – évaluer la fonction sur des valeurs données
- `formula <nom>` – afficher une formule équivalente

Des exemples de commandes valides se trouvent dans le répertoire `tests/`.

## Tests

Le script `run-tests.sh` compile le projet puis exécute tous les fichiers de test.

```sh
./run-tests.sh
```
