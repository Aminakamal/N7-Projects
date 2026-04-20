%% ====================================================================
% RECONSTRUCTION 3D D'UN OBJET PAR VISION MULTI-VUE (DINOSAURE)
% Etapes : Superpixels -> Binarisation -> Axe median -> 3D -> Maillage
% ====================================================================

clear;
close all;

%% ====================================================================
% ETAPE 1 : CHARGEMENT DES IMAGES MULTI-VUES
% ====================================================================
% Nombre d'images utilisees (36 prises de vue autour de l'objet)
nb_images = 36; 

% Chargement des images : chaque image est chargee dans un tableau 4D
% Dimension : nb_lignes x nb_colonnes x 3_canaux_RGB x nb_images
fprintf('Chargement des %d images...\n', nb_images);
for i = 1:nb_images
    if i<=10
        nom = sprintf('images/viff.00%d.ppm',i-1);
    else
        nom = sprintf('images/viff.0%d.ppm',i-1);
    end
    im(:,:,:,i) = imread(nom); 
end
fprintf('Chargement des images termine\n');

% Affichage d'un echantillon des images pour verifier le chargement
figure; 
subplot(2,2,1); imshow(im(:,:,:,1)); title('Image 1');
subplot(2,2,2); imshow(im(:,:,:,9)); title('Image 9');
subplot(2,2,3); imshow(im(:,:,:,17)); title('Image 17');
subplot(2,2,4); imshow(im(:,:,:,25)); title('Image 25');

%% ====================================================================
% ETAPE 2 : SEGMENTATION PAR SUPERPIXELS (SLIC-like)
% ====================================================================
% Les superpixels sont des regions homogenes en couleur et spatiales
% Objectif : diviser l'image en k=100 superpixels via partitionnement iteratif

% Nombre de superpixels souhaite
k = 100;
ligne = size(im(:,:,:,1),1);
colonne = size(im(:,:,:,1),2);
N = ligne*colonne;
centres = zeros(5,k,nb_images);  % centres contient [L,a,b,x,y] pour chaque superpixel

% Rayon de recherche : taille approximative de chaque superpixel
S = sqrt(N/k);

% Initialisation : placer les k centres en grille reguliere
% nc = nombre de colonnes, nl = nombre de lignes de la grille
nc = round(sqrt(k));
nl = ceil(k / nc);

% Pas de la grille (espacement entre deux centres voisins)
step_lig = ligne / nl;
step_col = colonne / nc;

% Placer les centres initiaux aux emplacements de grille
% Recuperer la couleur Lab et la position (x,y) de chaque centre
fprintf('Initialisation des %d centres de superpixels...\n', k);
for i = 1 : nb_images
    for j = 1 : k
        % Calcul position grille : (l,c) = (ligne, colonne) en grille
        l = fix((j-1)/nc);
        c = mod((j-1),nc);
        
        % Position au centre de chaque cellule grille
        xi = floor(l * step_lig + step_lig/2) + 1;
        yi = floor(c * step_col + step_col/2) + 1;

        % Securite : verifier que la position est bien dans l'image
        xi = min(max(xi, 1), ligne);
        yi = min(max(yi, 1), colonne);

        % Recuperer la couleur en ce point (canal RGB = 1,2,3)
        li = double(im(xi,yi,1,i));
        ai = double(im(xi,yi,2,i));
        bi = double(im(xi,yi,3,i));
        
        % Stocker : [couleur_L, couleur_a, couleur_b, position_x, position_y]
        centres(:,j,i) = [li;ai;bi;xi;yi];
    end
end

% Affichage des centres initiaux pour verifier la grille
figure; 
imshow(im(:,:,:,1)); title('Image 1 - Centres initiaux (SLIC)');
hold on;
scatter(centres(5,:,1), centres(4,:,1), 'red');
hold off;

% ======== AFFINEMENT ITERATIF DES SUPERPIXELS ========
% Algorithme SLIC : chaque pixel est assigne au centre le plus proche
% selon une distance combinant couleur (Lab) et espace (x,y)

m = 10;  % Parametre de ponderation : balance couleur vs espace
         % m petit : priorite a la couleur, m grand : priorite a la geometrie
labels = zeros(ligne,colonne,nb_images) - 1;  % Label de chaque pixel

seuil = 10;  % Seuil de convergence
nouveaux_centres = zeros(5,k,nb_images);

