clear;
close all;
taille_ecran = get(0,'ScreenSize');
L = taille_ecran(3);
H = taille_ecran(4);

% Lecture de l'image RGB puis conversion LAB :
image_rgb = imread('Images/rose.jpg');
image_lab = rgb2lab(image_rgb);

% Source : image LAB complete.
s = image_lab;

% Cible : meme image, avec canaux a et b annules (niveau de gris en LAB).
c = image_lab;
c(:,:,2) = 0;
c(:,:,3) = 0;

% Affichage des images en RGB pour interpretation visuelle :
figure('Name','Decoloration partielle (Poisson)','Position',[0.1*L,0.1*H,0.9*L,0.7*H]);
subplot(1,2,1);
imagesc(lab2rgb(s));
axis image off;
title('Image source','FontSize',20);
hold on;

% Selection et affichage d'un polygone p dans s :
disp('Selectionnez un polygone (double-clic pour valider)');
[p,x_p,y_p] = roipoly(lab2rgb(s));
for k = 1:length(x_p)-1
	line([x_p(k) x_p(k+1)],[y_p(k) y_p(k+1)],'Color','r','LineWidth',2);
end

% Bornes du rectangle englobant de p :
[nb_lignes_s,nb_colonnes_s,~] = size(s);
i_p = min(max(round(y_p),1),nb_lignes_s);
j_p = min(max(round(x_p),1),nb_colonnes_s);
i_p_min = min(i_p(:));
i_p_max = max(i_p(:));
j_p_min = min(j_p(:));
j_p_max = max(j_p(:));

% Affichage de l'image cible :
subplot(1,2,2);
imagesc(lab2rgb(c));
axis image off;
title('Image cible (decoloree)','FontSize',20);
hold on;

% Selection et affichage d'un rectangle r dans c :
disp('Cliquez les deux extremites de la zone cible');
[x_r,y_r] = ginput(2);
[nb_lignes_c,nb_colonnes_c,~] = size(c);
i_r = min(max(round(y_r),1),nb_lignes_c);
j_r = min(max(round(x_r),1),nb_colonnes_c);
j_r_min = min(j_r(:));
j_r_max = max(j_r(:));
i_r_min = min(i_r(:));
i_r_max = max(i_r(:));
line([j_r_min j_r_max],[i_r_min,i_r_min],'Color','r','LineWidth',2);
line([j_r_min j_r_max],[i_r_max,i_r_max],'Color','r','LineWidth',2);
line([j_r_min j_r_min],[i_r_min,i_r_max],'Color','r','LineWidth',2);
line([j_r_max j_r_max],[i_r_min,i_r_max],'Color','r','LineWidth',2);

% Sous-matrice de c correspondant au rectangle r :
r = c(i_r_min:i_r_max,j_r_min:j_r_max,:);

% Sous-matrices de s et p dans le rectangle englobant de p :
s = s(i_p_min:i_p_max,j_p_min:j_p_max,:);
p = p(i_p_min:i_p_max,j_p_min:j_p_max);

% Redimensionnement de s et p aux dimensions de r :
[nb_lignes_r,nb_colonnes_r,~] = size(r);
s = imresize(s,[nb_lignes_r,nb_colonnes_r]);
p = imresize(p,[nb_lignes_r,nb_colonnes_r]);

% Calcul de l'image resultat dans l'espace LAB :
u = c;
interieur = find(p>0);
u(i_r_min:i_r_max,j_r_min:j_r_max,:) = collage(r,s,interieur);

% Conversion LAB -> RGB pour affichage.
u_rgb = lab2rgb(u);
u_rgb = min(max(u_rgb,0),1);

hold off;
imagesc(u_rgb);
axis image off;
title('Resultat de la decoloration partielle','FontSize',20);
