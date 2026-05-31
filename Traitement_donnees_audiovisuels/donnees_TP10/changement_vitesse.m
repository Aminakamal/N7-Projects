function y_modifie = changement_vitesse(y, f_ech, proportion)

	% Changement de vitesse de lecture
	%	
	% Inputs :
	%	y			: signal réel
	%	f_ech			: fréquence d'échantillonnage de y
	%	proportion		: proportion de modification de la vitesse de lecture (2 = 2 x plus vite)
	%
	% Output :
	%	y_modifie		: signal modifié

	% Simule un changement de vitesse de lecture en ré-échantillonnant le signal :

	y_modifie = resample(y, f_ech, round(f_ech * proportion));
	
end
