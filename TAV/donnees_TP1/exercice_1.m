clear;
close all;

load donnees;

% Calcul de l'individu moyen :
X_moyen = mean(X,2);

% Centrage des donnees :
X_c = X-repmat(X_moyen,1,n);

% Calcul de n-1 vecteurs propres de Sigma formant une base orthonormee de Im(Sigma) :
W = eigenfaces(X_c);

% Affichage de l'individu moyen et des eigenfaces sous forme d'images :
figure('Name','Individu moyen et eigenfaces','Position',[0.33*L,0,0.67*L,H]);
colormap gray;
img = reshape(X_moyen,n_lig,n_col);
subplot(n_ind,n_pos,1);
imagesc(img);
axis image;
axis off;
title('Individu moyen','FontSize',15);
for l = 1:n-1
	img = reshape(W(:,l),n_lig,n_col);
	subplot(n_ind,n_pos,l+1);
	imagesc(img);
	axis image;
	axis off;
end
drawnow;

save exercice_1;

