function paires = appariement(pics_t, pics_f, n_v, delta_t, delta_f)

nb = length(pics_t);
paires = zeros(0,4);

for i = 1:nb
    critere1 = (pics_t > pics_t(i)) & (pics_t - pics_t(i) <= delta_t);
    critere2 = abs(pics_f - pics_f(i)) <= delta_f;
    Critere = find(critere1 & critere2, n_v);

    if ~isempty(Critere)
        nc = length(Critere);
        nouvelles_paires = [repmat(pics_f(i), nc, 1), pics_f(Critere), repmat(pics_t(i), nc, 1), pics_t(Critere)];
        paires = [paires; nouvelles_paires];
    end
end