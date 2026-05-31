function [Y_modifie,taux_compression] = compression(Y, m)

Y_modifie = zeros(size(Y));
m = max(0, min(round(m), size(Y,1)));

for col = 1:size(Y,2)
    if m == 0
        continue;
    end
    [~,idx] = maxk(abs(Y(:,col)),m);
    Y_modifie(idx,col) = Y(idx,col);
end

taux_compression = 1 - m/size(Y,1);