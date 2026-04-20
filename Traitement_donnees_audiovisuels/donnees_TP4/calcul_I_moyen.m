function resultat = calcul_I_moyen(I,c_i,R)

[nb_lignes,nb_colonnes] = size(I);
abscisse = c_i(1);
ordonnee = c_i(2);
i_min = max(1,floor(ordonnee-R));
i_max = min(nb_lignes,ceil(ordonnee+R));
j_min = max(1,floor(abscisse-R));
j_max = min(nb_colonnes,ceil(abscisse+R));
imagette = I(i_min:i_max,j_min:j_max);
[A,O] = meshgrid(1:size(imagette,2),1:size(imagette,1));
A = A-(abscisse-j_min);
O = O-(ordonnee-i_min);
masque = (A.*A+O.*O<=R*R);
imagette_masquee = imagette.*masque;
resultat = sum(imagette_masquee(:))/sum(masque(:));
