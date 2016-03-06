%Computes model PSD for optical trap versus regular frequency
function Pxx = OpticalTrapPsdModel(Parameters, Frequency)

f0 = Parameters(1);    % Hz
P0 = Parameters(2);

Pxx = P0 ./ (1 + (Frequency/f0).^2);

% (N*m/K)*(1E9 nm/m)*(1E12pN/N)=(pN*nm/K)
% boltzmannConstant = 1.3806503E-23;
% Alpha = Parameters(1);              % N/m
% qpdResponsivity = Parameters(2);    % m/V
% beta = 3 * pi * Viscosity * Diameter; % kg / s
% 
% resonantFrequency = Alpha / (2 * pi * beta); %(kg / s^2) / (kg / s) = 1/s
% 
% % (V^2/m^2) * (kg/(m^2*s^2*K) * K / (kg/s^3) = V^2/Hz
% Pxx = qpdResponsivity.^-2 * boltzmannConstant .* Temperature ./ (4 * pi^2 .* beta .* (resonantFrequency.^2 + Frequency.^2));
