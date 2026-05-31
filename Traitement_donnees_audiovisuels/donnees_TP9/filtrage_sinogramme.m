function S_filtered = filtrage_sinogramme(S)
% Apply Ram-Lak filter to sinogram in Fourier domain
%
% Input:
%   S: sinogram matrix (n_u x n_theta)
%
% Output:
%   S_filtered: filtered sinogram (n_u x n_theta)

    [n_u, n_theta] = size(S);
    S_filtered = zeros(size(S));
    
    % Create Ram-Lak filter: |f| (absolute value of frequency)
    % The frequencies go from -pi to pi (normalized)
    frequencies = linspace(-pi, pi, n_u);
    ram_lak_filter = abs(frequencies);
    
    % Apply filter to each column (each angle)
    for t = 1:n_theta
        % FFT of the column
        S_fft = fft(S(:, t));
        
        % Shift zero frequency to center
        S_fft_shifted = fftshift(S_fft);
        
        % Apply Ram-Lak filter
        S_fft_filtered = S_fft_shifted .* ram_lak_filter';
        
        % Shift back
        S_fft = ifftshift(S_fft_filtered);
        
        % IFFT to get back to spatial domain (take real part to remove numerical noise)
        S_filtered(:, t) = real(ifft(S_fft));
    end
end
