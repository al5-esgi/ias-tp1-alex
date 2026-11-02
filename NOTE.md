# TP1 — Terraform vs `docker run` : différences observées

Même cible dans les deux cas : un réseau `tp-net`, un conteneur `tp-nginx` (`nginx:1.27`) publié sur le port 8080, puis passage du port à 8081, puis nettoyage.
Environnement : Docker via OrbStack, Terraform 1.17.1, provider `kreuzwerker/docker` 3.9.0.

## Comparaison

| | Terraform | À la main (`docker run`) |
|---|---|---|
| Description | 3 fichiers `.tf` versionnés : l'état voulu est écrit | Une suite de commandes ; la seule trace est l'historique du shell |
| Avant d'agir | `plan` annonce ce qui va changer (`Plan: 3 to add`) | Rien : la commande s'exécute directement |
| Ordre de création | Calculé : réseau et image en parallèle, puis le conteneur qui y fait référence | À l'opérateur de le connaître |
| Relancer sans changement | `No changes. Your infrastructure matches the configuration.` | `docker run` : `Conflict. The container name "/tp-nginx" is already in use` ; `network create` : `already exists` |
| Changer le port | `plan` : `~ external = 8080 -> 8081 # forces replacement` (1 à créer, 1 à détruire), puis `apply` détruit et recrée | Aucune commande « modifier » : il faut savoir faire `docker rm -f` puis relancer `docker run` |
| Suppression hors outil (`docker rm -f`) | `plan` détecte l'écart (`will be created`), `apply` répare | Personne ne s'en aperçoit |
| Nettoyage | `destroy` supprime les 3 ressources dans l'ordre inverse (conteneur, image, réseau) | `network rm` échoue (`has active endpoints`) si on le fait avant le conteneur ; l'image (198 Mo) reste si on oublie `docker rmi` |

## Le point inattendu : l'idempotence n'est pas automatique

Au premier essai, un second `apply` sans aucune modification a **remplacé le conteneur** (`1 added, 1 destroyed`).
Cause : le daemon Docker d'OrbStack ajoute par défaut `max-size = 20m` et `max-file = 5` aux options de logs de chaque conteneur. Terraform lit ces valeurs dans le conteneur réel, ne les trouve pas dans le code, et cet attribut force un remplacement.
Après les avoir déclarées dans `main.tf` (`log_opts`), `plan` renvoie `No changes` (code de sortie 0).

L'idempotence suppose donc que le code décrive **tout** l'état réel, y compris ce que la plateforme ajoute. Avec `docker run`, ces mêmes options sont appliquées en silence et personne ne le remarque : c'est la dérive de configuration vue en cours, invisible sans outil déclaratif.

## Conclusion

- **`docker run`** est plus direct pour un essai ponctuel, mais tout repose sur l'opérateur : l'ordre, les noms, le nettoyage, les fautes de frappe. Rien ne permet de reproduire exactement l'environnement ni de savoir s'il a dérivé.
- **Terraform** décrit l'état voulu et l'outil calcule le reste : les actions (`plan`), l'ordre (dépendances implicites), le remplacement plutôt que la modification (infrastructure immuable) et la détection de la dérive. Versionné dans Git, l'environnement devient relu, reproductible et supprimable en une commande.
- **Contreparties** : il faut connaître le comportement du provider (attributs qui forcent un remplacement, valeurs ajoutées par la plateforme) et protéger `terraform.tfstate`, qui ne doit pas être commité.
