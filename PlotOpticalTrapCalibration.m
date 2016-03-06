function [ output_args ] = PlotOpticalTrapCalibration( AxesHandles, CalibrationData )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    plotColor = {'b', 'r'};
    axisName = {'X', 'Y'};
    legendString = {};

    % plot alpha versus power for equipartition and PSD methods
    for axisNumber = 1:2
        if(~isempty(CalibrationData.ThermalCalibrationData.Power'))
            plot(AxesHandles.AlphaAxesHandle, CalibrationData.ThermalCalibrationData.Power', CalibrationData.ThermalCalibrationData.AlphaEquipartition(:,axisNumber), [plotColor{axisNumber} 'x']);
            hold(AxesHandles.AlphaAxesHandle, 'on')
            legendString{end+1} = ['Equipartition data ', axisName{axisNumber}];

            fitAxis = [0 max(CalibrationData.ThermalCalibrationData.Power')];
            fitPower = [0 (max(CalibrationData.ThermalCalibrationData.Power') * CalibrationData.EquipartitionStiffnessCoefficient(axisNumber))];
            plot(AxesHandles.AlphaAxesHandle, fitAxis, fitPower, [plotColor{axisNumber} '--']);
            legendString{end+1} = ['Equipartition fit ', axisName{axisNumber}];
        
            plot(AxesHandles.AlphaAxesHandle, CalibrationData.ThermalCalibrationData.Power', CalibrationData.ThermalCalibrationData.AlphaPsd(:,axisNumber), [plotColor{axisNumber} 'd']);
            legendString{end+1} = ['PSD data', axisName{axisNumber}];

            fitPower = [0 (max(CalibrationData.ThermalCalibrationData.Power') * CalibrationData.PsdStiffnessCoefficient(axisNumber))];
            plot(AxesHandles.AlphaAxesHandle, fitAxis, fitPower, plotColor{axisNumber});
            legendString{end+1} = ['PSD fit ', axisName{axisNumber}];
        end
        
        if(~isempty(CalibrationData.StokesCalibrationData.Power{axisNumber}))
            plot(AxesHandles.AlphaAxesHandle, CalibrationData.StokesCalibrationData.Power{axisNumber}, abs(CalibrationData.StokesCalibrationData.Alpha{axisNumber}), [plotColor{axisNumber} '*']);
            legendString{end+1} = ['Stokes data', axisName{axisNumber}];
        end
        
        if(~isempty(CalibrationData.StokesCalibrationData.Power{axisNumber}))
            fitPower = [0 (max(CalibrationData.StokesCalibrationData.Power{axisNumber}) * abs(CalibrationData.StokesStiffnessCoefficient(axisNumber)))];
            fitAxis = [0 max(CalibrationData.StokesCalibrationData.Power{axisNumber})];
            plot(AxesHandles.AlphaAxesHandle, fitAxis, fitPower, [plotColor{axisNumber} '-.']);
            legendString{end+1} = ['Stokes fit ', axisName{axisNumber}];
        end
    end

    title(AxesHandles.AlphaAxesHandle, 'Alpha versus Power');
    xlabel(AxesHandles.AlphaAxesHandle, 'Power (AU)');
    ylabel(AxesHandles.AlphaAxesHandle, 'Alpha (N/m)');
    legend(AxesHandles.AlphaAxesHandle, legendString, 'Location', 'NorthWest', 'FontSize', 8);
    hold(AxesHandles.AlphaAxesHandle, 'off');

    % plot R versus power
    if(~isempty(CalibrationData.ThermalCalibrationData.Power') && isfield(AxesHandles, 'ResponsivityAxesHandle'))
        if(ishandle(AxesHandles.ResponsivityAxesHandle))
            legendString = {};
            for(ii=1:2)
                plot(AxesHandles.ResponsivityAxesHandle, CalibrationData.ThermalCalibrationData.Power'', CalibrationData.ThermalCalibrationData.Responsivity(:,ii), [plotColor{ii} 'x'], 'linewidth', 2);
                legendString{end+1} = [axisName{ii} ' Responsivity Data (PSD)'];
                hold(AxesHandles.ResponsivityAxesHandle, 'on');
                fitResponsivity = [CalibrationData.QpdPsdResponsivityCoefficient{ii}(2) (CalibrationData.QpdPsdResponsivityCoefficient{ii}(1) * max(CalibrationData.ThermalCalibrationData.Power) + CalibrationData.QpdPsdResponsivityCoefficient{ii}(2))];
                fitAxis = [0 max(CalibrationData.ThermalCalibrationData.Power')];
                plot(AxesHandles.ResponsivityAxesHandle, fitAxis, fitResponsivity, plotColor{ii});
                legendString{end+1} = [axisName{ii} ' Responsivity Fit (PSD)'];
            end
            title(AxesHandles.ResponsivityAxesHandle, 'QPD Responsivity versus Power');
            xlabel(AxesHandles.ResponsivityAxesHandle, 'Power (AU)');
            ylabel(AxesHandles.ResponsivityAxesHandle, 'Responsivity (V/m)');
            legend(AxesHandles.ResponsivityAxesHandle, legendString, 'Location', 'NorthWest');
            hold(AxesHandles.ResponsivityAxesHandle, 'off');
        end
    end
    
    plotFormat = {'x', 'd', '*'};
    
    if(isfield(AxesHandles, 'AnovaAxesHandle'))
        legendString = {};
        if(ishandle(AxesHandles.AnovaAxesHandle))
            for ii=1:2
                if(~isempty(CalibrationData.Anova{ii}))
                    [c means h gnames] = multcompare(CalibrationData.Anova{ii}.Statistics, 'dimension', [1 2], 'display', 'off');

                    groupNames = CalibrationData.Anova{ii}.Statistics.grpnames{1};
                    numberOfGroups = length(groupNames);
                    numberOfMeans = length(gnames);
                    selector = boolean(zeros(numberOfMeans, 1));

                    for jj = 1:numberOfGroups
                        for kk = 1:numberOfMeans
                            thisGroupName =  sscanf(gnames{kk}, 'X1=%[A-z]');
                            selector(kk) = strcmp(thisGroupName, groupNames{jj});
                        end

                        groupMeans = means(selector,:);
                        xAxis = 1:length(groupMeans(:,2));
                        errorbar(AxesHandles.AnovaAxesHandle, xAxis + (2 * ii - 3) * .125 + (jj / numberOfGroups) * .075, groupMeans(:,1), groupMeans(:,2),[plotColor{ii} plotFormat{jj}], 'LineWidth', 3, 'MarkerSize', 15)
                        hold(AxesHandles.AnovaAxesHandle, 'on');
                        legendString{end + 1} = groupNames{jj};
                    end
                end
            end
            title('Comparison of Mean Alpha Value by Method and Power (X Axis)');
            legend(AxesHandles.AnovaAxesHandle, legendString, 'Location', 'Northwest');
            hold(AxesHandles.AnovaAxesHandle, 'off');

        end
    end
    
    % display table of values
    tableData = { ...
        'Alpha Coefficient Equipartition (N/m-mW)', CalibrationData.EquipartitionStiffnessCoefficient(1), CalibrationData.EquipartitionStiffnessCoefficient(2); ...
        'Alpha Coefficient Confidence Interval', CalibrationData.EquipartitionStiffnessCoefficientConfidenceInterval{1}, CalibrationData.EquipartitionStiffnessCoefficientConfidenceInterval{2}; ...
         'Alpha Coefficient PSD (N/m-mW)', CalibrationData.PsdStiffnessCoefficient(1), CalibrationData.PsdStiffnessCoefficient(2); ...
         'Alpha Coefficient PSD Confidence Interval', CalibrationData.PsdStiffnessCoefficientConfidenceInterval{1}, CalibrationData.PsdStiffnessCoefficientConfidenceInterval{2}
         }
     
%      if(isfield(CalibrationData, 'StokesStiffnessCoefficient'))  
%          foo = { ...
%              'Alpha Coefficient Stokes (N/m-mW)', CalibrationData.StokesStiffnessCoefficient(1), CalibrationData.StokesStiffnessCoefficient(2); ...
%              'Alpha Coefficient Stokes Confidence Interval', CalibrationData.StokesStiffnessCoefficientConfidenceInterval{1}, CalibrationData.StokesStiffnessCoefficientConfidenceInterval{2} ...
%          };
%      
%      tableData{end+1:end+2,1:3} = foo;
%      end
%      
     
%      if(isfield(CalibrationData.StokesStiffnessCoefficient))  
%          'R Coefficient PSD (N/m-mW)', (CalibrationData.QpdPsdResponsivityCoefficient{ii}(1)...
%          'R Coefficient PSD Confidence Interval',
%         };
%      end
    stringConversionFunction = @(x) num2str(x, 3);
    tableData = cellfun(stringConversionFunction, tableData, 'UniformOutput', false);
%     
%     }

%     textAnnotation = ...
%         {'Alpha Coefficient Equipartition (N/m-mW)', num2str(CalibrationData.EquipartitionStiffnessCoefficient(1), 3), num2str(CalibrationData.EquipartitionStiffnessCoefficient(1), 3); ...
%          'Alpha Coefficient Confidence Interval', num2str(CalibrationData.EquipartitionStiffnessCoefficientConfidenceInterval{1}), num2str(CalibrationData.EquipartitionStiffnessCoefficientConfidenceInterval{2});
    set(AxesHandles.ResultsTable, 'Data', tableData);
    set(AxesHandles.ResultsTable, 'ColumnName', {'', 'X', 'Y'});
    
    %text(0, 0, textAnnotation, 'Parent', AxesHandles.TextAxesHandle, 'FontSize', 12, 'VerticalAlignment', 'Bottom');
    
end
%         if(exist('xAxis'))
%             set(AxesHandles.AnovaAxesHandle, 'XTick', xAxis);
%             set(AxesHandles.AnovaAxesHandle, 'XTickLabel', CalibrationData.Anova{ii}.Statistics.grpnames{2});
%         end
%         end
%     end
%     
% 
%     
% 
