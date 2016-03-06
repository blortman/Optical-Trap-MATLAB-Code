function out = TransferFunc(params, xdata)

kbandt = 1.38*10^-23*298;
beta = params(1);
f0 = params(2);
out = params(1)./(params(2).^2 + xdata.^2);