% Boucle iterative sur une seule image (ima=1) pour simplifier
fprintf('Raffinement iteratif des centres...\n');
for ima = 1 : 1
    erreur = 100;
    nb_iterations = 0;
    
    while erreur > seuil && nb_iterations < 10
        % ----- ETAPE 1 : ASSIGNATION des pixels aux centres -----
        distances = zeros(ligne,colonne) + 10e6;  % Initialiser tres grand
        
        % Pour chaque superpixel
        for i = 1 : k
            % Chercher seulement dans une region autour du centre (rayon S)
            for lig = max(1, round(centres(4,i,ima) - S)) : min(ligne, round(centres(4,i,ima) + S))
                for col = max(1, round(centres(5,i,ima) - S)) : min(colonne, round(centres(5,i,ima) + S))
                    
                    % Distance Lab (couleur) : difference entre pixel et centre
                    d_rouge = double(centres(1,i,ima)) - double(im(lig,col,1,ima));
                    d_vert  = double(centres(2,i,ima)) - double(im(lig,col,2,ima));
                    d_bleu  = double(centres(3,i,ima)) - double(im(lig,col,3,ima));
                    dlab = sqrt(d_rouge^2 + d_vert^2 + d_bleu^2);
                    
                    % Distance spatiale (x,y)
                    dxy = sqrt((centres(4,i,ima) - lig)^2 + (centres(5,i,ima) - col)^2);
                    
                    % Distance combinee : D = sqrt(dlab^2 + (m/S * dxy)^2)
                    % Normaliser dxy par S pour rendre les deux termes comparables
                    D = sqrt(dlab^2 + ((m/S)*dxy)^2);
                    
                    % Assigner au centre le plus proche
                    if (D < distances(lig, col))
                        distances(lig, col) = D;
                        labels(lig, col, ima) = i;
                    end
                end
            end
        end

        % ----- ETAPE 2 : MIS A JOUR des centres -----
        % Pour chaque superpixel, calculer le nouveau centre comme la moyenne
        img_n = im(:,:,:,ima);
        label_n = labels(:,:,ima);
        
        % Aplatir les images pour vectoriser les calculs
        img_n_flat = reshape(img_n, [], 3);
        label_n_flat = label_n(:);
        
        % Creer une grille de coordonnees (x,y) pour calculer les moyennes spatiales
        [cols_grid, ligs_grid] = meshgrid(1:colonne, 1:ligne);
        ligs_flat = ligs_grid(:);
        cols_flat = cols_grid(:);
        
        % Mettre a jour les centres
        for i = 1:k
            % Masque : pixels ayant ce label
            masque = (label_n_flat == i);
            
            if any(masque)
                % Couleur moyenne de ce superpixel
                moyenne_couleur = mean(img_n_flat(masque, :), 1);
                
                % Position moyenne (barycentre spatial) de ce superpixel
                moyenne_lig = mean(ligs_flat(masque));
                moyenne_col = mean(cols_flat(masque));
                
                % Stocker le nouveau centre
                nouveaux_centres(:, i, ima) = [moyenne_couleur, moyenne_lig, moyenne_col]';
            else
                % Pas de pixel assigne : garder le centre precedent
                nouveaux_centres(:, i, ima) = centres(:, i, ima); 
            end
        end

        % Calculer l'erreur : norme L2 du deplacement des centres
        erreur = norm(nouveaux_centres(:,:,ima) - centres(:,:,ima));

        % Mettre a jour pour l'iteration suivante
        centres(:,:,ima) = nouveaux_centres(:,:,ima);
        nb_iterations = nb_iterations + 1;
        fprintf('  Iteration %d : erreur = %.2f\n', nb_iterations, erreur);
    end
end

% Affichage des centres affines
figure; 
imshow(im(:,:,:,1)); title('Image 1 - Centres affines (apres iterations)');
hold on;
scatter(centres(5,:,1), centres(4,:,1), 'red');
hold off;

% Affichage des contours des superpixels
figure;
label_ima = labels(:,:,1); 
masque_frontieres = boundarymask(label_ima);  % Trouver les frontieres
imshow(uint8(im(:,:,:,1)));
title('Contours des Superpixels');
hold on;
visboundaries(masque_frontieres, 'Color', 'y', 'LineWidth', 1);
scatter(centres(5,:,1), centres(4,:,1), 20, 'red', 'filled');
hold off;

%% ====================================================================
% ETAPE 3 : BINARISATION DE L'IMAGE (Separation objet/fond)
% ====================================================================
% Convertir chaque superpixel en noir ou blanc selon sa couleur
% Logique : dominante bleue -> fond blanc, sinon -> objet noir

