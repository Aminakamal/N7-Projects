%============================================================
% TP8 - Exercice 2 : decomposition ROF (structure + texture)
%============================================================
clear; close all;

%--- Lecture image ---
u = imread('Images/Lena.jpg');         % ou autre image
u = double(u);
[nl, nc, nch] = size(u);
N = nl * nc;

%--- Parametres ROF ---
lambda  = 100;        % poids de la TV (plus grand = plus lisse)
epsilon = 0.01;       % regularisation pour TV differentiable
n_iter  = 20;         % nombre d'iterations de point fixe

%--- Construction des matrices de derivees Dx, Dy (creuses) ---
% Dx : difference avant en x (colonnes), Dy : en y (lignes)
e  = ones(N, 1);
Dx = spdiags([-e e], [0 nl], N, N);     % d/dx (col suivante - col)
Dy = spdiags([-e e], [0 1 ], N, N);     % d/dy (ligne suivante - ligne)

% Annuler les derivees qui sortent du domaine (bords)
% bord droit pour Dx : derniere colonne
idx_bord_x = (nl*(nc-1)+1):N;
Dx(idx_bord_x, :) = 0;
% bord bas pour Dy : ligne nl tous les nl pixels
idx_bord_y = nl:nl:N;
Dy(idx_bord_y, :) = 0;

%--- Boucle sur les canaux (R,G,B si couleur) ---
u_bar = zeros(size(u));
u_c   = zeros(size(u));

for ch = 1:nch
    canal  = u(:,:,ch);
    ubar_k = canal;                      % initialisation u^(0) = u

    for k = 1:n_iter
        % --- Calcul des gradients de u^(k) ---
        gx = Dx * ubar_k(:);
        gy = Dy * ubar_k(:);

        % --- Matrice diagonale W^(k) ---
        w = 1 ./ sqrt(gx.^2 + gy.^2 + epsilon);
        W = spdiags(w, 0, N, N);

        % --- Matrice A^(k) du systeme ---
        Ak = speye(N) - lambda * (-Dx' * W * Dx - Dy' * W * Dy);

        % --- Resolution lineaire ---
        ubar_kp1 = Ak \ canal(:);
        ubar_k   = reshape(ubar_kp1, nl, nc);

        % --- Affichage live (facultatif) ---
        imshow(uint8(ubar_k));
        title(sprintf('Canal %d - iteration %d', ch, k));
        drawnow nocallbacks;
    end

    u_bar(:,:,ch) = ubar_k;
    u_c  (:,:,ch) = canal - ubar_k;     % texture = residu
end

%--- Affichage final ---
figure;
subplot(1,3,1); imshow(uint8(u));               title('Image u');
subplot(1,3,2); imshow(uint8(u_bar));           title('Structure $\bar{u}$');
subplot(1,3,3); imshow(uint8(u_c + 128));       title('Texture u^c (+128)');
% Le +128 sur la texture est juste pour la visualisation (centree sur gris)

