import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from collections import defaultdict, deque
import json
import os
from pathlib import Path

class NanoSatelliteSwarm:
    """
    Classe pour analyser l'essaim de nanosatellites.
    Implémente les analyses pour les graphes valués et non-valués.
    """

    def __init__(self, csv_file, density_type):
        """Initialise l'essaim à partir d'un fichier CSV."""
        self.density_type = density_type
        self.positions = self._load_data(csv_file)
        self.n_satellites = len(self.positions)
        self.graphs = {}

    def _load_data(self, csv_file):
        """Charge les positions des satellites depuis un CSV."""
        try:
            df = pd.read_csv(csv_file)
            print(f" Données chargées: {csv_file} ({len(df)} satellites)")
            return df[['x', 'y', 'z']].values
        except FileNotFoundError:
            print(f" Erreur: {csv_file} non trouvé!")
            return np.random.randn(100, 3) * 1000
        except Exception as e:
            print(f" Erreur lors du chargement: {e}")
            return np.random.randn(100, 3) * 1000

    def build_graph(self, range_km):
        """
        Construit le graphe pour une portée donnée.
        Stocke l'adjacence, les arêtes et les distances.
        """
        graph = defaultdict(list)
        edges = []
        distances = {}

        for i in range(self.n_satellites):
            for j in range(i + 1, self.n_satellites):
                dist = np.linalg.norm(self.positions[i] - self.positions[j])
                if dist <= range_km:
                    graph[i].append(j)
                    graph[j].append(i)
                    edges.append((i, j))
                    distances[(i, j)] = dist
                    distances[(j, i)] = dist

        self.graphs[range_km] = {
            'adjacency': graph,
            'edges': edges,
            'distances': distances,
            'num_edges': len(edges)
        }
        print(f"  Portée {range_km}km: {len(edges)} arêtes")

    def visualize_graph_3d(self, range_km, save_path=None):
        """
        Génère une visualisation 3D du graphe.
        Affiche les satellites et les connexions.
        """
        if range_km not in self.graphs:
            self.build_graph(range_km)

        fig = plt.figure(figsize=(12, 10))
        ax = fig.add_subplot(111, projection='3d')

        # Afficher les nœuds
        ax.scatter(
            self.positions[:, 0],
            self.positions[:, 1],
            self.positions[:, 2],
            c='blue', s=40, alpha=0.6, label='Satellites'
        )

        # Afficher les arêtes
        for i, j in self.graphs[range_km]['edges']:
            pts = np.array([self.positions[i], self.positions[j]])
            ax.plot(pts[:, 0], pts[:, 1], pts[:, 2], color='gray', alpha=0.3)

        ax.set_title(f"Densité {self.density_type.upper()} – Portée {range_km} km\n"
                     f"({self.graphs[range_km]['num_edges']} arêtes)")
        ax.set_xlabel("X (km)")
        ax.set_ylabel("Y (km)")
        ax.set_zlabel("Z (km)")
        ax.legend()

        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            print(f"  Graphique sauvegardé: {save_path}")
        plt.close()

    def compute_degree_statistics(self, range_km):
        """Calcule les statistiques du degré des nœuds."""
        if range_km not in self.graphs:
            self.build_graph(range_km)

        graph = self.graphs[range_km]['adjacency']
        degrees = [len(graph[i]) for i in range(self.n_satellites)]

        return {
            'mean_degree': float(np.mean(degrees)),
            'std_degree': float(np.std(degrees)),
            'min_degree': int(np.min(degrees)),
            'max_degree': int(np.max(degrees)),
            'degree_distribution': degrees
        }

    def compute_clustering_coefficient(self, range_km):
        """Calcule le coefficient de clustering pour chaque nœud."""
        if range_km not in self.graphs:
            self.build_graph(range_km)

        graph = self.graphs[range_km]['adjacency']
        clustering = []

        for node in range(self.n_satellites):
            neighbors = graph[node]
            k = len(neighbors)

            if k < 2:
                clustering.append(0.0)
                continue

            # Compter les triangles
            triangles = 0
            for i in range(len(neighbors)):
                for j in range(i + 1, len(neighbors)):
                    if neighbors[j] in graph[neighbors[i]]:
                        triangles += 1

            # Formule: C = triangles / (k(k-1)/2)
            clustering.append(float(triangles / (k * (k - 1) / 2)))

        return {
            'mean_clustering': float(np.mean(clustering)),
            'std_clustering': float(np.std(clustering)),
            'min_clustering': float(np.min(clustering)),
            'max_clustering': float(np.max(clustering)),
            'clustering_distribution': clustering
        }

    def find_connected_components(self, range_km):
        """Trouve les composantes connexes du graphe (BFS)."""
        if range_km not in self.graphs:
            self.build_graph(range_km)

        graph = self.graphs[range_km]['adjacency']
        visited = set()
        components = []

        for start in range(self.n_satellites):
            if start in visited:
                continue

            queue = deque([start])
            visited.add(start)
            comp = []

            while queue:
                u = queue.popleft()
                comp.append(u)
                for v in graph[u]:
                    if v not in visited:
                        visited.add(v)
                        queue.append(v)

            components.append(comp)

        return {
            'num_components': len(components),
            'component_sizes': sorted([len(c) for c in components], reverse=True),
            'largest_component_size': max([len(c) for c in components]) if components else 0
        }

    def find_cliques_bron_kerbosch(self, range_km, min_size=3):
        """Trouve toutes les cliques de taille >= min_size (Bron-Kerbosch)."""
        if range_km not in self.graphs:
            self.build_graph(range_km)

        graph = self.graphs[range_km]['adjacency']
        cliques = []

        def bron_kerbosch(R, P, X):
            """Algorithme Bron-Kerbosch avec pivot."""
            if not P and not X:
                if len(R) >= min_size:
                    cliques.append(list(R))
                return

            pivot = max(P | X, key=lambda u: len(set(graph[u]) & P)) if P | X else None
            candidates = P - set(graph[pivot]) if pivot is not None else P.copy()

            for v in list(candidates):
                bron_kerbosch(R | {v}, P & set(graph[v]), X & set(graph[v]))
                P.remove(v)
                X.add(v)

        bron_kerbosch(set(), set(range(self.n_satellites)), set())
        clique_sizes = [len(c) for c in cliques]
        
        return {
            'num_cliques': len(cliques),
            'clique_sizes': sorted(clique_sizes, reverse=True) if clique_sizes else [],
            'max_clique_size': max(clique_sizes) if clique_sizes else 0
        }

    def compute_shortest_paths_bfs(self, range_km):
        """Calcule les plus courts chemins (en nombre de sauts) via BFS."""
        if range_km not in self.graphs:
            self.build_graph(range_km)

        graph = self.graphs[range_km]['adjacency']
        path_lengths = []

        for source in range(self.n_satellites):
            distances = {source: 0}
            queue = deque([source])

            while queue:
                u = queue.popleft()
                for v in graph[u]:
                    if v not in distances:
                        distances[v] = distances[u] + 1
                        queue.append(v)

            for t, d in distances.items():
                if t != source:
                    path_lengths.append(d)

        return {
            'mean_path_length': float(np.mean(path_lengths)) if path_lengths else 0,
            'std_path_length': float(np.std(path_lengths)) if path_lengths else 0,
            'max_path_length': int(np.max(path_lengths)) if path_lengths else 0,
            'num_connected_pairs': len(path_lengths)
        }

    def dijkstra_weighted(self, source, range_km):
        """Implémente Dijkstra pour les graphes valués (poids = distance²)."""
        if range_km not in self.graphs:
            self.build_graph(range_km)

        graph = self.graphs[range_km]['adjacency']
        weights = self.graphs[range_km]['distances']

        dist = {i: float('inf') for i in range(self.n_satellites)}
        dist[source] = 0
        visited = set()

        while len(visited) < self.n_satellites:
            u = min((n for n in dist if n not in visited), 
                   key=lambda x: dist[x], default=None)
            if u is None or dist[u] == float('inf'):
                break

            visited.add(u)
            for v in graph[u]:
                w = weights[(u, v)] ** 2  # Poids = distance²
                if dist[u] + w < dist[v]:
                    dist[v] = dist[u] + w

        return dist

    def analyze_weighted_graph(self, range_km=60):
        """Analyse le graphe valué: calcule les distances pondérées."""
        all_distances = []

        for s in range(self.n_satellites):
            dist = self.dijkstra_weighted(s, range_km)
            for t, d in dist.items():
                if t != s and d < float('inf'):
                    all_distances.append(d)

        if not all_distances:
            return {
                'mean_weighted_distance': 0,
                'std_weighted_distance': 0,
                'min_weighted_distance': 0,
                'max_weighted_distance': 0,
                'num_weighted_paths': 0
            }

        return {
            'mean_weighted_distance': float(np.mean(all_distances)),
            'std_weighted_distance': float(np.std(all_distances)),
            'min_weighted_distance': float(np.min(all_distances)),
            'max_weighted_distance': float(np.max(all_distances)),
            'num_weighted_paths': len(all_distances)
        }


