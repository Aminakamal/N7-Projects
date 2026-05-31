clear;
close all;

% Lecture de l'image Barbara :
u = imread('Images/Barbara.png');
if ndims(u) == 3
    u = rgb2gray(u);
end
u = double(u);
[nb_lignes,nb_colonnes] = size(u);

% Calcul du spectre s de l'image u :
s = fftshift(fft2(u));

% Grille des frequences centrees en (0,0) :
[nu_x,nu_y] = meshgrid(1:nb_colonnes,1:nb_lignes);
nu_x = nu_x/nb_colonnes - 0.5;
nu_y = nu_y/nb_lignes - 0.5;

% Partition franche du spectre :
eta = 0.05;
masque_structure = (nu_x.^2 + nu_y.^2) <= eta^2;
s_structure = masque_structure .* s;
s_texture = s - s_structure;

% Calcul des images par TFD inverse :
u_structure = real(ifft2(ifftshift(s_structure)));
u_texture = real(ifft2(ifftshift(s_texture)));

% Affichage :
taille_ecran = get(0,'ScreenSize');
L = taille_ecran(3);
H = taille_ecran(4);
figure('Name','Decomposition structure + texture par FFT','Position',[0.15*L,0,0.85*L,H]);

subplot(2,3,1);
affichage(u,'$x$','$y$','Image originale');
subplot(2,3,2);
affichage(u_structure,'$x$','$y$','Structure');
subplot(2,3,3);
affichage(u_texture,'$x$','$y$','Texture');

subplot(2,3,4);
affichage(log(abs(s)+1),'$\nu_x$','$\nu_y$','Spectre original');
subplot(2,3,5);
affichage(log(abs(s_structure)+1),'$\nu_x$','$\nu_y$','Spectre de la structure');
subplot(2,3,6);
affichage(log(abs(s_texture)+1),'$\nu_x$','$\nu_y$','Spectre de la texture');