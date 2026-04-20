function A = matrice_A(N,alpha,beta,gamma)
I = speye(N);
D = spdiags([1 -2 1],-1:1,N,N);
D(1,N)= 1;
D(N,1)= 1;
A = I + gamma*(alpha*D - beta*(D'*D));