def verify_csv_files(files):
    """Vérifie que tous les fichiers CSV existent."""
    print("\n Vérification des fichiers CSV:")
    all_exist = True
    for density, filename in files.items():
        if os.path.exists(filename):
            size = os.path.getsize(filename) / 1024  # KB
            print(f"  ✓ {filename} ({size:.1f} KB)")
        else:
            print(f"  ✗ {filename} - NON TROUVÉ!")
            all_exist = False
    return all_exist


def generate_comparison_report(results, output_file='analysis_report.txt'):
    """Génère un rapport texte comparatif des résultats."""
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("="*80 + "\n")
        f.write("ANALYSE COMPARÉE DES GRAPHES DE NANOSATELLITES\n")
        f.write("Projet Théorie des Graphes - 2025/2026\n")
        f.write("="*80 + "\n\n")

        # Partie 1: Graphes non valués
        f.write("PARTIE 1: GRAPHES NON VALUÉS\n")
        f.write("-"*80 + "\n\n")

        for density in ['low', 'avg', 'high']:
            f.write(f"\n{'='*80}\n")
            f.write(f"DENSITÉ: {density.upper()}\n")
            f.write(f"{'='*80}\n")

            for r in [20000, 40000, 60000]:
                range_km = r / 1000
                f.write(f"\nPortée: {range_km:.0f} km ({r} m)\n")
                f.write("-"*40 + "\n")

                # Degré
                deg = results[density][r]['degree']
                f.write(f"Degré:\n")
                f.write(f"  Moyenne: {deg['mean_degree']:.2f}\n")
                f.write(f"  Écart-type: {deg['std_degree']:.2f}\n")
                f.write(f"  Min-Max: {deg['min_degree']}-{deg['max_degree']}\n\n")

                # Clustering
                clust = results[density][r]['clustering']
                f.write(f"Coefficient de Clustering:\n")
                f.write(f"  Moyenne: {clust['mean_clustering']:.4f}\n")
                f.write(f"  Écart-type: {clust['std_clustering']:.4f}\n\n")

                # Composantes
                comp = results[density][r]['components']
                f.write(f"Composantes Connexes:\n")
                f.write(f"  Nombre: {comp['num_components']}\n")
                f.write(f"  Tailles: {comp['component_sizes']}\n\n")

                # Cliques
                cliq = results[density][r]['cliques']
                f.write(f"Cliques (min size 3):\n")
                f.write(f"  Nombre: {cliq['num_cliques']}\n")
                f.write(f"  Taille max: {cliq['max_clique_size']}\n\n")

                # Chemins
                path = results[density][r]['paths']
                f.write(f"Plus Courts Chemins:\n")
                f.write(f"  Longueur moyenne: {path['mean_path_length']:.2f} sauts\n")
                f.write(f"  Longueur max: {path['max_path_length']} sauts\n")
                f.write(f"  Paires connectées: {path['num_connected_pairs']}\n\n")

        # Partie 2: Graphes valués (60km)
        f.write("\n" + "="*80 + "\n")
        f.write("PARTIE 2: GRAPHES VALUÉS (Portée 60 km / 60000 m)\n")
        f.write("Poids des arêtes: distance²\n")
        f.write("="*80 + "\n\n")

        for density in ['low', 'avg', 'high']:
            f.write(f"\nDENSITÉ: {density.upper()}\n")
            f.write("-"*40 + "\n")
            weighted = results[density]['weighted_60']
            f.write(f"Distance pondérée moyenne: {weighted['mean_weighted_distance']:.2f}\n")
            f.write(f"Distance pondérée écart-type: {weighted['std_weighted_distance']:.2f}\n")
            f.write(f"Distance pondérée min-max: {weighted['min_weighted_distance']:.2f}-"
                   f"{weighted['max_weighted_distance']:.2f}\n")
            f.write(f"Nombre de chemins: {weighted['num_weighted_paths']}\n\n")

        # Tableau comparatif
        f.write("\n" + "="*80 + "\n")
        f.write("TABLEAU COMPARATIF SYNTHÉTIQUE (Portée 60 km / 60000 m)\n")
        f.write("="*80 + "\n\n")
        f.write(f"{'Densité':<10} {'Deg moy':<10} {'Clust':<10} {'Comp':<10} {'Cliques':<10}\n")
        f.write("-"*50 + "\n")

        for density in ['low', 'avg', 'high']:
            deg = results[density][60000]['degree']['mean_degree']
            clust = results[density][60000]['clustering']['mean_clustering']
            comp = results[density][60000]['components']['num_components']
            cliq = results[density][60000]['cliques']['num_cliques']
            f.write(f"{density:<10} {deg:<10.2f} {clust:<10.4f} {comp:<10} {cliq:<10}\n")

    print(f"✓ Rapport sauvegardé: {output_file}")


