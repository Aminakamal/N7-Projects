function [pics_t, pics_f] = pics_spectraux(S, eta_t, eta_f, epsilon)

SE = strel("rectangle", [eta_f eta_t]);
S_max = imdilate(S,SE);

pics_spect = (S==S_max) & (S>epsilon);
[pics_f, pics_t] = find(pics_spect);