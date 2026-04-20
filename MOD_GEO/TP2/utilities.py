
from math import *
import random as rd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from matplotlib.animation import FuncAnimation
import ipywidgets as widgets
from IPython.display import display
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from IPython.display import clear_output
from tqdm import tqdm
from interpolation import * #Chec
import time
from scipy import stats
from ipywidgets import interact, IntSlider
import ipywidgets as widgets
import traceback 



   
def normalize_to_0_1(values: List[float]) -> List[float]:
    """
    Le but : Normaliser les valeurs entre 0 et 1.
    
    Entrée :
    - values (List[float]) : Liste de valeurs à normaliser.
    
    Sortie :
    - List[float] : Liste de valeurs normalisées.
    """
    try :
        min_val = min(values)  # Valeur minimale
        max_val = max(values)  # Valeur maximale
        normalized_values = [(val - min_val) / (max_val - min_val) for val in values]  # Normalisation
        return normalized_values  # Retourne les valeurs normalisées
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")


def generate_points(nb_pts):
    """
    Le but : Générer des points aléatoires dans un plan.
    
    Entrée :
    - nb_pts (int) : Nombre de points à générer.
    
    Sortie :
    - Tuple (List[float], List[float]) : Listes des abscisses et ordonnées des points.
    """
    try :

        X = [rd.uniform(0, 9) for _ in range(nb_pts)]  # Génération des abscisses
        Y = [rd.uniform(0, 9) for _ in range(nb_pts)]  # Génération des ordonnées
        return X, Y  # Retourne les points générés
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")

def generer_points_2(n):
    """
    Le but : Générer des points avec des abscisses dans des intervalles spécifiques.
    
    Entrée :
    - n (int) : Nombre de points à générer.
    
    Sortie :
    - Tuple (List[float], List[float]) : Listes des abscisses et ordonnées des points.
    """
    try : 
        XX = [rd.uniform(i, i + 1) for i in range(n)]  # Abscisses par intervalle
        YY = [rd.uniform(0, 9) for _ in range(n)]  # Génération des ordonnées
        return XX, YY  # Retourne les points générés
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")


def generate_torus(R, r, num_u, num_v):
    """
    Le but : Générer des points pour un tore.
    
    Entrée :
    - R (float) : Rayon majeur du tore.
    - r (float) : Rayon mineur du tore.
    - num_u (int) : Nombre de divisions pour l'angle u.
    - num_v (int) : Nombre de divisions pour l'angle v.
    
    Sortie :
    - Tuple (np.ndarray, np.ndarray, np.ndarray) : Coordonnées X, Y, Z du tore.
    """
    try :
        u = np.linspace(0, 2 * np.pi, num_u)  # Paramètre u
        v = np.linspace(0, 2 * np.pi, num_v)  # Paramètre v
        u, v = np.meshgrid(u, v)  # Grille de u et v
        X = (R + r * np.cos(v)) * np.cos(u)  # Coordonnée X
        Y = (R + r * np.cos(v)) * np.sin(u)  # Coordonnée Y
        Z = r * np.sin(v)  # Coordonnée Z
        return X, Y, Z  # Retourne les coordonnées du tore
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")


def generate_random_grid(n1, n2, m, k, sg):
    """
    Le but : Générer une grille aléatoire avec bruit.
    
    Entrée :
    - n1 (int) : Nombre de points en X.
    - n2 (int) : Nombre de points en Y.
    - m (float) : Limite des coordonnées.
    - k (float) : Amplitude du bruit.
    - sg (float) : Écart-type du bruit.
    
    Sortie :
    - Tuple (np.ndarray, np.ndarray, np.ndarray) : Coordonnées XX, YY, ZZ de la grille.
    """
    try :
        XX, YY = np.meshgrid(np.linspace(-m, m, n2), np.linspace(-m, m, n1))  # Grille XY
        ZZ = np.ones((n1, n2))  # Grille initiale ZZ
        bruit = k * np.random.normal(0, sg, (n1, n2))  # Bruit
        ZZ += bruit  # Ajout du bruit
        return XX, YY, ZZ  # Retourne la grille avec bruit
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")


def generer_points_montagne(n1, n2, m, k):
    """
    Le but : Générer une surface simulant une montagne.
    
    Entrée :
    - n1 (int) : Nombre de points en X.
    - n2 (int) : Nombre de points en Y.
    - m (float) : Limite des coordonnées.
    - k (int) : Nombre de sommets à générer.
    
    Sortie :
    - Tuple (np.ndarray, np.ndarray, np.ndarray) : Coordonnées XX, YY, ZZ de la montagne.
    """
    try : 
        XX, YY = np.meshgrid(np.linspace(-m, m, n2), np.linspace(-m, m, n1))  # Grille XY
        ZZ = np.zeros((n1, n2))  # Grille initiale ZZ
        for _ in range(k):  # Génération des sommets
            A = np.random.uniform(5, 10)  # Amplitude
            mu_x, mu_y = np.random.uniform(-m, m, 2)  # Centre du sommet
            sigma = np.random.uniform(1, 3)  # Écart-type
            ZZ += A * np.exp(-((XX - mu_x)**2 + (YY - mu_y)**2) / (2 * sigma**2))  # Ajout du sommet
        return XX, YY, ZZ  # Retourne la surface de la montagne
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")

def generer_surface_pringles(n1, n2, m, a, b):
    """
    Le but : Générer une surface en forme de pringles.
    
    Entrée :
    - n1 (int) : Nombre de points en X.
    - n2 (int) : Nombre de points en Y.
    - m (float) : Limite des coordonnées.
    - a (float) : Coefficient pour XX.
    - b (float) : Coefficient pour YY.
    
    Sortie :
    - Tuple (np.ndarray, np.ndarray, np.ndarray) : Coordonnées XX, YY, ZZ de la surface.
    """
    try : 
        XX, YY = np.meshgrid(np.linspace(-m, m, n2), np.linspace(-m, m, n1))  # Grille XY
        ZZ = a * (XX**2) - b * (YY**2)  # Calcul de ZZ
        return XX, YY, ZZ  # Retourne la surface
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")

def diamond_square(size, scale):
    """
    Le but : Générer une surface fractale utilisant l'algorithme Diamond-Square.
    
    Entrée :
    - size (int) : Taille de la grille (doit être une puissance de 2).
    - scale (float) : Échelle pour l'amplitude des variations.

    Sortie :
    - np.ndarray : Grille 2D représentant la surface fractale.
    """
    try : 
        def diamond_step(arr, x, y, size, offset):
            # Étape Diamond : Moyenne des coins avec ajout de bruit
            half = size // 2  # Moitié de la taille
            avg = (arr[x, y] + arr[x + size, y] + arr[x, y + size] + arr[x + size, y + size]) / 4.0  # Moyenne des coins
            arr[x + half, y + half] = avg + np.random.uniform(-offset, offset)  # Ajout du bruit

        def square_step(arr, x, y, size, offset):
            # Étape Square : Moyenne des voisins avec ajout de bruit
            half = size // 2  # Moitié de la taille
            avg = 0
            count = 0
            if x - half >= 0:
                avg += arr[x - half, y]
                count += 1
            if x + half < arr.shape[0]:
                avg += arr[x + half, y]
                count += 1
            if y - half >= 0:
                avg += arr[x, y - half]
                count += 1
            if y + half < arr.shape[1]:
                avg += arr[x, y + half]
                count += 1
            avg /= count  # Moyenne des voisins
            arr[x, y] = avg + np.random.uniform(-offset, offset)  # Ajout du bruit

        arr = np.zeros((size + 1, size + 1))  # Initialisation de la grille
        arr[0, 0] = np.random.uniform(-scale, scale)  # Coin supérieur gauche
        arr[0, size] = np.random.uniform(-scale, scale)  # Coin supérieur droit
        arr[size, 0] = np.random.uniform(-scale, scale)  # Coin inférieur gauche
        arr[size, size] = np.random.uniform(-scale, scale)  # Coin inférieur droit
        
        step_size = size  # Taille de l'étape initiale
        offset = scale  # Offset initial
        
        while step_size > 1:
            half_step = step_size // 2
            
            # Exécution de l'étape Diamond
            for x in range(0, size, step_size):
                for y in range(0, size, step_size):
                    diamond_step(arr, x, y, step_size, offset)
            
            # Exécution de l'étape Square
            for x in range(0, size + 1, half_step):
                for y in range((x + half_step) % step_size, size + 1, step_size):
                    if y < size + 1 and x < size + 1:
                        square_step(arr, x, y, step_size, offset)
            
            step_size //= 2  # Réduction de la taille de l'étape
            offset /= 2.0  # Réduction de l'offset
        
        return arr  # Retourne la grille fractale
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")

def generer_points_fractale(n, m, scale):
    """
    Le but : Générer des points pour une surface fractale.
    
    Entrée :
    - n (int) : Puissance de 2 pour la taille de la grille.
    - m (float) : Limite des coordonnées.
    - scale (float) : Échelle pour l'amplitude des variations.

    Sortie :
    - Tuple (np.ndarray, np.ndarray, np.ndarray) : Coordonnées XX, YY, ZZ de la surface fractale.
    """
    try : 
        size = 2**n  # Taille de la grille
        fractal = diamond_square(size, scale)  # Génération de la surface fractale
        XX, YY = np.meshgrid(np.linspace(-m, m, size + 1), np.linspace(-m, m, size + 1))  # Grille XY
        ZZ = fractal  # Grille Z (surface fractale)
        return XX, YY, ZZ  # Retourne les coordonnées de la surface
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")



