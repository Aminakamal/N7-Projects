clear;
close all;
taille_ecran = get(0,'ScreenSize');
L = taille_ecran(3);
H = taille_ecran(4);

% Selection d'images parmi 15 individus et 6 postures faciales :
chemin = '/mnt/n7fs/ens/tp_queau/Images_TP2_TAV';
numeros_individus = [2 4 9 13];
numeros_postures = [1 2 3];
n_ind = length(numeros_individus);
n_pos = length(numeros_postures);
n = n_ind*n_pos;

% Nombre de lignes p de X (nombre de pixels des images) :
fichier = [chemin '/i' num2str(numeros_individus(1),'%02d') num2str(numeros_postures(1),'%1d') '.mat'];
load(fichier);
img = eval(['i' num2str(numeros_individus(1),'%02d') num2str(numeros_postures(1),'%1d')]);
[n_lig,n_col] = size(img);
p = n_lig*n_col;

% Remplissage de la matrice X :
X = [];
for j = 1:n_ind
	for k = 1:n_pos
		fichier = [chemin '/i' num2str(numeros_individus(j),'%02d') num2str(numeros_postures(k),'%1d') '.mat'];
		load(fichier);
		img = eval(['i' num2str(numeros_individus(j),'%02d') num2str(numeros_postures(k),'%1d')]);
		if (size(img,1) ~= n_lig) || (size(img,2) ~= n_col)
			disp('Probleme : les images ne sont pas toutes de meme taille !');
			exit;
		end
		X = [X double(img(:))];
	end
end
	
% Affichage des images (un individu par ligne, une posture par colonne) :
figure('Name',[num2str(n_pos) ' postures de ' num2str(n_ind) ' individus'],'Position',[0.33*L,0,0.67*L,H]);
colormap gray;
for l = 1:n
	j = numeros_individus(floor((l-1)/n_pos)+1);
	k = numeros_postures(mod((l-1),n_pos)+1);
	img = reshape(X(:,l),n_lig,n_col);
	subplot(n_ind,n_pos,l);
	imagesc(img);
	axis image;
	axis off;
end
drawnow;

save donnees;
