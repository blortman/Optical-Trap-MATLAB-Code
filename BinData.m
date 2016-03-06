function [quantizedXAxis BinnedData StandardDeviation Count] = BinData(Data, varargin)
    p = inputParser;
    p.addParamValue('XColumn', 3, @(x) isscalar(x));
    p.addParamValue('YColumn', 1, @(x) isscalar(x));
    p.addParamValue('NumberOfBins', 100, @(x) isscalar(x));
    p.parse(varargin{:});
    
    parameters = p.Results;

    x = Data(:, parameters.XColumn);
    y = Data(:, parameters.YColumn);
    
    quantizedXAxis = linspace(min(x), max(x), parameters.NumberOfBins);

    BinnedData = zeros(1,length(quantizedXAxis));
    Count = zeros(1,length(quantizedXAxis));
    
    binNumber = round(parameters.NumberOfBins * ((x - min(x))/range(x) * (1 - 2/parameters.NumberOfBins) + 1/parameters.NumberOfBins));

    for jj=1:length(x)
        BinnedData(binNumber(jj)) = BinnedData(binNumber(jj)) + y(jj);
        Count(binNumber(jj)) = Count(binNumber(jj)) + 1;
    end
    BinnedData = BinnedData ./ Count;
    
    StandardDeviation = zeros(1,length(quantizedXAxis));
    for jj=1:length(x)
        StandardDeviation(binNumber(jj)) = StandardDeviation(binNumber(jj)) + (y(binNumber(jj)) - BinnedData(binNumber(jj))).^2;
    end
    
    StandardDeviation = sqrt(StandardDeviation ./ Count);
    
