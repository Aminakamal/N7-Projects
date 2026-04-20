function parametres_MV = max_vraisemblance(D_app,parametres_test)
p = size(parametres_test,1);
r_p = zeros(p,1);    
for j= 1:p
    r_p(j) = sum(calcul_r(D_app,parametres_test(j,:)).^2);
 
end 
[~,indx]= min(r_p);
parametres_MV = parametres_test(indx,:);