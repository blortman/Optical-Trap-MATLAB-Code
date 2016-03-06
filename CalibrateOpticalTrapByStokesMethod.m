function [ Results ] = CalibrateOpticalTrapByStokesMethod( RawData, Parameters )

    Results = Parameters;

    % check validity of arguments
    if( isempty(RawData) | ...
        Parameters.QpdResponsivity(1) == 0 | ...
        Parameters.QpdResponsivity(2) == 0 ...
    )
        return
    end

    xStageAmplitude = range(RawData(:,3));
    yStageAmplitude = range(RawData(:,4));

    if(xStageAmplitude > yStageAmplitude)
        axisName = 'X';
        axisNumber = [1 3];
    else
        axisName = 'Y';
        axisNumber = [2 4];
    end

    beta = 3 .* pi .* Parameters.Viscosity .* Parameters.Diameter;

    force =  beta .* ...
        (Parameters.StageResponsivity .* diff(RawData(:,axisNumber(2))) + ...
         diff(RawData(:,axisNumber(1))) ./ Parameters.QpdResponsivity(axisNumber(1)) ) ...
         * Parameters.SampleRate;

    displacement = (RawData(1:(end-1),axisNumber(1))+ RawData(2:(end),axisNumber(1)))/2 ./ Parameters.QpdResponsivity(axisNumber(1));
    displacement = displacement - mean(displacement);

    X = [ones(size(force)) (force * 1e12)];

    [coefficients confidenceIntervals residuals intervals statistics] = regress(displacement * 1e12, X);

    intercept = coefficients(1) / 1e12;
    alpha = 1 / coefficients(2);
    rSquared = statistics(1);
    tStatistic = statistics(2);

    Results.Type = 'Stokes';
    Results.AxisNumber = axisNumber(1);
    Results.AxisName = axisName;
    Results.Alpha = alpha;
    Results.Intercept = intercept;
    Results.AlphaConfidenceInterval = 1 ./ confidenceIntervals(2,:) / 1e12;
    Results.Residuals = residuals;
    Results.Intervals = intervals;
    Results.RSquared = rSquared;
    Results.TStatistic = tStatistic;
    Results.Force = force;
    Results.Displacement = displacement;