fprintf('Binarisation par superpixels...\n');
image_binaire = im(:,:,:,:);
for ima = 1 : 1
    ligne = size(im(:,:,:,ima),1);
    colonne = size(im(:,:,:,ima),2);
    
    % Determiner la couleur de chaque superpixel
    couleur = zeros(k,3);
    for i = 1 : k
        % Si le bleu > rouge+1 ET bleu > vert+1 : fond bleu -> blanc
        % Sinon : objet -> noir
        if (centres(3,i,ima) > centres(1,i,ima) + 1) && (centres(3,i,ima) > centres(2,i,ima) + 1)
            couleur(i,:) = [0;0;0];     % Noir
        else
            couleur(i,:) = [255;255;255]; % Blanc
        end
    end
    
    % Appliquer la couleur binaire a chaque pixel selon son label
    for x = 1 : ligne
        for y = 1 : colonne
        image_binaire(x,y,:,ima) = couleur(labels(x,y,ima),:);
        end
    end
end

% Creer le masque binaire : une seule image N&B ou 1 = objet, 0 = fond
im_mask = zeros(ligne, colonne, nb_images);
for ima = 1 : 1
    canal_unique = image_binaire(:,:,1,ima);
    % Normaliser entre 0 et 1
    im_mask(:,:,ima) = double(canal_unique) / 255;
end

figure; 
imshow(image_binaire(:,:,:,1)); title('Image binaire');

figure; 
imshow(im_mask(:,:,1)); title('Masque binaire (1=objet, 0=fond)');

%% ====================================================================
% CHARGER LES DONNEES PRATES (SI SUPERPIXELS SONT PRE-CALCULES)
% ====================================================================
% Si vous utilisez des masques fournis plutot que calcules, decommenter :
% clear all; close all;

fprintf('\n===== NOUVELLE ETAPE : Axe Median et Reconstruction 3D =====\n');
nb_images = 36; 

% Charger les images brutes
fprintf('Chargement des %d images...\n', nb_images);
for i = 1:nb_images
    if i<=10
        nom = sprintf('images/viff.00%d.ppm',i-1);
    else
        nom = sprintf('images/viff.0%d.ppm',i-1);
    end
    im(:,:,:,i) = imread(nom); 
end

% Charger les masques pre-calcules
load mask;
fprintf('Chargement des donnees termine\n');

im_mask = imcomplement(im_mask);

% Affichage des images et masques
figure; 
subplot(2,2,1); imshow(im(:,:,:,1)); title('Image 1');
subplot(2,2,2); imshow(im(:,:,:,9)); title('Image 9');
subplot(2,2,3); imshow(im(:,:,:,17)); title('Image 17');
subplot(2,2,4); imshow(im(:,:,:,25)); title('Image 25');

figure;
subplot(2,2,1); imshow(im_mask(:,:,1)); title('Masque image 1');
subplot(2,2,2); imshow(im_mask(:,:,9)); title('Masque image 9');
subplot(2,2,3); imshow(im_mask(:,:,17)); title('Masque image 17');
subplot(2,2,4); imshow(im_mask(:,:,25)); title('Masque image 25');

%% ====================================================================
% ETAPE 4 : EXTRACTION DE L'AXE MEDIAN (Squelette via Voronoi)
% ====================================================================
% L'axe median = ensemble de points equidistants du contour
% Methode : diagramme de Voronoi des points du contour

fprintf('\nCalcul de l''axe median (squelette)...\n');

% Extraire le contour : convertir masque en contour net
masque_2D = logical(im_mask(:,:,1)); 

% Remplir les trous pour obtenir un masque propre
masque_propre = imfill(masque_2D, 'holes');

% Labeler les regions connectees et trouver la plus grande
matrice_labels = bwlabel(masque_propre);
proprietes_regions = regionprops(matrice_labels, 'Area');
toutes_les_surfaces = [proprietes_regions.Area];
[surface_max, index_max] = max(toutes_les_surfaces);
masque_seul_objet = (matrice_labels == index_max);

% Extraire les contours de cet objet
[contours_trouves, ~] = bwboundaries(masque_seul_objet, 'noholes');

figure;
imshow(im_mask(:,:,1)); 
title('Contour du Dinosaure');
hold on;

% Sous-echantillonner les contours (1 point tous les 4 pixels)
contour_sample = contours_trouves{1}(1:4:end,:);

