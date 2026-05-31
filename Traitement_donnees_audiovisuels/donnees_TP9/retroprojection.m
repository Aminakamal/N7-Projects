function f = retroprojection(S, theta, n_u, n_lignes, n_colonnes)
% Inverse Radon transform using backprojection
%
% Input:
%   S: sinogram matrix (n_u x n_theta)
%   theta: angle values in degrees
%   n_u: number of rays (should be odd)
%   n_lignes: number of rows in the reconstructed image
%   n_colonnes: number of columns in the reconstructed image
%
% Output:
%   f: reconstructed image (n_lignes x n_colonnes)

    n_theta = length(theta);
    
    % Initialize output image
    f = zeros(n_lignes, n_colonnes);
    
    % Center of the image
    center_x = (n_colonnes + 1) / 2;
    center_y = (n_lignes + 1) / 2;
    
    % u range (symmetric around 0)
    u_max = (n_u - 1) / 2;
    u = linspace(-u_max, u_max, n_u);
    
    % For each angle
    for t = 1:n_theta
        % Convert angle to radians
        theta_rad = deg2rad(theta(t));
        cos_theta = cos(theta_rad);
        sin_theta = sin(theta_rad);
        
        % For each pixel in the image
        for row = 1:n_lignes
            for col = 1:n_colonnes
                % Pixel coordinates relative to center
                x = col - center_x;
                y = -(row - center_y);  % Negative because y-axis is opposite to row numbers
                
                % Calculate u value for this pixel and angle
                u_pixel = x * cos_theta + y * sin_theta;
                
                % Find the closest discrete u index
                [~, u_idx] = min(abs(u - u_pixel));
                
                % Add the sinogram value to the pixel (backprojection)
                f(row, col) = f(row, col) + S(u_idx, t);
            end
        end
    end
    
    % Normalize by the number of angles
    f = f / n_theta;
end
