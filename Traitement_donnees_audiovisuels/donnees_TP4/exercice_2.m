clear;
close all;

taille_ecran = get(0,'ScreenSize');
L = taille_ecran(3);
H = taille_ecran(4);


% Parametres :
R = 7;					% Rayon des disques
nb_points_affichage_disque = 30;
increment_angulaire = 2*pi/nb_points_affichage_disque;
theta = 0:increment_angulaire:2*pi;
rose = [253 108 158]/255;
q_max = 75;
nb_affichages = 75;
pas_entre_affichages = floor(q_max/nb_affichages);
temps_pause = 0.0001;

beta = 1;
S = 140;
lambda = 5;
T0 = 0.1;
delta_0 = 100;
alpha = 0.99;

% Variante conseillee dans l'enonce : suppression deterministe
suppression_deterministe = true;

% Lecture et affichage de l'image :
I = imread('colonie.png');
I = rgb2ycbcr(I);
I = double(I(:,:,1));
[nb_lignes,nb_colonnes] = size(I);
figure('Name','Detection de flamants roses par processus ponctuel marque','Position',[0,0,L,0.58*H]);

% Configuration initiale (ensemble vide) :
c = zeros(0,2);
U_i = zeros(0,1);
liste_ids = zeros(0,1);
prochain_id = 1;
T = T0;
delta = delta_0;

U_config = 0;
liste_q = 0;
liste_U_config = U_config;

% Affichage de la configuration initiale :
subplot(1,2,1);
imagesc(I);
axis image;
axis off;
colormap gray;
hold on;
pause(temps_pause);

% Courbe d'evolution de l'energie :
subplot(1,2,2);
plot(liste_q,liste_U_config,'.','Color',rose);
axis([0 q_max -400 0]);
set(gca,'FontSize',20);
xlabel('Nombre d''iterations q','FontSize',20);
ylabel('Energie U(c)','FontSize',20);

% Recherche de la configuration optimale :
for q = 1:q_max
	% 1) Naissances :
	N_nouveaux = poissrnd(delta);
	if N_nouveaux>0
		c_nouveaux = [nb_colonnes*rand(N_nouveaux,1) nb_lignes*rand(N_nouveaux,1)];
		I_moyen_nouveaux = zeros(N_nouveaux,1);
		for j = 1:N_nouveaux
			I_moyen_nouveaux(j) = calcul_I_moyen(I,c_nouveaux(j,:),R);
		end
		U_nouveaux = 1-2./(1+exp(lambda*(I_moyen_nouveaux-S)));

		c = [c; c_nouveaux];
		U_i = [U_i; U_nouveaux];
		ids_nouveaux = (prochain_id:prochain_id+N_nouveaux-1)';
		liste_ids = [liste_ids; ids_nouveaux];
		prochain_id = prochain_id+N_nouveaux;
	end

	% Energie de la configuration apres naissances :
	U_config = sum(U_i)+beta*nombre_conflits(c,R);

	% 2) Tri des disques par valeurs decroissantes de Ui :
	[~,ordre] = sort(U_i,'descend');
	ids_tries = liste_ids(ordre);

	% 3) Morts :
	for j = 1:length(ids_tries)
		id_courant = ids_tries(j);
		indice = find(liste_ids==id_courant,1);
		if isempty(indice)
			continue;
		end

		nb_conflits_du_disque = nombre_conflits_disque(c,indice,R);
		U_sans_disque = U_config-U_i(indice)-beta*nb_conflits_du_disque;

		if suppression_deterministe
			supprimer = (U_sans_disque<U_config);
		else
			p_suppression = delta/(delta+exp((U_sans_disque-U_config)/T));
			supprimer = (rand<p_suppression);
		end

		if supprimer
			c(indice,:) = [];
			U_i(indice) = [];
			liste_ids(indice) = [];
			U_config = U_sans_disque;
		end
	end

	% Affichage de la configuration courante :
	hold off;
	subplot(1,2,1);
	imagesc(I);
	axis image;
	axis off;
	colormap gray;
	hold on;
	for j = 1:size(c,1)
		x_affich = c(j,1)+R*cos(theta);
		y_affich = c(j,2)+R*sin(theta);
		indices = find(x_affich>0 & x_affich<nb_colonnes & y_affich>0 & y_affich<nb_lignes);
		plot(x_affich(indices),y_affich(indices),'Color',rose,'LineWidth',3);
	end
	pause(temps_pause);

	% Courbe d'evolution de l'energie :
	if rem(q,pas_entre_affichages)==0
		liste_q = [liste_q q];
		liste_U_config = [liste_U_config U_config];
		subplot(1,2,2);
		plot(liste_q,liste_U_config,'.-','Color',rose,'LineWidth',3);
		axis([0 q_max -400 0]);
		set(gca,'FontSize',20);
		xlabel('Nombre d''iterations q','FontSize',20);
		ylabel('Energie U(c)','FontSize',20);
	end

	% 4) Refroidissement :
	T = alpha*T;
	delta = alpha*delta;
end

disp(['Nombre final de disques detectes : ' num2str(size(c,1))]);


function resultat = nombre_conflits(c,R)

N = size(c,1);
resultat = 0;
for i = 1:N-1
	distances = sqrt(sum((c(i+1:N,:)-c(i,:)).^2,2));
	resultat = resultat+sum(distances<2*R);
end

end


function resultat = nombre_conflits_disque(c,indice,R)

if size(c,1)<=1
	resultat = 0;
	return;
end

distances = sqrt(sum((c-c(indice,:)).^2,2));
distances(indice) = inf;
resultat = sum(distances<2*R);

end