def graph_interface():
    """
    Le but : Créer une interface graphique pour tracer une interpolation de Lagrange avec des points générés aléatoirement.
    
    Entrées : Aucune.
    
    Sorties : Aucune (affiche l'interface graphique).
    """
    try :
        def plot_graph(button):
            # Effacer le graphique
            ax.clear()

            try:
                nb_pts = int(nb_points.value)  # Récupérer le nombre de points
            except ValueError:
                display(widgets.HTML('<p style="color:red;">Please enter a valid number of points.</p>'))
                return
            
            X, Y = generate_points(nb_pts)  # Générer les points

            # Tracer les points
            sns.scatterplot(x=X, y=Y, ax=ax, color='red', s=100, marker='o')
            
            x_int = np.linspace(min(X), max(X), 800)  # Générer les abscisses pour l'interpolation
            y_int = [lagrange(Y, X, xi) for xi in x_int]  # Calculer les ordonnées interpolées
            
            # Calculer les distances aux points les plus proches
            distances = [min([np.sqrt((xi - xj)**2 + (yi - yj)**2) for xj, yj in zip(X, Y)]) for xi, yi in zip(x_int, y_int)]
            colors = distance_color(distances)  # Obtenir les couleurs basées sur les distances
            
            # Tracer l'interpolation avec des couleurs
            for i in range(len(x_int) - 1):
                ax.plot(x_int[i:i+2], y_int[i:i+2], color=colors[i], linewidth=2)

            # Mettre à jour la barre de couleurs
            sm.set_array(distances)
            sm.set_clim(vmin=min(distances), vmax=max(distances))

            ax.set_title("Lagrange's interpolation")  # Titre du graphique
            ax.set_xlabel("X")  # Label X
            ax.set_ylabel("Y")  # Label Y
            fig.canvas.draw()  # Dessiner le graphique
        
        def close_window(button):
            plt.close('all')  # Fermer toutes les fenêtres matplotlib
        
        def distance_color(distances):
            # Générer les couleurs en fonction des distances
            max_dist = 30
            min_dist = min(distances)
            norm = plt.Normalize(min_dist, max_dist)
            return plt.cm.cividis(norm(distances))

        # Création des widgets pour l'interface
        point_choice = widgets.RadioButtons(
            options=['Random points'],
        )
        nb_points = widgets.IntText(
            value=5,
            description='Number of points:'
        )
        plot_button = widgets.Button(description="Trace")
        plot_button.on_click(plot_graph)
        close_button = widgets.Button(description="Close")
        close_button.on_click(close_window)
        
        # Afficher les widgets
        display(widgets.VBox([point_choice, nb_points, plot_button, close_button]))
        
        global fig, ax, sm
        fig, ax = plt.subplots()  # Créer une figure et des axes matplotlib
        sm = plt.cm.ScalarMappable(cmap=plt.cm.cividis)  # Créer une barre de couleur
        sm.set_array([])
        fig.colorbar(sm, ax=ax, orientation='vertical', label='Distance of the closest neighbor')
        fig.canvas.toolbar_visible = True  # Afficher la barre d'outils
        fig.canvas.colorbar_visible = True  # Afficher la barre de couleur
        plt.show()  # Afficher le graphique
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")






def calculate_interpolations(deb, fin, pas):
    """
    Le but : Calculer les interpolations de Lagrange et de Neville pour des valeurs de n données.
    
    Entrées :
    - deb (int) : Début de la plage des valeurs de n.
    - fin (int) : Fin de la plage des valeurs de n.
    - pas (int) : Pas entre les valeurs de n.

    Sorties :
    - lagrange_results (dict) : Résultats des interpolations de Lagrange pour chaque n.
    - neville_results (dict) : Résultats des interpolations de Neville pour chaque n.
    """
    try : 
        n_values = range(deb, fin, pas)  # Plage des valeurs de n
        lagrange_results = {}  # Dictionnaire pour les résultats de Lagrange
        neville_results = {}  # Dictionnaire pour les résultats de Neville
        
        total_work = sum(n**2 for n in n_values)  # Travail total estimé
        
        # Barre de progression
        with tqdm(total=total_work, desc="Computing interpolations", unit="work units") as pbar:
            for n in n_values:
                XX = np.sort(np.random.rand(n))  # Génération des abscisses aléatoires
                YY = np.random.rand(n)  # Génération des ordonnées aléatoires
        
                t_eval = np.linspace(0, 1, 300)  # Points d'évaluation
                
                lagrange_vals = np.array([lagrange(YY, XX, t) for t in t_eval])  # Interpolation de Lagrange
                neville_vals = np.array([neville(YY, XX, t) for t in t_eval])  # Interpolation de Neville
                
                lagrange_results[n] = (XX, YY, t_eval, lagrange_vals)  # Stockage des résultats de Lagrange
                neville_results[n] = (XX, YY, t_eval, neville_vals)  # Stockage des résultats de Neville

                pbar.update(n**2)  # Mise à jour de la barre de progression
        
        return lagrange_results, neville_results  # Retourne les résultats
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")



def estimate_line(n_values, times):
    """
    Le but : Estimer une ligne de régression linéaire.
    
    Entrées :
    - n_values (List[int]) : Liste des valeurs de n.
    - times (List[float]) : Liste des temps correspondants pour chaque n.

    Sorties :
    - slope (float) : Pente de la ligne de régression.
    - intercept (float) : Ordonnée à l'origine de la ligne de régression.
    """
    try : 
        slope, intercept, _, _, _ = stats.linregress(n_values, times)  # Régression linéaire
        return slope, intercept  # Retourne la pente et l'ordonnée à l'origine
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")

def extrapolate(slope, intercept, max_n):
    """
    Le but : Extrapoler les temps pour des valeurs de n supérieures.
    
    Entrées :
    - slope (float) : Pente de la ligne de régression.
    - intercept (float) : Ordonnée à l'origine de la ligne de régression.
    - max_n (int) : Valeur maximale de n pour l'extrapolation.

    Sorties :
    - extrapolated_n_values (np.ndarray) : Valeurs extrapolatedes de n.
    - extrapolated_times (np.ndarray) : Temps extrapolateds pour chaque valeur de n.
    """
    try : 
        extrapolated_n_values = np.linspace(0, max_n * 2.5, 100)  # Génération des valeurs de n extrapolatedes
        extrapolated_times = slope * extrapolated_n_values + intercept  # Calcul des temps extrapolateds
        return extrapolated_n_values, extrapolated_times  # Retourne les valeurs extrapolatedes
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")

def compare_interpolation_times(nb_pts, deb, fin, pas):
    """
    Le but : Comparer les temps de calcul des interpolations de Lagrange et de Neville pour différentes valeurs de n.
    
    Entrées :
    - nb_pts (int) : Nombre de points pour générer les données.
    - deb (int) : Valeur de départ de n.
    - fin (int) : Valeur de fin de n.
    - pas (int) : Pas entre les valeurs de n.

    Sorties : Aucune (affiche un graphique comparatif).
    """
    try : 
        n_values = range(deb, fin + 1, pas)  # Plage des valeurs de n
        lagrange_times = []  # Liste pour les temps de Lagrange
        neville_times = []  # Liste pour les temps de Neville
        
        XX = np.linspace(0, 1, nb_pts)  # Abscisses des points
        YY = np.random.rand(nb_pts)  # Ordonnées des points
        
        total_iterations = len(n_values)  # Nombre total d'itérations
        
        for n in tqdm(n_values, desc="Calcul des différences", total=total_iterations):
            evaluation_points = np.random.rand(n)  # Points d'évaluation aléatoires
            
            start_time = time.time()  # Temps de début pour Lagrange
            _ = [lagrange(YY, XX, t) for t in evaluation_points]
            lagrange_times.append(time.time() - start_time)  # Temps de calcul pour Lagrange
            
            start_time = time.time()  # Temps de début pour Neville
            _ = [neville(YY, XX, t) for t in evaluation_points]
            neville_times.append(time.time() - start_time)  # Temps de calcul pour Neville
        
        differences = np.array(lagrange_times) - np.array(neville_times)  # Difference de temps
        
        # Estimation des lignes de régression pour les temps de Lagrange et Neville, et leurs différences
        lagrange_slope, lagrange_intercept = estimate_line(list(n_values), lagrange_times)
        neville_slope, neville_intercept = estimate_line(list(n_values), neville_times)
        diff_slope, diff_intercept = estimate_line(list(n_values), differences)
        
        max_n = max(n_values)  # Valeur maximale de n
        
        # Extrapolation des valeurs de n et des temps de calcul
        extra_lagrange_n_values, extra_lagrange_times = extrapolate(lagrange_slope, lagrange_intercept, max_n)
        extra_neville_n_values, extra_neville_times = extrapolate(neville_slope, neville_intercept, max_n)
        extra_diff_n_values, extra_diff_times = extrapolate(diff_slope, diff_intercept, max_n)
        
        plt.figure(figsize=(12, 12))
        
        # Premier sous-graphe : comparaison des temps de calcul
        plt.subplot(2, 1, 1)
        plt.plot(n_values, lagrange_times, label='Lagrange (real)', marker='x', linestyle='-', color='blue', markersize=3)
        plt.plot(extra_lagrange_n_values, extra_lagrange_times, label='Lagrange (extrapolated)', linestyle='-', color='blue', alpha=0.5)
        plt.plot(n_values, neville_times, label='Neville (real)', marker='x', linestyle='--', color='orange', markersize=3)
        plt.plot(extra_neville_n_values, extra_neville_times, label='Neville (extrapolated)', linestyle='--', color='orange', alpha=0.5)
        plt.xlabel('Number of evaluation points')
        plt.ylabel('Computing time (sec)')
        plt.title('Comparison of the computing times between Lagrange and Neville interpolation')
        plt.legend()
        plt.grid(True, which="both", ls="--")
        
        # Deuxième sous-graphe : Difference des temps de calcul
        plt.subplot(2, 1, 2)
        plt.plot(n_values, differences, label='Difference (real)', color='green', markersize=3)
        plt.plot(extra_diff_n_values, extra_diff_times, label='Difference (extrapolated)', color='green', alpha=0.5)
        plt.xlabel('Number of evaluation points')
        plt.ylabel('Time difference (sec)')
        plt.title('Difference of the computing times of Lagrange and Neville')
        plt.legend()
        plt.grid(True, which="both", ls="--")
        
        plt.tight_layout()  # Ajustement de la mise en page
        plt.show()  # Afficher le graphique
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")

def estimate_quadratic(n_values, times):
    """
    Le but : Estimer les coefficients d'une régression quadratique.
    
    Entrées :
    - n_values (List[int]) : Liste des valeurs de n.
    - times (List[float]) : Liste des temps correspondants pour chaque n.

    Sortie :
    - coeffs (np.ndarray) : Coefficients de la régression quadratique.
    """
    try :
        coeffs = np.polyfit(n_values, times, 2)  # Régression quadratique
        return coeffs  # Retourne les coefficients
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")

def extrapolate_quadratic(coeffs, max_n):
    """
    Le but : Extrapoler les temps de calcul en utilisant une régression quadratique.
    
    Entrées :
    - coeffs (np.ndarray) : Coefficients de la régression quadratique.
    - max_n (int) : Valeur maximale de n pour l'extrapolation.

    Sorties :
    - extrapolated_n_values (np.ndarray) : Valeurs extrapolatedes de n.
    - extrapolated_times (np.ndarray) : Temps extrapolateds pour chaque valeur de n.
    """
    try : 
        a, b, c = coeffs  # Extraction des coefficients
        extrapolated_n_values = np.linspace(0, max_n * 2.5, 100)  # Génération des valeurs de n extrapolatedes
        extrapolated_times = a * extrapolated_n_values**2 + b * extrapolated_n_values + c  # Calcul des temps extrapolateds
        return extrapolated_n_values, extrapolated_times  # Retourne les valeurs extrapolatedes
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")

