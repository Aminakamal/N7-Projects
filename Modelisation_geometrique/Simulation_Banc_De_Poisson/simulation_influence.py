import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from mpl_toolkits.mplot3d import Axes3D

from banc_de_poisson import BancDePoissons

def run_simulation_influence():
    # Paramètres initiaux
    N = 200
    L = 50.0 # zone limite
    
    banc = BancDePoissons(N, zone_limite=L)
    
    # Paramètres de simulation
    dt = 0.5
    r_rep = 5.0
    r_ali = 15.0
    r_att = 25.0
    V_constante = 2.0
    k_rep = 0.5
    k_att = 0.05
    
    # Configuration du plot 3D
    fig = plt.figure(figsize=(10, 8))
    ax = fig.add_subplot(111, projection='3d')
    ax.set_xlim(-L, L)
    ax.set_ylim(-L, L)
    ax.set_zlim(-L, L)
    ax.set_title("Simulation Influence (Réseau Visuel 60°)")
    color_map = {'bleu': 'blue', 'rouge': 'red', 'vert': 'green'}
    
    # Initialisation du quiver (vecteurs normalisés)
    colors = [color_map[c] for c in banc.couleurs]
    q = ax.quiver(banc.positions[:, 0], banc.positions[:, 1], banc.positions[:, 2],
                  banc.vitesses[:, 0], banc.vitesses[:, 1], banc.vitesses[:, 2],
                  color=colors, length=3.0, normalize=True)

    def update(frame):
        nonlocal q
        
        # 1. Règles d'Aoki axées sur la VISION (cône de 60°)
        banc.regles_aoki_influence(r_rep, r_ali, r_att, V_constante, k_rep, k_att)
        
        # 2. Mise à jour des positions
        banc.mise_a_jour_positions(dt)
        
        # Mise à jour des données du graphique
        q.remove()
        colors = [color_map[c] for c in banc.couleurs]
        q = ax.quiver(banc.positions[:, 0], banc.positions[:, 1], banc.positions[:, 2],
                      banc.vitesses[:, 0], banc.vitesses[:, 1], banc.vitesses[:, 2],
                      color=colors, length=3.0, normalize=True)
        
        return q,

    # Création de l'animation
    anim = FuncAnimation(fig, update, frames=200, interval=50, blit=False)
    
    plt.show()

if __name__ == "__main__":
    run_simulation_influence()