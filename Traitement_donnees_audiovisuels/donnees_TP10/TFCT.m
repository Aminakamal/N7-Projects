function Y = TFCT(y, N, D, fenetre)

x = buffer(y,N,N-D,'nodelay');

switch fenetre
    case 'rectangulaire'
        w = ones(N,1);
    case 'hann'
        w = hann(N);
end
x = x.*w;
tfct = fft(x);
Y = tfct(1:N/2+1,:);