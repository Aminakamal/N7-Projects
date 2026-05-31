clear;
close all;

% Lecture de l'image couleur :
u = imread('Images/Lena.jpg');
if ndims(u) == 2
    u = repmat(u,[1 1 3]);
end
u = im2double(u);
[nb_lignes, nb_colonnes, nb_canaux] = size(u);
N = nb_lignes * nb_colonnes;

% Operateurs de differences finies :
Dx1 = spdiags([-ones(nb_colonnes,1), ones(nb_colonnes,1)], [0 1], nb_colonnes, nb_colonnes);
Dx1(end,end) = 0;
Dy1 = spdiags([-ones(nb_lignes,1), ones(nb_lignes,1)], [0 1], nb_lignes, nb_lignes);
Dy1(end,end) = 0;
Dx = kron(speye(nb_lignes), Dx1);
Dy = kron(Dy1, speye(nb_colonnes));

% Filtre passe-bas en frequences :
[nu_x, nu_y] = meshgrid(1:nb_colonnes, 1:nb_lignes);
nu_x = nu_x / nb_colonnes - 0.5;
nu_y = nu_y / nb_lignes   - 0.5;
eta  = 0.05;
Phi  = 1 ./ (1 + (nu_x.^2 + nu_y.^2) / eta);

% Parametres du modele :
epsilon      = 0.5;
mu0          = 5000;
gamma        = 3e-5;
nb_iterations = 1000;
pas_affichage = 50;

% Initialisation :
u_structure = u;

figure('Name','Decomposition structure + texture par TV-Hilbert');

for k = 1:nb_iterations
    for canal = 1:nb_canaux
        u_originale = u(:,:,canal);
        u_courante  = u_structure(:,:,canal);

        % Terme FFT : TF^{-1}{ Phi * [TF(u^k) - TF(u)] }
        filtre = partie_basse(u_courante, u_originale, Phi, nb_lignes, nb_colonnes);

        % Derivees partielles (vectorisees) :
        u_vec = u_courante(:);
        ux    =  Dx  * u_vec;
        uy    =  Dy  * u_vec;
        uxx   = -Dx' * ux;
        uxy   = -Dx' * uy;
        uyy   = -Dy' * uy;

        % Courbure  equation (14) :
        denom32   = (ux.^2 + uy.^2 + epsilon).^(3/2);
        divergence = (uxx .* (uy.^2 + epsilon) ...
                    + uyy .* (ux.^2 + epsilon) ...
                    - 2 * ux .* uy .* uxy) ./ denom32;

        % Mise a jour  equation (13) :
        u_vec = real(u_vec - gamma * (filtre(:) - mu0 * divergence));
        u_structure(:,:,canal) = reshape(u_vec, nb_lignes, nb_colonnes);
    end

    % Affichage :
    if mod(k, pas_affichage) == 0 || k == 1 || k == nb_iterations
        u_texture = u - u_structure;
        clf;
        subplot(1,3,1); affichage_rgb(u,           'Image originale');
        subplot(1,3,2); affichage_rgb(u_structure,  'Structure');
        subplot(1,3,3); affichage_rgb(u_texture,    'Texture');
        sgtitle(sprintf('TV-Hilbert  iteration %d/%d', k, nb_iterations), ...
                'FontSize', 14);
        drawnow;
    end
end

u_texture = u - u_structure;

% =========================================================
function g = partie_basse(u_k, u_orig, Phi, nb_lignes, nb_colonnes)
% Calcule real( TF^{-1}{ Phi * [TF(u_k) - TF(u_orig)] } )
    S_diff = fftshift(fft2(u_k)) - fftshift(fft2(u_orig));
    g = real(ifft2(ifftshift(Phi .* S_diff)));
end

% =========================================================
function affichage_rgb(I, titre)
    I = double(I);
    I = I - min(I(:));
    m = max(I(:));
    if m > 0
        I = I / m;
    end
    image(I);
    axis image off;
    title(titre, 'FontSize', 24, 'Interpreter', 'Latex');
end