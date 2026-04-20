function X = moindres_carres_ponderes(D_app,poids)
% Estimation moindres carres avec poids pour l'ajustement d'une ellipse.

x = D_app(1,:)';
y = D_app(2,:)';
w = poids(:);

A1 = [x.^2 x.*y y.^2 x y ones(size(x))];
W = sqrt(w);
A = [1 0 1 0 0 0; A1.*W];
B = [1; zeros(size(x))];

X = A\B;
