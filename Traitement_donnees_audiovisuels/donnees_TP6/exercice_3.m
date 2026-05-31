clear;
close all;
taille_ecran = get(0,'ScreenSize');
L = taille_ecran(3);
H = taille_ecran(4);

% Lecture de l'image a segmenter :
I = imread('pears.png');
[nb_lignes,nb_colonnes,nb_canaux] = size(I);
if nb_canaux==3
	I = rgb2gray(I);
end
I = double(I);
I = I/max(I(:));

% Affichage de l'image non filtree :
figure('Name','Champ de force externe','Position',[0.1*L,0.1*H,0.9*L,0.7*H]);
subplot(1,2,1);
imagesc(I);
colormap gray;
axis image off;
title('Image a segmenter','FontSize',20);
drawnow;

% Champ de force externe :
[Ix, Iy] = gradient(I);
Eext0 = -(Ix.^2 + Iy.^2);
[Fx0, Fy0] = gradient(Eext0);
mu_GVF = 2;
gamma_GVF = 0.01;
nb_iterations = 300;
Fx = Fx0;
Fy = Fy0;
poids = Fx0.^2 + Fy0.^2;
for k = 1:nb_iterations
    lapFx = del2(Fx);
    lapFy = del2(Fy);
    Fx = Fx - gamma_GVF*(poids.*(Fx - Fx0) - mu_GVF*lapFx);
    Fy = Fy - gamma_GVF*(poids.*(Fy - Fy0) - mu_GVF*lapFy);
end

% Normalisation pour affichage
norme = sqrt(Fx.^2 + Fy.^2);
Fx_normalise = Fx ./ (norme + eps);
Fy_normalise = Fy ./ (norme + eps);

% Affichage du champ de force externe :
subplot(1,2,2);
imagesc(I);
colormap gray;
axis image off;
hold on;
pas_fleches = 5;
taille_fleches = 1;
[x,y] = meshgrid(1:pas_fleches:nb_colonnes,1:pas_fleches:nb_lignes);
Fx_normalise_quiver = Fx_normalise(1:pas_fleches:nb_lignes,1:pas_fleches:nb_colonnes);
Fy_normalise_quiver = Fy_normalise(1:pas_fleches:nb_lignes,1:pas_fleches:nb_colonnes);
hq = quiver(x,y,Fx_normalise_quiver,Fy_normalise_quiver,taille_fleches);
set(hq,'LineWidth',1,'Color',[1,0,0]);
title('Champ de force externe elementaire','FontSize',20);

save force_externe;
