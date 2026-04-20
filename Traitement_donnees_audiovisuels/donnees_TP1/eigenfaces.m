function W = eigenfaces(X)
    [p,n] = size(X);
    sigma_2 = (X'*X)/n;
    [V, D] = eig(sigma_2);
    [~, idx] = sort(diag(D),'descend');
    V_trie = V(:, idx);

    nb_vect = max(n-1,1);
    V_trie = V_trie(:,1:nb_vect);
    W = X*V_trie;

    normes = sqrt(sum(W.^2,1));
    normes(normes==0) = 1;
    W = W./repmat(normes,p,1);
end