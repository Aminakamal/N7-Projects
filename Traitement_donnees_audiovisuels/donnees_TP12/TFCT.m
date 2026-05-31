function [Y,valeurs_tau,valeurs_f] = TFCT(y,f_ech,n_fenetre,n_decalage,varargin)

% TFCT (transformée de Fourier à court terme)
%	
% Entrées :
%	y		: signal réel
%	f_ech		: fréquence d'échantillonage
%	n_fenetre	: taille d'une fenêtre
%	n_decalage	: taille entre deux fenêtres
%
% Sorties :
%	Y		: TFCT(y)
%	valeurs_f	: points fréquences
%	valeurs_t	: points temporels

% Découpage du signal en tranches de taille n_fenetre,
% avec un recouvrement de n_fenetre - n_decalage 
% (n_decalage est la taille entre deux fenêtres) :
frames = buffer(y,n_fenetre,n_fenetre-n_decalage,'nodelay');

% Fenêtrage (pour éviter les fuites hautes-fréquences)
if nargin == 4 || strcmp(varargin{1},'hann')
	w = hann(n_fenetre);		% Fenêtre de Hann
elseif strcmp(varargin{1},'rect')
	w = ones(n_fenetre,1);		% Fenêtre rectangulaire
end
Y = fft(frames.*repmat(w,1,size(frames,2)));

% Élimination des fréquences négatives (car signal réel) :
Y = Y(1:floor(n_fenetre/2)+1,:);

% Conversion des colonnes en secondes et des lignes en fréquences :
valeurs_tau = (0:size(Y,2)-1)*n_decalage/f_ech;
valeurs_f = (0:size(Y,1)-1)*f_ech/n_fenetre;