def diagnose_data(csv_file, density_type):
    """Diagnostic des données pour comprendre les distances réelles."""
    print(f"\n📋 Diagnostic: {csv_file}")
    df = pd.read_csv(csv_file)
    positions = df[['x', 'y', 'z']].values
    
    print(f"  Nombre de satellites: {len(positions)}")
    print(f"  Colonnes CSV: {df.columns.tolist()}")
    print(f"\n  Premiers satellites:")
    print(f"    {positions[0]}")
    print(f"    {positions[1]}")
    
    # Calculer quelques distances
    distances = []
    for i in range(min(10, len(positions)-1)):
        for j in range(i+1, min(10, len(positions))):
            d = np.linalg.norm(positions[i] - positions[j])
            distances.append(d)
    
    if distances:
        print(f"\n  Statistiques des distances (premiers 10 satellites):")
        print(f"    Minimum: {np.min(distances):.2f}")
        print(f"    Maximum: {np.max(distances):.2f}")
        print(f"    Moyenne: {np.mean(distances):.2f}")
        print(f"    Médiane: {np.median(distances):.2f}")
    
    return positions


def main():
    """Fonction principale : orchestration de l'analyse complète."""
    print("\n" + "="*80)
    print("ANALYSE DES NANOSATELLITES - THÉORIE DES GRAPHES")
    print("="*80)

    files = {
        'low': 'topology_low.csv',
        'avg': 'topology_avg.csv',
        'high': 'topology_high.csv'
    }

    # Vérifier les fichiers CSV
    if not verify_csv_files(files):
        print("\n  Attention: Des fichiers CSV sont manquants!")
        return

    # 🔍 DIAGNOSTIC DES DONNÉES
    for density, file in files.items():
        diagnose_data(file, density)

    # ⚠️ PORTÉES EN MÈTRES (pas en km) !
    ranges = [20000, 40000, 60000]  # 20km, 40km, 60km en mètres
    results = {}

    print("\n 📊 Analyse en cours...\n")

    for density, file in files.items():
        print(f"\nDensité {density.upper()}:")
        swarm = NanoSatelliteSwarm(file, density)
        results[density] = {}

        # Graphes non valués (3 portées)
        for r in ranges:
            range_km = r / 1000  # Conversion pour affichage
            print(f"Traitement portée {range_km:.0f} km ({r} m)...")
            swarm.build_graph(r)
            
            results[density][r] = {
                'degree': swarm.compute_degree_statistics(r),
                'clustering': swarm.compute_clustering_coefficient(r),
                'components': swarm.find_connected_components(r),
                'cliques': swarm.find_cliques_bron_kerbosch(r),
                'paths': swarm.compute_shortest_paths_bfs(r)
            }

            # Générer visualisation 3D
            swarm.visualize_graph_3d(r, f'graph_{density}_{range_km:.0f}km.png')

        # Graphe valué (60km = 60000m)
        print(f"Traitement graphe valué (60 km)...")
        results[density]['weighted_60'] = swarm.analyze_weighted_graph(60000)

    # Sauvegarder en JSON
    print("\n 💾 Sauvegarde des résultats...")
    with open('results.json', 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2)
    print(" ✓ Résultats sauvegardés: results.json")

    # Générer rapport texte
    generate_comparison_report(results)
    print(" ✓ ANALYSE COMPLÈTE TERMINÉE")
 
    print("\nFichiers générés:")
    print("  - results.json (données complètes)")
    print("  - analysis_report.txt (rapport comparatif)")
    print("  - graph_*.png (9 graphiques 3D)")
    print("\n")

    return results


if __name__ == "__main__":
    results = main()