% ----- CALCUL DU DIAGRAMME DE VORONOI -----
% X, Y = points du contour
X = contour_sample(:, 2);  % Colonne (x)
Y = contour_sample(:, 1);  % Ligne (y)

% Voronoi : pour chaque paire de points de contour,
% tracer le segment equidistant (arete du diagramme)
[vx vy] = voronoi(X,Y);
vx = round(vx);
vy = round(vy);

hold on;
plot(vx, vy);
hold off;

% ----- FILTRAGE : GARDER SEULEMENT LES ARETES DANS L'OBJET -----
% Les aretes a l'exterieur du masque sont supprimees
lignes_max = size(im(:,:,:,1),1);
cols_max = size(im(:,:,:,1),2);

for i = 1 : size(vx,2)
    % Points d'extremite de l'arete Voronoi i
    x1 = vx(1, i);
    y1 = vy(1, i);
    x2 = vx(2, i);
    y2 = vy(2, i);

    % Verifier que les 2 points sont dans l'image
    if x1 < 1 || x1 > cols_max || y1 < 1 || y1 > lignes_max || ...
       x2 < 1 || x2 > cols_max || y2 < 1 || y2 > lignes_max
        vx(:, i) = NaN;
        vy(:, i) = NaN;
        continue;
    end
    
    % Verifier que les 2 points sont dans le masque (objet)
    if masque_seul_objet(y1, x1) == 0 || masque_seul_objet(y2, x2) == 0
        vx(:, i) = NaN;
        vy(:, i) = NaN;
    end
end

figure;
imshow(im_mask(:,:,1));
hold on;
plot(vx, vy);
title('Diagramme de Voronoi filtre');
hold off;

% ----- EXTRACTION DES POINTS UNIQUES DU SQUELETTE -----
% Recuperer tous les points des aretes valides et eliminer les doublons
tous_les_points = [vx(:), vy(:)];
points_valides = tous_les_points(~isnan(tous_les_points(:, 1)), :);
points = unique(points_valides, 'rows');

figure;
imshow(im_mask(:,:,1));
hold on;
plot(points(:,1), points(:,2), 'b+', 'LineStyle', 'none');
title('Points du squelette (MAT)');
hold off;

% ----- MATRICE D'ADJACENCE : CONNECTER LES POINTS DU SQUELETTE -----
% Creer un graphe ou les noeuds sont les points du squelette
N = size(points, 1);
matrice_adj = zeros(N, N);

% Pour chaque arete Voronoi restante, creer une arete dans le graphe
for i = 1:size(vx, 2)
    if ~isnan(vx(1, i))
        p1 = [vx(1, i), vy(1, i)];
        p2 = [vx(2, i), vy(2, i)];
        
        % Retrouver les indices de p1 et p2 dans la liste 'points'
        [~, idx1] = ismember(p1, points, 'rows');
        [~, idx2] = ismember(p2, points, 'rows');
        
        if idx1 > 0 && idx2 > 0
            matrice_adj(idx1, idx2) = 1;
            matrice_adj(idx2, idx1) = 1;  % Graphe non-oriente
        end
    end
end

figure;
imshow(im_mask(:,:,1));
hold on;
gplot(matrice_adj, points, 'm.-'); 
title('Topologie du Squelette (Axe Median)');
hold off;

% ----- CALCUL DES RAYONS (MAT = Medial Axis Transform) -----
% Pour chaque point du squelette, calculer sa distance au contour
% Cette distance = rayon du cercle maximal centre en ce point

% Creer une image avec les points du contour
image_contour = false(lignes_max, cols_max);
for i=1:length(X)
    image_contour(Y(i), X(i)) = true; 
end

% Distance transform : chaque pixel prend la distance au contour
carte_distances = bwdist(image_contour);

% Lire le rayon pour chaque point du squelette
rayons = zeros(size(points, 1), 1);
for i = 1:size(points, 1)
    px = round(points(i, 1));
    py = round(points(i, 2));
    rayons(i) = carte_distances(py, px);
end

figure;
imshow(im_mask(:,:,1));
title('Verification de la M.A.T (Cercles maximaux)');
hold on;
viscircles(points, rayons, 'Color', 'c', 'LineWidth', 0.1);
gplot(matrice_adj, points, 'm.-');  % Superposer aussi le squelette
hold off;

