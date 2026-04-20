function parametres_estim = max_vraisemblance_2(D_app,parametres_test,sigma)
nb_tir = size(parametres_test,1);

scores = zeros(nb_tir,1);
sigma2 = sigma^2;
for j = 1:nb_tir
    param_1 = reshape(parametres_test(j,1,:),1,5);
    param_2 = reshape(parametres_test(j,2,:),1,5);
    r1 = calcul_r(D_app,param_1);
    r2 = calcul_r(D_app,param_2);
    p1 = exp(-(r1.^2)/(2*sigma2));
    p2 = exp(-(r2.^2)/(2*sigma2));
    scores(j) = sum(log(0.5*p1 + 0.5*p2 + eps));
end
[~,indx] = max(scores);
parametres_estim = parametres_test(indx,:,:);