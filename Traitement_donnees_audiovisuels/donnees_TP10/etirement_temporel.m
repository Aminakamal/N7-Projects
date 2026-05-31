function y_modifie = etirement_temporel(y, pourcentage, N, D, fenetre)

if nargin < 3 || isempty(N)
    N = 2048;
end
if nargin < 4 || isempty(D)
    D = 512;
end
if nargin < 5 || isempty(fenetre)
    fenetre = 'hann';
end

Y = TFCT(y, N, D, fenetre);

if size(Y, 2) <= 1
    y_modifie = ITFCT(Y, N, D, fenetre);
    return;
end

C = 1 : pourcentage : size(Y, 2);
phi = angle(Y(:, 1));
Yp = zeros(size(Y, 1), length(C));

for i = 1:length(C)
    c = floor(C(i));
    alpha = C(i) - c;

    if c >= size(Y, 2)
        c = size(Y, 2) - 1;
        alpha = 1;
    end

    rho = (1 - alpha) * abs(Y(:, c)) + alpha * abs(Y(:, c + 1));
    Yp(:, i) = rho .* exp(1i * phi);

    dphi = angle(Y(:, c + 1)) - angle(Y(:, c));
    phi = phi + dphi;
end

y_modifie = ITFCT(Yp, N, D, fenetre);
end