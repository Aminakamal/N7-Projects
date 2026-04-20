function X = moindres_carres(D_app)
    A1 = [transpose(D_app(1,:).^2)  transpose(D_app(1,:)).*transpose(D_app(2,:)) transpose(D_app(2,:).^2) transpose(D_app(1,:)) transpose(D_app(2,:)) ones(size(D_app,2),1)];
    A = [1 0 1 0 0 0 ; A1];
    B = zeros(size(D_app,2)+1,1);
    B(1) = 1;
    X = A\B;