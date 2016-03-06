function Waveform = HypocycloidScanWaveform(varargin)
    p = inputParser;
    p.addParamValue('Diameter', 1, @(x) isscalar(x));
    p.addParamValue('P', 11, @(x) isscalar(x));
    p.addParamValue('Q', 5, @(x) isscalar(x));
    p.addParamValue('NumberOfSamples', 1000, @(x) isscalar(x));
    p.parse(varargin{:});
    
    parameters = p.Results;

    numberOfCusps = parameters.P / parameters.Q;
    insideRadius = parameters.Diameter / numberOfCusps;
    theta = (0:(parameters.NumberOfSamples-1))' * 2 * pi /  parameters.NumberOfSamples * parameters.Q ;
    x = insideRadius * (numberOfCusps - 1) * cos(theta) + insideRadius * cos((numberOfCusps - 1) * theta);
    y = insideRadius * (numberOfCusps - 1) * sin(theta) - insideRadius * sin((numberOfCusps - 1) * theta);

    x = x ./ range(x) .* parameters.Diameter;
    y = y ./ range(y) .* parameters.Diameter;

    Waveform = [x y];