function [ Results ] = ProcessOpticalTrapCalibrationDataset( RawData )
%CalculateOpticalTrapCalibration Calculates alpha/power and R/power
%coefficients from multiple calibration datasets
%   RawData is a cell array of the individual measurements
    Results = struct();

    thermalResults = struct();
    thermalResults.AlphaEquipartition = [];
    thermalResults.AlphaPsd = [];
    thermalResults.Responsivity = [];
    thermalResults.Power = [];
    numberOfThermalResults = 0;

    stokesResults = struct();
    stokesResults.Alpha{1} = [];
    stokesResults.Alpha{2} = [];
    stokesResults.Power{1} = [];
    stokesResults.Power{2} = [];
    numberOfStokesResults = [0 0];
    
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
                 numberOfThermalResults = numberOfThermalResults + 1;

            case ('Stokes')
                stokesResults.Alpha{RawData{ii}.AxisNumber}(:,end+1) = abs(RawData{ii}.Alpha);
                stokesResults.Power{RawData{ii}.AxisNumber}(:,end+1) = RawData{ii}.Power;
                numberOfStokesResults(RawData{ii}.AxisNumber) =  numberOfStokesResults(RawData{ii}.AxisNumber) + 1;

            case ('XY Scan')
                xyScanResults.Responsivity{RawData{ii}.AxisNumber}(end+1) = RawData{ii}.Alpha;
                xyScanResults.Power{RawData{ii}.AxisNumber}(end+1) = RawData{ii}.Power;
                numberOfXyScans(RawData{ii}.AxisNumber) =  numberOfXyScans(RawData{ii}.AxisNumber) + 1;
        end
    end
    
    Results.ThermalCalibrationData = thermalResults;
    Results.StokesCalibrationData = stokesResults;
    
    Results.EquipartitionStiffnessCoefficient = [0 0];
    Results.EquipartitionStiffnessCoefficientConfidenceInterval = {};
    Results.PsdStiffnessCoefficient = [0 0];
    Results.PsdStiffnessCoefficientConfidenceInterval = {};
    Results.QpdPsdResponsivityCoefficient = {};
    Results.QpdPsdResponsivityCoefficientConfidenceInterval = {};
    
    for ii=1:2
        if(numberOfThermalResults > 0)
            [Results.EquipartitionStiffnessCoefficient(ii) Results.EquipartitionStiffnessCoefficientConfidenceInterval{ii}] = regress(thermalResults.AlphaEquipartition(:,ii), thermalResults.Power');
            [Results.PsdStiffnessCoefficient(ii) Results.PsdStiffnessCoefficientConfidenceInterval{ii}] = regress(thermalResults.AlphaPsd(:,ii), thermalResults.Power');
            X = [thermalResults.Power' ones(length(thermalResults.Power),1)];
            [Results.QpdPsdResponsivityCoefficient{ii} Results.QpdPsdResponsivityCoefficientConfidenceInterval{ii}] = regress(thermalResults.Responsivity(:,ii), X);
        else
            Results.EquipartitionStiffnessCoefficient(ii) = NaN;
            Results.EquipartitionStiffnessCoefficientConfidenceInterval = {[NaN NaN], [NaN NaN]};
            Results.QpdPsdResponsivityCoefficient{ii} = 0;
            Results.QpdPsdResponsivityCoefficientConfidenceInterval{ii} = {[NaN NaN], [NaN NaN]};
        end
    end

    Results.StokesStiffnessCoefficient = [0 0];
    Results.StokesStiffnessCoefficientConfidenceInterval = {};

    for ii = 1:2
        if(numberOfStokesResults(ii) > 0)
            [Results.StokesStiffnessCoefficient(ii) Results.StokesStiffnessCoefficientConfidenceInterval{ii}] = regress(stokesResults.Alpha{ii}', stokesResults.Power{ii}');
        else
            Results.StokesStiffnessCoefficient(ii) = NaN;
            Results.StokesStiffnessCoefficientConfidenceInterval{ii} = [NaN NaN];
        end
    end
    
    % calculate responsivity coefficient from XY scan

    Results.QpdResponsivityXyScan = [0 0];
    Results.QpdResponsivityXyScanConfidenceInterval = {};

    for ii = 1:2
        if(numberOfXyScans(ii) > 0)
            [Results.QpdResponsivityXyScan(ii) Results.QpdResponsivityXyScanConfidenceInterval(ii)] = regress(xyScanResults.Responsivity{ii}', xyScanResults.Power{ii}');
        else
            Results.QpdResponsivityXyScan(ii) = NaN;
            Results.QpdResponsivityXyScanConfidenceInterval{ii} = [NaN NaN];
        end
    end
    
    % analysis of variance
    
    Results.Anova = {};

    for ii=1:2
        if((numberOfThermalResults > 0) & (numberOfStokesResults(ii) > 0))
            Results.Anova{ii} = struct();
            Results.Anova{ii}.P = [];
            Results.Anova{ii}.Statistics = [];

            allAlphas = [thermalResults.AlphaEquipartition(:,ii)' thermalResults.AlphaPsd(:,ii)' stokesResults.Alpha{ii}];
            allPowers = [thermalResults.Power thermalResults.Power stokesResults.Power{ii}];
            powerStrings = arrayfun(@(x) {num2str(x)}, allPowers);
            methodStrings = cell(1, length(allAlphas));

            numberOfStokes = length(stokesResults.Power{ii});
            methodStrings(1:length(thermalResults.Power)) = {'Equipartition'};
            methodStrings((length(thermalResults.Power)+1):(2*length(thermalResults.Power))) = {'PSD'};
            methodStrings((2*length(thermalResults.Power)+1):(2*length(thermalResults.Power)+numberOfStokes)) = {'Stokes'};

            [Results.Anova{ii}.P unused Results.Anova{ii}.Statistics] = anovan(allAlphas, {methodStrings, powerStrings}, 'display', 'off');
        else
            Results.Anova{ii} = [];
        end
    end
end

