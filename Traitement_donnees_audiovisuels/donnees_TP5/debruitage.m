function u_kp1 = debruitage(b,u_k,lambda,Dx,Dy,epsilon)

nb_pixels = size(u_k,1);
IN = speye(nb_pixels);
%grad_uk = [Dx*u_k Dy*u_k];
diag = 1./(sqrt((Dx*u_k).^2 +(Dy*u_k).^2  + epsilon));
Wk = spdiags(diag,0,nb_pixels,nb_pixels);

Ak = IN - lambda*(-Dx'*Wk*Dx -Dy'*Wk*Dy);

u_kp1 = Ak\b;