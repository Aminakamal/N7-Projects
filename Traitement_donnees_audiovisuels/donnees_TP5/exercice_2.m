%--------------------------------------------------------------------------
% ENSEEIHT - 2SN MM - Traitement des donnees audio-visuelles
% TP5 - Restauration d'images
% exercice_2 : inpainting avec variation totale
%--------------------------------------------------------------------------

clear
close all
clc

% Mise en place de la figure pour affichage :
taille_ecran = get(0,'ScreenSize');
L = taille_ecran(3);
H = taille_ecran(4);
figure('Name','Inpainting par variation totale',...
	'Position',[0.05*L,0.1*H,0.9*L,0.7*H]);

% Lecture de l'image :
u_0 = double(imread('Images/fleur_avec_defaut.png'));
[nb_lignes,nb_colonnes,nb_canaux] = size(u_0);
u_max = max(u_0(:));

% Lecture du domaine D :
D = imread('Images/defaut_fleur.png') > 0;

% Affichage de l'image :
subplot(1,3,1)
	imagesc(max(0,min(1,u_0/u_max)),[0 1])
	if nb_canaux==1
		colormap gray
	end
	axis image off
	title('Image degradee','FontSize',20)

% Affichage de l'image restauree a l'iteration 0 :
subplot(1,3,2)
	imagesc(max(0,min(1,u_0/u_max)),[0 1])
	if nb_canaux==1
		colormap gray
	end
	axis image off
	title('Image restauree (iteration 0)','FontSize',20)
drawnow nocallbacks

% Vectorisation des canaux de u_0 :
nb_pixels = nb_lignes*nb_colonnes;
u_0 = reshape(u_0,[nb_pixels nb_canaux]);

% Parametre pour garantir la differentiabilite de la variation totale :
epsilon = 0.01;

% Operateur gradient :
e = ones(nb_pixels,1);
Dx = spdiags([-e e],[0 nb_lignes],nb_pixels,nb_pixels);
Dx(end-nb_lignes+1:end,:) = 0;
Dy = spdiags([-e e],[0 1],nb_pixels,nb_pixels);
Dy(nb_lignes:nb_lignes:end,:) = 0;

% Second membre :
chi_D = double(D(:));
W_D = spdiags(1-chi_D,0,nb_pixels,nb_pixels);
b = W_D*u_0;
		
% Point fixe :
lambda = 100;			% Poids de la regularisation
u_k = u_0;
convergence = +Inf;
iteration = 0;

while convergence > 1e-3

	% Incrementation du nombre d'iterations :
	iteration = iteration + 1;

	% Iteration (8) :
	u_kp1 = inpainting(b,u_k,lambda,Dx,Dy,epsilon,D);	

	% Test de convergence :
	convergence = norm(u_kp1(:)-u_k(:))/norm(u_k(:));

	% Mise a jour de l'image courante u_k :
	u_k = u_kp1;

	% Affichage de l'image restauree a chaque iteration :
	subplot(1,3,2)
		imagesc(max(0,min(1,reshape(u_k,[nb_lignes nb_colonnes nb_canaux])/u_max)),[0 1])
		if nb_canaux==1
			colormap gray
		end
		axis image off
		title(['Image restauree (iteration ' num2str(iteration) ')'],'FontSize',20)
        
    subplot(1,3,3)
        imagesc(max(0,min(1,(reshape(u_0-u_k,[nb_lignes nb_colonnes nb_canaux])/u_max+1)/2)),[0 1])
        if nb_canaux==1
			colormap gray
        end
		axis image off
        title(['Soustraction de la solution (iteration ' num2str(iteration) ')'],'FontSize',20)    
        
	drawnow nocallbacks
	pause(0.1)

end
