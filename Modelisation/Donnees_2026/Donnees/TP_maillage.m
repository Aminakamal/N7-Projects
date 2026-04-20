clear;
close all;

% =========================================================
% CHARGEMENT DES IMAGES
% On charge 36 images du dinosaure sur fond bleu.
% im est un tableau 4D : (lignes x colonnes x canaux x images)
% =========================================================
nb_images = 36;

for i = 1:nb_images
    if i <= 10
        nom = sprintf('images/viff.00%d.ppm', i-1);
    else
        nom = sprintf('images/viff.0%d.ppm', i-1);
    end
    im(:,:,:,i) = imread(nom);
end

% Affichage de 4 images pour vérification visuelle
figure;
subplot(2,2,1); imshow(im(:,:,:,1));  title('Image 1');
subplot(2,2,2); imshow(im(:,:,:,9));  title('Image 9');
subplot(2,2,3); imshow(im(:,:,:,17)); title('Image 17');
subplot(2,2,4); imshow(im(:,:,:,25)); title('Image 25');

%% =========================================================
% PARTIE 1 : SEGMENTATION EN SUPERPIXELS (algorithme SLIC)
% =========================================================
%Lalgorithme SLIC regroupe les pixels en régions compactes appelées superpixels.
% --- Paramètres ---
k      = 100;                        % Nombre de superpixels souhaités
ligne  = size(im(:,:,:,1), 1);       % Hauteur de l'image
colonne= size(im(:,:,:,1), 2);       % Largeur de l'image
N      = ligne * colonne;            % Nombre total de pixels
S      = sqrt(N / k);                % Taille caractéristique d'un superpixel
                                     % (côté d'une cellule de la grille régulière)
m      = 10;                         % Compacité : grand m = superpixels carrés
                                     % petit m = superpixels qui suivent les bords
%Initialisation des germes. Tu divises limage en une grille régulière de k=100 cellules. 
%Pour chaque cellule, tu calcules un centre (xi, yi) et tu lis la couleur RGB de ce pixel. Chaque germe est donc un vecteur de 5 valeurs : [R, G, B, ligne, colonne]. 
%Le paramètre S = sqrt(N/k) est la taille caractéristique dun superpixel.
% centres(5, k, nb_images) : pour chaque image et chaque superpixel,
% on stocke [R, G, B, ligne_centre, col_centre]
centres = zeros(5, k, nb_images);

% --- Calcul du nombre de cellules sur la grille ---
nc = round(sqrt(k));        % Nombre de colonnes dans la grille
nl = ceil(k / nc);          % Nombre de lignes dans la grille

step_lig = ligne   / nl;    % Espacement vertical entre germes
step_col = colonne / nc;    % Espacement horizontal entre germes

% --- Initialisation des germes : placement régulier sur grille ---
for i = 1 : nb_images
    for j = 1 : k
        % Numéro de ligne et colonne dans la grille (indexé à partir de 0)
        l = fix((j-1) / nc);
        c = mod((j-1),  nc);

        % Coordonnées pixel du centre de la cellule (j,l)
        xi = floor(l * step_lig + step_lig/2) + 1;
        yi = floor(c * step_col + step_col/2) + 1;

        % Clamp pour rester dans les bornes de l'image
        xi = min(max(xi, 1), ligne);
        yi = min(max(yi, 1), colonne);

        % Lecture de la couleur RGB du pixel germe
        li = double(im(xi, yi, 1, i));   % canal Rouge
        ai = double(im(xi, yi, 2, i));   % canal Vert
        bi = double(im(xi, yi, 3, i));   % canal Bleu

        centres(:, j, i) = [li; ai; bi; xi; yi];
    end
end

% Affichage des germes initiaux (avant k-means)
figure;
imshow(im(:,:,:,1)); title('Image 1 — germes initiaux');
hold on;
scatter(centres(5,:,1), centres(4,:,1), 'red');  % (col, ligne) pour scatter
hold off;
%Boucle k-means. À chaque itération, pour chaque germe tu explores uniquement une fenêtre de taille 2S × 2S autour de lui (pas l'image entière, 
%c'est l'astuce de SLIC pour la rapidité. 
%Pour chaque pixel de cette fenêtre tu calcules la distance composite :
%où dlab est la distance colorimétrique RGB et dxy est la distance spatiale. 
%Le paramètre m=10 contrôle la compacité : grand m → superpixels plus carrés, petit m → superpixels qui suivent mieux les bords. 
%Ensuite tu mets à jour les centres en faisant la moyenne des pixels assignés à chaque germe.
%Pourquoi ne pas explorer toute limage ? → Pour que SLIC soit en O(N) et non O(N×k).
%Quel est le rôle de m ? → Pondérer la distance spatiale vs colorimétrique.
%Pourquoi les superpixels sont-ils initialisés sur grille régulière et pas aléatoirement ? 
% =Pour garantir une répartition homogène et une bonne couverture de limage.


% --- Boucle k-means SLIC ---
% labels(ligne, col, image) = indice du superpixel auquel appartient le pixel
labels = zeros(ligne, colonne, nb_images) - 1;

seuil           = 10;   % Seuil de convergence sur le déplacement des centres
nouveaux_centres = zeros(5, k, nb_images);

for ima = 1 : 1   % On traite ici seulement l'image 1
    erreur       = 100;
    nb_iterations = 0;

    while erreur > seuil && nb_iterations < 10

        % distances(l,c) = distance minimale au germe le plus proche
        distances = zeros(ligne, colonne) + 10e6;

        % --- Étape E du k-means : affectation de chaque pixel au germe le + proche ---
        for i = 1 : k
            % On cherche uniquement dans une fenêtre 2S x 2S autour du germe i
            % → complexité O(N) au lieu de O(N*k) sans cette restriction
            for lig = max(1, round(centres(4,i,ima) - S)) : min(ligne, round(centres(4,i,ima) + S))
                for col = max(1, round(centres(5,i,ima) - S)) : min(colonne, round(centres(5,i,ima) + S))

                    % Distance colorimétrique RGB entre pixel et centre du germe i
                    d_rouge = double(centres(1,i,ima)) - double(im(lig,col,1,ima));
                    d_vert  = double(centres(2,i,ima)) - double(im(lig,col,2,ima));
                    d_bleu  = double(centres(3,i,ima)) - double(im(lig,col,3,ima));
                    dlab = sqrt(d_rouge^2 + d_vert^2 + d_bleu^2);

                    % Distance spatiale entre pixel et centre du germe i
                    dxy = sqrt((centres(4,i,ima) - lig)^2 + (centres(5,i,ima) - col)^2);

                    % Distance combinée SLIC : D = sqrt(dlab² + (m/S * dxy)²)
                    % m/S pondère le terme spatial par rapport au terme couleur
                    D = sqrt(dlab^2 + ((m/S) * dxy)^2);

                    % On affecte le pixel au germe le plus proche
                    if D < distances(lig, col)
                        distances(lig, col) = D;
                        labels(lig, col, ima) = i;
                    end
                end
            end
        end

        % --- Étape M du k-means : mise à jour des centres ---
        img_n    = im(:,:,:,ima);       % Image courante (ligne x col x 3)
        label_n  = labels(:,:,ima);     % Carte des labels (ligne x col)

        % Aplatissement pour simplifier les calculs de moyennes
        img_n_flat   = reshape(img_n, [], 3);   % (N x 3)
        label_n_flat = label_n(:);              % (N x 1)

        % Grilles de coordonnées pour calculer la position moyenne
        [cols_grid, ligs_grid] = meshgrid(1:colonne, 1:ligne);
        ligs_flat = ligs_grid(:);
        cols_flat = cols_grid(:);

        for i = 1:k
            masque = (label_n_flat == i);   % Pixels appartenant au superpixel i

            if any(masque)
                % Nouvelle couleur = moyenne RGB des pixels du superpixel
                moyenne_couleur = mean(img_n_flat(masque, :), 1);
                % Nouvelle position = centroïde géométrique
                moyenne_lig = mean(ligs_flat(masque));
                moyenne_col = mean(cols_flat(masque));
                nouveaux_centres(:, i, ima) = [moyenne_couleur, moyenne_lig, moyenne_col]';
            else
                % Superpixel vide → on conserve l'ancien centre
                nouveaux_centres(:, i, ima) = centres(:, i, ima);
            end
        end

        % Critère de convergence : norme du déplacement des centres
        erreur = norm(nouveaux_centres(:,:,ima) - centres(:,:,ima));
        centres(:,:,ima) = nouveaux_centres(:,:,ima);
        nb_iterations = nb_iterations + 1;
    end
end

% Affichage des centres après convergence
figure;
imshow(im(:,:,:,1)); title('Image 1 — centres après k-means');
hold on;
scatter(centres(5,:,1), centres(4,:,1), 'red');
hold off;

% --- Affichage des contours des superpixels ---
figure;
label_ima        = labels(:,:,1);
masque_frontieres = boundarymask(label_ima);   % Détecte les bords entre régions
imshow(uint8(im(:,:,:,1)));
title('Contours des superpixels');
hold on;
visboundaries(masque_frontieres, 'Color', 'y', 'LineWidth', 1);
scatter(centres(5,:,1), centres(4,:,1), 20, 'red', 'filled');
hold off;

%% =========================================================
% PARTIE 2 : BINARISATION (fond bleu → noir, dinosaure → blanc)
% =========================================================
%Pourquoi sappuyer sur les superpixels plutôt que pixel à pixel ? 
%→ Plus robuste au bruit, les superpixels correspondent à des régions homogènes.
%Quelle autre approche aurait pu marcher ? → Critère de compacité des régions, ou seuillage dans lespace LAB.

image_binaire = im(:,:,:,:);   % On va écraser les valeurs RGB

for ima = 1 : 1
    ligne   = size(im(:,:,:,ima), 1);
    colonne = size(im(:,:,:,ima), 2);

    couleur = zeros(k, 3);   % Couleur binaire assignée à chaque superpixel

    for i = 1 : k
        % Critère couleur : si le canal bleu (3) domine rouge (1) ET vert (2)
        % → c'est du fond bleu → on met noir
        % centres(1,...) = Rouge, centres(2,...) = Vert, centres(3,...) = Bleu
        if (centres(3,i,ima) > centres(1,i,ima) + 1) && ...
           (centres(3,i,ima) > centres(2,i,ima) + 1)
            couleur(i,:) = [0; 0; 0];      % Fond → noir
        else
            couleur(i,:) = [255; 255; 255]; % Forme → blanc
        end
    end

    % Application : chaque pixel reçoit la couleur de son superpixel
    for x = 1 : ligne
        for y = 1 : colonne
            image_binaire(x, y, :, ima) = couleur(labels(x,y,ima), :);
        end
    end
end

% Conversion en masque [0,1] (on prend un seul canal, blanc=1, noir=0)
im_mask = zeros(ligne, colonne, nb_images);
for ima = 1 : 1
    canal_unique      = image_binaire(:,:,1,ima);
    im_mask(:,:,ima) = double(canal_unique) / 255;
end

figure; imshow(image_binaire(:,:,:,1)); title('Image binaire');
figure; imshow(im_mask(:,:,1));         title('Masque binaire');

%% =========================================================
% CHARGEMENT DES MASQUES FOURNIS (meilleure qualité)
% On repart de zéro avec les masques officiels
% =========================================================

clear all;
close all;
nb_images = 36;

for i = 1:nb_images
    if i <= 10
        nom = sprintf('images/viff.00%d.ppm', i-1);
    else
        nom = sprintf('images/viff.0%d.ppm', i-1);
    end
    im(:,:,:,i) = imread(nom);
end

% Chargement des masques pré-calculés (fond=1 dans le fichier)
load mask;
fprintf('Chargement des données terminé\n');

% ATTENTION : imcomplement inverse le masque car la convention du fichier
% est fond=1/objet=0, alors qu'on veut objet=1 (blanc) / fond=0 (noir)
im_mask = imcomplement(im_mask);

% Affichage des images et masques associés
figure;
subplot(2,2,1); imshow(im(:,:,:,1));  title('Image 1');
subplot(2,2,2); imshow(im(:,:,:,9));  title('Image 9');
subplot(2,2,3); imshow(im(:,:,:,17)); title('Image 17');
subplot(2,2,4); imshow(im(:,:,:,25)); title('Image 25');

figure;
subplot(2,2,1); imshow(im_mask(:,:,1));  title('Masque image 1');
subplot(2,2,2); imshow(im_mask(:,:,9));  title('Masque image 9');
subplot(2,2,3); imshow(im_mask(:,:,17)); title('Masque image 17');
subplot(2,2,4); imshow(im_mask(:,:,25)); title('Masque image 25');

%% =========================================================
% PARTIE 3 : AXE MÉDIAN (MAT — Medial Axis Transform)
% Les points du squelette = sommets du diagramme de Voronoï
% des points du contour = centres des cercles maximaux inscrits
% =========================================================

% --- Étape 3.1 : Extraction du contour de la forme ---
%Tu utilises bwboundaries pour trouver les pixels de bord de la forme binaire après imfill pour boucher les trous et bwlabel pour garder le plus grand composant connexe. 
%Tu sous-échantillonnes avec contours_trouves{1}(1:4:end,:) pour réduire le nombre de points.
masque_2D = logical(im_mask(:,:,1));

% imfill : bouche les trous intérieurs pour éviter des contours parasites
masque_propre = imfill(masque_2D, 'holes');

% bwlabel : étiquette les composantes connexes
matrice_labels     = bwlabel(masque_propre);
proprietes_regions = regionprops(matrice_labels, 'Area');

% On garde uniquement la plus grande composante connexe (le dinosaure)
toutes_les_surfaces    = [proprietes_regions.Area];
[surface_max, index_max] = max(toutes_les_surfaces);
masque_seul_objet      = (matrice_labels == index_max);

% Extraction du contour (coordonnées en (ligne, colonne))
[contours_trouves, ~] = bwboundaries(masque_seul_objet, 'noholes');

figure;
imshow(im_mask(:,:,1));
title('Contour du dinosaure');
hold on;

% Sous-échantillonnage 1/4 : réduire le nombre de points pour accélérer
% le calcul du Voronoï (compromis précision / temps de calcul)
contour_sample = contours_trouves{1}(1:4:end, :);

% --- Étape 3.2 : Calcul du diagramme de Voronoï ---
%Les sommets du diagramme de Voronoï des points du contour sont exactement les centres des cercles circonscrits aux triangles de Delaunay 
%— ce sont donc les candidats pour laxe médian. Tu calcules voronoi(X, Y)
% ATTENTION : voronoi attend (x, y) = (colonne, ligne)
X = contour_sample(:, 2);   % x = colonnes
Y = contour_sample(:, 1);   % y = lignes

% vx, vy : matrices 2 x nb_arêtes
% chaque colonne i = une arête reliant (vx(1,i),vy(1,i)) à (vx(2,i),vy(2,i))
[vx, vy] = voronoi(X, Y);
vx = round(vx);
vy = round(vy);

hold on;
plot(vx, vy);   % Affichage du Voronoï brut (avant filtrage)
hold off;

lignes_max = size(im(:,:,:,1), 1);
cols_max   = size(im(:,:,:,1), 2);

% --- Étape 3.3 : Filtrage — on garde uniquement les arêtes intérieures ---
%Tu ne gardes que les sommets Voronoï qui sont à lintérieur de la forme (masque_seul_objet(y,x) == 1) et dans les bornes de limage. 
%Cest ce qui donne laxe médian interne.
for i = 1 : size(vx, 2)
    x1 = vx(1,i); y1 = vy(1,i);
    x2 = vx(2,i); y2 = vy(2,i);

    % Supprimer les arêtes hors image
    if x1<1 || x1>cols_max || y1<1 || y1>lignes_max || ...
       x2<1 || x2>cols_max || y2<1 || y2>lignes_max
        vx(:,i) = NaN;
        vy(:,i) = NaN;
        continue;
    end

    % Supprimer les arêtes dont un sommet est hors du masque (extérieur à la forme)
    % masque_seul_objet(y,x) → on indexe en (ligne, colonne) !
    if masque_seul_objet(y1, x1) == 0 || masque_seul_objet(y2, x2) == 0
        vx(:,i) = NaN;
        vy(:,i) = NaN;
    end
end

figure;
imshow(im_mask(:,:,1));
hold on;
plot(vx, vy);   % Voronoï filtré (axe médian interne)
hold off;

% --- Collecte des sommets valides (non NaN) ---
tous_les_points = [vx(:), vy(:)];
points_valides  = tous_les_points(~isnan(tous_les_points(:,1)), :);
points          = unique(points_valides, 'rows');   % Dédupliquer

figure;
imshow(im_mask(:,:,1));
hold on;
plot(points(:,1), points(:,2), 'b+', 'LineStyle', 'none');
hold off;

% --- Étape 3.4 : Construction de la matrice d'adjacence ---
%Tu construis une matrice dadjacence en reprenant les arêtes du diagramme de Voronoï — 
%deux points squelette sont connectés si larête Voronoï correspondante est valide. Tu traces avec gplot
% Deux sommets sont connectés si l'arête Voronoï correspondante est valide
N_pts      = size(points, 1);
matrice_adj = zeros(N_pts, N_pts);

for i = 1:size(vx, 2)
    if ~isnan(vx(1,i))
        p1 = [vx(1,i), vy(1,i)];
        p2 = [vx(2,i), vy(2,i)];

        % ismember(...,'rows') cherche la ligne entière dans la matrice
        [~, idx1] = ismember(p1, points, 'rows');
        [~, idx2] = ismember(p2, points, 'rows');

        if idx1 > 0 && idx2 > 0
            matrice_adj(idx1, idx2) = 1;
            matrice_adj(idx2, idx1) = 1;   % Matrice symétrique (arête non orientée)
        end
    end
end

% gplot trace toutes les arêtes de la matrice d'adjacence
figure;
imshow(im_mask(:,:,1));
hold on;
gplot(matrice_adj, points, 'm.-');
title('Topologie du squelette (axe médian)');
hold off;

% --- Étape 3.5 (Bonus) : Calcul des rayons par bwdist ---
% Pour chaque point du squelette, le rayon = distance au bord le plus proche
% = rayon du cercle maximal inscrit en ce point

% Image binaire avec uniquement les pixels du contour
image_contour = false(lignes_max, cols_max);
for i = 1:length(X)
    image_contour(Y(i), X(i)) = true;
end

% bwdist : distance euclidienne de chaque pixel à l'objet binaire (ici le contour)
carte_distances = bwdist(image_contour);

rayons = zeros(size(points, 1), 1);
for i = 1:size(points, 1)
    px = round(points(i, 1));   % x = colonne
    py = round(points(i, 2));   % y = ligne
    rayons(i) = carte_distances(py, px);
end

figure;
imshow(im_mask(:,:,1));
title('Vérification MAT — cercles maximaux');
hold on;
viscircles(points, rayons, 'Color', 'c', 'LineWidth', 0.1);
gplot(matrice_adj, points, 'm.-');
hold off;

%% =========================================================
% PARTIE 4 : RECONSTRUCTION 3D ET MAILLAGE SURFACIQUE
% =========================================================

% Chargement des points 2D appariés et des matrices de projection caméra
% pts(i, 2j-1:2j) = coordonnées (x,y) du point i dans l'image j (-1 si absent)
pts = load('viff.xy');
load dino_Ps;   % P{i} : matrice de projection 3x4 de la caméra i

% --- Reconstruction des points 3D par triangulation multi-vues ---
X     = [];   % Coordonnées 3D des points
color = [];   % Couleur RGB associée

for i = 1:size(pts, 1)
    % Récupération des images où ce point est visible (colonne non égale à -1)
    l = find(pts(i, 1:2:end) ~= -1);

    % On ne traite que les points vus dans au moins 2 images non consécutives
    if size(l,2) > 1 && max(l)-min(l) > 1 && max(l)-min(l) < 36
        A = [];   % Matrice du système linéaire A·X = 0
        R = 0; G = 0; B = 0;

        for j = l
            % Pour chaque vue j, on ajoute 2 lignes à A selon la contrainte :
            %   P(1,:) - u*P(3,:) et P(2,:) - v*P(3,:)
            % où (u,v) sont les coordonnées 2D observées dans l'image j
            A = [A;
                 P{j}(1,:) - pts(i,(j-1)*2+1) * P{j}(3,:);
                 P{j}(2,:) - pts(i,(j-1)*2+2) * P{j}(3,:)];

            % Accumulation des couleurs pour moyenner
            R = R + double(im(int16(pts(i,(j-1)*2+1)), int16(pts(i,(j-1)*2+2)), 1, j));
            G = G + double(im(int16(pts(i,(j-1)*2+1)), int16(pts(i,(j-1)*2+2)), 2, j));
            B = B + double(im(int16(pts(i,(j-1)*2+1)), int16(pts(i,(j-1)*2+2)), 3, j));
        end

        % SVD : solution = dernière colonne de V (vecteur singulier droit)
        % On normalise par la 4e coordonnée (passage homogène → cartésien)
        [U, S, V] = svd(A);
        X     = [X V(:,end)/V(end,end)];
        color = [color [R/size(l,2); G/size(l,2); B/size(l,2)]];
    end
end
fprintf('Calcul des points 3D terminé : %d points trouvés.\n', size(X,2));

% Affichage du nuage de points 3D coloré
figure;
hold on;
for i = 1:size(X,2)
    plot3(X(1,i), X(2,i), X(3,i), '.', 'col', color(:,i)/255);
end
axis equal;

%% --- Tétraédrisation de Delaunay ---
% DelaunayTri remplit l'enveloppe convexe entière avec des tétraèdres
% Beaucoup de tétraèdres seront hors du dinosaure → il faudra les filtrer
T = DelaunayTri(X(1:3,:)');
fprintf('Tétraédrisation terminée : %d tétraèdres trouvés.\n', size(T,1));

figure;
tetramesh(T);   % Visualisation de tous les tétraèdres

%% --- Calcul des barycentres pour le filtrage ---
% Pour chaque tétraèdre, on calcule 5 barycentres avec des poids différents :
% - 1 barycentre géométrique (poids = 0.25 partout)
% - 4 barycentres biaisés vers chaque sommet (poids = 0.70 vers un sommet)
% Cela permet de tester les coins du tétraèdre, pas seulement son centre
%Pour chaque tétraèdre, tu calcules plusieurs barycentres (avec des poids différents pour sapprocher de chaque sommet). 
%Tu projettes chaque barycentre dans chacune des 36 images via la matrice de projection P{i}.
% Si la projection tombe hors du masque ou hors de l'image, le tétraèdre est supprimé.
poids = [0.25, 0.70, 0.10, 0.10, 0.10;
         0.25, 0.10, 0.70, 0.10, 0.10;
         0.25, 0.10, 0.10, 0.70, 0.10;
         0.25, 0.10, 0.10, 0.10, 0.70];

nb_barycentres = size(poids, 2);
C_g = zeros(4, size(T,1), nb_barycentres);   % C_g(:, tétraèdre, barycentre)

for i = 1:size(T,1)
    indices_sommets = T(i,:);                 % Indices des 4 sommets du tétraèdre i
    sommets = X(:, indices_sommets);          % Coordonnées 3D homogènes (4x4)

    for kk = 1:nb_barycentres
        % Barycentre k = combinaison linéaire des sommets avec les poids
        C_g(:, i, kk) = sommets * poids(:, kk);
    end
end

%% --- Filtrage des tétraèdres hors de la forme 3D ---
% Pour chaque tétraèdre, si un barycentre se projette hors du masque
% dans au moins une image → on le supprime

tri  = T.Triangulation;   % Copie modifiable de la triangulation
keep = true(size(tri, 1), 1);   % Vecteur logique : true = garder le tétraèdre

lignes_max = size(im_mask, 1);
cols_max   = size(im_mask, 2);

for i = 1:nb_images
    for kk = 1:nb_barycentres
        % Projection de tous les barycentres dans l'image i
        o = P{i} * C_g(:, :, kk);
        % Normalisation homogène : division par la 3e coordonnée (facteur d'échelle w)
        o = o ./ repmat(o(3,:), 3, 1);

        % Coordonnées pixel arrondies
        u = round(o(2,:));   % Colonnes
        v = round(o(1,:));   % Lignes

        for t = 1:size(tri, 1)
            if keep(t)
                % Vérification que le barycentre est dans l'image
                if u(t)<1 || u(t)>cols_max || v(t)<1 || v(t)>lignes_max
                    keep(t) = false;
                % Vérification que le barycentre tombe dans le dinosaure (masque=1)
                elseif im_mask(v(t), u(t), i) == 0
                    keep(t) = false;
                end
            end
        end
    end
end

% Application du masque logique
Tbis = tri(keep, :);
fprintf('Filtrage terminé : %d tétraèdres restants.\n', size(Tbis,1));

figure;
trisurf(Tbis, X(1,:), X(2,:), X(3,:));   % Volume 3D filtré

% Sauvegarde pour ne pas relancer les calculs longs à chaque fois
save donnees;

%% =========================================================
% PARTIE 4.3 : EXTRACTION DU MAILLAGE SURFACIQUE
% Une face est sur la surface ↔ elle appartient à 1 seul tétraèdre
% =========================================================
%Un tétraèdre a 4 faces. Une face est sur la surface si et seulement si elle appartient à un seul tétraèdre (pas partagée). 
%Tu listes toutes les faces, tu tries, et tu gardes celles qui n'apparaissent qu'une seule fois. 
%Cest lalgorithme en O(n log n) décrit dans le sujet.
% --- Étape 1 : Lister toutes les faces (4 faces triangulaires par tétraèdre) ---
faces_1 = Tbis(:, [1,2,3]);
faces_2 = Tbis(:, [1,2,4]);
faces_3 = Tbis(:, [1,3,4]);
faces_4 = Tbis(:, [2,3,4]);
toutes_les_faces = [faces_1; faces_2; faces_3; faces_4];

% --- Étape 2 : Normalisation — trier les indices dans chaque face ---
% Nécessaire pour que [A,B,C] et [C,A,B] soient reconnus comme identiques
toutes_les_faces = sort(toutes_les_faces, 2);   % Tri par ligne (indices croissants)

% --- Étape 3 : Trier toutes les faces → les doublons sont adjacents ---
% Complexité O(n log n) — beaucoup plus efficace que la comparaison naïve O(n²)
faces_triees = sortrows(toutes_les_faces);

% --- Étape 4 : Parcourir et supprimer les faces apparaissant 2 fois ---
% Une face présente 2 fois = face intérieure (partagée entre 2 tétraèdres)
% Une face présente 1 fois = face de surface (bord entre matière et vide)
Nf = size(faces_triees, 1);
faces_a_garder = true(Nf, 1);

i = 1;
while i < Nf
    if isequal(faces_triees(i,:), faces_triees(i+1,:))
        % Doublon détecté → face intérieure → on supprime les deux occurrences
        faces_a_garder(i)   = false;
        faces_a_garder(i+1) = false;
        i = i + 2;
    else
        i = i + 1;
    end
end

FACES = faces_triees(faces_a_garder, :);
fprintf('Maillage final : %d faces de surface.\n', size(FACES,1));

% --- Affichage du maillage surfacique final ---
figure;
trisurf(FACES, X(1,:), X(2,:), X(3,:), 'FaceColor', 'none', 'EdgeColor', 'r');
axis equal;
title('Maillage surfacique final du dinosaure');