function [ output_args ] = CalculateOpticalTrapCalibration( RawData )
%CalculateOpticalTrapCalibration Calculates alpha/power and R/power
%coefficients from multiple calibration datasets
%   RawData is a cell array of the individual measurements

    thermalResults = struct();
    thermalResults.AlphaEquipartition = [];
    thermalResults.AlphaPsd = [];
    thermalResults.Responsivity = [];
    thermalResults.Power = [];
    numberOfThermal = 0;

    stokesResults = struct();
    stokesResults.Alpha{1} = [];
    stokesResults.Alpha{2} = [];
    stokesResults.Power{1} = [];
    stokesResults.Power{2} = [];
    numberOfStokes = [0 0];
    
    xyScanResults = struct();
    xyScanResults.Responsivity{1} = [];
    xyScanResults.Responsivity{2} = [];
    xyScanResults.Power{1} = [];
    xyScanResults.Power{2} = [];
    numberOfXyScans = [0 0];

    for ii=1:length(RawData)
        switch(RawData{ii}.Type)

            case ('PSD')
                thermalResults.AlphaEquipartition(end+1,:) = RawData{ii}.AlphaEquipartition;
                thermalResults.AlphaPsd(end+1,:) = RawData{ii}.AlphaPsd;
                thermalResults.Responsivity(end+1,:) = RawData{ii}.Responsivity;
                thermalResults.Power(end+1) = RawData{ii}.Power;

                figure
                clf
                loglog(RawData{ii}.Frequency, RawData{ii}.Pxx );
                hold on
                % loglog(f, OpticalTrapPsdModel(initialGuesses, f), 'r-');
                loglog(RawData{ii}.Frequency, RawData{ii}.ModelPxx , 'g', 'linewidth', 2);
                set(gca, 'FontSize', 14);
                xlabel('Frequency (Hz)')
                ylabel('Noise Power (V^2/Hz)');

                textAnnotation = {};
                textAnnotation{1} = [RawData{ii}.FileName];
                textAnnotation{2} = ['Alpha PSD: ' num2str(RawData{ii}.AlphaPsd, 3) ' N/m'];
                textAnnotation{3} = ['Alpha Eq: ' num2str(RawData{ii}.AlphaEquipartition, 3) ' N/m'];
                textAnnotation{4} = ['Responsivity ' num2str(RawData{ii}.Responsivity, 3) 'V/m'];
                textAnnotation{5} = ['F0 ' num2str(RawData{ii}.ResonantFrequency, 3) 'Hz'];
                textAnnotation{6} = ['P0 ' num2str(RawData{ii}.FitParameters(2), 3) 'V^2/Hz'];

                textPositionX = RawData{ii}.Frequency(2);
                textPositionY = 100 * min(RawData{ii}.Pxx);
                text(textPositionX, textPositionY, textAnnotation);

            case ('Stokes')
                stokesResults.Alpha{RawData{ii}.AxisNumber}(end+1) = RawData{ii}.Alpha;
                stokesResults.Power{RawData{ii}.AxisNumber}(end+1) = RawData{ii}.Power;

                figure

                plot(RawData{ii}.Force, RawData{ii}.Displacement, 'x')
                title(['Force versus Velocity (N=' num2str(length(force)) ')'])
                xlabel('Force (N)')
                ylabel('Displacement (M)')
                hold on
                xAxis = [min(force) max(force)];
                predictedY = 1 / RawData{ii}.Alpha * xAxis + RawData{ii}.Intercept;
                plot(xAxis, predictedY, 'r', 'linewidth', 2)

                textAnnotation = {};
                textAnnotation{1} = RawData{ii}.FileName;
                textAnnotation{2} = ['Alpha: ' num2str(RawData{ii}.Alpha, 3) ' N/m'];

                textPositionX = min(RawData{ii}.Force);
                textPositionY = -0.8 * min(RawData{ii}.Displacement);
                text(textPositionX, textPositionY, textAnnotation);
                
            case ('XY Scan')
                xyScanResults.Responsivity{RawData{ii}.AxisNumber}(end+1) = RawData{ii}.Alpha;
                stokesResults.Power{RawData{ii}.AxisNumber}(end+1) = RawData{ii}.Power;
                
        end
    end


    figure

    legendString = {};

    % plot alpha versus power for equipartition and PSD methods
    if(~isempty(thermalResults.Power))
        xEquipartitionStiffnessCoefficient = regress(thermalResults.AlphaEquipartition(:,1), thermalResults.Power');
        yEquipartitionStiffnessCoefficient = regress(thermalResults.AlphaEquipartition(:,2), thermalResults.Power');

        plot(thermalResults.Power, thermalResults.AlphaEquipartition(:,1), 'b+', 'linewidth', 2);
        hold on
        plot(thermalResults.Power, thermalResults.AlphaEquipartition(:,2), 'r+', 'linewidth', 2);
        legendString = [legendString; 'Equipartition X'; 'Equipartition Y'];

        fitXPower = [0 (max(thermalResults.Power) * xEquipartitionStiffnessCoefficient)];
        fitYPower = [0 (max(thermalResults.Power) * yEquipartitionStiffnessCoefficient)];
        fitXAxis = [0 max(thermalResults.Power)];
        plot(fitXAxis, fitXPower, 'b--');
        plot(fitXAxis, fitYPower, 'r--');
        legendString = [legendString; 'Equipartition model X'; 'Equipartition model Y'];

        xPsdStiffnessCoefficient = regress(thermalResults.AlphaPsd(:,1), thermalResults.Power');
        yPsdStiffnessCoefficient = regress(thermalResults.AlphaPsd(:,2), thermalResults.Power');

        plot(thermalResults.Power, thermalResults.AlphaPsd(:,1), 'bx', 'linewidth', 2);
        hold on
        plot(thermalResults.Power, thermalResults.AlphaPsd(:,2), 'rx', 'linewidth', 2);
        legendString = [legendString; 'PSD X'; 'PSD Y'];

        fitXPower = [0 (max(thermalResults.Power) * xPsdStiffnessCoefficient)];
        fitYPower = [0 (max(thermalResults.Power) * yPsdStiffnessCoefficient)];
        fitXAxis = [0 max(thermalResults.Power)];
        plot(fitXAxis, fitXPower, 'b-', 'LineWidth', 2);
        plot(fitXAxis, fitYPower, 'r-', 'LineWidth', 2);
        legendString = [legendString; 'PSD model X'; 'PSD model Y'];

        AggregateResults.PsdStiffnessCoefficient = [xPsdStiffnessCoefficient yPsdStiffnessCoefficient];
        AggregateResults.EquipartitionStiffnessCoefficient = [xEquipartitionStiffnessCoefficient yEquipartitionStiffnessCoefficient];
    end

    if(~isempty(stokesResults.Power{1}))
        xStokesStiffnessCoefficient = regress(stokesResults.Alpha{1}', stokesResults.Power{1}');

        plot(stokesResults.Power{1}, stokesResults.Alpha{1}, 'bo', 'linewidth', 2);
        hold on
        fitXPower = [0 (max(stokesResults.Power{1}) * xStokesStiffnessCoefficient)];
        fitXAxis = [0 max(stokesResults.Power{1})];
        plot(fitXAxis, fitXPower, 'b-.');
        legendString = [legendString; 'Stokes X'; 'Stokes model X'];


        AggregateResults.StokesStiffnessCoefficient(1) = xStokesStiffnessCoefficient;
    end

    if(~isempty(stokesResults.Power{2}))
        yStokesStiffnessCoefficient = regress(stokesResults.Alpha{2}', stokesResults.Power{2}');

        plot(stokesResults.Power{2}, stokesResults.Alpha{2}, 'ro', 'linewidth', 2);
        hold on
        fitYPower = [0 (max(stokesResults.Power{2}) * yStokesStiffnessCoefficient)];
        fitYAxis = [0 max(stokesResults.Power{2})];
        plot(fitYAxis, fitYPower, 'r-.');
        AggregateResults.StokesStiffnessCoefficient(2) = yStokesStiffnessCoefficient;
        legendString = [legendString; 'Stokes Y'; 'Stokes model Y'];
    end
    legend(legendString);

    if(~isempty(thermalResults.Power))
        figure
        plot(thermalResults.Power', thermalResults.Responsivity(:,1), 'bx', 'linewidth', 2);
        hold on
        plot(thermalResults.Power', thermalResults.Responsivity(:,2), 'rx', 'linewidth', 2);

        xQpdPsdResponsivityCoefficient = regress(thermalResults.Responsivity(:,1), thermalResults.Power');
        yQpdPsdResponsivityCoefficient = regress(thermalResults.Responsivity(:,2), thermalResults.Power');

        fitXResponsivity = [0 (xQpdPsdResponsivityCoefficient * max(thermalResults.Power))];
        fitYResponsivity = [0 (yQpdPsdResponsivityCoefficient * max(thermalResults.Power))];
        fitXAxis = [0 max(thermalResults.Power)];
        plot(fitXAxis, fitXResponsivity, 'b');
        plot(fitXAxis, fitYResponsivity, 'r');
        title('QPD Responsivity versus Power');

        AggregateResults.QpdPsdResponsivityCoefficient = [xQpdPsdResponsivityCoefficient yQpdPsdResponsivityCoefficient];
    end

    allXAlphas = [thermalResults.AlphaEquipartition(:,1)' thermalResults.AlphaPsd(:,1)' stokesResults.Alpha{1}];
    allXPowers = [thermalResults.Power thermalResults.Power stokesResults.Power{1}];
    allXPowerGroup = arrayfun(@(x) {num2str(x)}, allXPowers);
    allXMethodGroup = cell(1, length(allXAlphas));

    numberOfStokes = length(stokesResults.Power{1});
    allXMethodGroup(1:length(thermalResults.Power)) = {'Equipartition'};
    allXMethodGroup((length(thermalResults.Power)+1):(2*length(thermalResults.Power))) = {'PSD'};
    allXMethodGroup((2*length(thermalResults.Power)+1):(2*length(thermalResults.Power)+numberOfStokes)) = {'Stokes'};

    [p t s] = anovan(allXAlphas, {allXMethodGroup, allXPowerGroup}, 'display', 'off');
    multcompare(s, 'dimension', [1 2]);
    title('Comparison of Mean Alpha Value by Method and Power (X Axis)');

    allYAlphas = [thermalResults.AlphaEquipartition(:,2)' thermalResults.AlphaPsd(:,2)' stokesResults.Alpha{2}];
    allYPowers = [thermalResults.Power thermalResults.Power stokesResults.Power{2}];
    allYPowerGroup = arrayfun(@(x) {num2str(x)}, allXPowers);
    allYMethodGroup = cell(1, length(allXAlphas));

    numberOfStokes = length(stokesResults.Power{2});
    allYMethodGroup(1:length(thermalResults.Power)) = {'Equipartition'};
    allYMethodGroup((length(thermalResults.Power)+1):(2*length(thermalResults.Power))) = {'PSD'};
    allYMethodGroup((2*length(thermalResults.Power)+1):(2*length(thermalResults.Power)+numberOfStokes)) = {'Stokes'};

    [p t s] = anovan(allYAlphas, {allYMethodGroup, allYPowerGroup}, 'display', 'off');
    figure
    multcompare(s, 'dimension', [1 2]);
    title('Comparison of Mean Alpha Value by Method and Power (Y Axis)');
end

