function [ Results ] = CalibrateOpticalTrapByPsdMethod( RawData, Parameters )

    Parameters.LowCutoffFrequency = 5;
    Results = Parameters;

    for axisNumber=1:2
        qpdVoltage = RawData(:, axisNumber);
        zeroOffsetQpdVoltage = qpdVoltage - mean(qpdVoltage);

        % compute power spectrum of QPD signal using Welch's method
        [Pxx, f] = pwelch(zeroOffsetQpdVoltage, [], [], 65536, Parameters.SampleRate);
        
        Pxx = Pxx( f > Parameters.LowCutoffFrequency);
        f = f( f > Parameters.LowCutoffFrequency);

        %
        % use nlinfit to estimate P0 and f0
        %

        % compute initial guesses for nlinfit
        p0Guess = mean(Pxx(5:15));
        fortyDbIndex = round(find(Pxx < 0.01 * p0Guess, 1));
        if(isempty(fortyDbIndex))
            fortyDbIndex = round(0.5 * length(Pxx));
        end
        f0Guess = f(max(1,round(fortyDbIndex / 20)));

        if(isempty(f0Guess))
            f0Guess = max(f) / 4;
        end

        initialGuesses = [f0Guess, p0Guess];

        logModelFunction = @(Parameters, Frequency) log(OpticalTrapPsdModel(Parameters, Frequency));

        fitOptions = optimset('TolFun',1E-30,'TolX',1E-10);
        bestFit = nlinfit(f, log(Pxx), logModelFunction, initialGuesses, fitOptions);

        f0 = bestFit(1);
        P0 = bestFit(2);

        boltzmannConstant = 1.3806503E-23;
        kbT = boltzmannConstant * Parameters.Temperature;
        beta = 3 * pi * Parameters.Viscosity * Parameters.Diameter;

        alphaPsd = 2 * pi * f0 * beta;
        qpdResponsivityPsd = sqrt(pi^2 * beta * f0^2 * P0 / (kbT));

        Results.Type = 'PSD';
        Results.AlphaPsd(axisNumber) = alphaPsd;
        Results.ResonantFrequency(axisNumber) = bestFit(1);
        Results.FitParameters{axisNumber} = bestFit;
        Results.Frequency = f;
        Results.Pxx{axisNumber} = Pxx;
        Results.ModelPxx{axisNumber} = OpticalTrapPsdModel(bestFit, f);
        Results.Beta = 3 * pi * Parameters.Viscosity * Parameters.Diameter;
        Results.Responsivity(axisNumber) = qpdResponsivityPsd;
        Results.Power = Parameters.Power;

        % compute stiffness by equipartition method using
        % responsivity from other calibration

        Results.AlphaEquipartition(axisNumber) = ...
            boltzmannConstant * Parameters.Temperature / var( zeroOffsetQpdVoltage / Results.Responsivity(axisNumber));
    end

end

