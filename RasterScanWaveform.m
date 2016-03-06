function out = RasterScanWaveform( varargin )
    p = inputParser;
    p.addParamValue('FastAxisSamplesPerLine', 1000, @(x) isscalar(x));
    p.addParamValue('NumberOfLines', 11, @(x) isscalar(x));
    p.addParamValue('Overscan', 0.05, @(x) and(x > 0, x <= 0.5));
    p.addParamValue('Amplitude', 1, @(x) isscalar(x));
    p.parse(varargin{:});
    
    parameters = p.Results;


    numberOfLines = parameters.NumberOfLines + 1 - mod(parameters.NumberOfLines, 2);  % ensure an odd number of lines
    numberOfTurnaroundSamples = round(pi * (1 - 2 * parameters.Overscan) * parameters.FastAxisSamplesPerLine * parameters.Overscan);
    numberOfFastScanSamples = parameters.FastAxisSamplesPerLine - numberOfTurnaroundSamples;
    quantizedOverscan = numberOfTurnaroundSamples / parameters.FastAxisSamplesPerLine / 2;
    
    fastRight = linspace(quantizedOverscan, 1 - quantizedOverscan, numberOfFastScanSamples)';
    fastVelocity = fastRight(2) - fastRight(1);
    fastLeft = fastRight(end:-1:1);
    fastRightTurnaround = fastRight(end) + fastVelocity + (quantizedOverscan - fastVelocity) * 2 / pi * sin(pi / (numberOfTurnaroundSamples - 1) * (0:(numberOfTurnaroundSamples-1))');
    fastLeftTurnaround  = fastRight(1)   - fastVelocity - (quantizedOverscan - fastVelocity) * 2 / pi * sin(pi / (numberOfTurnaroundSamples - 1) * (0:(numberOfTurnaroundSamples-1))');
    temp = (numberOfTurnaroundSamples - mod(numberOfTurnaroundSamples, 2))/2;
    fastScanStart = [zeros(numberOfTurnaroundSamples - temp, 1); fastLeftTurnaround((end-temp+1):end)];
    fastScanEnd = [fastRightTurnaround(1:temp) ; ones(numberOfTurnaroundSamples - temp, 1)];
    slowAxisIncrement = 1 / (numberOfLines - 1) / 2 * (cos(pi / numberOfTurnaroundSamples * (0:(numberOfTurnaroundSamples-1))') - 1);
    
    slowWaveform = zeros(parameters.FastAxisSamplesPerLine * numberOfLines, 1);
    for ii = 0:(numberOfLines-1)
        baseline = 1 - (ii / (numberOfLines - 1));
        startIndex = ii * parameters.FastAxisSamplesPerLine + 1;
        if(ii == 0)
             slowWaveform(startIndex:(startIndex + parameters.FastAxisSamplesPerLine - 1)) = [ ...
                ones(numberOfFastScanSamples, 1);
                1 + slowAxisIncrement;];
        else if (ii < (numberOfLines - 1))
            startIndex = ii * parameters.FastAxisSamplesPerLine + 1;
            slowWaveform(startIndex:(startIndex + parameters.FastAxisSamplesPerLine - 1)) = [...
                baseline * ones(numberOfFastScanSamples, 1); ...
                baseline + slowAxisIncrement;];
            else
                 slowWaveform(startIndex:(startIndex + parameters.FastAxisSamplesPerLine - 1)) = [ ...
                    zeros(numberOfFastScanSamples, 1);
                    fastScanStart];
            end
        end
    end
    
    waveform1 = parameters.Amplitude .* ([ ...
        repmat([fastRight; fastRightTurnaround; fastLeft; fastLeftTurnaround], (numberOfLines - 1)/2, 1); ...
        fastRight; fastScanEnd; slowWaveform] - 0.5);
    
    waveform2 = parameters.Amplitude .* ([ ...
        slowWaveform; ...
        repmat([fastRight; fastRightTurnaround; fastLeft; fastLeftTurnaround], (numberOfLines - 1)/2, 1); ...
        fastRight; fastScanEnd;] - 0.5);

    out = [waveform1 waveform2];