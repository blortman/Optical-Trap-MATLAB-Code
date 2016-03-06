close all
plotBackgroundColor = [.8 .8 1];

boltzmannConstant = 1.3806503E-23;
temperature = 275;
viscosity = 1e-3;
diameter = 1e-6;
beta = 3 * pi * viscosity * diameter;
alpha = 0.2e-6;
f0 = alpha / 2 / pi / beta;
p0 = boltzmannConstant* temperature / pi / f0;

% figure
% f = 1:25e3;
% Pxx = OpticalTrapPsdModel([f0 p0], f);
% loglog(f, Pxx, 'b', 'linewidth', 3);
% hold on
% %area(f, Pxx, 1e-29, 'FaceColor', [0 1 0]);
% loglog(f, Pxx, 'b', 'linewidth', 3);
% 
% % alpha = 2e-6;
% % f0 = alpha / 2 / pi / beta;
% % p0 = boltzmannConstant* temperature / pi / f0;
% % Pxx = OpticalTrapPsdModel([f0 p0], f);
% % loglog(f, Pxx, 'r', 'linewidth', 3);
% % 
% % alpha = 20e-6;
% % f0 = alpha / 2 / pi / beta;
% % p0 = boltzmannConstant* temperature / pi / f0;
% % Pxx = OpticalTrapPsdModel([f0 p0], f);
% % %area(f, Pxx, 1e-29, 'FaceColor', [0 1 0]);
% % loglog(f, Pxx, 'g', 'linewidth', 3);
% 
% axis([1, 25e3, 1e-28 1e-20]);
% set(gca, 'FontSize', 14);
% xlabel('Frequency (Hz)');
% ylabel('PSD (kg m^2/ s)');
% title('Trapped Particle Power Spectrum');
% %legend('0.2e-6 N/m', '2e-6 N/m', '20e-6 N/m')
% legend('2e-6 N/m')
% set(gca,'XTick',[1 10 1e2 1e3 1e4], 'Color', plotBackgroundColor)
% 
% alpha = 0.2e-6;
% f0 = alpha / 2 / pi / beta;
% p0 = boltzmannConstant* temperature / pi / f0;
% 
% f = 1:25e3;
% Pxx = OpticalTrapPsdModel([f0 p0], f);
% %loglog(f, Pxx, 'b', 'linewidth', 3);
% hold on
%  area(f, Pxx, 1e-29, 'FaceColor', [0 0 1]);
% loglog(f, Pxx, 'b', 'linewidth', 3);



figure

alpha = 2e-6;
f0 = alpha / 2 / pi / beta;
p0 = boltzmannConstant* temperature / pi^2 / beta / f0^2;
Pxx = OpticalTrapPsdModel([f0 p0], f);
loglog(f, Pxx, 'r', 'linewidth', 3);

axis([1, 25e3, 1e-22 1e-14]);
set(gca, 'FontSize', 14);
xlabel('Frequency (Hz)');
ylabel('Noise power (m^2/ Hz)');
title('Trapped Particle Displacement Spectrum');
legend('2e-6 N/m')
set(gca,'XTick',[1 10 1e2 1e3 1e4], 'Color', plotBackgroundColor)

figure

alpha = 2e-6;
f0 = alpha / 2 / pi / beta;
p0 = boltzmannConstant* temperature / pi^2 / beta / f0^2;
Pxx = OpticalTrapPsdModel([f0 p0], f);
loglog(f, Pxx, 'r', 'linewidth', 3);
hold on
area(f, Pxx, 1e-29, 'FaceColor', [1 0 0]);
loglog(f, Pxx, 'r', 'linewidth', 3);

axis([1, 25e3, 1e-22 1e-14]);
set(gca, 'FontSize', 14);
xlabel('Frequency (Hz)');
ylabel('Noise power (m^2/ Hz)');
title('Trapped Particle Displacement Spectrum');
%legend('2e-6 N/m')
set(gca,'XTick',[1 10 1e2 1e3 1e4], 'Color', plotBackgroundColor)


figure

alpha = 0.2e-6;
f0 = alpha / 2 / pi / beta;
p0 = boltzmannConstant* temperature / pi^2 / beta / f0^2;

f = 1:25e3;
Pxx = OpticalTrapPsdModel([f0 p0], f);
loglog(f, Pxx, 'b', 'linewidth', 3);
hold on

alpha = 2e-6;
f0 = alpha / 2 / pi / beta;
p0 = boltzmannConstant* temperature / pi^2 / beta / f0^2;
Pxx = OpticalTrapPsdModel([f0 p0], f);
loglog(f, Pxx, 'r', 'linewidth', 3);

alpha = 20e-6;
f0 = alpha / 2 / pi / beta;
p0 = boltzmannConstant* temperature / pi^2 / beta / f0^2;
Pxx = OpticalTrapPsdModel([f0 p0], f);
loglog(f, Pxx, 'g', 'linewidth', 3);

axis([1, 25e3, 1e-22 1e-14]);
set(gca, 'FontSize', 14);
xlabel('Frequency (Hz)');
ylabel('Noise power (m^2/ Hz)');
title('Trapped Particle Displacement Spectrum');
legend('0.2e-6 N/m', '2e-6 N/m', '20e-6 N/m')
set(gca,'XTick',[1 10 1e2 1e3 1e4], 'Color', plotBackgroundColor)