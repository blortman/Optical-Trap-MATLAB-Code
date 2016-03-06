function [ output_args ] = PlotPsdCalibration( AxesHandle,  CalibrationResults)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    plotRange = and( CalibrationResults.Frequency > 2, CalibrationResults.Frequency < 5000);

    Pxx = CalibrationResults.Pxx{1}(plotRange);
    Pyy = CalibrationResults.Pxx{2}(plotRange);
    modelPxx = CalibrationResults.ModelPxx{1}(plotRange);
    modelPyy = CalibrationResults.ModelPxx{2}(plotRange);
    f = CalibrationResults.Frequency(plotRange);

    maxPower = max([Pxx; Pyy]);
    minPower = min([Pxx; Pyy]);
    if(minPower == maxPower)
        maxPower = 1;
    end

    cla(AxesHandle);
    plot(AxesHandle, log10(f), log10(Pxx), 'linewidth', 1);
    hold(AxesHandle, 'on');
    plot(AxesHandle, log10(f), log10(Pyy), 'r', 'linewidth', 1);
    plot(AxesHandle, log10(f), log10(modelPxx), 'y', 'linewidth', 2);
    plot(AxesHandle, log10(f), log10(modelPyy), 'c', 'linewidth', 2);

    set(AxesHandle, 'FontSize', 9);
    xlabel(AxesHandle, 'Log Frequency (Hz)');
    ylabel(AxesHandle, 'PSD (V^2/Hz)');
    legend(AxesHandle, 'X', 'Y');

    textAnnotation = {};
    textAnnotation{1} = ['Alpha: ' num2str(CalibrationResults.AlphaPsd, 3) ' N/m'];
    textAnnotation{2} = ['R: ' num2str(CalibrationResults.Responsivity, 3) 'V/m'];
    textAnnotation{3} = ['F0 ' num2str(CalibrationResults.ResonantFrequency, 3) 'Hz'];

    axisLimits = axis(AxesHandle);
    textPositionX = axisLimits(1);
    textPositionY = axisLimits(3);

    text(textPositionX, textPositionY, textAnnotation, 'Parent', AxesHandle, 'FontSize', 9, 'VerticalAlignment', 'Bottom');

    hold(AxesHandle, 'off');

end

