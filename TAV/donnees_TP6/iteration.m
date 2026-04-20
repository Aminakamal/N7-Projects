function [X,Y] = iteration(x,y,Fx,Fy,gamma,A)

sz = size(Fx);
nb_lignes = sz(1);
nb_colonnes = sz(2);

x_i = round(x);
y_i = round(y);

ind = sub2ind([nb_lignes, nb_colonnes], y_i, x_i);

Bx = -gamma*Fx(ind);
By = -gamma*Fy(ind);


X = A*x + Bx;
Y = A*y + By;