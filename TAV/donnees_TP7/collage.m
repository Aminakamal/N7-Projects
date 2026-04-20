function u_double = collage(r,s,interieur)

r_double = double(r);
s_double = double(s);

[nb_lignes_r, nb_colonnes_r, ~] = size(r_double);
n_r = nb_lignes_r * nb_colonnes_r;
e = ones(n_r,1);
Dx = spdiags([-e e],[0 nb_lignes_r],n_r,n_r);
Dx(end-nb_lignes_r+1:end,:) = 0;
Dy = spdiags([-e e],[0 1],n_r,n_r);
Dy(nb_lignes_r:nb_lignes_r:end,:) = 0;

bord_r = ones(nb_lignes_r,nb_colonnes_r);
if nb_lignes_r > 2 && nb_colonnes_r > 2
    bord_r(2:end-1,2:end-1) = 0;
end
indices_bord_r = find(bord_r(:) > 0);
n_bord_r = numel(indices_bord_r);

A = -Dx'*Dx -Dy'*Dy;
A(indices_bord_r,:) = sparse(1:n_bord_r,indices_bord_r,ones(n_bord_r,1),n_bord_r,n_r);

u_double = zeros(size(r_double));
for k = 1:size(r_double,3)
    r_k = r_double(:,:,k);
    s_k = s_double(:,:,k);
    r_vec = r_k(:);
    s_vec = s_k(:);
  
    gx_r = Dx*r_vec;
    gy_r = Dy*r_vec;
    gx_s = Dx*s_vec;
    gy_s = Dy*s_vec;
    gx_r(interieur) = gx_s(interieur);
    gy_r(interieur) = gy_s(interieur);

    b_k = -(Dx'*gx_r + Dy'*gy_r);
    b_k(indices_bord_r) = r_vec(indices_bord_r);

    u_vec = A \ b_k;
	u_double(:,:,k) = reshape(u_vec, nb_lignes_r, nb_colonnes_r);
end