def compare_interpolation_times_2(fixed_evaluation_points, deb, fin, pas):
    """
    Le but : Comparer les temps de calcul des interpolations de Lagrange et de Neville pour différentes valeurs de n avec un nombre fixe de points d'évaluation.
    
    Entrées :
    - fixed_evaluation_points (int) : Nombre fixe de points d'évaluation.
    - deb (int) : Valeur de départ de n.
    - fin (int) : Valeur de fin de n.
    - pas (int) : Pas entre les valeurs de n.

    Sorties : Aucune (affiche un graphique comparatif).
    """
    try : 
        n_values = range(deb, fin + 1, pas)  # Plage des valeurs de n
        lagrange_times = []  # Liste pour les temps de Lagrange
        neville_times = []  # Liste pour les temps de Neville
        
        evaluation_points = np.random.rand(fixed_evaluation_points)  # Points d'évaluation aléatoires
        
        total_iterations = len(n_values)  # Nombre total d'itérations
        
        for n in tqdm(n_values, desc="Computing differences", total=total_iterations):
            XX = np.linspace(0, 1, n)  # Abscisses des points
            YY = np.random.rand(n)  # Ordonnées des points
            
            start_time = time.time()  # Temps de début pour Lagrange
            _ = [lagrange(YY, XX, t) for t in evaluation_points]
            lagrange_times.append(time.time() - start_time)  # Temps de calcul pour Lagrange
            
            start_time = time.time()  # Temps de début pour Neville
            _ = [neville(YY, XX, t) for t in evaluation_points]
            neville_times.append(time.time() - start_time)  # Temps de calcul pour Neville
        
        differences = np.array(lagrange_times) - np.array(neville_times)  # Difference de temps
        
        # Estimation des coefficients quadratiques pour les temps de Lagrange et Neville, et leurs différences
        lagrange_coeffs = estimate_quadratic(list(n_values), lagrange_times)
        neville_coeffs = estimate_quadratic(list(n_values), neville_times)
        diff_coeffs = estimate_quadratic(list(n_values), differences)
        
        max_n = fin  # Valeur maximale de n
        
        # Extrapolation des valeurs de n et des temps de calcul
        extra_lagrange_n_values, extra_lagrange_times = extrapolate_quadratic(lagrange_coeffs, max_n)
        extra_neville_n_values, extra_neville_times = extrapolate_quadratic(neville_coeffs, max_n)
        extra_diff_n_values, extra_diff_times = extrapolate_quadratic(diff_coeffs, max_n)
        
        plt.figure(figsize=(12, 12))
        
        # Premier sous-graphe : comparaison des temps de calcul
        plt.subplot(2, 1, 1)
        plt.plot(n_values, lagrange_times, label='Lagrange (real)', marker='x', linestyle='-', color='blue', markersize=3)
        plt.plot(extra_lagrange_n_values, extra_lagrange_times, label='Lagrange (extrapolated)', linestyle='-', color='blue', alpha=0.5)
        plt.plot(n_values, neville_times, label='Neville (real)', marker='x', linestyle='--', color='orange', markersize=3)
        plt.plot(extra_neville_n_values, extra_neville_times, label='Neville (extrapolated)', linestyle='--', color='orange', alpha=0.5)
        plt.xlabel('Number of control points')
        plt.ylabel('Computing time (sec)') 
        plt.title('Comparison of the computing times between Lagrange and Neville interpolation')
        plt.legend()
        plt.grid(True, which="both", ls="--")

        # Deuxième sous-graphe : Difference des temps de calcul
        plt.subplot(2, 1, 2)
        plt.plot(n_values, differences, label='Difference (real)', color='green', markersize=3)
        plt.plot(extra_diff_n_values, extra_diff_times, label='Difference (extrapolated)', color='green', alpha=0.5)
        plt.xlabel('Number of control points')
        plt.ylabel('Time difference (sec)')
        plt.title('Difference of the computing times of Lagrange and Neville')
        plt.legend()
        plt.grid(True, which="both", ls="--")

        plt.tight_layout()  # Ajustement de la mise en page
        plt.show()  # Afficher le graphique
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")


def plot_interpolation_differences(deb, fin, pas):
    """
    Le but : Tracer la Difference entre l'interpolation de Neville et les points de contrôle.
    
    Entrées :
    - deb (int) : Valeur de départ de n.
    - fin (int) : Valeur de fin de n.
    - pas (int) : Pas entre les valeurs de n.

    Sorties : Aucune (affiche un graphique).
    """
    try :
        n_values = range(deb, fin, pas)  # Plage des valeurs de n
        sum_neville_control_diff = []  # Liste pour les sommes des différences

        total_weight = sum(n**2 for n in n_values)  # Poids total pour la barre de progression

        # Barre de progression
        with tqdm(total=total_weight, desc="Calcul des différences") as pbar:
            for n in n_values:
                XX = np.sort(np.random.rand(n))  # Génération des abscisses aléatoires triées
                YY = np.random.rand(n)  # Génération des ordonnées aléatoires
                
                # Calcul des différences absolues entre l'interpolation de Neville et les points de contrôle
                neville_control_diff = np.abs([neville(YY, XX, x) - y for x, y in zip(XX, YY)])
                
                # Somme des différences
                sum_neville_control_diff.append(np.sum(neville_control_diff))
                
                pbar.update(n**2)  # Mise à jour de la barre de progression
            
        sum_neville_control_diff = np.log10(sum_neville_control_diff)  # Conversion en échelle logarithmique
        plt.figure(figsize=(12, 6))  # Taille de la figure
        plt.plot(list(n_values), sum_neville_control_diff, marker='x', linestyle='-', label='Neville')  # Tracé de la courbe
        plt.xlabel('Number of control points')  # Label de l'axe X
        plt.ylabel('Sum of differences (log10)')  # Label de l'axe Y
        plt.title('Sum of differences between the interpolations and the control point (log10)')  # Titre
        plt.legend()  # Légende
        plt.grid(True)  # Grille
        plt.show()  # Afficher le graphique
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")


def test_tchebycheff_parametrisation():
    """
    Le but : Tester la fonction `tchebycheff_parametrisation` pour des valeurs de nb_point de 0 à 9 en comparant les résultats obtenus avec des résultats attendus.
    
    Entrées : Aucune.
    
    Sorties : Aucune (affiche les résultats des tests).
    """
    try : 
        expected_results = [
            [],
            [6.123233995736766e-17],
            [0.7071067811865476, -0.7071067811865475],
            [0.8660254037844387, 6.123233995736766e-17, -0.8660254037844387],
            [0.9238795325112867, 0.38268343236508984, -0.3826834323650897, -0.9238795325112867],
            [0.9510565162951535, 0.5877852522924731, 6.123233995736766e-17, -0.587785252292473, -0.9510565162951535],
            [0.9659258262890683, 0.7071067811865476, 0.25881904510252074, -0.25881904510252063, -0.7071067811865475, -0.9659258262890682],
            [0.9749279121818236, 0.7818314824680298, 0.4338837391175582, 6.123233995736766e-17, -0.43388373911755806, -0.7818314824680295, -0.9749279121818237],
            [0.9807852804032304, 0.8314696123025452, 0.5555702330196023, 0.19509032201612833, -0.1950903220161282, -0.555570233019602, -0.8314696123025453, -0.9807852804032304],
            [0.984807753012208, 0.8660254037844387, 0.6427876096865394, 0.3420201433256688, 6.123233995736766e-17, -0.3420201433256685, -0.6427876096865394, -0.8660254037844385, -0.984807753012208]
        ]
        
        tolerance = 1e-6  # Tolérance pour la comparaison des résultats
        
        for nb_point in range(10):
            result = tchebycheff_parametrisation(nb_point)  # Résultat de la fonction à tester
            expected = expected_results[nb_point]  # Résultat attendu
            
            if len(result) != len(expected):
                print(f"KO pour nb_point = {nb_point}: Longueur différente. Résultat = {result}, Attendu = {expected}")
                continue
            
            error_found = False
            for r, e in zip(result, expected):
                if abs(r - e) > tolerance:
                    error_found = True  # Erreur trouvée
                    break
            
            if error_found:
                print(f"KO pour nb_point = {nb_point}: Résultat = {result}, Attendu = {expected}")
            else:
                print(f"OK pour nb_point = {nb_point}")  # Test réussi
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")





