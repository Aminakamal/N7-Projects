function k = recuit_simule(k,AD,beta,T)
n = size(AD,1);
m = size(AD,2);
N = size(AD,3);

for i = 1:n
    for j = 1:m
        classe_courante = k(i,j);
        classe_test = randi(N-1);
        if classe_test >= classe_courante
            classe_test = classe_test + 1;
        end
        i_min = max(1,i-1);
        i_max = min(n,i+1);
        j_min = max(1,j-1);
        j_max = min(m,j+1);

        voisins = [];
        for ii = i_min:i_max
            for jj = j_min:j_max
                if ~(ii == i && jj == j)
                    voisins(end+1,1) = k(ii,jj);
                end
            end
        end

        U_s = AD(i,j,classe_courante) + beta*sum(voisins ~= classe_courante);
        U_s_prim = AD(i,j,classe_test) + beta*sum(voisins ~= classe_test);

        delta_U = U_s_prim - U_s;

        if delta_U < 0
            k(i,j) = classe_test;
        elseif T > 0
            if rand < exp(-delta_U/T)
                k(i,j) = classe_test;
            end
        end
    end
end
