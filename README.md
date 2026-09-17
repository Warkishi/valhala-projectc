# Valhala Projectc

Prototype jouable Godot 4 d'un RPG gacha fantastique hors ligne.

## Fonctionnalités

- Invocations x1 et x10 avec fragments virtuels gratuits.
- Raretés de 1 à 10 étoiles, probabilités affichées et distribution exponentielle.
- Classes et noms générés aléatoirement.
- Portrait procédural animé et unique pour chaque héros (graine propre au personnage).
- Inventaire, puissance, historique de session et sauvegarde locale.
- Architecture sans dépendance réseau : un backend et des achats intégrés pourront être ajoutés ensuite.

## Lancer le jeu

1. Installer Godot 4.2 ou plus récent.
2. Importer ce dépôt dans Godot.
3. Ouvrir `project.godot` et cliquer sur **Run Project**.

Pour un export Android : installer les modèles d'export Android dans Godot, configurer le SDK Android, puis utiliser **Project > Export > Android**. Le projet est configuré en renderer Compatibility pour les appareils mobiles.

## Probabilités

Les poids sont calculés avec `2^(10 - rareté)`, puis normalisés. Une 10★ est donc bien plus rare qu'une 1★. Les probabilités complètes sont visibles directement dans l'autel.

## Note produit

Ce prototype n'utilise aucun paiement réel ni connexion en ligne. Avant toute monétisation, il faudra ajouter un serveur d'autorité, la validation des reçus, des limites d'achat et les obligations de transparence propres aux jeux de hasard virtuel.
