clear;
close all;

verif_Y = [3.75 8.25 12.75 17.25;-2.25-1.5i -4.5-3.75i -6.75-6i -9-8.25i;0.75 0.75 0.75 0.75];
verif_t = [0 0.3 0.6 0.9];
verif_f = [0 2.5 5];

f_ech = 10;
y = (1:12);
N = 4;
D = 3;
fenetre = 'hann';

Y = TFCT(y, N, D, fenetre);

if size(Y,1)~=(N/2+1)
	disp('Le nombre de lignes n''est pas bon : avez-vous supprimé les fréquences négatives ?');
	return;
end

if size(Y,2)~=ceil((length(y)-N)/D)+1
	disp('Le nombre de colonnes n''est pas bon : vérifiez l''appel a la fonction buffer !');
	return;
end

if ~all(abs(Y - verif_Y) <= 1e-10)
	disp('La matrice TFCT n''est pas correcte : le fenêtrage a-t-il été effectué correctement ?');
else
	disp('Bravo, vous pouvez passer à l''exercice 2 !');
end
