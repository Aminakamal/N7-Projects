function f = kaczmarz(s, W, nboucles)
% Kaczmarz algorithm for solving the system W*f = s
%
% Input:
%   s: sinogram vector (N_s x 1)
%   W: projection matrix (N_s x N_f)
%   nboucles: number of loops through all equations
%
% Output:
%   f: reconstructed image vector (N_f x 1)

    [N_s, N_f] = size(W);
    n_u = N_s / size(unique(s), 1);  % Number of rays per angle
    
    % Initialize f to zero
    f = zeros(N_f, 1);
    
    % Pre-calculate squared norms of each row of W
    W_norms_squared = sum(W .* W, 2);  % ||w_i||^2 for each row i
    
    % Pre-calculate W transpose for efficiency
    W_T = W';
    
    % Total number of iterations
    k_max = nboucles * N_s;
    
    % Kaczmarz iterations
    for k = 0:k_max-1
        % Get the equation index (cyclic)
        i = mod(k, N_s) + 1;  % +1 because MATLAB uses 1-based indexing
        
        % Get the i-th row of W
        w_i = W(i, :);
        w_i_norm_squared = W_norms_squared(i);
        
        % Skip if the norm is zero
        if w_i_norm_squared > 1e-15
            % Calculate the residual: s_i - w_i * f
            residual = s(i) - w_i * f;
            
            % Update: f = f + (residual / ||w_i||^2) * w_i^T
            f = f + (residual / w_i_norm_squared) * w_i';
        end
    end
end
