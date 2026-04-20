function probas = probabilites(D_app,parametres_estim,sigma)
sigma2 = sigma^2;

param_1 = parametres_estim(1,:);
param_2 = parametres_estim(2,:);
r1 = calcul_r(D_app,param_1);
r2 = calcul_r(D_app,param_2);

p1 = exp(-(r1.^2)/(2*sigma2));
p2 = exp(-(r2.^2)/(2*sigma2));

denom = p1 + p2 + eps;
probas = [p1./denom ; p2./denom];