def test_parametrisations():
    """
    Le but : Tester différentes méthodes de paramétrisation pour divers ensembles de points.
    
    Entrées : Aucune.
    
    Sorties : Aucune (affiche les résultats des tests).
    """
    # Cas de test avec différentes valeurs de XX et YY
    try : 
        XX1 = [0, 0, 1, 1, 100]
        YY1 = [0, 0.001, 1, 100, 0]
        
        XX2 = [1, 2, 3, 4, 5, 6]
        YY2 = [1, 2, 3, 4, 5, 6]
        
        XX3 = [0, 0, 0, 0, 0, 0, 0, 0]
        YY3 = [0, 1, 2, 3, 4, 5, 6, 7]
        
        XX4 = [100000, 0, 0, 0, 0, -100000000, 0, 0]
        YY4 = [0, -21, 2, 3, 4, 5, 6, 7]
        
        XX5 = [i**2 for i in range(100)]
        YY5 = [np.sin(x) for x in XX5]
        
        # Liste des cas de test
        test_cases = [
            (XX1, YY1, [0.0, 0.25, 0.5, 0.75, 1.0], [0.0, 4.147131384351938e-06, 0.005866144848836501, 0.41643215189967836, 1.0], [0.0, 0.0013729462493527144, 0.05299109921963316, 0.48497855153457814, 1.0]),
            (XX2, YY2, [0.0, 0.2, 0.4, 0.6000000000000001, 0.8, 1.0], [0.0, 0.2, 0.4, 0.6000000000000001, 0.8, 1.0], [0.0, 0.2, 0.4, 0.6000000000000001, 0.8, 1.0]),
            (XX3, YY3, [0.0, 0.14285714285714285, 0.2857142857142857, 0.42857142857142855, 0.5714285714285714, 0.7142857142857142, 0.8571428571428571, 1.0], [0.0, 0.14285714285714285, 0.2857142857142857, 0.42857142857142855, 0.5714285714285714, 0.7142857142857143, 0.8571428571428571, 1.0], [0.0, 0.14285714285714285, 0.2857142857142857, 0.42857142857142855, 0.5714285714285714, 0.7142857142857143, 0.8571428571428571, 1.0]),
            (XX4, YY4, [0.0, 0.14285714285714285, 0.2857142857142857, 0.42857142857142855, 0.5714285714285714, 0.7142857142857142, 0.8571428571428571, 1.0], [0.0, 0.0004997500710164726, 0.000499865013530272, 0.000499870011030872, 0.000499875008531472, 0.5002499350055154, 0.9999999950024994, 1.0], [0.0, 0.015559309303659558, 0.01579527790994825, 0.015844480765624402, 0.01589368362130055, 0.5079222403828122, 0.9999507971443239, 1.0]),
            (XX5, YY5, [0.0, 0.010101010101010102, 0.020202020202020204, 0.030303030303030304, 0.04040404040404041, 0.05050505050505051, 0.06060606060606061, 0.07070707070707072, 0.08080808080808081, 0.09090909090909091, 0.10101010101010102, 0.11111111111111112, 0.12121212121212122, 0.13131313131313133, 0.14141414141414144, 0.15151515151515152, 0.16161616161616163, 0.17171717171717174, 0.18181818181818182, 0.19191919191919193, 0.20202020202020204, 0.21212121212121213, 0.22222222222222224, 0.23232323232323235, 0.24242424242424243, 0.25252525252525254, 0.26262626262626265, 0.27272727272727276, 0.2828282828282829, 0.29292929292929293, 0.30303030303030304, 0.31313131313131315, 0.32323232323232326, 0.33333333333333337, 0.3434343434343435, 0.3535353535353536, 0.36363636363636365, 0.37373737373737376, 0.38383838383838387, 0.393939393939394, 0.4040404040404041, 0.4141414141414142, 0.42424242424242425, 0.43434343434343436, 0.4444444444444445, 0.4545454545454546, 0.4646464646464647, 0.4747474747474748, 0.48484848484848486, 0.494949494949495, 0.5050505050505051, 0.5151515151515152, 0.5252525252525253, 0.5353535353535354, 0.5454545454545455, 0.5555555555555556, 0.5656565656565657, 0.5757575757575758, 0.5858585858585859, 0.595959595959596, 0.6060606060606061, 0.6161616161616162, 0.6262626262626263, 0.6363636363636365, 0.6464646464646465, 0.6565656565656566, 0.6666666666666667, 0.6767676767676768, 0.686868686868687, 0.696969696969697, 0.7070707070707072, 0.7171717171717172, 0.7272727272727273, 0.7373737373737375, 0.7474747474747475, 0.7575757575757577, 0.7676767676767677, 0.7777777777777778, 0.787878787878788, 0.797979797979798, 0.8080808080808082, 0.8181818181818182, 0.8282828282828284, 0.8383838383838385, 0.8484848484848485, 0.8585858585858587, 0.8686868686868687, 0.8787878787878789, 0.888888888888889, 0.8989898989898991, 0.9090909090909092, 0.9191919191919192, 0.9292929292929294, 0.9393939393939394, 0.9494949494949496, 0.9595959595959597, 0.9696969696969697, 0.9797979797979799, 0.98989898989899, 1.0], [0.0, 0.00013332251929889597, 0.000480079658888771, 0.0010038916875952722, 0.0017215357656031733, 0.0026397787321553526, 0.003765327774389769, 0.005091486340296431, 0.006633555473738782, 0.008374948025871269, 0.010313212443541086, 0.012460955106134331, 0.014812142775466998, 0.01736246192733239, 0.02012126493263623, 0.02308574758837366, 0.02624812003746637, 0.029615970185872854, 0.03318658953809853, 0.036961668562334724, 0.04094179777835079, 0.045128194971269756, 0.049515332707168715, 0.05410648758433739, 0.05890464330370414, 0.06390439339847645, 0.06910749047787737, 0.07451455757747018, 0.08012639913001474, 0.08594109646261495, 0.09196261993716015, 0.09818679265793319, 0.10461355511021925, 0.11124520799823046, 0.11808077473426815, 0.1251195957533534, 0.1323634912357583, 0.13981228841484966, 0.14746320816832806, 0.1553193346571197, 0.16337927795594223, 0.17164242513399547, 0.18010975120566616, 0.18878311523780753, 0.1976581852647776, 0.20673727314558657, 0.21602249873698642, 0.22550975619146263, 0.23520100357974083, 0.24509761053525392, 0.255197760918287, 0.26550103519427226, 0.27600876860267365, 0.2867200758916542, 0.29763534683246246, 0.308754651407728, 0.3200779956669337, 0.33160532739731086, 0.34333668071943324, 0.35527216001722134, 0.3674116205455685, 0.3797556904423452, 0.39230470196786105, 0.4050561729471007, 0.41801170914491104, 0.4311716396882337, 0.4445353005941822, 0.45810302878227616, 0.47187482417942167, 0.4858505627302045, 0.5000302157322793, 0.5144149498372501, 0.5290027546958118, 0.5437945145049552, 0.5587905629327989, 0.5739908101905743, 0.5893945861854445, 0.6050033615292929, 0.6208161144275792, 0.636831961041167, 0.6530525712030812, 0.6694771977925937, 0.6861051209399716, 0.7029370986019272, 0.7199731413843745, 0.73721323708372, 0.7546577163486249, 0.7723063476615352, 0.7901585976531567, 0.8082149079973313, 0.826475829061278, 0.8449402763422329, 0.8636085888066056, 0.8824809060661529, 0.9015574709818047, 0.9208377105692103, 0.9403227330712756, 0.9600113001257956, 0.9799036062453317, 1.0], [0.0, 0.001230377634462557, 0.003214641291544141, 0.005653431293008385, 0.008508004761115868, 0.011736985671174335, 0.015311926711415538, 0.019192397331320055, 0.023376849369206917, 0.02782352052748739, 0.03251482028560377, 0.03745312397639827, 0.04262002711279017, 0.048001286648207436, 0.05359817981789096, 0.05939995811462091, 0.06539225305381403, 0.07157616151106866, 0.07794350750352252, 0.08449061837963963, 0.09121318721898453, 0.0981077524907159, 0.10516568184385433, 0.11238585551305949, 0.11976700228852963, 0.1273016130381315, 0.13498791844584473, 0.14282343354297702, 0.1508059417263741, 0.15893144424128697, 0.1672001942900572, 0.17560693185428294, 0.18414938874971817, 0.1928269475546785, 0.2016369075441229, 0.21057688931676743, 0.2196461682663509, 0.22884282013171406, 0.23816341209084455, 0.24760817163990306, 0.2571746626010735, 0.2668609960700699, 0.2766662718832107, 0.28659012801399797, 0.2966287145345118, 0.3067820277120119, 0.3170499577779911, 0.32742899370535655, 0.33791901843889033, 0.34851960345729494, 0.35922864472826005, 0.3700448346068787, 0.38096781603137936, 0.3919960992701386, 0.4031288871016104, 0.41436524297148003, 0.42570422397763036, 0.43714488367994486, 0.4486863431204705, 0.4603277804394704, 0.47206827430295956, 0.4839072971403406, 0.49584419372301286, 0.5078769969751528, 0.5200057001648888, 0.5322297038110939, 0.5445479646434499, 0.5569599209890509, 0.5694648708044762, 0.5820620717174969, 0.594750840211521, 0.6075310384828734, 0.6204011302861159, 0.6333608794322471, 0.6464098150792091, 0.6595472929797568, 0.6727724327141303, 0.6860852841993528, 0.6994848403947267, 0.7129701717634304, 0.7265414347247862, 0.7401977779879871, 0.7539383773350786, 0.7677630305255684, 0.7816712339208193, 0.7956624836492251, 0.8097364230635422, 0.8238924763099378, 0.838129957132602, 0.852448577592823, 0.8668480974741688, 0.8813276395803586, 0.8958868962659835, 0.9105254875954812, 0.9252430796058764, 0.940039030640744, 0.9549133508997157, 0.9698651594241214, 0.9848941301724632, 1.0])
        ]
        
        tolerance = 0.00000001  # Tolérance pour la comparaison des résultats
        
        def compare_results(actual, expected):
            # Comparer les résultats obtenus avec les résultats attendus
            if len(actual) != len(expected):
                return False, f"Longueur différente. Résultat = {actual}, Attendu = {expected}"
            for a, e in zip(actual, expected):
                if abs(a - e) > tolerance:
                    return False, f"Difference supérieure à la tolérance. Résultat = {actual}, Attendu = {expected}"
            return True, "OK"
        
        # Exécution des tests pour chaque cas
        for i, (XX, YY, expected_reg, expected_dist, expected_rdist) in enumerate(test_cases):
            reg_result = regular_parametrisation(len(XX))  # Résultat de la paramétrisation régulière
            dist_result = distance_parametrisation(XX, YY)  # Résultat de la paramétrisation par distance
            rdist_result = parametrisation_racinedistance(XX, YY)  # Résultat de la paramétrisation par racine de la distance
            
            reg_ok, reg_msg = compare_results(reg_result, expected_reg)  # Comparer les résultats pour regular_parametrisation
            dist_ok, dist_msg = compare_results(dist_result, expected_dist)  # Comparer les résultats pour distance_parametrisation
            rdist_ok, rdist_msg = compare_results(rdist_result, expected_rdist)  # Comparer les résultats pour parametrisation_racinedistance
            
            # Afficher les résultats des tests pour chaque paramétrisation
            if reg_ok:
                print(f"OK pour XX{i+1}, YY{i+1} avec regular_parametrisation")
            else:
                print(f"KO pour XX{i+1}, YY{i+1} avec regular_parametrisation: {reg_msg}")
            
            if dist_ok:
                print(f"OK pour XX{i+1}, YY{i+1} avec distance_parametrisation")
            else:
                print(f"KO pour XX{i+1}, YY{i+1} avec distance_parametrisation: {dist_msg}")
            
            if rdist_ok:
                print(f"OK pour XX{i+1}, YY{i+1} avec parametrisation_racinedistance")
            else:
                print(f"KO pour XX{i+1}, YY{i+1} avec parametrisation_racinedistance: {rdist_msg}")
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")




class AnimationManager:
    """
    Le but : Gérer et créer des animations pour visualiser l'interpolation de Lagrange.
    
    Entrées : Aucune (initialisation des attributs).
    
    Sorties : Aucune (affiche l'animation et les contrôles).
    """
    try : 
        def __init__(self):
            # Initialisation de la figure et des axes
            self.fig, (self.ax1, self.ax2) = plt.subplots(1, 2, figsize=(12, 6))
            # Bouton pour réinitialiser l'animation
            self.reset_button = widgets.Button(description="Reset Animation")
            self.reset_button.on_click(self.on_reset_button_clicked)
            self.ani = None
            display(self.reset_button)  # Affichage du bouton

        def points_def(self):
            # Définit les points de contrôle
            X = [0.0, 0.3, 0.5, 0.65, 0.95, 1]
            Y = [0.2, 0.4, 0.2, 0.5, 0.1, 1]
            return X, Y

        def distance_color(self, distances):
            # Calcule les couleurs basées sur les distances
            max_dist = 20
            min_dist = min(distances)
            norm = plt.Normalize(min_dist, max_dist)
            return plt.cm.cividis(norm(distances))

        def lagrange(self, Y, X, x):
            # Calcule l'interpolation de Lagrange
            n = len(X)
            result = 0
            for i in range(n):
                term = Y[i]
                for j in range(n):
                    if j != i:
                        term = term * (x - X[j]) / (X[i] - X[j])
                result += term
            return result

        def create_animation(self):
            # Crée l'animation
            X, Y = self.points_def()
            x_vals = [0] + list(np.linspace(0, 1, 50)) + [1]
            total_frames = 100
            initial_position = X[2]
            final_position = 0.30025
            position_diff = initial_position - final_position
            pause_frames = 1

            def update(frame):
                # Met à jour les positions des points pour chaque frame
                if frame < total_frames:
                    X[1] = 0.3
                    X[2] = initial_position - (position_diff * (1 - np.exp(-11 * frame / total_frames)))
                else:
                    X[2] = final_position

                y_vals = [self.lagrange(Y, X, x) for x in x_vals]
                distances_cache = np.array([min([np.sqrt((xi - xj)**2 + (yi - yj)**2) for xj, yj in zip(X, Y)]) for xi, yi in zip(x_vals, y_vals)])
                colors_cache = self.distance_color(distances_cache)

                self.ax1.clear()
                self.ax2.clear()

                for i in range(len(x_vals) - 1):
                    self.ax1.plot(x_vals[i:i+2], y_vals[i:i+2], color=colors_cache[i], linewidth=2)
                self.ax1.plot(X, Y, 'ro')
                self.ax1.relim()
                self.ax1.autoscale_view()

                for i in range(len(x_vals) - 1):
                    self.ax2.plot(x_vals[i:i+2], y_vals[i:i+2], color=colors_cache[i], linewidth=2)
                self.ax2.plot(X, Y, 'ro')
                self.ax2.set_xlim([-0.1, 1.1])
                self.ax2.set_ylim([-2, 3])

                return self.ax1, self.ax2

            # Création de l'animation
            self.ani = FuncAnimation(self.fig, update, frames=np.arange(0, total_frames + pause_frames), blit=False, interval=1, repeat=False)

            plt.show()

        def on_reset_button_clicked(self, b):
            # Réinitialise l'animation lorsque le bouton est cliqué
            clear_output(wait=True)
            display(self.reset_button)
            self.create_animation()
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")





