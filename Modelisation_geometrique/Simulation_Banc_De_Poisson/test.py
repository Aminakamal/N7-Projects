import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from mpl_toolkits.mplot3d import Axes3D

from banc_de_poisson import BancDePoissons

def run_simulation_trafalgar():
    # Paramètres initiaux
    N = 300
    L = 50.0 # zone limite
    
    banc = BancDePoissons(N, zone_limite=L)
    
    # Paramètres de simulation
    dt = 0.2
    limite_distance_trafalgar = 10.0
    
    # Configuration du plot 3D
    fig = plt.figure(figsize=(10, 8))
    ax = fig.add_subplot(111, projection='3d')
    ax.set_xlim(-L, L)
    ax.set_ylim(-L, L)
    ax.set_zlim(-L, L)
    ax.set_title("Simulation Trafalgar (Mouvement aléatoire et Propagation)")
    color_map = {'bleu': 'blue', 'rouge': 'red', 'vert': 'green'}
    
    colors = [color_map[c] for c in banc.couleurs]

    scat = ax.scatter(banc.positions[:, 0], banc.positions[:, 1], banc.positions[:, 2],
                      c=colors, s=20, marker='o', depthshade=False)

    def update(frame):
        # 1. Effet Trafalgar (Propagation d'alerte)
        if frame % 5 == 0:
            banc.effet_trafalgar(limite_distance_trafalgar)
        
        # 2. Mise à jour des positions
        banc.mise_a_jour_positions(dt)
        
        # Mise à jour des positions
        scat._offsets3d = (banc.positions[:, 0], banc.positions[:, 1], banc.positions[:, 2])
        
        # Mise à jour des couleurs
        colors = [color_map[c] for c in banc.couleurs]
        scat.set_color(colors)
        
        return scat,

    # Création de l'animation
    anim = FuncAnimation(fig, update, frames=200, interval=50, blit=False)
    
    plt.show()

if __name__ == "__main__":
    run_simulation_trafalgar()