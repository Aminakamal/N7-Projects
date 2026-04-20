clear;
close all;

load clusters;

% Affichage d'une image par individu de l'ensemble d'apprentissage :
figure('Name','Individus de EA','Position',[0.2*L,0.2*H,0.2*L,0.8*H]);
colormap gray;
for j = 1:n_ind
	img = reshape(X(:,(j-1)*n_pos+1),n_lig,n_col);
	subplot(n_ind,1,j);
	imagesc(img);
	axis image;
	axis off;
	title({['Individu numero ' num2str(numeros_individus(j))]},'FontSize',20);
end
drawnow;

% Tirage aleatoire d'une image de test :
individu = randi(15);
posture = randi(6);
fichier = [chemin '/i' num2str(individu,'%02d') num2str(posture,'%1d') '.mat'];
load(fichier);
img = eval(['i' num2str(individu,'%02d') num2str(posture,'%1d')]);

% Affichage de l'image de test :
figure('Name','Image tiree aleatoirement','Position',[0.4*L,0.2*H,0.6*L,0.5*H]);
colormap gray;
imagesc(img);
axis image;
axis off;

% Projection de l'image de test sur les 3 premieres composantes principales :
x_test = double(img(:));
c_test = W'*(x_test-X_moyen);
c3_test = c_test(1:3)';

% Calcul des centroïdes des clusters de EA :
centroides = zeros(n_ind,3);
dist_intra = [];
for j = 1:n_ind
	indices = (j-1)*n_pos+1:j*n_pos;
	centroides(j,:) = mean(C_3(indices,:),1);
	d = sqrt(sum((C_3(indices,:)-centroides(j,:)).^2,2));
	dist_intra = [dist_intra ; d];
end

% Seuil base sur la dispersion intra-cluster :
seuil = mean(dist_intra) + 2*std(dist_intra);

% Decision de reconnaissance :
distances = sqrt(sum((centroides-c3_test).^2,2));
[dmin, idx_min] = min(distances);
if dmin < seuil
	individu_estime = numeros_individus(idx_min);
	titre = ['Individu reconnu : ' num2str(individu_estime) ' (d=' num2str(dmin,'%.2f') ')'];
else
	titre = ['Individu inconnu (d=' num2str(dmin,'%.2f') ')'];
end
title(titre,'FontSize',20);
