function Results = CalibrateOpticalTrapQpdResponsivityFromXyScan(xyScanData, varargin)
    p = inputParser;
    p.addRequired('xyScanData', @(x) 1);
    p.addParamValue('Overscan', 0.1, @(x) and(x > 0, x <= 1));
    p.addParamValue('XColumn', 3, @(x) 1);
    p.addParamValue('YColumn', 4, @(x) 1);
    p.addParamValue('ZColumn', 1, @(x) 1);
    p.addParamValue('AxisHandle', 0, @(x) 1);
    p.addParamValue('PlotDatapoints', false, @(x) islogical(x));
    p.addParamValue('PlotResolution', 40, @(x) isnumeric(x));
    p.addParamValue('NumberOfPoints', 0, @(x) isnumeric(x));
    p.addParamValue('NoPlot', false, @(x) islogical(x));
    p.addParamValue('PlotType', 'Pseudocolor', @(x) 1);
    p.parse(xyScanData, varargin{:});
    
    parameters = p.Results;
    
    xyScanData(:,parameters.XColumn) = xyScanData(:,parameters.XColumn) - min(xyScanData(:,parameters.XColumn)) - range(xyScanData(:,parameters.XColumn)) / 2;
    xyScanData(:,parameters.YColumn) = xyScanData(:,parameters.YColumn) - min(xyScanData(:,parameters.YColumn)) - range(xyScanData(:,parameters.YColumn)) / 2;
    
    if(parameters.NumberOfPoints ~= 0)
        decimationFactor = round(length(xyScanData) / parameters.NumberOfPoints);
        xyScanData = resample(xyScanData, 1, decimationFactor);
    end
    
    xRange = range(xyScanData(:,parameters.XColumn));
    yRange = range(xyScanData(:,parameters.YColumn));
    xMinimum = min(xyScanData(:,parameters.XColumn)) + parameters.Overscan * xRange;
    xMaximum = max(xyScanData(:,parameters.XColumn)) - parameters.Overscan * xRange;
    yMinimum = min(xyScanData(:,parameters.XColumn)) + parameters.Overscan * yRange;
    yMaximum = max(xyScanData(:,parameters.XColumn)) - parameters.Overscan * yRange;

    xGrid = linspace(xMinimum, xMaximum, parameters.PlotResolution);
    yGrid = linspace(yMinimum, yMaximum, parameters.PlotResolution);
    [x y] = meshgrid(xGrid, yGrid);

     interpolator = TriScatteredInterp(xyScanData(:,parameters.XColumn), xyScanData(:,parameters.YColumn), xyScanData(:,parameters.ZColumn));
     z = interpolator(x, y);

    [maximumValue maximumIndex] = max(z(:));
    [xMaximumIndex yMaximumIndex] = ind2sub(size(z), maximumIndex);
    peak = [x(xMaximumIndex, yMaximumIndex), y(xMaximumIndex, yMaximumIndex)];
    [minimumValue minimumIndex] = min(z(:));
    [xMinimumIndex yMinimumIndex] = ind2sub(size(z), minimumIndex);
    trough = [x(xMinimumIndex, yMinimumIndex), y(xMinimumIndex, yMinimumIndex)];
    
    xMidpoint = mean([x(xMaximumIndex, yMaximumIndex), x(xMinimumIndex, yMinimumIndex)]);
    yMidpoint = mean([y(xMaximumIndex, yMaximumIndex), y(xMinimumIndex, yMinimumIndex)]);
    midpoint = [xMidpoint yMidpoint];
    
    peakToTroughLine = [linspace(peak(1), trough(1), 30)' linspace(peak(2), trough(2), 30)'];
    peakToTroughValues = interpolator(peakToTroughLine(:,1), peakToTroughLine(:,2));
    peakToTroughLineLength = sqrt((peak(1)-trough(1))^2 + (peak(2)-trough(2))^2);
    peakToTroughAxis = linspace(-peakToTroughLineLength/2, peakToTroughLineLength/2, length(peakToTroughValues))';
    
    polynomialCoefficients = polyfit(peakToTroughAxis, peakToTroughValues, 7);
    slopeCoefficients = polyder(polynomialCoefficients);
    responsivity = polyval(slopeCoefficients, 0);
    
    if(~parameters.NoPlot)
        if(parameters.AxisHandle == 0)
            figure();
            parameters.AxisHandle = gca;
        end

        switch(parameters.PlotType)
            case 'Surface'
                meshc(parameters.AxisHandle, x, y, z);

                hold(parameters.AxisHandle, 'on');
                if(parameters.PlotDatapoints ~= false)
                    plot3(parameters.AxisHandle, x, y, z, 'ro');
                end

                plot3(parameters.AxisHandle, peak(1),peak(2),interpolator(peak(1),peak(2)), 'rx','linewidth',2);
                plot3(parameters.AxisHandle, trough(1),trough(2),interpolator(trough(1),trough(2)), 'kx','linewidth',2);
                plot3(parameters.AxisHandle, xMidpoint, yMidpoint, interpolator(xMidpoint, yMidpoint), 'gx', 'linewidth', 2);
                plot3(parameters.AxisHandle, peakToTroughLine(:,1), peakToTroughLine(:,2), interpolator(peakToTroughLine(:,1), peakToTroughLine(:,2)));

                hold(parameters.AxisHandle, 'off');
        
            case 'Pseudocolor'
                plotHandle = pcolor(parameters.AxisHandle, x, y, z);
                set(plotHandle, 'EdgeColor', 'none');
                shading(parameters.AxisHandle, 'interp');
                axis(parameters.AxisHandle, 'square');

                hold(parameters.AxisHandle, 'on');

                plot(parameters.AxisHandle, peakToTroughLine(:,1), peakToTroughLine(:,2), 'LineWidth', 2, 'color', [.25 .25 .25]);
                plot(parameters.AxisHandle, peak(1), peak(2),'cx','LineWidth', 2, 'MarkerSize',10);
                plot(parameters.AxisHandle, trough(1), trough(2), 'mx','LineWidth', 2, 'MarkerSize',10);
                plot(parameters.AxisHandle, xMidpoint, yMidpoint, 'ko', 'MarkerSize',10);
                
            case 'Responsivity'
                plot(parameters.AxisHandle, peakToTroughAxis, peakToTroughValues, 'bx', 'MarkerSize', 5);
                hold(parameters.AxisHandle, 'on');
                plot(parameters.AxisHandle, peakToTroughAxis, polyval(polynomialCoefficients, peakToTroughAxis), 'g', 'LineWidth', 3);
                fitAxis = [peakToTroughAxis(1) + 0.25 * (peakToTroughAxis(end) - peakToTroughAxis(1)), peakToTroughAxis(end) - 0.25 * (peakToTroughAxis(end) - peakToTroughAxis(1))];
                plot(parameters.AxisHandle, fitAxis, responsivity * fitAxis + polynomialCoefficients(end), 'r', 'LineWidth', 2);
                plot(parameters.AxisHandle, peakToTroughAxis, peakToTroughValues, 'bx', 'MarkerSize', 5, 'LineWidth', 2);
                legend(parameters.AxisHandle, 'Data', 'Fit', 'Linear');
                
        end       
        hold(parameters.AxisHandle, 'off');
        
    end
    
    Results = struct();
    Results.Type = 'XY Scan';
    Results.Axis = parameters.ZColumn;
    Results.Interpolator = interpolator;
    Results.CenterPoint = midpoint;
    Results.Peak = peak;
    Results.trough = trough;
    Results.PeakToTroughValues = peakToTroughValues;
    Results.PeakToTroughAxis = peakToTroughAxis;
    Results.PeakToTroughAngle = atan((peak(2)-peak(1))/(trough(2)-trough(1)));
    Results.Responsivity = responsivity;
    Results.PeakToTroughFitPolynomial = polynomialCoefficients;
    Results.PlotRange = [xMinimum xMaximum yMinimum yMaximum];