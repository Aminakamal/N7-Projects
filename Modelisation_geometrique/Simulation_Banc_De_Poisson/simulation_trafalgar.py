import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from mpl_toolkits.mplot3d import Axes3D

from banc_de_poisson import BancDePoissons

def run_simulation_trafalgar():
    # Paramètres initiaux
    N = 200
    L = 70.0 # zone limite
    
    banc = BancDePoissons(N, zone_limite=L)
    
    # Paramètres de simulation
    dt = 0.2
    limite_distance_trafalgar = 15.0
    
    # Configuration du plot 3D
    fig = plt.figure(figsize=(10, 8))
    ax = fig.add_subplot(111, projection='3d')
    ax.set_xlim(-L, L)
    ax.set_ylim(-L, L)
    ax.set_zlim(-L, L)
    ax.set_title("Simulation Trafalgar (Mouvement aléatoire et Propagation)")
    color_map = {'bleu': 'blue', 'rouge': 'red', 'vert': 'green'}
    
    # Initialisation du quiver (vecteurs normalisés)
    colors = [color_map[c] for c in banc.couleurs]
    q = ax.quiver(banc.positions[:, 0], banc.positions[:, 1], banc.positions[:, 2],
                  banc.vitesses[:, 0], banc.vitesses[:, 1], banc.vitesses[:, 2],
                  color=colors, length=10.0, normalize=True, arrow_length_ratio=0.0)

    def update(frame):
        nonlocal q
        
        # 1. Effet Trafalgar (Propagation d'alerte)
        if frame % 5 == 0:
            banc.effet_trafalgar(limite_distance_trafalgar)
        
        # 2. Mise à jour des positions (mouvement aléatoire sans règles d'Aoki)
        banc.mise_a_jour_positions(dt)
        
        # Mise à jour des données du graphique
        q.remove()
        colors = [color_map[c] for c in banc.couleurs]
        q = ax.quiver(banc.positions[:, 0], banc.positions[:, 1], banc.positions[:, 2],
                      banc.vitesses[:, 0], banc.vitesses[:, 1], banc.vitesses[:, 2],
                      color=colors, length=10.0, normalize=True, arrow_length_ratio=0.0)
        
        return q,

    # Création de l'animation
    anim = FuncAnimation(fig, update, frames=200, interval=50, blit=False)
    
    plt.show()

if __name__ == "__main__":
    run_simulation_trafalgar()