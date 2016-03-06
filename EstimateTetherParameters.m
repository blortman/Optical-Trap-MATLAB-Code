function out = EstimateTetherParameters( StageDisplacement, QpdDisplacement )

numberOfSamples = length(StageDisplacement);

[ amplitude1Guess center1Guess] = max(QpdDisplacement);
[ amplitude2Guess center2Guess] = min(QpdDisplacement);
lowerBounds = [ -Inf, 1, 1, ...
                -Inf, 1, 1, ...
                -Inf ];
upperBounds = [  Inf, numberOfSamples/2, numberOfSamples, ...
                 Inf, numberOfSamples/2, numberOfSamples, ...
                 Inf ];

out = lsqcurvefit( @TetherDisplacementModel, [ ...
    amplitude1Guess, 0.15 * numberOfSamples, center1Guess, ...
    amplitude2Guess, 0.15 * numberOfSamples, center2Guess, ...
    mean(QpdDisplacement) ], ...
    StageDisplacement, ...
    QpdDisplacement, lowerBounds, upperBounds );

