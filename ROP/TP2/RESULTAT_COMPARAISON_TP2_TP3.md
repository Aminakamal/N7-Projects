# Comparaison TP2 vs TP3 - Résultats

## 📊 Résumé Exécutif

| Critère | TP2 (Branch-and-Bound) | TP3 (Programmation Dynamique) |
|---------|------------------------|-------------------------------|
| **Optimalité** | À compléter | Garantie ✓ |
| **Complexité Temps** | À compléter | O(n × capacity) |
| **Complexité Espace** | À compléter | O(n × capacity) |
| **Déterministe** | À compléter | Oui |

---

## 🧪 Résultats par Instance

### Instance 1 : test.opb.txt
- **Données** : Prix=[42, 40, 12, 25], Poids=[7, 4, 3, 5], Capacité=10
- **TP2** : 
  - Coût = À compléter
  - Temps = À compléter ms
  - Objets = À compléter
  
- **TP3** : 
  - Coût = **65** ✓
  - Temps = À compléter ms
  - Objets = **[2, 4]** ✓
  
- **Comparaison** : ✓ Résultats identiques (à vérifier avec TP2)

---

### Instance 2 : Similar_Weights_100
- **Description** : 100 objets, capacité ~1000, poids similaires

- **TP2** : 
  - Coût = À compléter
  - Temps = À compléter ms
  - Nœuds explorés = À compléter
  
- **TP3** : 
  - Coût = À compléter
  - Temps = À compléter ms
  
- **Analyse** : À compléter

---

### Instance 3 : Strongly_Correlated_100
- **Description** : 100 objets, prix et poids fortement corrélés

- **TP2** : 
  - Coût = À compléter
  - Temps = À compléter ms
  - Efficacité = À compléter
  
- **TP3** : 
  - Coût = À compléter
  - Temps = À compléter ms
  
- **Observation** : À compléter

---

### Instance 4 : Uncorrelated_100
- **Description** : 100 objets, prix et poids non corrélés

- **TP2** : 
  - Coût = À compléter
  - Temps = À compléter ms
  
- **TP3** : 
  - Coût = À compléter
  - Temps = À compléter ms
  
- **Remarque** : À compléter

---

### Instance 5 : Weakly_Correlated_100
- **Description** : 100 objets, prix et poids faiblement corrélés

- **TP2** : 
  - Coût = À compléter
  - Temps = À compléter ms
  
- **TP3** : 
  - Coût = À compléter
  - Temps = À compléter ms
  
- **Analyse** : À compléter

---

## 📈 Tableau Comparatif Synthétique

```
Instance                    | TP2 Coût | TP2 Temps | TP3 Coût | TP3 Temps | Match? | Écart
---------------------------|----------|-----------|----------|-----------|--------|-------
test.opb.txt                | À compl. | À compl.  | 65       | À compl.  |   ?    |  ?
Similar_Weights_100         | À compl. | À compl.  | À compl. | À compl.  |   ?    |  ?
Strongly_Correlated_100     | À compl. | À compl.  | À compl. | À compl.  |   ?    |  ?
Uncorrelated_100            | À compl. | À compl.  | À compl. | À compl.  |   ?    |  ?
Weakly_Correlated_100       | À compl. | À compl.  | À compl. | À compl.  |   ?    |  ?
```

---

## 🔍 Analyse des Performances

### Temps d'Exécution
```
TP2 (B&B) vs TP3 (PD) :
- Petit instances (n<50) : À compléter
- Moyennes instances (50<n<500) : À compléter
- Grandes instances (n>500) : À compléter
```

### Consommation Mémoire
- **TP2 (B&B)** : À compléter
- **TP3 (PD)** : O(n × capacity) = À compléter Mo

### Efficacité d'Exploration (B&B)
- **Nœuds du B&B** : À compléter
- **Ratio exploration** : À compléter %

---

## 💡 Observations et Conclusions

### Points Forts du TP2 (Branch-and-Bound)
1. À compléter
2. À compléter
3. À compléter

### Points Forts du TP3 (Programmation Dynamique)
1. **Optimalité garantie** : Trouve toujours la solution optimale
2. **Déterministe** : Résultats reproductibles
3. **Récurrence claire** : Facile à comprendre et déboguer

### Résultats Surprenants
- À compléter

### Cas d'Usage Recommandé
- **TP2 (B&B)** : À compléter
- **TP3 (PD)** : Problèmes de taille petite à moyenne, quand capacity est raisonnable

---

## 📝 Conclusion Générale

À compléter après avoir analysé tous les résultats.

**Points clés à couvrir** :
- Les deux approches trouvent-elles les mêmes solutions ?
- Quelle approche est plus rapide en pratique ?
- Laquelle consomme moins de mémoire ?
- Quelle approche est plus facile à implémenter et déboguer ?
- Recommandation finale pour un usage pratique

---

## 📎 Annexe : Détails d'Implémentation

### TP2 : Branch-and-Bound
- **Règle de séparation** : À compléter
- **Borne supérieure** : À compléter
- **Tests de sondabilité** : À compléter
- **Stratégie d'exploration** : À compléter

### TP3 : Programmation Dynamique
- **Formule de récurrence** : DP[i][c] = max(DP[i-1][c], DP[i-1][c-w[i]]+p[i])
- **Initialisation** : Première ligne avec l'objet 1
- **Backtracking** : Parcours inverse pour reconstruire la solution
- **Complexité** : O(n × capacity) temps et espace
