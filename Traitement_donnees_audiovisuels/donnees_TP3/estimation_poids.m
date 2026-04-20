function [poids,argument] = estimation_poids(mu_test,sigma_test,liste_nvg,F)
N = length(mu_test);
nb_nvg = length(liste_nvg);

% Construction de la matrice A (nb_nvg x N)
A = zeros(nb_nvg, N);
for k = 1:N
    mu_k = mu_test(k);
    sigma_k = sigma_test(k);
    % Chaque colonne contient une gaussienne normalisée
    A(:,k) = (1/(sigma_k*sqrt(2*pi))) * exp(-(liste_nvg' - mu_k).^2 / (2*sigma_k^2));
end

% Résolution du système linéaire AP = F (moindres carrés)
% F doit être un vecteur colonne
F_col = F(:);

% Résolution par moindres carrés : min ||AP - F||^2
poids = A \ F_col;

% Calcul de l'argument (résiduel des moindres carrés)
residus = F_col - A * poids;
argument = sum(residus.^2);
