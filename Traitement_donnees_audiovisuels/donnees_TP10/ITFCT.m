function y = ITFCT(Y, N, D, fenetre)

	% ITFCT (inverse de la transformée de Fourier à court terme)
	% Par Overlap - Add
	%	
	% Inputs :
	%	Y		: TFCT d'un signal réel
	%	f_ech		: fréquence d'échantillonnage
	%	N		: nombre d'échantillons d'une fenêtre
	%	D		: décalage entre deux fenêtres
	%
	% Output :
	%	y		: ITFCT(Y)

	% On redonne la bonne taille à Y (pas besoin de remettre les bons coefficients,
	% la fonction ifft de Matlab gère pour nous) :
	Y(size(Y, 1) + 1:N, :) = 0;

	% Récupération de la fenêtre utilisée :
	if nargin == 3 || strcmp(fenetre, 'hann') || strcmp(fenetre, 'hann_symmetric')
		% Par défaut, fenêtre de Hann :
		w = hann(N);
	elseif strcmp(fenetre, 'rect') || strcmp(fenetre, 'rectangulaire')
		w = ones(N, 1);
	else
		error('Fenetre inconnue : %s', fenetre);
	end

	% Création d'un signal vierge et d'une variable permettant de calculer la somme des fenêtres :
	n = (size(Y, 2) - 1) * D + N;
	y = zeros(n, 1);
	w_sum = zeros(n, 1);

	for valeurs_t = 1:size(Y,2)
		% On retrouve le signal fenêtré (l'option 'symmetric' indique à
		% Matlab d'utiliser la symétrie hermitienne de la TFCT d'un signal réel) :
		y_win = ifft(Y(:, valeurs_t), 'symmetric');
		
		% On ajoute ce tronçon de signal fenêtré au signal,
		% et la fenêtre à la somme des fenêtres :
		start = 1 + (valeurs_t-1)*D;
		y(start : start + N - 1) = y(start : start + N - 1) + y_win .* w;
		w_sum(start : start + N - 1) = w_sum(start : start + N - 1) + w.^2;
	end

	% On dé-fenêtre (en évitant de diviser par 0) :
	y(w_sum~=0) = y(w_sum~=0) ./ (w_sum(w_sum~=0));

end