class InterpolationVisualizer:
    """
    Le but : Visualiser l'interpolation polynomiale de la fonction f(x) = 1 / (1 + 25 * x^2) et comparer les erreurs maximales en fonction du nombre de points d'interpolation.
    
    Entrées :
    - start_points (int) : Nombre de points d'interpolation de départ (par défaut 10).
    - end_points (int) : Nombre de points d'interpolation de fin (par défaut 35).
    
    Sorties : Aucune (affiche l'animation et les graphiques interactifs).
    """
    try : 
        def __init__(self, start_points=10, end_points=35):
            # Initialisation des paramètres et des données
            self.start_points = start_points
            self.end_points = end_points
            self.x = np.linspace(-1, 1, 400)  # Points x pour l'interpolation
            self.f_x = 1 / (1 + 25 * self.x**2)  # Valeurs de la fonction f(x)
            self.interpolations = self.calculate_interpolations()  # Calcul des interpolations
            self.max_error = self.calculate_max_error_across_all()  # Calcul de l'erreur maximale
            self.errors = [self.calculate_max_error(n) for n in range(self.start_points, self.end_points + 1)]  # Erreurs pour chaque n

            # Configuration des figures et des axes pour la visualisation
            self.fig = plt.figure(figsize=(10, 8))
            plt.subplots_adjust(top=0.9)  
            self.ax = plt.subplot2grid((2, 2), (0, 0))
            self.line_f, = self.ax.plot(self.x, self.f_x, 'r-', label='$f(x) = \\frac{1}{1 + 25x^2}$')  # Trace de f(x)
            self.line_interp, = self.ax.plot([], [], 'b--', label='Interpolation')  # Trace de l'interpolation
            self.scatter_points = self.ax.scatter([], [], c='blue')  # Points d'interpolation
            self.ax.legend()
            self.ax.set_xlabel('$x$')
            self.ax.set_ylabel('$y$')
            self.ax.set_title('Polynomial Interpolation of $f(x)$')
            self.ax.grid(True)
            
            self.ax_diff = plt.subplot2grid((2, 2), (0, 1))
            self.ax_diff.set_xlim(0, 1)
            self.ax_diff.set_ylim(0, self.max_error)
            self.ax_diff.set_xticks([])
            self.ax_diff.set_yticks(np.linspace(0, self.max_error, num=5))
            self.ax_diff.set_title('Log max Error')
            self.bar = self.ax_diff.bar(0.5, 0, width=0.3, color='green')

            self.ax_err = plt.subplot2grid((2, 2), (1, 0), colspan=2)
            self.ax_err.set_xlim(self.start_points - 1, self.end_points + 1)
            self.ax_err.set_ylim(0, self.max_error)
            self.error_points, = self.ax_err.plot([], [], 'bo-')
            self.ax_err.set_xlabel('n')
            self.ax_err.set_ylabel('$\\max_{x} |f(x) - P_n(x)|$')
            self.ax_err.set_title('Log max Error vs. Number of Points')
            self.ax_err.grid(True)

        def calculate_interpolations(self):
            # Calcule les interpolations pour chaque n dans la plage
            interpolations = {}
            for n in range(self.start_points, self.end_points + 1):
                x_points = np.linspace(-1, 1, n)
                y_points = 1 / (1 + 25 * x_points**2)
                interpolations[n] = [lagrange(y_points, x_points, t) for t in self.x]
            return interpolations

        def calculate_max_error_across_all(self):
            # Calcule l'erreur maximale sur tous les points d'interpolation
            max_error = 0
            for num_points in range(self.start_points, self.end_points + 1):
                y_interp = self.interpolations[num_points]
                error = np.max(np.abs(self.f_x - y_interp))
                if error > max_error:
                    max_error = error
            return np.log10(max_error)

        def calculate_max_error(self, num_points):
            # Calcule l'erreur maximale pour un nombre donné de points d'interpolation
            y_interp = self.interpolations[num_points]
            max_error = np.max(np.abs(self.f_x - y_interp))
            return np.log10(max_error)

        def update_plot(self, num_points):
            # Met à jour le graphique en fonction du nombre de points d'interpolation
            y_interp = self.interpolations[num_points]
            x_points = np.linspace(-1, 1, num_points)
            y_points = 1 / (1 + 25 * x_points**2)
            
            self.line_interp.set_data(self.x, y_interp)
            self.scatter_points.set_offsets(np.c_[x_points, y_points])
            
            self.ax.legend([self.line_f, self.line_interp], ['$f(x) = \\frac{1}{1 + 25x^2}$', f'Interpolation with {num_points} points'])

            max_error = self.calculate_max_error(num_points)
            self.bar[0].set_height(max_error)

            # Ajuste la couleur de la barre d'erreur en fonction des seuils
            threshold1 = self.max_error / 5
            threshold2 = 2 * self.max_error / 5
            threshold3 = 3 * self.max_error / 5
            threshold4 = 4 * self.max_error / 5

            if max_error > threshold4:
                self.bar[0].set_color('red')
            elif max_error > threshold3:
                self.bar[0].set_color('orange')
            elif max_error > threshold2:
                self.bar[0].set_color('yellow')
            elif max_error > threshold1:
                self.bar[0].set_color('lightgreen')
            else:
                self.bar[0].set_color('green')

            # Met à jour les points d'erreur
            n_values = list(range(self.start_points, num_points + 1))
            current_errors = self.errors[:num_points - self.start_points + 1]
            self.error_points.set_data(n_values, current_errors)
            
            self.fig.canvas.draw_idle()

        def display(self):
            # Affiche l'interface interactive
            interact(self.update_plot, num_points=IntSlider(min=self.start_points, max=self.end_points, step=1, value=self.start_points, description='Num Points'))
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")

class InterpolationVisualizer_2:
    """
    Le but : Visualiser l'interpolation polynomiale de la fonction f(x) = 1 / (1 + 25 * x^2) en utilisant la paramétrisation de Tchebycheff et comparer les erreurs maximales en fonction du nombre de points d'interpolation.
    
    Entrées :
    - start_points (int) : Nombre de points d'interpolation de départ (par défaut 10).
    - end_points (int) : Nombre de points d'interpolation de fin (par défaut 35).
    
    Sorties : Aucune (affiche l'animation et les graphiques interactifs).
    """
    try :

        def __init__(self, start_points=10, end_points=35):
            # Initialisation des paramètres et des données
            self.start_points = start_points
            self.end_points = end_points
            self.x = np.linspace(-1, 1, 400)  # Points x pour l'interpolation
            self.f_x = 1 / (1 + 25 * self.x**2)  # Valeurs de la fonction f(x)
            self.interpolations = self.calculate_interpolations()  # Calcul des interpolations
            self.max_error = self.calculate_max_error_across_all()  # Calcul de l'erreur maximale
            self.errors = [self.calculate_max_error(n) for n in range(self.start_points, self.end_points + 1)]  # Erreurs pour chaque n

            # Configuration des figures et des axes pour la visualisation
            self.fig = plt.figure(figsize=(10, 8))
            plt.subplots_adjust(top=0.9)  

            self.ax = plt.subplot2grid((2, 2), (0, 0))
            self.line_f, = self.ax.plot(self.x, self.f_x, 'r-', label='$f(x) = \\frac{1}{1 + 25x^2}$')  # Trace de f(x)
            self.line_interp, = self.ax.plot([], [], 'm--', label='Interpolation')  # Trace de l'interpolation
            self.scatter_points = self.ax.scatter([], [], c='blue')  # Points d'interpolation
            self.ax.legend()
            self.ax.set_xlabel('$x$')
            self.ax.set_ylabel('$y$')
            self.ax.set_title('Polynomial Interpolation of $f(x)$')
            self.ax.grid(True)
            
            self.ax_diff = plt.subplot2grid((2, 2), (0, 1))
            self.ax_diff.set_xlim(0, 1)
            self.ax_diff.set_ylim(0, self.max_error)
            self.ax_diff.set_xticks([])
            self.ax_diff.set_yticks(np.linspace(0, self.max_error, num=5))
            self.ax_diff.set_title('Max Error')
            self.bar = self.ax_diff.bar(0.5, 0, width=0.3, color='green')

            self.ax_err = plt.subplot2grid((2, 2), (1, 0), colspan=2)
            self.ax_err.set_xlim(self.start_points - 1, self.end_points + 1)
            self.ax_err.set_ylim(0, self.max_error)
            self.error_points, = self.ax_err.plot([], [], 'go-')
            self.ax_err.set_xlabel('n')
            self.ax_err.set_ylabel('$\\max_{x} |f(x) - P_n(x)|$')
            self.ax_err.set_title('Max Error vs. Number of Points')
            self.ax_err.grid(True)

        def calculate_interpolations(self):
            # Calcule les interpolations pour chaque n dans la plage
            interpolations = {}
            for n in range(self.start_points, self.end_points + 1):
                x_points = tchebycheff_parametrisation(n)
                y_points = 1 / (1 + 25 * np.array(x_points)**2)
                interpolations[n] = [lagrange(y_points, x_points, t) for t in self.x]
            return interpolations

        def calculate_max_error_across_all(self):
            # Calcule l'erreur maximale sur tous les points d'interpolation
            max_error = 0
            for num_points in range(self.start_points, self.end_points + 1):
                y_interp = self.interpolations[num_points]
                error = np.max(np.abs(self.f_x - y_interp))
                if error > max_error:
                    max_error = error
            return max_error

        def calculate_max_error(self, num_points):
            # Calcule l'erreur maximale pour un nombre donné de points d'interpolation
            y_interp = self.interpolations[num_points]
            max_error = np.max(np.abs(self.f_x - y_interp))
            return max_error

        def update_plot(self, num_points):
            # Met à jour le graphique en fonction du nombre de points d'interpolation
            y_interp = self.interpolations[num_points]
            x_points = tchebycheff_parametrisation(num_points)
            y_points = 1 / (1 + 25 * np.array(x_points)**2)
            
            self.line_interp.set_data(self.x, y_interp)
            self.scatter_points.set_offsets(np.c_[x_points, y_points])
            
            self.ax.legend([self.line_f, self.line_interp], ['$f(x) = \\frac{1}{1 + 25x^2}$', f'Interpolation with {num_points} points'])

            max_error = self.calculate_max_error(num_points)
            self.bar[0].set_height(max_error)

            # Ajuste la couleur de la barre d'erreur en fonction des seuils
            threshold1 = self.max_error / 5
            threshold2 = 2 * self.max_error / 5
            threshold3 = 3 * self.max_error / 5
            threshold4 = 4 * self.max_error / 5

            if max_error > threshold4:
                self.bar[0].set_color('red')
            elif max_error > threshold3:
                self.bar[0].set_color('orange')
            elif max_error > threshold2:
                self.bar[0].set_color('yellow')
            elif max_error > threshold1:
                self.bar[0].set_color('lightgreen')
            else:
                self.bar[0].set_color('green')

            n_values = list(range(self.start_points, num_points + 1))
            current_errors = self.errors[:num_points - self.start_points + 1]
            self.error_points.set_data(n_values, current_errors)
            
            self.fig.canvas.draw_idle()

        def display(self):
            # Affiche l'interface interactive
            interact(self.update_plot, num_points=IntSlider(min=self.start_points, max=self.end_points, step=1, value=self.start_points, description='Num Points'))
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")


