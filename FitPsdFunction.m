% Fits a first order transfer function to PSD
% Usage: out = FitPsdFunction(f, psd)
% arguments: 
% f = frequency vector
% psd = psd data
% returns:
% out = cutoff frequency and whatever else
function [IndividualResults AggregateResults] = FitPsdFunction(Descriptor, varargin)

    p = inputParser;
    p.addParamValue('Path', 'Calibration/', @(x) ischar(x));
    p.addParamValue('DebugMode', false, @(x) islogical(x));
    p.addParamValue('QpdCoefficient', [], @(x) isnumeric(x));
    p.parse(varargin{:});

    parameters = p.Results;

    IndividualResults = cell(1,length(Descriptor));
    AggregateResults = struct();

    for ii=1:length(Descriptor)
        if(strcmp(Descriptor{ii}.Type, 'XY Scan'))
            rawData = LoadRawData(Descriptor{ii}, parameters.Path);
            [interpolator results] = PlotNonuiformSampledSurface(rawData);
        end
    end    
    
    for ii=1:length(Descriptor)
        rawData = LoadRawData(Descriptor{ii}, parameters.Path);

        switch(Descriptor{ii}.Type)

            case ('PSD')
                IndividualResults{ii} = CalibrateOpticalTrapByPsdMethod(rawData, Descriptor{ii});
                IndividualResults{ii}.FileName = Descriptor{ii}.FileName;

            case('Stokes')
                disp(['Stokes calibration file: ' Descriptor{ii}.FileName]);
                xStageAmplitude = range(rawData(:,3)) - min(rawData(:,3));
                yStageAmplitude = range(rawData(:,4)) - min(rawData(:,4));

                if(xStageAmplitude > yStageAmplitude)
                    disp('X axis selected');
                    axisName = 'X';
                    axisNumber = [1 3];
                else
                    disp('Y axis selected');
                    axisName = 'Y';
                    axisNumber = [2 4];
                end

                beta = 3 .* pi .* Descriptor{ii}.Viscosity .* Descriptor{ii}.Diameter;

                force =  beta .* ...
                    (Descriptor{ii}.StageResponsivity .* diff(rawData(:,axisNumber(2))) + ...
                     diff(rawData(:,axisNumber(1))) ./ Descriptor{ii}.QpdResponsivity(axisNumber(1)) ) ...
                     * Descriptor{ii}.SampleRate;

                displacement = (rawData(1:(end-1),axisNumber(1))+ rawData(2:(end),axisNumber(1)))/2 ./ Descriptor{ii}.QpdResponsivity(axisNumber(1));
                displacement = displacement - mean(displacement);

                X = [ones(size(force)) (force * 1e12)];

                [coefficients confidenceIntervals residuals intervals statistics] = regress(displacement * 1e12, X);

                intercept = coefficients(1) / 1e12;
                alpha = 1 / coefficients(2);
                rSquared = statistics(1);
                tStatistic = statistics(2);

                IndividualResults{ii} = Descriptor{ii};
                IndividualResults{ii}.AxisNumber = axisNumber(1);
                IndividualResults{ii}.Alpha = alpha;
                IndividualResults{ii}.Intercept = intercept;
                IndividualResults{ii}.AlphaConfidenceInterval = confidenceIntervals(2,:);
                IndividualResults{ii}.Residuals = residuals;
                IndividualResults{ii}.Intervals = intervals;
                IndividualResults{ii}.RSquared = rSquared;
                IndividualResults{ii}.TStatistic = tStatistic;
                IndividualResults{ii}.Force = force;
                IndividualResults{ii}.Displacement = displacement;
        end
    end

    thermalResults = struct();
    thermalResults.AlphaEquipartition = [];
    thermalResults.AlphaPsd = [];
    thermalResults.Responsivity = [];
    thermalResults.Power = [];

    stokesResults = struct();
    stokesResults.Alpha{1} = [];
    stokesResults.Alpha{2} = [];
    stokesResults.Power{1} = [];
    stokesResults.Power{2} = [];

    for ii=1:length(IndividualResults)
        switch(Descriptor{ii}.Type)

            case ('PSD')
                thermalResults.AlphaEquipartition(end+1,:) = IndividualResults{ii}.AlphaEquipartition;
                thermalResults.AlphaPsd(end+1,:) = IndividualResults{ii}.AlphaPsd;
                thermalResults.Responsivity(end+1,:) = IndividualResults{ii}.Responsivity;
                thermalResults.Power(end+1) = IndividualResults{ii}.Power;

                figure
                clf
                loglog(IndividualResults{ii}.Frequency, IndividualResults{ii}.Pxx );
                hold on
                % loglog(f, OpticalTrapPsdModel(initialGuesses, f), 'r-');
                loglog(IndividualResults{ii}.Frequency, IndividualResults{ii}.ModelPxx , 'g', 'linewidth', 2);
                set(gca, 'FontSize', 14);
                xlabel('Frequency (Hz)')
                ylabel('Noise Power (V^2/Hz)');

                textAnnotation = {};
                textAnnotation{1} = [IndividualResults{ii}.FileName];
                textAnnotation{2} = ['Alpha PSD: ' num2str(IndividualResults{ii}.AlphaPsd, 3) ' N/m'];
                textAnnotation{3} = ['Alpha Eq: ' num2str(IndividualResults{ii}.AlphaEquipartition, 3) ' N/m'];
                textAnnotation{4} = ['Responsivity ' num2str(IndividualResults{ii}.Responsivity, 3) 'V/m'];
                textAnnotation{5} = ['F0 ' num2str(IndividualResults{ii}.ResonantFrequency, 3) 'Hz'];
                textAnnotation{6} = ['P0 ' num2str(IndividualResults{ii}.FitParameters(2), 3) 'V^2/Hz'];

                textPositionX = IndividualResults{ii}.Frequency(2);
                textPositionY = 100 * min(IndividualResults{ii}.Pxx);
                text(textPositionX, textPositionY, textAnnotation);

            case ('Stokes')
                stokesResults.Alpha{IndividualResults{ii}.AxisNumber}(end+1) = IndividualResults{ii}.Alpha;
                stokesResults.Power{IndividualResults{ii}.AxisNumber}(end+1) = IndividualResults{ii}.Power;

                figure

                plot(IndividualResults{ii}.Force, IndividualResults{ii}.Displacement, 'x')
                title(['Force versus Velocity (N=' num2str(length(force)) ')'])
                xlabel('Force (N)')
                ylabel('Displacement (M)')
                hold on
                xAxis = [min(force) max(force)];
                predictedY = 1 / IndividualResults{ii}.Alpha * xAxis + IndividualResults{ii}.Intercept;
                plot(xAxis, predictedY, 'r', 'linewidth', 2)

                textAnnotation = {};
                textAnnotation{1} = IndividualResults{ii}.FileName;
                textAnnotation{2} = ['Alpha: ' num2str(IndividualResults{ii}.Alpha, 3) ' N/m'];

                textPositionX = min(IndividualResults{ii}.Force);
                textPositionY = -0.8 * min(IndividualResults{ii}.Displacement);
                text(textPositionX, textPositionY, textAnnotation);
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

function RawData = LoadRawData(Descriptor, Path)
    if(isfield(Descriptor, 'FileName'))
        RawData = load([Path Descriptor.FileName]);
        disp(['Loading ' Descriptor.Type ' file: ' Descriptor.FileName]);
    else
        RawData = Descriptor.RawData;
    end

