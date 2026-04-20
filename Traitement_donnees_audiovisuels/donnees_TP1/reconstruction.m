clear;
close all;

load exercice_1;

% Calcul des composantes principales des donnees d'apprentissage :
C = transpose(X_c)*W;		% Composantes principales des donnees d'apprentissage : matrice n x (n-1)

h = figure('Position',[0.33*L,0,0.67*L,H]);
figure('Name','RMSE en fonction du nombre de composantes principales','Position',[0,0,0.33*L,0.3*L]);

% Calcul de la RMSE entre images originales et images reconstruites :
RMSE_max = 0;
for q = 0:n-1
	Cq = C(:,1:q);		% q premieres composantes principales : sous-matrice n x q
	Wq = W(:,1:q);		% q premieres eigenfaces : sous-matrice p x q
	X_reconstruit = Wq*transpose(Cq)+repmat(X_moyen,1,n);
	figure(1);
	set(h,'Name',['Utilisation des ' num2str(q) ' premieres composantes principales']);
	colormap gray;
	hold off;
	for k = 1:n
		subplot(n_ind,n_pos,k);
		img = reshape(X_reconstruit(:,k),n_lig,n_col);
		imagesc(img);
		hold on;
		axis image;
		axis off;
	end

	figure(2);
	hold on;
	ecart_quadratique_moyen = mean(mean((X-X_reconstruit).^2));
	RMSE = sqrt(ecart_quadratique_moyen);
	RMSE_max = max(RMSE,RMSE_max);
	plot(q,RMSE,'r+','MarkerSize',8,'LineWidth',2);
	axis([0 n-1 0 1.1*RMSE_max]);
	set(gca,'FontSize',20);
	xlabel('$q$','FontSize',30,'Interpreter','Latex');
	ylabel('RMSE','FontSize',30);

	pause(0.01);
end
