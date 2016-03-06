function PlotStokesCalibration( AxesHandle,  CalibrationResults)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    plot(AxesHandle, CalibrationResults.Force, CalibrationResults.Displacement, 'x');
    hold(AxesHandle, 'on');
    forceAxis = 0.9 * [min(CalibrationResults.Force) max(CalibrationResults.Force)];
    predictedY = 1 / CalibrationResults.Alpha * forceAxis + CalibrationResults.Intercept;
    plot(AxesHandle, forceAxis, predictedY, 'r', 'linewidth', 2);                            

    textAnnotation = {};
    textAnnotation{1} = ['Alpha: ' num2str(CalibrationResults.Alpha, 3) ' N/m'];
    textAnnotation{2} = ['R: ' num2str(CalibrationResults.QpdResponsivity(CalibrationResults.AxisNumber), 3) 'V/m'];
    textAnnotation{3} = ['Alpha CI: ' num2str(CalibrationResults.AlphaConfidenceInterval, 3) 'N/m'];

    axisLimits = axis(AxesHandle);
    if(CalibrationResults.Alpha < 0)
        textPositionX = axisLimits(1);
        textPositionY = axisLimits(3);
        alignment = 'Bottom';
    else
        textPositionX = axisLimits(1);
        textPositionY = axisLimits(4);
        alignment = 'Top';
    end
    text(textPositionX, textPositionY, textAnnotation, 'Parent', AxesHandle, 'FontSize', 8, 'VerticalAlignment', alignment);

    set(AxesHandle, 'FontSize', 9);
    xlabel(AxesHandle, 'Force (N)');
    ylabel(AxesHandle, 'Displacement (m)');
    legend(AxesHandle, 'Data', 'Fit');

    hold(AxesHandle, 'off');
end

