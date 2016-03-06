function varargout = OTKB(varargin)
% OTKB M-file for OTKB.fig
%      OTKB, by itself, creates a new OTKB or raises the existing
%      singleton*.
%
%      H = OTKB returns the handle to a new OTKB or the handle to
%      the existing singleton*.
%
%      OTKB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OTKB.M with the given input arguments.
%
%      OTKB('Property','Value',...) creates a new OTKB or raises the
%      existing singleton*.  Starting from the left, property value pairs
%      are
%      applied to the GUI before OTKB_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OTKB_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OTKB

% Last Modified by GUIDE v2.5 30-Mar-2012 11:47:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OTKB_OpeningFcn, ...
                   'gui_OutputFcn',  @OTKB_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before OTKB is made visible.
function OTKB_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn. 
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OTKB (see VARARGIN)
% initialization
    handles.output = hObject; % Choose default command line output for OTKB

    % read command line arguments and place values into handles structure
    p = inputParser;
    p.addParamValue('DebugMode', false, @(x) islogical(x));
    p.addParamValue('DisplayUpdateRate', 5, @(x) isscalar(x))
    p.addParamValue('PsdUpdateRate', 5, @(x) isscalar(x));
    p.addParamValue('XYVoltageRangePlotMargin', 1.2, @(x) isscalar(x));
    p.addParamValue('StageResponsivity', 2.22e-6, @(x) isscalar(x));
    p.addParamValue('MainFigureHeight', 700, @(x) isscalar(x));
    p.addParamValue('NoPiezos', false, @(x) islogical(x));
    p.addParamValue('PiezoDriverSerialNumbers', [81827174 81818241 81819823], @(x) 1);
    p.addParamValue('PiezoUpperLimit', [100 100 75], @(x) 1);
    p.addParamValue('PiezoLowerLimit', [0 0 0], @(x) 1);
    p.addParamValue('StrainGaugeReaderSerialNumbers', [84831728 84825070 0], @(x) 1);
    p.addParamValue('QpdReaderSerialNumber', 89825082, @(x) 1);
    p.addParamValue('PlotModeDefaults', [2 3 1 5], @(x) 1);
    p.addParamValue('PlotTitleFontSize', 13, @(x) 1);
    p.addParamValue('AxesLabelFontSize', 9, @(x) 1);
    p.addParamValue('LaserPowerDaqDeviceName', 'Dev2', @(x) isstring(x));
    p.addParamValue('LaserPowerDaqChannel', 1, @(x) 1);
    p.addParamValue('LaserPower', 100, @(x) isscalar(x));
    p.addParamValue('LaserEnable', true, @(x) islogical(x));
    p.parse(varargin{:});

    % transfer parameter values to handles data structure
    fieldName = fieldnames(p.Results);
    
    for ii=1:length(fieldName)
        handles.(fieldName{ii}) =  p.Results.(fieldName{ii});
    end
    
    Status(handles,  'OTKB_OpeningFcn called');
    Status(handles, p.Results);

    handles.QpdRunning = 0;

    % display configuration
    global PsdCount;
    PsdCount = 0;
    handles.XYVoltageRange = 0.05;
    
    handles.PlotTypes = {'Off', 'QPD X/Y', 'QPD vs time', 'Stage X/Y', 'Stage vs time', 'PSD', 'Alpha Calibration', 'R Calibration', 'Stokes', 'QPD X Pseudocolor', 'QPD Y Pseudocolor', 'QPD X Surface', 'QPD Y Surface', 'QPD X Responsivity', 'QPD Y Resonsivity', 'QPD vs Stage'};
    handles.PlotModePopupMenus = [handles.popupmenuPlot1 handles.popupmenuPlot2 handles.popupmenuPlot3 handles.popupmenuPlot4];
    handles.PlotModeDefaults = [2 3 1 5];
    
    for ii=1:length(handles.PlotModePopupMenus)
        set(handles.PlotModePopupMenus(ii), 'String', handles.PlotTypes);
        set(handles.PlotModePopupMenus(ii), 'Value', handles.PlotModeDefaults(ii));
    end

    % DAQ variables
    handles.DaqInput = struct();
    handles.DaqInput.ObjectHandle = 0;
    handles.DaqInput.ChannelNumbers = 0:3;
    handles.DaqInput.ChannelNames = {'X-axis QPD','Y-axis QPD','X-axis Piezo','Y-axis Piezo'};

    handles.DaqOutput = struct();
    handles.DaqOutput.ObjectHandle = 0;
    handles.DaqOutput.ChannelNumbers = 0:1;
    handles.DaqOutput.ChannelNames = {'X-axis Piezo Drive', 'Y-axis Piezo Drive'};
    handles.DaqDeviceName = 'Dev1';
    handles.DaqDeviceType = 'nidaq';
    
    handles.LaserPowerDaqObjectHandle = 0;

    % setup screen layout and
    % create figure for ThorLabs ActiveX controls
    set(0, 'Units', 'pixels');
    screenSize = get(0, 'ScreenSize');
    activeXFigureOuterPosition = [1 1 screenSize(3)/2 (screenSize(4) - handles.MainFigureHeight - 1)];
    handles.activeXControlFigure = figure('OuterPosition', activeXFigureOuterPosition, 'MenuBar', 'none', 'Name', 'Piezo Controls');
    handles.mainFigureOuterPosition = [1 (screenSize(4) - handles.MainFigureHeight) screenSize(3)/2 handles.MainFigureHeight];
    handles.xyScanFigure = 0;

    % piezo descriptors
    piezoAxisName = {'X' 'Y' 'Z'};
    piezoMode = {'position' 'position' 'voltage'};
    activeXControlRectangle = get(handles.activeXControlFigure, 'position');
    activeXControlUpperLeftCorner = [0 0];
    activeXControlSize = [(round(activeXControlRectangle(3)/3)) (activeXControlRectangle(4)/2)];

    piezoDriverDescriptorList = cell(1,length(piezoAxisName));

    for ii=1:length(piezoAxisName)
        piezoDriverDescriptorList{ii} = struct();
        piezoDriverDescriptorList{ii}.AxisName = piezoAxisName{ii};
        piezoDriverDescriptorList{ii}.PiezoDriverSerialNumber = handles.PiezoDriverSerialNumbers(ii);
        piezoDriverDescriptorList{ii}.Mode = piezoMode{ii};
        piezoDriverDescriptorList{ii}.PiezoUpperLimit = handles.PiezoUpperLimit(ii);
        piezoDriverDescriptorList{ii}.PiezoLowerLimit = handles.PiezoLowerLimit(ii);
        piezoDriverDescriptorList{ii}.StrainGaugeReaderSerialNumber = handles.StrainGaugeReaderSerialNumbers(ii);
        piezoDriverDescriptorList{ii}.PiezoDriverRectangle = ...
            [ (activeXControlUpperLeftCorner + [((ii - 1) * activeXControlSize(1)) activeXControlSize(2)]) activeXControlSize];
        piezoDriverDescriptorList{ii}.StrainGaugeReaderRectangle = ...
            [ (activeXControlUpperLeftCorner + [((ii - 1) * activeXControlSize(1))  0]) activeXControlSize];
    end

    handles.PiezoDriverDescriptorList = piezoDriverDescriptorList;

    % QPD descriptor
    handles.QpdDriverDescriptor = struct();
    handles.QpdDriverDescriptor.SerialNumber = handles.QpdReaderSerialNumber;
    handles.QpdDriverDescriptor.Rectangle =  [ (2 * activeXControlSize(1))  0 activeXControlSize];
    
    % initialize TimeData
    global TimeData
    TimeData = [];
    
    % initialize calibration results data structure
    handles.CalibrationData = {};
    handles.CurrentCalibration = [];
    handles.CalibrationFigure = NaN;
    handles.CalibrationAxes = struct();

    Status(handles, handles);
    Status(handles,  'OTKB_OpeningFcn complete.');
    % Update handles structure
    guidata(hObject, handles);

