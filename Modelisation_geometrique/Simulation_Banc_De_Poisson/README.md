# Simulation d'un Banc de Poissons 3D

Ce projet est une modélisation mathématique et visuelle en 3D du comportement émergent d'un banc de poissons. Il explore comment des règles de prise de décision individuelles et simples génèrent des mouvements collectifs complexes, en se basant sur l'effet Trafalgar et le modèle d'Ichiro Aoki (1982).

## Les 4 Étapes de la Simulation

Le projet est conçu de manière pédagogique pour illustrer l'évolution du réalisme biologique. Vous pouvez lancer chaque script séparément :

1. **`simulation_trafalgar.py`** *(L'Effet Trafalgar)*
   Modélise la propagation d'une alerte ou d'une panique. Un "leader" (poisson rouge) s'enfuit et déclenche une réaction en chaîne lorsqu'il s'approche d'autres poissons aléatoires (les rendant verts).

2. **`simulation_aoki.py`** *(Les Règles d'Aoki)*
   Application du modèle mathématique de base impliquant 3 forces :
   - **Répulsion** : Éviter les collisions à très courte distance.
   - **Alignement** : Nager dans le même sens que le groupe à moyenne distance.
   - **Attraction** : Se rapprocher des autres à longue distance.

3. **`simulation_densite.py`** *(Influence de la Densité)*
   Une optimisation biologique : au lieu de prendre tous les voisins dans le rayon, le calcul est restreint strictement aux **6 voisins les plus proches** via un KDTree. Les "murs" de la zone agissent ici comme ceux de Pac-Man (téléportation d'un bord à l'autre) pour un maintien du banc infini.

4. **`simulation_influence.py`** *(Le Réseau Visuel)*
   Le summum du réalisme : les poissons n'observent qu'un **cône de 60° vers l'avant**. Les individus nageant hors de ce champ de vision n'ont aucune influence sur la trajectoire mathématique.

## Prérequis et Installation

Assurez-vous d'avoir installé Python 3, ainsi que les trois bibliothèques scientifiques principales :
```bash
apt install python3-numpy
apt install python3-scipy
apt install python3-matplotlib
```

## Exécution

Pour lancer une simulation, il suffit d'exécuter un des scripts `simulation_*.py`. Par exemple :
```bash
python3 simulation_influence.py
```

## Structure du Code
- `banc_de_poisson.py` : La "boîte noire" (Classe `BancDePoissons`). Contient toute la logique mathématique, la gestion spatiale (KDTree) et le calcul des forces (les règles du bac à sable).
- `simulation_*.py` : Les scripts de rendu 3D. Ils utilisent `matplotlib.animation` pour dessiner les vecteurs dynamiques (flèches) des positions et vitesses respectives.