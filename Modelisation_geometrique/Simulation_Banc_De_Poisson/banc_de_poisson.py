import numpy as np
from scipy.spatial import cKDTree

class BancDePoissons:
    # Modélisation d'un banc de poissons par une liste de positions et de vitesses en 3D
    def __init__(self, nombre_poissons, zone_limite):
        self.N = nombre_poissons
        self.zone_limite = zone_limite
        
        # Initialisation aléatoire des positions et vitesses en 3D
        self.positions = np.random.uniform(-zone_limite, zone_limite, (self.N, 3))
        self.vitesses = np.random.uniform(-1, 1, (self.N, 3))
        
        # Pour l'effet Trafalgar
        self.contamines = np.zeros(self.N, dtype=bool)
        self.couleurs = np.array(['bleu'] * self.N, dtype=object)

    # Mise à jour de la position : position(t + ∆t) = position(t) + vitesse(t) × ∆t
    def mise_a_jour_positions(self, dt):
        # Mise à jour de la position
        self.positions += self.vitesses * dt
        
        # Vérification des frontières (inversion de la vitesse)
        hors_limites = (self.positions < -self.zone_limite) | (self.positions > self.zone_limite)
        self.vitesses[hors_limites] *= -1

    # Mise à jour de la position avec téléportation
    def mise_a_jour_positions_teleportation(self, dt):
        # Mise à jour de la position
        self.positions += self.vitesses * dt
        
        # Téléportation aux frontières (les poissons sortant d'un côté réapparaissent de l'autre)
        taille_boite = 2 * self.zone_limite
        self.positions = ((self.positions + self.zone_limite) % taille_boite) - self.zone_limite

    # 
    def effet_trafalgar(self, limite_distance):
        # 1. Sélection du leader au début de la simulation
        if not np.any(self.contamines):
            leader = np.random.choice(self.N)
            self.contamines[leader] = True
            self.couleurs[leader] = 'rouge' # Distinguer le leader
            
        # 2. Identifier les indices des poissons actuellement contaminés
        idx_contamines = np.where(self.contamines)[0]
        
        # 3. Calcul des distances euclidiennes et propagation
        for p in range(self.N):
            if not self.contamines[p]:
                # Calcul de la distance entre un poisson et tous les poissons contaminés
                distances = np.linalg.norm(self.positions[idx_contamines] - self.positions[p], axis=1)
                
                # a. Trouver les voisins proches contaminés
                # b. Adopter le comportement
                if np.any(distances < limite_distance):
                    variation_aleatoire = np.random.uniform(-0.5, 0.5, 3)
                    self.vitesses[p] += variation_aleatoire
                    self.contamines[p] = True
                    self.couleurs[p] = 'vert'
    
    def regles_aoki(self, r_rep, r_ali, r_att, V_constante, k_rep, k_att):
        # 1. Construction du KDTree
        arbre = cKDTree(self.positions)
        
        # 2. Recherche des voisins dans le rayon d'attraction maximum (r_att)
        # On utilise query_ball_point pour obtenir TOUS les voisins dans le rayon, 
        # plutôt qu'un nombre fixe k=7, pour respecter strictement "identifier les voisins dans les 3 zones"
        voisins_indices = arbre.query_ball_point(self.positions, r=r_att)
        
        nouvelles_vitesses = np.copy(self.vitesses)
        
        for i in range(self.N):
            F_repulsion = np.zeros(3)
            F_alignement = np.zeros(3)
            F_attraction = np.zeros(3)
            n_ali = 0
            
            # Application des forces de comportement
            for j_idx in voisins_indices[i]:
                if i == j_idx:
                    continue # On s'exclut soi-même
                    
                vec_d = self.positions[i] - self.positions[j_idx] # Vecteur d = pi - pj
                dist = np.linalg.norm(vec_d)
                
                if dist < r_rep:
                    # Évitement (Répulsion) : proportionnelle à k_rep
                    # Force subie par i : s'éloigne de j (direction pi - pj)
                    F_repulsion += k_rep * (vec_d / dist)
                elif dist < r_ali:
                    # Alignement : on somme les vitesses
                    F_alignement += self.vitesses[j_idx]
                    n_ali += 1
                elif dist < r_att:
                    # Attraction : proportionnelle à k_att
                    # Force subie par i : se rapproche de j (direction pj - pi, donc -vec_d)
                    F_attraction -= k_att * (vec_d / dist)
                    
            if n_ali > 0:
                # Moyenne des vitesses pour l'alignement
                F_alignement = F_alignement / n_ali
                
            # 3. Mise à jour des vitesses : combinaison des forces
            v_nouvelle = self.vitesses[i] + F_repulsion + F_alignement + F_attraction
            
            # Normalisation de la vitesse
            norme = np.linalg.norm(v_nouvelle)
            if norme > 0:
                nouvelles_vitesses[i] = (v_nouvelle / norme) * V_constante
                
        self.vitesses = nouvelles_vitesses

    def regles_aoki_densite(self, r_rep, r_ali, r_att, V_constante, k_rep, k_att):
        # 1. Construction du KDTree
        arbre = cKDTree(self.positions)
        
        # 2. Recherche des 7 voisins les plus proches (le premier étant le poisson lui-même)
        distances, indices = arbre.query(self.positions, k=7)
        
        nouvelles_vitesses = np.copy(self.vitesses)
        
        for i in range(self.N):
            # 3. Filtrage : On exclut le premier voisin (indice 0) pour ne garder que les 6 plus proches
            voisins_idx = indices[i, 1:]
            
            F_repulsion = np.zeros(3)
            F_alignement = np.zeros(3)
            F_attraction = np.zeros(3)
            n_ali = 0
            
            # Application des forces de comportement uniquement sur les 6 voisins
            for j_idx in voisins_idx:
                vec_d = self.positions[i] - self.positions[j_idx] # Vecteur d = pi - pj
                dist = np.linalg.norm(vec_d)
                
                if dist > 0:
                    if dist < r_rep:
                        # Évitement (Répulsion)
                        F_repulsion += k_rep * (vec_d / dist)
                    elif dist < r_ali:
                        # Alignement
                        F_alignement += self.vitesses[j_idx]
                        n_ali += 1
                    elif dist < r_att:
                        # Attraction
                        F_attraction -= k_att * (vec_d / dist)
                        
            if n_ali > 0:
                # Moyenne des vitesses pour l'alignement
                F_alignement = F_alignement / n_ali
                
            # Mise à jour des vitesses
            v_nouvelle = self.vitesses[i] + F_repulsion + F_alignement + F_attraction
            
            # Normalisation de la vitesse
            norme = np.linalg.norm(v_nouvelle)
            if norme > 0:
                nouvelles_vitesses[i] = (v_nouvelle / norme) * V_constante
                
        self.vitesses = nouvelles_vitesses

    def regles_aoki_influence(self, r_rep, r_ali, r_att, V_constante, k_rep, k_att):
        # Angle max de vision : 30 degrés en radians (pour un cône total de 60 degrés)
        angle_max_rad = np.radians(90)
        
        arbre = cKDTree(self.positions)
        # On recherche dans le rayon maximum d'attraction
        voisins_indices = arbre.query_ball_point(self.positions, r=r_att)
        
        nouvelles_vitesses = np.copy(self.vitesses)
        
        for i in range(self.N):
            F_repulsion = np.zeros(3)
            F_alignement = np.zeros(3)
            F_attraction = np.zeros(3)
            n_ali = 0
            
            # Direction de déplacement de i (vi)
            norme_vi = np.linalg.norm(self.vitesses[i])
            dir_i = self.vitesses[i] / norme_vi if norme_vi > 0 else np.zeros(3)
            
            # Application des forces de comportement uniquement sur les particules visibles
            for j_idx in voisins_indices[i]:
                if i == j_idx:
                    continue
                    
                # d est le vecteur allant de i vers j : pj - pi
                vec_d = self.positions[j_idx] - self.positions[i]
                dist = np.linalg.norm(vec_d)
                
                if dist > 0:
                    # Règle visuelle : angle entre vi et la direction vers j
                    dir_d = vec_d / dist
                    cos_theta = np.clip(np.dot(dir_i, dir_d), -1.0, 1.0)
                    angle = np.arccos(cos_theta)
                    
                    # Si l'angle est dans le cône de vision (visible)
                    if angle < angle_max_rad:
                        if dist < r_rep:
                            # Évitement (Répulsion) : on va dans le sens opposé à j
                            F_repulsion += k_rep * (-vec_d / dist)
                        elif dist < r_ali:
                            # Alignement : on prend la vitesse de j
                            F_alignement += self.vitesses[j_idx]
                            n_ali += 1
                        elif dist < r_att:
                            # Attraction : on va vers j
                            F_attraction += k_att * (vec_d / dist)
                            
            if n_ali > 0:
                # Moyenne des vitesses pour l'alignement
                F_alignement = F_alignement / n_ali
                
            # Mise à jour des vitesses
            v_nouvelle = self.vitesses[i] + F_repulsion + F_alignement + F_attraction
            
            # Normalisation de la vitesse
            norme = np.linalg.norm(v_nouvelle)
            if norme > 0:
                nouvelles_vitesses[i] = (v_nouvelle / norme) * V_constante
                
        self.vitesses = nouvelles_vitesses