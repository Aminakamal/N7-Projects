clear;
close all;

load exercice_1;

% Calcul des composantes principales des donnees d'apprentissage :
C = transpose(X_c)*W;		% Composantes principales des donnees d'apprentissage : matrice n x (n-1)

% On conserve uniquement les q = 3 premieres composantes principales :
C_3 = C(:,1:3);			% Matrice n x 3

% Affichage des points de R^3 avec une couleur differente par individu :
figure('Name',['Espace des trois premieres composantes principales'],'Position',[0.33*L,0,0.67*L,0.67*H]);
hold on;
for j = 1:n_ind
	indices = (j-1)*n_pos+1:j*n_pos;
	plot3(C(indices,1),C(indices,2),C(indices,3),['*' 0.5*(rand(1,3)+1)],'MarkerSize',10,'LineWidth',2);
end
proportion = 0.5;
ecart_x = max(C(:,1))-min(C(:,1));
min_x = min(C(:,1))-proportion*ecart_x;
max_x = max(C(:,1))+proportion*ecart_x;
ecart_y = max(C(:,2))-min(C(:,2));
min_y = min(C(:,2))-proportion*ecart_y;
max_y = max(C(:,2))+proportion*ecart_y;
ecart_z = max(C(:,3))-min(C(:,3));
min_z = min(C(:,3))-proportion*ecart_z;
max_z = max(C(:,3))+proportion*ecart_z;
axis([min_x max_x min_y max_y min_z max_z]);
axis equal;
set(gca,'FontSize',20);
xlabel('$C_1$','FontSize',30,'Interpreter','Latex');
ylabel('$C_2$','FontSize',30,'Interpreter','Latex');
zlabel('$C_3$','FontSize',30,'Interpreter','Latex');

rotate3d;

save clusters;