%% ====================================================================
% ETAPE 5 : RECONSTRUCTION 3D PAR TRIANGULATION
% ====================================================================
% Les correspondances 2D entre images (pts) et matrices de projection (P)
% permettent de calculer les positions 3D des points via SVD

fprintf('\nChargement des appariements 2D et matrices de projection...\n');

% Charger les correspondances 2D
% pts[i, :] = appariements du point 3D i dans les images
% Format : [x1, y1, x2, y2, ..., x36, y36] ou -1 = pas visible
pts = load('viff.xy');

% Charger les matrices de projection
% P{i} = matrice 3x4 de projection pour l'image i
load dino_Ps;

fprintf('Reconstruction des points 3D via SVD...\n');

% Conteneurs pour les resultats
X = [];      % Coordonnees 3D
color = [];  % Couleur moyenne de chaque point

% Pour chaque point 3D a reconstruire
for i = 1:size(pts,1)
    % Recuperer les indices j des images ou ce point est visible (pts ~= -1)
    l = find(pts(i,1:2:end)~=-1);
    
    % Verifier qu'il existe au moins 2 visibilites valides et espacees
    if size(l,2) > 1 && max(l)-min(l) > 1 && max(l)-min(l) < 36
        
        % Matrice A pour SVD : chaque 2 lignes = 1 equation de projection
        % Forme : P[j](1,:)*X - u[j]*P[j](3,:)*X = 0
        %         P[j](2,:)*X - v[j]*P[j](3,:)*X = 0
        A = [];
        R = 0; G = 0; B = 0;
        
        % Ajouter une equation pour chaque image ou le point est vu
        for j = l
            % Coordonnees 2D du point dans l'image j
            u = pts(i,(j-1)*2+1);    % Colonne (x)
            v = pts(i,(j-1)*2+2);    % Ligne (y)
            
            % Ajouter les 2 equations de projection pour cette image
            A = [A; P{j}(1,:) - u*P{j}(3,:);
                   P{j}(2,:) - v*P{j}(3,:)];
            
            % Accumuler la couleur RGB du point (moyenne sur toutes les vues)
            R = R + double(im(int16(v), int16(u), 1, j));
            G = G + double(im(int16(v), int16(u), 2, j));
            B = B + double(im(int16(v), int16(u), 3, j));
        end
        
        % SVD : A * X = 0, solution = dernier vecteur singulier (colonne de V)
        [U,S,V] = svd(A);
        
        % Point 3D homogene = derniere colonne de V
        % Normaliser par la derniere coordonnee homogene pour obtenir [x,y,z]
        X = [X V(:,end)/V(end,end)];
        
        % Couleur moyenne
        color = [color [R/size(l,2); G/size(l,2); B/size(l,2)]];
    end
end

fprintf('Calcul des points 3D termine : %d points trouves. \n',size(X,2));

% Affichage du nuage de points 3D
figure;
hold on;
for i = 1:size(X,2)
    plot3(X(1,i),X(2,i),X(3,i),'.','col',color(:,i)/255);
end
axis equal;
title('Nuage de points 3D');
hold off;

%% ====================================================================
% ETAPE 6 : MAILLAGE VOLUMIQUE PAR TRIANGULATION DE DELAUNAY
% ====================================================================
% Creer un maillage 3D en tetraedres a partir du nuage de points

fprintf('\nTriangulation volumique (DelaunayTri)...\n');

