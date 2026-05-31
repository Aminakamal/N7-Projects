function Y_modifie = passe_haut(Y, valeurs_f, freq_filtrage)

Y_modifie = Y;
masque = reshape(valeurs_f < freq_filtrage, [], 1);
Y_modifie(masque, :) = 0;
end