def visualize_parametrisation(XX: List[float], YY: List[float]):
    """
    Le but : Visualiser et comparer différentes méthodes de paramétrisation pour un ensemble donné de points.
    
    Entrées :
    - XX (List[float]) : Liste des abscisses des points.
    - YY (List[float]) : Liste des ordonnées des points.
    
    Sorties : Aucune (affiche les graphiques comparatifs).
    """
    try : 
        nb_point = len(XX)  # Nombre de points
        tchebycheff = tchebycheff_parametrisation(nb_point)  # Paramétrisation de Tchebycheff
        tchebycheff_normalized = normalize_to_0_1(tchebycheff)  # Normalisation

        reguliere = regular_parametrisation(nb_point)  # Paramétrisation régulière
        distance = distance_parametrisation(XX, YY)  # Paramétrisation par distance
        racine_distance = parametrisation_racinedistance(XX, YY)  # Paramétrisation par racine de la distance

        fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 12))  # Création des figures

        colors = plt.cm.jet(np.linspace(0, 1, nb_point))  # Couleurs pour les points
        for i in range(nb_point):
            ax1.plot(XX[i], YY[i], 'o', color=colors[i], markersize=8)  # Trace des points de contrôle
            if i > 0:
                ax1.plot([XX[i-1], XX[i]], [YY[i-1], YY[i]], 'gray', linewidth=1)  # Trace des segments entre points

        ax1.set_xlim(-0.1, 9.1)
        ax1.set_ylim(-0.1, 9.1)
        ax1.set_aspect('equal', 'box')
        ax1.set_title('Control points in R2')
        ax1.set_xlabel('X')
        ax1.set_ylabel('Y')
        ax1.grid(True)

        ax2.plot(tchebycheff_normalized, [0]*nb_point, '-', label="Tchebycheff",color = 'violet')
        for i in range(nb_point):
            ax2.plot(tchebycheff_normalized[i], 0, 'o', color=colors[i], markersize=8)

        ax2.plot(reguliere, [0.1]*nb_point, '-', label="Regular",color ='b')
        for i in range(nb_point):
            ax2.plot(reguliere[i], 0.1, 'o', color=colors[i], markersize=8)

        ax2.plot(distance, [0.2]*nb_point, '-', label="Distance", color = 'r')
        for i in range(nb_point):
            ax2.plot(distance[i], 0.2, 'o', color=colors[i], markersize=8)

        ax2.plot(racine_distance, [0.3]*nb_point, '-', label="Root Distance", color = 'orange')
        for i in range(nb_point):
            ax2.plot(racine_distance[i], 0.3, 'o', color=colors[i], markersize=8)

        ax2.set_yticks([])
        ax2.set_xlabel("Parametrization")
        ax2.set_title("Comparison of different parametrisations")
        ax2.legend(bbox_to_anchor=(1.05, 1), loc='upper left', borderaxespad=0.)
        ax2.grid(True)

        plt.subplots_adjust(right=0.75, hspace=0.4)

        plt.show()  # Afficher les graphiques
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")


class ParametricInterpolationPlot:
    """
    Le but : Visualiser une interpolation paramétrique à partir de points donnés et de leur paramétrisation.
    
    Entrées :
    - XX (List[float]) : Liste des abscisses des points.
    - YY (List[float]) : Liste des ordonnées des points.
    - TT (List[float]) : Liste des paramètres pour l'interpolation.
    - nb_échantillon (int) : Nombre d'échantillons pour l'interpolation.
    
    Sorties : Aucune (affiche les graphiques).
    """
    try : 
        def __init__(self, XX, YY, TT, nb_échantillon):
            # Initialisation des attributs
            self.XX = XX
            self.YY = YY
            self.TT = TT
            self.nb_e = nb_échantillon

        def plot(self, figsize=(12, 8)):
            try : 
                # Génère les points de paramétrisation
                list_tt = np.linspace(min(self.TT), max(self.TT), self.nb_e)
                
                # Calcul des interpolations paramétriques
                interp_x, interp_y = neville_param(self.XX, self.YY, self.TT, list_tt)
                
                # Configuration des sous-graphiques
                fig, axs = plt.subplots(2, 2, gridspec_kw={'width_ratios': [1, 3], 'height_ratios': [3, 1]}, figsize=figsize)
                fig.delaxes(axs[1, 0])  # Supprime l'axe inférieur gauche
                ax_central = axs[0, 1]  # Axe principal
                ax_left = axs[0, 0]  # Axe gauche
                ax_bottom = axs[1, 1]  # Axe inférieur
                
                nb_point = len(self.XX)  # Nombre de points
                colors = plt.cm.jet(np.linspace(0, 1, nb_point))  # Couleurs pour les points
                
                # Tracé de l'interpolation paramétrique
                ax_central.plot(interp_x, interp_y, 'r-', label='Parametric Interpolation')
                for i in range(nb_point):
                    ax_central.plot(self.XX[i], self.YY[i], 'o', color=colors[i], markersize=8)
                ax_central.set_xlabel('X')
                ax_central.set_ylabel('Y')
                ax_central.legend()
                
                # Tracé des interpolations sur l'axe gauche
                interp_yy = [neville( self.YY, self.TT, tt) for tt in list_tt]
                ax_left.plot(list_tt, interp_yy, 'g-')
                for i in range(nb_point):
                    ax_left.plot(self.TT[i], self.YY[i], 'o', color=colors[i], markersize=8)
                ax_left.set_xlabel('T')
                ax_left.set_ylabel('Y')
                
                for t, y, color in zip(self.TT, self.YY, colors):
                    ax_left.plot([t], [0], '.', c='red', markersize=8)  # Points de contrôle en rouge

                # Tracé des interpolations sur l'axe inférieur
                interp_xx = [neville(self.XX, self.TT, tt) for tt in list_tt]
                ax_bottom.plot(interp_xx, list_tt, 'b-')
                for i in range(nb_point):
                    ax_bottom.plot(self.XX[i], self.TT[i], 'o', color=colors[i], markersize=8)
                ax_bottom.set_xlabel('X')
                ax_bottom.set_ylabel('T')
                
                for x, t, color in zip(self.XX, self.TT, colors):
                    ax_bottom.plot([0], [t], '.', c='red', markersize=8)  # Points de contrôle en rouge
                
                plt.tight_layout()  # Ajustement de la mise en page
                plt.show()  # Afficher les graphiques
            except Exception as e:
                print("An error occurred:")
                traceback.print_exc()
                print(f"Exception type: {type(e).__name__}")
                print(f"Exception description: {e}")
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")



class NevilleInterpolation:
    try : 
        def __init__(self, xlim, ylim, max_points):
            self.points = []
            self.max_points = max_points
            self.fig, self.ax = plt.subplots()
            self.ax.set_xlim(xlim)
            self.ax.set_ylim(ylim)
            self.ax.set_title(f'Click to insert up to {max_points} points')
            self.cid = self.fig.canvas.mpl_connect('button_press_event', self.onclick)
            self.ani = None 

            self.reset_button = widgets.Button(description='Reset')
            self.reset_button.on_click(self.reset)

            display(self.fig.canvas)  
            display(self.reset_button) 

        def reset(self, event):
            self.points = []
            self.ax.cla()
            self.ax.set_xlim(self.ax.get_xlim())
            self.ax.set_ylim(self.ax.get_ylim())
            self.ax.set_title(f'Click to insert up to {self.max_points} points')

        def onclick(self, event):
            if event.inaxes is not None and len(self.points) < self.max_points:
                self.points.append((event.xdata, event.ydata))
                self.ax.plot(event.xdata, event.ydata, 'ro')
                if len(self.points) == self.max_points:
                    self.interpolate_and_animate()

        def interpolate_and_animate(self):
            try :
                self.points = sorted(self.points, key=lambda p: p[0])
                XX, YY = zip(*self.points)
                temps = np.linspace(min(XX),max(XX),500) 
            
                interpolated_points_neville = [neville(YY, XX, tt) for tt in temps]
                
                
                interpolated_points_lagrange = [lagrange(YY, XX, x) for x in temps]

                all_x_points = np.concatenate((temps, temps))
                all_y_points = np.concatenate((interpolated_points_neville, interpolated_points_lagrange))
                
                self.ax.set_xlim(min(all_x_points) - 0.2, max(all_x_points) + 0.2)
                self.ax.set_ylim(min(all_y_points) - 0.2, max(all_y_points) + 0.2)

                line_neville, = self.ax.plot([], [], 'b-', label='Neville')

                self.ax.plot(temps, interpolated_points_lagrange, 'g--', label='Lagrange')

                self.ax.legend()

                def init():
                    line_neville.set_data([], [])
                    return line_neville,

                def animate(i):
                    x_vals =  temps[:i]
                    y_vals_neville = interpolated_points_neville[:i]
                    line_neville.set_data(x_vals, y_vals_neville)
                    return line_neville,

                self.ani = FuncAnimation(self.fig, animate, init_func=init, frames=len(temps), interval=2, blit=True, repeat=False)
                plt.draw()
            except Exception as e:
                print("An error occurred:")
                traceback.print_exc()
                print(f"Exception type: {type(e).__name__}")
                print(f"Exception description: {e}")
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")

    

