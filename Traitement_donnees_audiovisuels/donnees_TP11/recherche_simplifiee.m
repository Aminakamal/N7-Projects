function resultats = recherche_simplifiee(identifiants, bdd)
    resultats = zeros(0,1);
    for i = 1:length(identifiants)
        id = identifiants(i);
        if bdd.isKey(id)
            occ = bdd(id);
            resultats = [resultats; occ(:,2)];
        end
    end
end