% Triangulation de Delaunay : creer des tetraedres
% T(i,:) = indices des 4 sommets du tetraedre i
T = DelaunayTri(X(1:3,:)');

fprintf('Tetraedrisation terminee : %d tetraedres trouves. \n',size(T,1));

% Affichage du maillage brut
figure;
tetramesh(T);
title('Maillage Delaunay complet (avant filtrage)');

%% ====================================================================
% ETAPE 7 : FILTRAGE DES TETRAEDRES EXTERNES
% ====================================================================
% Garder seulement les tetraedres qui sont probablement a l'interieur
% de l'objet en testant si leurs barycentres se projettent dans le masque

fprintf('\nFiltrage des tetraedres externes...\n');

% Calcul des barycentres de chaque tetraedre
% On teste plusieurs poids pour plus de robustesse
poids = [0.25, 0.70, 0.10, 0.10, 0.10;
         0.25, 0.10, 0.70, 0.10, 0.10;
         0.25, 0.10, 0.10, 0.70, 0.10;
         0.25, 0.10, 0.10, 0.10, 0.70];
nb_barycentres = size(poids, 2); 

% C_g[i, t, k] = barycentre du tetraedre t avec le poids k
C_g = zeros(4, size(T,1), nb_barycentres);
for i = 1:size(T,1)
    indices_sommets = T(i,:);
    sommets = X(:, indices_sommets);  % 4 colonnes = 4 sommets du tetraedre
    
    % Calculer differents barycentres selon differents poids
    for k = 1:nb_barycentres
        C_g(:, i, k) = sommets * poids(:, k);  % Combinaison lineaire ponderee
    end
end

% Copier la triangulation pour filtrer
tri = T.Triangulation;  % Matrice Nt x 4

% Indicateur : vrai si le tetraedre doit etre garde
keep = true(size(tri, 1), 1);
lignes_max = size(im_mask, 1);
cols_max = size(im_mask, 2);

% Tester chaque tetraedre : projeter ses barycentres dans chaque image
% et verifier qu'ils tombent dans le masque (objet)
for i = 1:nb_images
    fprintf('  Image %d/%d\n', i, nb_images);
    
    for k = 1:nb_barycentres
        % Projeter tous les barycentres dans l'image i
        % Projection homogene : o = P{i} * C_g(:,:,k)
        o = P{i} * C_g(:, :, k);
        
        % Normaliser par la coordonnee homogene (3eme ligne)
        o = o ./ repmat(o(3, :), 3, 1);
        
        % Coordonnees 2D projetees
        u = round(o(2, :));  % Colonne (x)
        v = round(o(1, :));  % Ligne (y)
        
        % Verifier chaque tetraedre
        for t = 1:size(tri, 1)
            if keep(t)
                % Le barycentre doit rester dans l'image
                if u(t) < 1 || u(t) > cols_max || v(t) < 1 || v(t) > lignes_max
                    keep(t) = false;
                % Le barycentre doit tomber dans le masque (objet, pas fond)
                elseif im_mask(v(t), u(t), i) == 0
                    keep(t) = false;
                end
            end
        end
    end
end

% Appliquer le filtre : ne garder que les tetraedres valides
Tbis = tri(keep, :);

fprintf('Retrait des tetraedres exterieurs a la forme 3D termine : %d tetraedres restants. \n', size(Tbis,1));

% Affichage du maillage filtre
figure;
trisurf(Tbis, X(1,:), X(2,:), X(3,:));
title('Maillage Delaunay - Apres filtrage');

% Sauvegarde
save donnees;

%% ====================================================================
% ETAPE 8 : EXTRACTION DES FACES (Maillage surfacique)
% ====================================================================
% A partir du maillage volumique (tetraedres),
% extraire la surface (faces du bord)

fprintf('\nExtraction du maillage surfacique...\n');

% Chaque tetraedre a 4 faces (triangles)
% Faces externes = faces qui n'apparaissent qu'une fois
% Faces internes = faces partagees par 2 tetraedres, eliminer

faces_1 = Tbis(:, [1, 2, 3]);
faces_2 = Tbis(:, [1, 2, 4]);
faces_3 = Tbis(:, [1, 3, 4]);
faces_4 = Tbis(:, [2, 3, 4]);

toutes_les_faces = [faces_1; faces_2; faces_3; faces_4];

% Trier chaque face par ses indices (pour reconnaitre les doublons)
toutes_les_faces = sort(toutes_les_faces, 2);

% Trier les faces globalement
faces_triees = sortrows(toutes_les_faces);

% Identifier et retirer les faces internes (celles qui apparaissent 2 fois)
Nf = size(faces_triees, 1);
faces_a_garder = true(Nf, 1);

i = 1;
while i < Nf
    % Si deux faces consecutives sont identiques, c'est une face interne
    if isequal(faces_triees(i, :), faces_triees(i+1, :))
        faces_a_garder(i) = false;      % Supprimer la premiere
        faces_a_garder(i+1) = false;    % Supprimer la deuxieme
        i = i + 2;
    else
        i = i + 1;
    end
end

% Garder seulement les faces externes
FACES = faces_triees(faces_a_garder, :);

fprintf('Calcul du maillage final termine : %d faces. \n', size(FACES,1));

% Affichage du maillage final surfacique
figure;
trisurf(FACES, X(1,:), X(2,:), X(3,:), ...
        'FaceColor', 'none', 'EdgeColor', 'r');
axis equal;
title('Maillage surfacique final du Dinosaure');
xlabel('X'); ylabel('Y'); zlabel('Z');