class NevilleInterpolationPlotter_2x2:
    def __init__(self, XX, YY, nb_ech):
        self.XX = XX
        self.YY = YY
        self.nb_e = nb_ech

    def plot(self):
        nb_point = len(self.XX)
        colors = plt.cm.jet(np.linspace(0, 1, nb_point))

        TT_Reguliere = normalize_to_0_1(regular_parametrisation(len(self.XX)))
        TT_Distance = normalize_to_0_1(distance_parametrisation(self.XX, self.YY))
        TT_RacineDistance = normalize_to_0_1(parametrisation_racinedistance(self.XX, self.YY))
        TT_Tchebycheff = normalize_to_0_1(tchebycheff_parametrisation(len(self.XX)))

        list_tt = np.linspace(0, 1, self.nb_e)

        fig, axs = plt.subplots(2, 2, figsize=(14, 10))
        fig.suptitle('Neville Interpolation with Different Parametrizations')

        params = [
            (TT_Reguliere, 'b', 'Regular parametrization', axs[0, 0]),
            (TT_Distance, 'r', 'Distance parametrization', axs[0, 1]),
            (TT_RacineDistance, 'orange', 'Root distance parametrization', axs[1, 0]),
            (TT_Tchebycheff, 'violet', 'Tchebycheff parametrization', axs[1, 1])
        ]

        for TT, color, label, ax in params:
            interp_x, interp_y = neville_param(self.XX, self.YY, TT, list_tt)
            ax.plot(interp_x, interp_y, color=color, label=label)
            ax.set_title(label)
            ax.grid(True)
            ax.set_xlabel('X')
            ax.set_ylabel('Y')
            for i in range(nb_point):
                ax.plot(self.XX[i], self.YY[i], 'o', color=colors[i], markersize=8)

        plt.tight_layout()
        plt.subplots_adjust(top=0.9)
        plt.show()

class NevilleInterpolation:
    """
    Le but : Permettre à l'utilisateur de placer des points sur une figure et d'afficher l'interpolation de Neville et de Lagrange pour ces points.
    
    Entrées :
    - xlim (tuple) : Limites de l'axe x de la figure.
    - ylim (tuple) : Limites de l'axe y de la figure.
    - max_points (int) : Nombre maximum de points que l'utilisateur peut placer.
    
    Sorties : Aucune (affiche la figure interactive et les interpolations).
    """
    try : 
        def __init__(self, xlim, ylim, max_points):
            # Initialisation des attributs
            self.points = []
            self.max_points = max_points
            self.fig, self.ax = plt.subplots()
            self.ax.set_xlim(xlim)
            self.ax.set_ylim(ylim)
            self.ax.set_title(f'Click to insert up to {max_points} points')
            self.cid = self.fig.canvas.mpl_connect('button_press_event', self.onclick)
            self.ani = None

            # Bouton de réinitialisation
            self.reset_button = widgets.Button(description='Reset')
            self.reset_button.on_click(self.reset)

            display(self.fig.canvas)
            display(self.reset_button)

        def reset(self, event):
            # Réinitialise la figure et les points
            self.points = []
            self.ax.cla()
            self.ax.set_xlim(self.ax.get_xlim())
            self.ax.set_ylim(self.ax.get_ylim())
            self.ax.set_title(f'Click to insert up to {self.max_points} points')

        def onclick(self, event):
            # Gère les clics de souris pour placer les points
            if event.inaxes is not None and len(self.points) < self.max_points:
                self.points.append((event.xdata, event.ydata))
                self.ax.plot(event.xdata, event.ydata, 'ro')
                if len(self.points) == self.max_points:
                    self.interpolate_and_animate()

        def interpolate_and_animate(self):
            # Trie les points par abscisse
            self.points = sorted(self.points, key=lambda p: p[0])
            XX, YY = zip(*self.points)
            temps = np.linspace(min(XX), max(XX), 500)

            # Calcul des interpolations de Neville et de Lagrange
            interpolated_points_neville = [neville(YY, XX, tt) for tt in temps]
            interpolated_points_lagrange = [lagrange(YY, XX, tt) for tt in temps]

            # Préparation des données pour le tracé
            all_x_points = np.concatenate((temps, temps))
            all_y_points = np.concatenate((interpolated_points_neville, interpolated_points_lagrange))
            
            self.ax.set_xlim(min(all_x_points) - 0.2, max(all_x_points) + 0.2)
            self.ax.set_ylim(min(all_y_points) - 0.2, max(all_y_points) + 0.2)

            # Tracé de l'interpolation de Neville
            line_neville, = self.ax.plot([], [], 'b-', label='Neville')

            # Tracé de l'interpolation de Lagrange
            self.ax.plot(temps, interpolated_points_lagrange, 'g--', label='Lagrange')

            self.ax.legend()

            def init():
                # Initialisation de l'animation
                line_neville.set_data([], [])
                return line_neville,

            def animate(i):
                # Animation des données
                x_vals = temps[:i]
                y_vals_neville = interpolated_points_neville[:i]
                line_neville.set_data(x_vals, y_vals_neville)
                return line_neville,

            # Création de l'animation
            self.ani = FuncAnimation(self.fig, animate, init_func=init, frames=len(temps), interval=2, blit=True, repeat=False)
            plt.draw()
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")



class NevilleInterpolationPlotter_2:
    """
    Le but : Visualiser les interpolations de Neville avec différentes paramétrisations des points donnés.
    
    Entrées :
    - XX (List[float]) : Liste des abscisses des points.
    - YY (List[float]) : Liste des ordonnées des points.
    - nb_ech (int) : Nombre d'échantillons pour l'interpolation.
    
    Sorties : Aucune (affiche le graphique des interpolations).
    """
    try : 
        def __init__(self, XX, YY, nb_ech):
            # Initialisation des attributs
            self.XX = XX
            self.YY = YY
            self.nb_e = nb_ech

        def plot(self):
            # Prépare les données et les couleurs pour les points
            nb_point = len(self.XX)
            colors = plt.cm.jet(np.linspace(0, 1, nb_point))

            # Calcul des paramétrisations normalisées
            TT_Reguliere = normalize_to_0_1(regular_parametrisation(len(self.XX)))
            TT_Distance = normalize_to_0_1(distance_parametrisation(self.XX, self.YY))
            TT_RacineDistance = normalize_to_0_1(parametrisation_racinedistance(self.XX, self.YY))
            TT_Tchebycheff = normalize_to_0_1(tchebycheff_parametrisation(len(self.XX)))

            list_tt = np.linspace(0, 1, self.nb_e)  # Points de paramétrisation pour l'interpolation

            fig, ax = plt.subplots(figsize=(10, 8))  # Préparation de la figure

            # Liste des paramétrisations avec leurs couleurs et labels
            params = [
                (TT_Reguliere, 'b', 'Regular parametrization'),
                (TT_Distance, 'r', 'Distance parametrization'),
                (TT_RacineDistance, 'orange', 'Root distance parametrization'),
                (TT_Tchebycheff, 'violet', 'Tchebycheff parametrization')
            ]

            all_interp_x = []
            all_interp_y = []

            # Calcul et tracé des interpolations pour chaque paramétrisation
            for TT, color, label in params:
                interp_x, interp_y = neville_param(self.XX, self.YY, TT, list_tt)
                all_interp_x.append(interp_x)
                all_interp_y.append(interp_y)
                ax.plot(interp_x, interp_y, color=color, label=label)

            # Tracé des points de contrôle
            for i in range(nb_point):
                ax.plot(self.XX[i], self.YY[i], 'o', color=colors[i], markersize=8)

            # Détermination des limites des axes
            max_x = max([max(x) for x in all_interp_x])
            min_x = min([min(x) for x in all_interp_x])
            max_y = max([max(y) for y in all_interp_y])
            min_y = min([min(y) for y in all_interp_y])

            ax.set_xlim([min_x, max_x])
            ax.set_ylim([min_y, max_y])
            ax.legend()
            ax.grid(True)
            plt.title('Neville Interpolation with Different Parametrizations')
            plt.xlabel('X')
            plt.ylabel('Y')
            plt.show()
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")



def plot_with_interpolation(X, Y, Z, interpolated_surface_reg, interpolated_surface_tch, op):
    """
    Le but : Visualiser deux surfaces interpolées (Régulière et Tchebycheff) et les points de contrôle 3D.
    
    Entrées :
    - X (np.ndarray) : Coordonnées X des points de contrôle.
    - Y (np.ndarray) : Coordonnées Y des points de contrôle.
    - Z (np.ndarray) : Coordonnées Z des points de contrôle.
    - interpolated_surface_reg (np.ndarray) : Surface interpolée régulière.
    - interpolated_surface_tch (np.ndarray) : Surface interpolée Tchebycheff.
    - op (float) : Opacité des surfaces interpolées.
    
    Sorties : Aucune (affiche les graphiques des surfaces interpolées).
    """
    try : 
        fig = make_subplots(rows=1, cols=2, specs=[[{'type': 'surface'}, {'type': 'surface'}]],
                            subplot_titles=('Interpolation regular parametrization', 'Interpolation Tchebycheff parametrization'))

        # Calcul des gammes des axes pour la surface régulière
        x_range_R = [interpolated_surface_reg[:,:,0].min() - 0.1 * abs(interpolated_surface_reg[:,:,0].min()), interpolated_surface_reg[:,:,0].max() + 0.1 * abs(interpolated_surface_reg[:,:,0].max())]
        y_range_R = [interpolated_surface_reg[:,:,1].min() - 0.1 * abs(interpolated_surface_reg[:,:,1].min()), interpolated_surface_reg[:,:,1].max() + 0.1 * abs(interpolated_surface_reg[:,:,1].max())]
        z_range_R = [interpolated_surface_reg[:,:,2].min() - 0.1 * abs(interpolated_surface_reg[:,:,2].min()), interpolated_surface_reg[:,:,2].max() + 0.1 * abs(interpolated_surface_reg[:,:,2].max())]

        # Calcul des gammes des axes pour la surface Tchebycheff
        x_range_T = [interpolated_surface_tch[:,:,0].min() - 0.1 * abs(interpolated_surface_tch[:,:,0].min()), interpolated_surface_tch[:,:,0].max() + 0.1 * abs(interpolated_surface_tch[:,:,0].max())]
        y_range_T = [interpolated_surface_tch[:,:,1].min() - 0.1 * abs(interpolated_surface_tch[:,:,1].min()), interpolated_surface_tch[:,:,1].max() + 0.1 * abs(interpolated_surface_tch[:,:,1].max())]
        z_range_T = [interpolated_surface_tch[:,:,2].min() - 0.1 * abs(interpolated_surface_tch[:,:,2].min()), interpolated_surface_tch[:,:,2].max() + 0.1 * abs(interpolated_surface_tch[:,:,2].max())]

        # Création de la surface interpolée régulière
        neville_surface = go.Surface(x=interpolated_surface_reg[:,:,0],
                                    y=interpolated_surface_reg[:,:,1],
                                    z=interpolated_surface_reg[:,:,2],
                                    colorscale='Viridis', opacity=op, name='Surface regular parametrization',
                                    showscale=False)
        
        # Création de la surface interpolée Tchebycheff
        lagrange_surface = go.Surface(x=interpolated_surface_tch[:,:,0],
                                    y=interpolated_surface_tch[:,:,1],
                                    z=interpolated_surface_tch[:,:,2],
                                    colorscale='Cividis', opacity=op, name='Surface Tchebycheff parametrization',
                                    showscale=False)
        
        # Points de contrôle
        control_points = go.Scatter3d(
            x=X.flatten(),
            y=Y.flatten(),
            z=Z.flatten(),
            mode='markers',
            marker=dict(size=3, color='red')
        )

        lines = []
        num_u, num_v = X.shape

        # Création des lignes de la grille
        for i in range(num_u):
            for j in range(num_v):
                if i < num_u - 1:
                    lines.append((X[i, j], Y[i, j], Z[i, j], X[i + 1, j], Y[i + 1, j], Z[i + 1, j]))
                if j < num_v - 1:
                    lines.append((X[i, j], Y[i, j], Z[i, j], X[i, j + 1], Y[i, j + 1], Z[i, j + 1]))
        
        mesh_lines = go.Scatter3d(
            x=[item for line in lines for item in [line[0], line[3], None]],
            y=[item for line in lines for item in [line[1], line[4], None]],
            z=[item for line in lines for item in [line[2], line[5], None]],
            mode='lines',
            line=dict(color='black', width=1)
        )

        # Ajout des surfaces et des points de contrôle aux sous-graphiques
        fig.add_trace(neville_surface, row=1, col=1)
        fig.add_trace(control_points, row=1, col=1)
        fig.add_trace(mesh_lines, row=1, col=1)

        fig.add_trace(lagrange_surface, row=1, col=2)
        fig.add_trace(control_points, row=1, col=2)
        fig.add_trace(mesh_lines, row=1, col=2)

        # Calcul des proportions des axes pour l'aspect
        x_span_R = x_range_R[1] - x_range_R[0]
        y_span_R = y_range_R[1] - y_range_R[0]
        z_span_R = z_range_R[1] - z_range_R[0]
        max_span_R = max(x_span_R, y_span_R, z_span_R)

        x_span_T = x_range_T[1] - x_range_T[0]
        y_span_T = y_range_T[1] - y_range_T[0]
        z_span_T = z_range_T[1] - z_range_T[0]
        max_span_T = max(x_span_T, y_span_T, z_span_T)

        # Mise à jour de la disposition et des proportions des scènes
        fig.update_layout(
            scene=dict(
                aspectratio=dict(x=x_span_R / max_span_R, y=y_span_R / max_span_R, z=z_span_R / max_span_R),
                xaxis=dict(range=x_range_R),
                yaxis=dict(range=y_range_R),
                zaxis=dict(range=z_range_R),
                xaxis_title='X',
                yaxis_title='Y',
                zaxis_title='Z'
            ),
            scene2=dict(
                aspectratio=dict(x=x_span_T / max_span_T, y=y_span_T / max_span_T, z=z_span_T / max_span_T),
                xaxis=dict(range=x_range_T),
                yaxis=dict(range=y_range_T),
                zaxis=dict(range=z_range_T),
                xaxis_title='X',
                yaxis_title='Y',
                zaxis_title='Z'
            ),
            width=1200, 
            height=600
        )

        fig.show()
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")



