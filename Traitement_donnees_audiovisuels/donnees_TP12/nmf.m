function [D,A] = nmf(S,D_0,A_0,nIter)

D = D_0;
A = A_0;
for k = 1:nIter
A = A.*((D'* S) ./ ((D' * D * A) ));
D = D .* ((S * A') ./ ((D * (A * A'))));
end
