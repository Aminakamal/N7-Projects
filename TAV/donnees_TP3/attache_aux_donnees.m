function AD = attache_aux_donnees(I,moyennes,variances)
n = size(I,1);
m = size(I,2);
N= size(moyennes,2);
AD = zeros(n,m,N);

I = double(I);
for k=1:N
      variance_k = max(variances(k),eps);
      AD(:,:,k) = 0.5*(log(variance_k) + ((I-moyennes(k)).^2)./variance_k);
end