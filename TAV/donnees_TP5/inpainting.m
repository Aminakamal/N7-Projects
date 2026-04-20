function u_kp1 = inpainting(b,u_k,lambda,Dx,Dy,epsilon,D)

nb_pixels = size(u_k,1);
chi_D = D(:);
diag_omega_moins_D = 1 - chi_D;
W_D = spdiags(diag_omega_moins_D,0,nb_pixels,nb_pixels);
diag_k = 1./(sqrt((Dx*u_k).^2 +(Dy*u_k).^2  + epsilon));
Wk = spdiags(diag_k,0,nb_pixels,nb_pixels);

Ak = W_D- lambda*(-Dx'*Wk*Dx -Dy'*Wk*Dy);
W_b = W_D*b;

u_kp1 = Ak\W_b;