def plot_with_interpolation_2(X, Y, Z, interpolated_surface_reg, interpolated_surface_tch, op):
    """
    Le but : Visualiser deux surfaces interpolées (Régulière et Tchebycheff) et les points de contrôle 3D.
    
    Entrées :
    - X (np.ndarray) : Coordonnées X des points de contrôle.
    - Y (np.ndarray) : Coordonnées Y des points de contrôle.
    - Z (np.ndarray) : Coordonnées Z des points de contrôle.
    - interpolated_surface_reg (np.ndarray) : Surface interpolée régulière.
    - interpolated_surface_tch (np.ndarray) : Surface interpolée Tchebycheff.
    - op (float) : Opacité des surfaces interpolées.
    
    Sorties : Aucune (affiche les graphiques des surfaces interpolées).
    """
    try : 
        fig = make_subplots(rows=1, cols=2, specs=[[{'type': 'surface'}, {'type': 'surface'}]],
                            subplot_titles=('Regular Interpolation', "Tchebycheff's Interpolation"))

        # Création de la surface interpolée régulière
        neville_surface = go.Surface(x=interpolated_surface_reg[:,:,0],
                                    y=interpolated_surface_reg[:,:,1],
                                    z=interpolated_surface_reg[:,:,2],
                                    colorscale='Viridis', opacity=op, name='Surface regular parametrization',
                                    showscale=False) 

        # Création de la surface interpolée Tchebycheff
        lagrange_surface = go.Surface(x=interpolated_surface_tch[:,:,0],
                                    y=interpolated_surface_tch[:,:,1],
                                    z=interpolated_surface_tch[:,:,2],
                                    colorscale='Cividis', opacity=op, name='Surface Tchebycheff parametrization',
                                    showscale=False)  
        
        # Points de contrôle
        control_points = go.Scatter3d(
            x=X.flatten(),
            y=Y.flatten(),
            z=Z.flatten(),
            mode='markers',
            marker=dict(size=3, color='red')
        )

        lines = []
        num_u, num_v = X.shape

        # Création des lignes de la grille
        for i in range(num_u):
            for j in range(num_v):
                if i < num_u - 1:
                    lines.append((X[i, j], Y[i, j], Z[i, j], X[i + 1, j], Y[i + 1, j], Z[i + 1, j]))
                if j < num_v - 1:
                    lines.append((X[i, j], Y[i, j], Z[i, j], X[i, j + 1], Y[i, j + 1], Z[i, j + 1]))
        
        mesh_lines = go.Scatter3d(
            x=[item for line in lines for item in [line[0], line[3], None]],
            y=[item for line in lines for item in [line[1], line[4], None]],
            z=[item for line in lines for item in [line[2], line[5], None]],
            mode='lines',
            line=dict(color='black', width=1)
        )

        # Ajout des surfaces et des points de contrôle aux sous-graphiques
        fig.add_trace(neville_surface, row=1, col=1)
        fig.add_trace(control_points, row=1, col=1)
        fig.add_trace(mesh_lines, row=1, col=1)

        fig.add_trace(lagrange_surface, row=1, col=2)
        fig.add_trace(control_points, row=1, col=2)
        fig.add_trace(mesh_lines, row=1, col=2)

        # Mise à jour de la disposition et des proportions des scènes
        fig.update_layout(scene=dict(xaxis_title='X', yaxis_title='Y', zaxis_title='Z'),
                        width=1200,  
                        height=600)  

        fig.show()
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")

def plot_patch_interpolation(X, Y, Z, interpolated_surfaces):
    """
    Le but : Visualiser plusieurs surfaces interpolées et les points de contrôle 3D.
    
    Entrées :
    - X (np.ndarray) : Coordonnées X des points de contrôle.
    - Y (np.ndarray) : Coordonnées Y des points de contrôle.
    - Z (np.ndarray) : Coordonnées Z des points de contrôle.
    - interpolated_surfaces (List[np.ndarray]) : Liste des surfaces interpolées.
    
    Sorties : Aucune (affiche le graphique des surfaces interpolées).
    """
    try : 
        fig = go.Figure()

        # Ajout de chaque surface interpolée au graphique
        for surface in interpolated_surfaces:
            surface_plot = go.Surface(
                x=surface[:, :, 0],
                y=surface[:, :, 1],
                z=surface[:, :, 2],
                colorscale='Viridis',
                opacity=1,
                showscale=False
            )
            fig.add_trace(surface_plot)

        num_u, num_v = X.shape

        # Mise à jour de la disposition et des proportions des scènes
        fig.update_layout(scene=dict(xaxis_title='X', yaxis_title='Y', zaxis_title='Z'),
                        width=800,  
                        height=600,  
                        legend=dict(itemsizing='constant'))  

        fig.show()
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")

def create_patches(X, Y, Z, num_patches):
    """
    Le but : Diviser une surface en plusieurs sous-patchs pour faciliter l'interpolation locale.
    
    Entrées :
    - X (np.ndarray) : Coordonnées X des points de contrôle.
    - Y (np.ndarray) : Coordonnées Y des points de contrôle.
    - Z (np.ndarray) : Coordonnées Z des points de contrôle.
    - num_patches (int) : Nombre de patchs à créer dans chaque dimension.
    
    Sorties :
    - patches (List[tuple]) : Liste de tuples contenant les coordonnées X, Y, Z de chaque patch.
    """
    try : 
        patch_size_x = X.shape[0] // num_patches  # Taille des patchs en X
        patch_size_y = Y.shape[1] // num_patches  # Taille des patchs en Y
        
        patches = []  # Liste des patchs
        
        # Création des patchs
        for i in range(num_patches):
            for j in range(num_patches):
                x_start = i * patch_size_x
                y_start = j * patch_size_y
                x_end = (i + 1) * patch_size_x + 1 if i != num_patches - 1 else X.shape[0]
                y_end = (j + 1) * patch_size_y + 1 if j != num_patches - 1 else Y.shape[1]
                
                X_patch = X[x_start:x_end, y_start:y_end]  # Patch X
                Y_patch = Y[x_start:x_end, y_start:y_end]  # Patch Y
                Z_patch = Z[x_start:x_end, y_start:y_end]  # Patch Z
                
                patches.append((X_patch, Y_patch, Z_patch))  # Ajout du patch à la liste
        
        return patches  # Retourne la liste des patchs
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")


def plot_fractal(X, Y, Z):
    """
    Le but : Visualiser une surface fractale avec ses points de contrôle et les lignes de la grille.
    
    Entrées :
    - X (np.ndarray) : Coordonnées X des points de contrôle.
    - Y (np.ndarray) : Coordonnées Y des points de contrôle.
    - Z (np.ndarray) : Coordonnées Z des points de contrôle.
    
    Sorties : Aucune (affiche le graphique 3D de la surface fractale).
    """
    try : 
        fig = go.Figure()  # Création de la figure

        # Ajout des points de contrôle
        control_points = go.Scatter3d(
            x=X.flatten(),
            y=Y.flatten(),
            z=Z.flatten(),
            mode='markers',
            marker=dict(size=1.5, color='black'),
            name='Control Points'
        )
        fig.add_trace(control_points)

        lines = []
        num_u, num_v = X.shape

        # Création des lignes de la grille
        for i in range(num_u):
            for j in range(num_v):
                if i < num_u - 1:
                    lines.append((X[i, j], Y[i, j], Z[i, j], X[i + 1, j], Y[i + 1, j], Z[i + 1, j]))
                if j < num_v - 1:
                    lines.append((X[i, j], Y[i, j], Z[i, j], X[i, j + 1], Y[i, j + 1], Z[i, j + 1]))
        
        mesh_lines = go.Scatter3d(
            x=[item for line in lines for item in [line[0], line[3], None]],
            y=[item for line in lines for item in [line[1], line[4], None]],
            z=[item for line in lines for item in [line[2], line[5], None]],
            mode='lines',
            line=dict(color='gray', width=0.9),
            name='Mesh Lines'
        )
        fig.add_trace(mesh_lines)

        # Mise à jour de la disposition de la scène
        fig.update_layout(scene=dict(xaxis_title='X', yaxis_title='Y', zaxis_title='Z'),
                        width=800,  
                        height=600, 
                        legend=dict(itemsizing='constant')) 

        fig.show()  # Affiche la figure
    except Exception as e:
        print("An error occurred:")
        traceback.print_exc()
        print(f"Exception type: {type(e).__name__}")
        print(f"Exception description: {e}")