% post visibility initialization
function varargout = OTKB_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    Status(handles,  'OTKB_OutputFcn called.')
    set(handles.figureMain, 'OuterPosition', handles.mainFigureOuterPosition);

    figure(handles.figureMain);
    set(handles.uipanelPlots, 'Units', 'pixels')
    plotArea = get(handles.uipanelPlots, 'Position');
    plotOuterWidth = floor(plotArea(3) / 2);
    plotOuterHeight = floor(plotArea(4) / 2);
    plotLeftMargin = floor(0.2 * plotOuterWidth);
    plotBottomMargin = floor(0.15 * plotOuterHeight);
    plotWidth = floor(.75 * plotOuterWidth);
    plotHeight = floor(.75 * plotOuterHeight);

    handles.axes1 = axes('Units', 'pixels', 'ActivePositionProperty', 'outerposition');
    set(handles.axes1, 'OuterPosition', [(plotArea(1:2) + [        0 plotOuterHeight]) plotOuterWidth plotOuterHeight]);
    set(handles.axes1, 'Position', [(plotArea(1:2) + [plotLeftMargin, plotOuterHeight + plotBottomMargin]) plotWidth plotHeight]);
    handles.axes2 = axes('Units', 'pixels', 'ActivePositionProperty', 'outerposition');
    set(handles.axes2, 'OuterPosition', [(plotArea(1:2) + [plotOuterWidth plotOuterHeight]) plotOuterWidth plotOuterHeight]);
    set(handles.axes2, 'Position', [(plotArea(1:2) + [plotOuterWidth + plotLeftMargin, plotOuterHeight + plotBottomMargin]) plotWidth plotHeight]);
    handles.axes3 = axes('Units', 'pixels', 'ActivePositionProperty', 'outerposition');
    set(handles.axes3, 'OuterPosition', [(plotArea(1:2) + [        0          0]) plotOuterWidth plotOuterHeight]);
    set(handles.axes3, 'Position', [(plotArea(1:2) + [plotLeftMargin, plotBottomMargin]) plotWidth plotHeight]);
    handles.axes4 = axes('Units', 'pixels', 'ActivePositionProperty', 'outerposition');
    set(handles.axes4, 'OuterPosition', [(plotArea(1:2) + [plotOuterWidth          0]) plotOuterWidth plotOuterHeight]);
    set(handles.axes4, 'Position', [(plotArea(1:2) + [plotOuterWidth + plotLeftMargin, plotBottomMargin]) plotWidth plotHeight]);
    handles.PlotAxesHandles = [handles.axes1 handles.axes2 handles.axes3 handles.axes4];

    
    % initialize daq and zero outputs
    Status(handles,  'OTKB_OutputFcn: Zeroing daq outputs.');
    daqreset
    handles.DaqOutput.ObjectHandle = InitializeDaqOutput( handles, 1000,'Immediate',inf);
    ZeroDaqOutput(handles);
    stop(handles.DaqOutput.ObjectHandle);

    Status(handles,  'OTKB_OutputFcn: Initializing ActiveX controls.');
    if(handles.NoPiezos)
        handles.PiezoDriverDescriptorList = {};
        handles.QpdDriverDescriptor = {};
    else
        handles.PiezoDriverDescriptorList = InitializePiezoDrivers(handles.PiezoDriverDescriptorList, handles.activeXControlFigure); 
        handles.QpdDriverDescriptor = InitializeQpdDriver(handles.QpdDriverDescriptor, handles.activeXControlFigure);
    end
    
    % initialize laser control daq channel, if present
    if(~isempty(handles.LaserPowerDaqDeviceName'))
        set(handles.editLaserPower, 'String', num2str(handles.LaserPower, '%1f'));
        set(handles.editLaserPower, 'Enable', 'on');
        handles.LaserPowerDaqObjectHandle = SetLaserPower(handles, handles.LaserPower);
    end

    % Update handles structure
    Status(handles,  'OTKB_OutputFcn: ActiveX initialized.');
    varargout{1} = handles.output;
    
    % Start daq output and callback
    handles = StartAcquisition(handles);
    Status(handles,  'OTKB_OutputFcn: QPD monitor started.');

    Status(handles,  '-OTKB_OutputFcn complete.');
    guidata(hObject, handles);

% --- Executes on button press in pushbuttonClose.
function handles = CloseApplication(handles)
    Status(handles,  '+pushbuttonClose_Callback called.')
    % Stop the qpd monitor
    handles = StopAcquisition(handles);
    %Daqreset

    Status(handles,  'Closing ActiveX controls.');
    % close all the piezo controllers
    for ii=1:length(handles.PiezoDriverDescriptorList)
        if(isfield(handles.PiezoDriverDescriptorList{ii}, 'DriverActiveXControl'))
            if(handles.PiezoDriverDescriptorList{ii}.DriverActiveXControl ~= 0)
                invoke(handles.PiezoDriverDescriptorList{ii}.DriverActiveXControl, 'StopCtrl');
            end
            handles.PiezoDriverDescriptorList{ii}.DriverActiveXControl = 0;
        end
        if(isfield(handles.PiezoDriverDescriptorList{ii}, 'ReaderActiveXControl'))
            if(handles.PiezoDriverDescriptorList{ii}.ReaderActiveXControl ~= 0)
                invoke(handles.PiezoDriverDescriptorList{ii}.ReaderActiveXControl, 'StopCtrl');
            end
            handles.PiezoDriverDescriptorList{ii}.ReaderActiveXControl = 0;
        end
    end

    % close the QPD
    if(isfield(handles.QpdDriverDescriptor, 'ActiveXControl') ~= 0)
        if(handles.QpdDriverDescriptor.ActiveXControl ~= 0)
            invoke(handles.QpdDriverDescriptor.ActiveXControl, 'StopCtrl');
        end
    end

    Status(handles,  'ActiveX controls closed.');
    Status(handles,  '-pushbuttonClose_Callback complete.')

% --- Executes on button press in pushbuttonCenterAll.
function pushbuttonCenterAll_Callback(hObject, eventdata, handles)
    Status(handles,  '+pushbuttonCenterAll_Callback called.')
    % set piezo drivers in the middle
    for ii = 1:length(handles.PiezoDriverDescriptorList)
        Status(handles,  ['pushbuttonCenterAll_Callback: Piezo driver ' num2str(ii) ' centered.']);
        if(handles.PiezoDriverDescriptorList{ii}.DriverActiveXControl ~= 0)
            newPosition = ...
                (handles.PiezoDriverDescriptorList{ii}.PiezoUpperLimit + ...
                handles.PiezoDriverDescriptorList{ii}.PiezoLowerLimit) / 2;
            if( strcmp(handles.PiezoDriverDescriptorList{ii}.Mode, 'position') )
                invoke(handles.PiezoDriverDescriptorList{ii}.DriverActiveXControl, 'SetPosOutput', 0, newPosition);
            end
            if( strcmp(handles.PiezoDriverDescriptorList{ii}.Mode, 'voltage') )
                invoke(handles.PiezoDriverDescriptorList{ii}.DriverActiveXControl, 'SetVoltOutput', 0, newPosition);
            end
        end
    end
    Status(handles,  '+pushbuttonCenterAll_Callback complete.')

    guidata(hObject, handles);
    Status(handles,  'Piezos centered');

%
% QPD monitor functions
%

function handles = HandleSettingsChanged(handles)
    Status(handles,  '+HandleSettingsChanged called.');
    handles = StopAcquisition(handles);
    handles = StartAcquisition(handles);
    Status(handles,  '-HandleSettingsChanged complete.');

% StartQpdMonitor
function handles = StartAcquisition(handles)
    Status(handles,  '+StartQpdMonitor called.');
    global TimeData;
    
    if(handles.QpdRunning == 0)
        handles.QpdRunning = 1;
        uiSettings = GetUiSettings(handles);
        Status(handles, uiSettings);
        ClearAxes(handles);
        TimeData = [];
        
        % default values
        waveform = [0 0];
        inputSampleRate = uiSettings.sampleRate;
        outputSampleRate = uiSettings.sampleRate;
        handles.SamplesToSave = uiSettings.numberOfSeconds * uiSettings.sampleRate;
        
        switch(uiSettings.stageMovementMode)
            case 'Off'
        
            case {'X','Y'}
                numberOfSamples = round(uiSettings.sampleRate / uiSettings.stageOscillationFrequency);
                singleCycle = SineWaveSingleCycle(uiSettings.stageOscillationAmplitude, numberOfSamples)';
                if uiSettings.stageMovementMode == 'X'
                    waveform = [singleCycle zeros(numberOfSamples, 1)];
                else
                    waveform = [zeros(numberOfSamples, 1) singleCycle];
                end

            case 'X/Y Scan'
                fastAxisSamplesPerLine = round(0.8 * outputSampleRate / uiSettings.stageOscillationFrequency);

                waveform = RasterScanWaveform( ...
                    'FastAxisSamplesPerLine', fastAxisSamplesPerLine, ...
                    'NumberOfLines', uiSettings.numberOfLines, ...
                    'Overscan', 0.1, ...
                    'Amplitude', uiSettings.stageOscillationAmplitude);                        

            case 'Hypocycloid'
                totalSamples = uiSettings.numberOfLines * uiSettings.stageOscillationFrequency * uiSettings.sampleRate;

                waveform = HypocycloidScanWaveform( ...
                'Diameter', uiSettings.stageOscillationAmplitude, ...
                'P', uiSettings.numberOfLines, ...
                'Q', ceil(uiSettings.numberOfLines / 2) - 1, ...
                'NumberOfSamples', totalSamples);
            
            case 'DNA Tether'
                CenterSample(handles, uiSettings);
        end
        
        samplesPerTrigger = inputSampleRate / handles.DisplayUpdateRate;
        Status(handles, 'StartQpdMonitor: Starting daq input.');
        handles.DaqInput.ObjectHandle = InitializeDaqInput(handles, inputSampleRate, 'Immediate', samplesPerTrigger);
        set(handles.DaqInput.ObjectHandle, 'TriggerRepeat', inf);
        set(handles.DaqInput.ObjectHandle, 'TriggerFcn', {@DaqCallback, handles.figureMain});

        %TimeData = zeros(uiSettings.numberOfSeconds * uiSettings.sampleRate, 4);

        try
            start(handles.DaqInput.ObjectHandle)
        catch Exception
            disp('*** StartQpdMonitor: Exception starting daq input ***');
            disp(Exception);
            disp(handles.DaqInput.ObjectHandle);
        end

        Status(handles, 'StartQpdMonitor: Starting daq output.');
        handles.DaqOutput.ObjectHandle = InitializeDaqOutput( handles, outputSampleRate, 'Immediate', inf);
        putdata(handles.DaqOutput.ObjectHandle, waveform);
        try
            start(handles.DaqOutput.ObjectHandle);
        catch Exception
            disp('*** StartQpdMonitor: Exception starting daq output ***');
            disp(Exception);
            disp(handles.DaqOutput.ObjectHandle);
        end
       
    else
        Status(handles, 'StartQpdMonitor: start called with QPD running -- not started');
    end
    
    guidata(handles.figureMain, handles);
    Status(handles,  '-StartQpdMonitor complete.');

% StopQpdMonitor
function handles = StopAcquisition(handles)
    Status(handles,  '+StopQpdMonitor called.');
    if(handles.DaqInput.ObjectHandle ~= 0)
        if(isvalid(handles.DaqInput.ObjectHandle))
            if(isrunning(handles.DaqInput.ObjectHandle))
                try
                    stop(handles.DaqInput.ObjectHandle);
                catch Exception
                    disp('*** StopQpdMonitor: Exception stopping daq input ***');
                    disp(Exception);
                    disp(handles.DaqInput.ObjectHandle);
                end
                try
                    stop(handles.DaqOutput.ObjectHandle);
                    handles.DaqOutput.ObjectHandle = InitializeDaqOutput( handles, 1000,'Immediate',inf);
                    putsample(handles.DaqOutput.ObjectHandle, [0, 0]); 
                    stop(handles.DaqOutput.ObjectHandle);
                catch Exception
                    disp('*** StopQpdMonitor: Exception stopping daq output ***');
                    disp(Exception);
                    disp(handles.DaqOutput.ObjectHandle);
                end
                try
                    wait(handles.DaqInput.ObjectHandle, 1);
                catch Exception
                    handles.DaqInput.ObjectHandle = 0;
                end
            end
        else
            Status(handles,  'StopQpdMonitor: not stopped. Called while not running.');
        end
    end
    handles.QpdRunning = 0;
    drawnow
    Status(handles,  '-StopQpdMonitor complete.');

%
% daq callback function
%
function DaqCallback(hObject, eventdata, figureMain)
    global TimeData;
    global PsdCount;
    handles = guidata(figureMain);
    UiSettings = GetUiSettings(handles);
    samplesPerUpdate = round(UiSettings.sampleRate / handles.DisplayUpdateRate);

    % skip UI update if there is a backlog of samples
    skipUpdate = false; %handles.DaqInput.ObjectHandle.SamplesAvailable > 2 * samplesPerUpdate;
    
    % get most recent samples and concatenate them to global TimeData
    while(handles.DaqInput.ObjectHandle.SamplesAvailable > samplesPerUpdate)
        % uncomment this for performance debugging: 
        % Status(handles,  [num2str(handles.DaqInput.ObjectHandle.SamplesAvailable) ' samples available']);
        data = getdata(handles.DaqInput.ObjectHandle, samplesPerUpdate);
        if(length(data) >= handles.SamplesToSave)
            TimeData = data((end-handles.SamplesToSave+1):end,:);
        else
            samplesToDrop = max(1, length(TimeData) - UiSettings.numberOfSeconds * UiSettings.sampleRate + length(data) + 1);
            TimeData = vertcat( TimeData(samplesToDrop:end,:), data);
        end
    end
    
    % update laser power output
    if(and( ...
        or(UiSettings.LaserPower ~= handles.LaserPower, UiSettings.LaserEnable ~= handles.LaserEnable), ...
        ~isempty(handles.LaserPowerDaqDeviceName)))
        if(UiSettings.LaserEnable)
            power = UiSettings.LaserPower;
        else
            power = 0;
        end
        handles.LaserPowerDaqObjectHandle =  SetLaserPower(handles, power);
        handles.LaserPower = UiSettings.LaserPower;
        handles.LaserEnable = UiSettings.LaserEnable;
    end
    
    % update calibration, if selected in UI
    if(UiSettings.UpdateCalibration)
        handles.CurrentCalibration = ProcessOpticalTrapCalibrationDataset(handles.CalibrationData);
        set(handles.checkboxUpdateCalibration, 'Value', false);
        set(handles.editQpdXResponsivityCoefficient, 'String', num2str(handles.CurrentCalibration.QpdPsdResponsivityCoefficient{1}(1) / 1e6, 4));
        set(handles.editQpdYResponsivityCoefficient, 'String', num2str(handles.CurrentCalibration.QpdPsdResponsivityCoefficient{2}(1) / 1e6, 4));
        
        if(~ishandle(handles.CalibrationFigure))
            handles.CalibrationFigure = figure();
            handles.CalibrationAxes = struct();
            handles.CalibrationAxes.AlphaAxesHandle = axes('Parent', handles.CalibrationFigure, 'OuterPosition', [0 .5 .5 .5]);
            handles.CalibrationAxes.ResponsivityAxesHandle = axes('Parent', handles.CalibrationFigure, 'OuterPosition', [.5 .5 .5 .5]);
            handles.CalibrationAxes.AnovaAxesHandle = axes('Parent', handles.CalibrationFigure, 'OuterPosition', [.5 0 .5 .5]);
            handles.CalibrationAxes.TextPanel = uipanel('Parent', handles.CalibrationFigure, 'Position', [0 0 .5 .5]);
            handles.CalibrationAxes.ResultsTable = uitable(handles.CalibrationAxes.TextPanel, 'FontSize', 14);
            set(handles.CalibrationAxes.ResultsTable, 'Units', 'normalized', 'Position', [0 0 1 1]);
            set(handles.CalibrationAxes.ResultsTable, 'ColumnWidth', {450, 235, 235});
        end
        
        PlotOpticalTrapCalibration(handles.CalibrationAxes, handles.CurrentCalibration);
    end
    
    % reset calibration data, if selected in UI
    if(UiSettings.ResetCalibration)
        handles.CalibrationData = {};
        handles.CurrentCalibration = [];
        set(handles.checkboxResetCalibration, 'Value', false);
    end
    
    % update plots
    if(and(~skipUpdate, ~isempty(TimeData)))
        skip = max(1,floor(length(TimeData) / UiSettings.numberOfSeconds / UiSettings.stageOscillationFrequency / 60));
        decimatedData = TimeData(1:skip:end,:);
        voltageRange = 1.1 * max([abs(decimatedData(:,1));abs(decimatedData(:,2))]);
        
        for ii=1:length(handles.PlotModePopupMenus)
            plotMode = handles.PlotTypes{get(handles.PlotModePopupMenus(ii), 'Value')};
            axesHandle = handles.PlotAxesHandles(ii);
            timeAxis = (1:skip:length(TimeData))/UiSettings.sampleRate;

            switch(plotMode)

                case 'QPD X/Y'

                    plot(axesHandle, decimatedData(:,1), decimatedData(:,2), 'x', 'Color', [0 1 1]);
                    hold(axesHandle, 'on');
                    recentDataStartIndex = length(decimatedData) - 60;
                    recentDataStartIndex = max(1, recentDataStartIndex);
                    plot(axesHandle, decimatedData(recentDataStartIndex:end,1), decimatedData(recentDataStartIndex:end,2), 'LineWidth', 1 ,'Marker', 'x', 'Color', [0 .75 0]);
                    plot(axesHandle, decimatedData((end-10):end,1), decimatedData((end-10):end,2), 'LineWidth', 2, 'Color', [1 0 1]);
                    plot(axesHandle, mean(decimatedData(:,1)), mean(decimatedData(:,2)), 'kx', 'MarkerSize', 10, 'LineWidth', 2);

                    hold(axesHandle, 'off');
                    grid(axesHandle,'on')
                    axis(axesHandle, [-voltageRange voltageRange -voltageRange voltageRange]);
                    set(axesHandle, 'FontSize', 9);
                    xlabel(axesHandle, 'X Voltage');
                    ylabel(axesHandle, 'Y Voltage');
                    title(axesHandle, 'QPD X/Y Voltage', 'FontSize', handles.PlotTitleFontSize);

                case 'QPD vs time'

                    plot(axesHandle, timeAxis, -decimatedData(:,1), 'LineWidth', 2);
                    hold(axesHandle, 'on');
                    plot(axesHandle, timeAxis, -decimatedData(:,2), 'r', 'LineWidth', 2);
                    set(axesHandle, 'FontSize', 9);
                    axis(axesHandle, [timeAxis(1) timeAxis(end) -voltageRange voltageRange]);
                    title(axesHandle, 'QPD X and Y signals', 'FontSize', handles.PlotTitleFontSize);
                    xlabel(axesHandle, 'Time (sec)');
                    ylabel(axesHandle, 'Volts');
                    legend(axesHandle, 'X', 'Y');
                    hold(axesHandle, 'off');

                case 'Stage X/Y'

                    plot(axesHandle, decimatedData(:,3), decimatedData(:,4), 'x', 'Color',[0 1 1]);
                    hold(axesHandle, 'on');
                    recentDataStartIndex = length(decimatedData) - 60;
                    recentDataStartIndex = max(1, recentDataStartIndex);
                    plot(axesHandle, decimatedData(recentDataStartIndex:end,3), decimatedData(recentDataStartIndex:end,4), 'LineWidth', 1, 'Marker', 'x', 'Color', [0 .6 0]);
                    plot(axesHandle, decimatedData((end-10):end,3), decimatedData((end-10):end,4), 'LineWidth', 2, 'Color', [1 0 1]);
                    
                    stageRange = [min(decimatedData(:,3)),   max(decimatedData(:,3)),  min(decimatedData(:,4)),  max(decimatedData(:,4))];
                    scale = max(range(decimatedData(:,3)), range(decimatedData(:,4))); 
                    stageRange = (1 + scale .* 0.05 .* [-1 1 -1 1] .* sign(stageRange)) .* stageRange;

                    hold(axesHandle, 'off');
                    grid(axesHandle,'on')
                    axis(axesHandle, stageRange);
                    set(axesHandle, 'FontSize', 9);
                    xlabel(axesHandle, 'X Voltage');
                    ylabel(axesHandle, 'Y Voltage');
                    title(axesHandle, 'Stage X/Y Position', 'FontSize', handles.PlotTitleFontSize);

                case 'Stage vs time'
                    
                    plot(axesHandle, timeAxis, decimatedData(:,3), 'LineWidth', 2);
                    hold(axesHandle, 'on');
                    plot(axesHandle, timeAxis, decimatedData(:,4), 'r', 'LineWidth', 2);
                    set(axesHandle, 'FontSize', 9);
                    title(axesHandle, 'Stage Position', 'FontSize', handles.PlotTitleFontSize);
                    xlabel(axesHandle, 'Time (sec)');
                    ylabel(axesHandle, 'Volts');
                    legend(axesHandle, 'X', 'Y');
                    hold(axesHandle, 'off');

                case 'PSD'
                    if(length(TimeData) > 256)
                        PsdCount = PsdCount + 1;
                        if(mod(PsdCount, handles.PsdUpdateRate) == 0)
                            Parameters = struct();
                            Parameters.SampleRate = UiSettings.sampleRate;
                            Parameters.Temperature = 295;
                            Parameters.Viscosity = UiSettings.SolventViscosity * 1e-3;
                            Parameters.Diameter = UiSettings.ParticleDiameter * 1e-6;
                            Parameters.Power = handles.LaserPower;

%                            try
                                results = CalibrateOpticalTrapByPsdMethod(TimeData, Parameters);
                                PlotPsdCalibration(axesHandle, results);
                                title(axesHandle, 'Power Spectral Density', 'FontSize', handles.PlotTitleFontSize);
                                % plot results
%                            catch Exception
%                                Status(handles, 'DaqCallback: CalibrateOpticalTrapByPsdMethod threw an exception');
%                            end
                            
                            if(UiSettings.SaveCalibration == true)
                                handles.CalibrationData{end+1} = results;
                                set(handles.checkboxSaveCalibration, 'Value', false);
                            end
                        end
                    end
                    
                case 'Stokes'
                    if(length(TimeData) > 100)
                        Parameters = struct();
                        Parameters.SampleRate = UiSettings.sampleRate;
                        Parameters.Temperature = 295;
                        Parameters.Viscosity = UiSettings.SolventViscosity * 1e-3;
                        Parameters.Diameter = UiSettings.ParticleDiameter * 1e-6;
                        Parameters.QpdResponsivity = UiSettings.QpdResponsivityCoefficients .* handles.LaserPower * 1e6;
                        Parameters.StageResponsivity = handles.StageResponsivity;
                        Parameters.Power = handles.LaserPower;
%                        try
                            results = CalibrateOpticalTrapByStokesMethod(TimeData, Parameters);
                            PlotStokesCalibration( axesHandle,  results);
                            title(axesHandle, 'Displacement vs. Force', 'FontSize', handles.PlotTitleFontSize);
%                        catch Exception
%                            Status(handles, 'DaqCallback: CalibrateOpticalTrapByPsdMethod threw an exception');
%                        end
                        if(UiSettings.SaveCalibration == true)
                            handles.CalibrationData{end+1} = results;
                            set(handles.checkboxSaveCalibration, 'Value', false);
                        end
                    end
                    
                    case 'Alpha Calibration'
                        if(~isempty(handles.CurrentCalibration))
                            PlotOpticalTrapCalibration(axesHandle, handles.CurrentCalibration);
                        end
                        
                    case 'R Calibration'
                        if(false)
                        end

                    case {'QPD X Pseudocolor', 'QPD Y Pseudocolor', 'QPD X Surface', 'QPD Y Surface', 'QPD X Responsivity', 'QPD Y Respnosivity'}
                        fastAxisSamplesPerLine = round(0.8 * UiSettings.sampleRate / UiSettings.stageOscillationFrequency);
                        if(length(TimeData) > (4 * fastAxisSamplesPerLine)) % only plot if at least four lines of data acquired
                            % decimate data for plotting so there are about 200 samples per line
                            decimationRatio = round (fastAxisSamplesPerLine / 200);
                            if(decimationRatio > 1)
                                xyScanData = [ ...
                                    decimate(TimeData(:,1), decimationRatio), ...
                                    decimate(TimeData(:,2), decimationRatio), ...
                                    decimate(TimeData(:,3), decimationRatio), ...
                                    decimate(TimeData(:,4), decimationRatio)  ...
                                    ];
                            else
                                xyScanData = TimeData;
                            end

                            % convert stage voltage to microns and center around zero
                            stageResponsivityMultiplier = floor(log10(handles.StageResponsivity));
                            xyScanData(:,3) = (xyScanData(:,3) ) * handles.StageResponsivity / 10^stageResponsivityMultiplier;
                            xyScanData(:,4) = (xyScanData(:,4) ) * handles.StageResponsivity / 10^stageResponsivityMultiplier;

                            if(plotMode(5) =='X')
                                columnNumber = 1;
                            else
                                columnNumber = 2;
                            end
                            
                            switch(plotMode(7))
                                case 'P'
                                    plotType = 'Pseudocolor';
                                case 'S'
                                    plotType = 'Surface';
                                case 'R'
                                    plotType = 'Responsivity';
                            end
                            
                            results = PlotNonuiformSampledSurface(xyScanData, 'ZColumn', columnNumber, 'PlotType', plotType, 'AxisHandle', axesHandle);
                            results.Power = handles.LaserPower;
                            
                            switch(plotMode(7))
                                case 'S'
                                    AddTitleAndAxisLabelsToPlot( ...
                                        handles, axesHandle, ...
                                        ['QPD ' plotMode(5) ' Voltage vs Stage Position'], [], []); 
                                
                                case 'P'
                                    AddTitleAndAxisLabelsToPlot( ...
                                        handles, axesHandle, ...
                                        ['QPD ' plotMode(5) ' Voltage vs Stage Position'], ...
                                         ['X Position (m * 1e' num2str(stageResponsivityMultiplier, '%1.0f') ')'], ...
                                         ['Y Position (m * 1e' num2str(stageResponsivityMultiplier, '%1.0f') ')']);
                                    textAnnotation = ['R: ' num2str(results.Responsivity, '%1.2f') 'e' num2str(-stageResponsivityMultiplier,1) ' V/m'];

                                    textPositionX = 0.95 * results.PlotRange(1);
                                    textPositionY = 0.95 * results.PlotRange(3);
                                    text(textPositionX, textPositionY, textAnnotation, 'Parent', axesHandle, 'FontSize', 9);

                                
                                case 'R'
                                    AddTitleAndAxisLabelsToPlot( ...
                                        handles, axesHandle, ...
                                        [plotMode(5) ' Responsivity: ' num2str(results.Responsivity, '%1.2f') 'e' num2str(-stageResponsivityMultiplier,1) ' V/m'], ...
                                        ['Stage Position  (m * 1e' num2str(stageResponsivityMultiplier, '%1.0f') ')'], ...
                                        'QPD Voltage (V)');
                            end
                        end

                    case 'QPD vs Stage'
                        samplesPerLine = round(UiSettings.sampleRate / UiSettings.stageOscillationFrequency);
                        if(length(TimeData) > samplesPerLine) % only plot if at least one line of data acquired
                            xRange = range(TimeData(:,3));
                            yRange = range(TimeData(:,4));
                            
                            if(xRange > yRange)
                                xColumn = 3;
                            else
                                xColumn = 4;
                            end
                            
                            [quantizedXAxis xBinnedData xStandardDeviation xCount] = BinData( ...
                                TimeData, 'XColumn', xColumn, 'YColumn', 1);
                            [quantizedXAxis yBinnedData yStandardDeviation yCount] = BinData( ...
                                TimeData, 'XColumn', xColumn, 'YColumn', 2);
                            
                            plot(axesHandle, quantizedXAxis, xBinnedData, 'LineWidth', 2);
                            hold(axesHandle, 'on')
                            plot(axesHandle, quantizedXAxis, yBinnedData, 'r', 'LineWidth', 2);

%                            errorbar(axesHandle, quantizedXAxis, BinnedData, StandardDeviation ./ sqrt(Count), plotColor);
                            title(axesHandle, plotMode);
                            xlabel(axesHandle, 'Stage Position (V)');
                            ylabel(axesHandle, 'QPD (V)');
                            legend(axesHandle, 'X', 'Y');
                            hold(axesHandle, 'off')
                        end
            end
        end
    end
    guidata(handles.figureMain, handles);
    drawnow;


%
% DAQ functions
%
function Samples = SineWaveSingleCycle(Amplitude, NumberOfSamples)
    t = (0:(NumberOfSamples - 1)) * 2 * pi / NumberOfSamples;
    Samples = Amplitude * sin(t);

% initialize DAQ output channels
function DaqOutputDeviceHandle = InitializeDaqOutput(handles, SampleRate, TriggerType, RepeatOutput)
    Status(handles,  '+InitializeDaqOutput called.');
    if(~isobject(handles.DaqOutput.ObjectHandle))
        Status(handles,  'InitializeDaqOutput: creating output device.');
        DaqOutputDeviceHandle = analogoutput(handles.DaqDeviceType, handles.DaqDeviceName);
        addchannel(DaqOutputDeviceHandle, handles.DaqOutput.ChannelNumbers, handles.DaqOutput.ChannelNames);
    else
        DaqOutputDeviceHandle = handles.DaqOutput.ObjectHandle;
    end
    Status(handles,  ['InitializeDaqOutput: setting Sample rate' num2str(SampleRate) '  TriggerType' num2str(TriggerType) ' RepeatOutput ' num2str(RepeatOutput)]);
    set(DaqOutputDeviceHandle, 'SampleRate', SampleRate);
    set(DaqOutputDeviceHandle, 'TriggerType', TriggerType);
    set(DaqOutputDeviceHandle, 'RepeatOutput', RepeatOutput);
    Status(handles,  '-InitializeDaqOutput complete.');

% initialize DAQ input channels
function DaqInputObjectHandle = InitializeDaqInput(handles, sampleRate,triggerType,samplesPerTrigger)
    Status(handles,  '+InitializeDaqInput called.');
    
    % lazy initialization of daq analonginput channels
    if(handles.DaqInput.ObjectHandle == 0)
        DaqInputObjectHandle = analoginput(handles.DaqDeviceType, handles.DaqDeviceName);
        addchannel(DaqInputObjectHandle, handles.DaqInput.ChannelNumbers, handles.DaqInput.ChannelNames);
    else
        DaqInputObjectHandle = handles.DaqInput.ObjectHandle;
    end
    set(DaqInputObjectHandle, 'SampleRate', sampleRate);
    set(DaqInputObjectHandle, 'SamplesPerTrigger', samplesPerTrigger);
    set(DaqInputObjectHandle,'TriggerType',triggerType);
    Status(handles,  '-InitializeDaqInput complete.');

function ZeroDaqOutput(handles)
    Status(handles, '+ZeroDaqOutput called.');
    if(handles.DaqInput.ObjectHandle ~= 0)
        if(isvalid(handles.DaqInput.ObjectHandle))
            if(isrunning(handles.DaqInput.ObjectHandle))
                Status(handles, 'Zeroing DAQ otuput');
                putsample(handles.DaqOutput.ObjectHandle, [0 0]);
            end
        end
    end
    Status(handles, '+ZeroDaqOutput complete.');

function LaserOutputDaqDeviceHandle = SetLaserPower(handles, Power)
    Status(handles,  '+SetLaserPower called.');
    
    % lazy initialization of laser power analog output
    if(~isobject(handles.LaserPowerDaqObjectHandle))
        Status(handles,  'SetLaserPower: creating output device.');
        LaserOutputDaqDeviceHandle = analogoutput(handles.DaqDeviceType, handles.LaserPowerDaqDeviceName);
        addchannel(LaserOutputDaqDeviceHandle, handles.LaserPowerDaqChannel, 'Laser Power');
    else
        LaserOutputDaqDeviceHandle = handles.LaserPowerDaqObjectHandle;
    end
    
    % compute modulation voltage
    if(Power == 0)
        modulationVoltage = -10;
    else
        percentModulation = (Power + 80.2485) / 183.18;
        percentModulation = max(0, min(100, percentModulation));
        modulationVoltage = 20 * percentModulation - 10;
    end
    
    % set the laser modulation daq output to the computed value
    putsample(LaserOutputDaqDeviceHandle, modulationVoltage);
    Status(handles,  ['SetLaserPower: laser control voltage set to ' num2str(modulationVoltage)]);
    Status(handles,  '-SetLaserPower complete.');
    

%
% UI  functions
%
function SettingChanged_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxPositionMonitorStageOscillationEnable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    Status(handles,  '+SettingChanged_Callback: called.');
    HandleSettingsChanged(handles);
    Status(handles,  '+SettingChanged_Callback: complete.');

% --- Executes on button press in pushbuttonSavePositionData.
function pushbuttonSavePositionData_Callback(hObject, eventdata, handles)
    SaveData(handles)

% returns a structure with the current values of UI settings
function UiSettings = GetUiSettings(handles)
    UiSettings = struct();
    UiSettings.sampleRate = str2double(get(handles.editMonitorSampleRate, 'String'));
    UiSettings.stageOscillationAmplitude = str2double(get(handles.editStageOscillationApmplitude, 'String'));
    UiSettings.stageOscillationFrequency = str2double(get(handles.editStageOscillationFrequency, 'String'));
    temp = get(handles.popupmenuStageMovementMode, 'String');
    UiSettings.stageMovementMode = temp{get(handles.popupmenuStageMovementMode, 'Value')};
    temp = get(handles.popupmenuPlot1, 'String');
    UiSettings.plotMode =  {temp{get(handles.popupmenuPlot1, 'Value')}, temp{get(handles.popupmenuPlot2, 'Value')}, temp{get(handles.popupmenuPlot3, 'Value')}, temp{get(handles.popupmenuPlot4, 'Value')}};
    UiSettings.numberOfSeconds = str2double(get(handles.editPositionMonitorNumberOfSeconds, 'String'));
    UiSettings.numberOfLines = str2double(get(handles.editCalibrationNumberOfLines, 'String'));
    UiSettings.ParticleDiameter =  str2double(get(handles.editParticleDiameter, 'String'));
    UiSettings.SolventViscosity =  str2double(get(handles.editSolventViscosity, 'String'));
    UiSettings.LaserPower =  str2double(get(handles.editLaserPower, 'String'));
    UiSettings.LaserEnable = get(handles.checkboxLaserEnable, 'Value');
    UiSettings.QpdResponsivityCoefficients =  ...
        [str2double(get(handles.editQpdXResponsivityCoefficient, 'String')), str2double(get(handles.editQpdYResponsivityCoefficient, 'String'))];
    UiSettings.SaveCalibration = get(handles.checkboxSaveCalibration, 'Value');
    UiSettings.UpdateCalibration = get(handles.checkboxUpdateCalibration, 'Value');
    UiSettings.ResetCalibration = get(handles.checkboxResetCalibration, 'Value');

% display status text
function Status(handles, StatusString)
    if(handles.DebugMode)
        disp(StatusString);
    end

function ClearAxes(handles)
    cla(handles.axes1, 'reset')
    cla(handles.axes2, 'reset')
    cla(handles.axes3, 'reset')
    cla(handles.axes4, 'reset')

% save captured data and settings
function SaveData(handles)
    global TimeData;
    dataToSave = TimeData;
    drawnow
    uiSettings = GetUiSettings(handles); 
    
    [filename, pathname] = uiputfile('*.txt','Save XY Scan Data');
    dataFilename = strcat(pathname, filename);
    settingsFilename = strcat(pathname, [filename(1:(end-4)) ' Settings' filename((end-3):end)]);
    if ~isequal(filename,0) && ~isequal(pathname,0)
        dlmwrite(dataFilename, dataToSave, 'delimiter', '\t', 'precision', 6);
        fileId = fopen(settingsFilename, 'w');
        fprintf(fileId, ...
            'Sample Rate: %f\r\nLaser Power: %f\r\nLaser Enable: %1.0f\r\nParticle Diameter: %f\r\nViscosity: %f\r\n', ...
            uiSettings.sampleRate, ...
            uiSettings.LaserPower , ...
            uiSettings.LaserEnable , ...
            uiSettings.ParticleDiameter, ...
            uiSettings.SolventViscosity);
        fclose(fileId);
    end
    
% add title and axis labels to plot
function AddTitleAndAxisLabelsToPlot(handles, AxesHandle, TitleString, XAxisLabelString, YAxisLabelString)
    if(~isempty(XAxisLabelString))
        xlabel(AxesHandle, XAxisLabelString, 'FontSize', handles.AxesLabelFontSize);
    end
    if(~isempty(YAxisLabelString))
        ylabel(AxesHandle, YAxisLabelString, 'FontSize', handles.AxesLabelFontSize);
    end
    if(~isempty(TitleString))
        title(AxesHandle, TitleString, 'FontSize', handles.PlotTitleFontSize);
    end

%
% creation and resize functions
%

% --- Executes during object creation, after setting all properties.
function Generic_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStageOscillationFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function figureMain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figureMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when figureMain is resized.
function figureMain_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figureMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figureMain.
function figureMain_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figureMain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
    pushbuttonClose_Callback(hObject, eventdata, handles)
    try
        close(handles.activeXControlFigure)
    catch Exception

    end
    handles.activeXControlFigure = 0;
    delete(hObject);
    
function pushbuttonClose_Callback(hObject, eventdata, handles)
    handles = CloseApplication(handles);
    guidata(hObject, handles);
