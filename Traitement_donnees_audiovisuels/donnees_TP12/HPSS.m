function [F_h, F_p] = HPSS(absYcarre)
n1 = 17;
n2 = 17;
F_h = medfilt2(absYcarre,[1 n1]);
F_p = medfilt2(absYcarre, [n2 1]);