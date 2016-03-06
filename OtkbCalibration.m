function varargout = OtkbCalibration(varargin)
% OtkbCalibration M-file for OtkbCalibration.fig
%      OtkbCalibration, by itself, creates a new OtkbCalibration or raises the existing
%      singleton*.
%
%      H = OtkbCalibration returns the handle to a new OtkbCalibration or
%      the handle to
%      the existing singleton*.
%
%      OtkbCalibration('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OtkbCalibration.M with the given input arguments.
%
%      OtkbCalibration('Property','Value',...) creates a new OtkbCalibration or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OtkbCalibration_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OtkbCalibration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OtkbCalibration

% Last Modified by GUIDE v2.5 24-Jan-2011 13:13:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OtkbCalibration_OpeningFcn, ...
                   'gui_OutputFcn',  @OtkbCalibration_OutputFcn, ...
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

% --- Executes just before OtkbCalibration is made visible.
function OtkbCalibration_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OtkbCalibration (see VARARGIN)

piezoAxisName = {'X' 'Y' 'Z'};
piezoDriverSerialNumber = [81817001 81818241 84825070];
piezoMode = {'position' 'position' 'voltage'};
piezoUpperLimit = [100 100 75];
piezoLowerLimit = [0 0 0];
strainGaugeReaderSerialNumber = [84825069 84825070 0];
activeXControlUpperLeftCorner = [950 134];
activeXControlSize = [100 66];

piezoDriverDescriptorList = cell(1,length(piezoAxisName));

for ii=1:length(piezoAxisName)
    piezoDriverDescriptorList{ii}.AxisName = piezoAxisName{ii};
    piezoDriverDescriptorList{ii} = struct();
    piezoDriverDescriptorList{ii}.PiezoDriverSerialNumber = piezoDriverSerialNumber(ii);
    piezoDriverDescriptorList{ii}.Mode = piezoMode(ii);
    piezoDriverDescriptorList{ii}.PiezoUpperLimit = piezoUpperLimit{ii};
    piezoDriverDescriptorList{ii}.PiezoLowerLimit = piezoLowerLimit(ii);
    piezoDriverDescriptorList{ii}.StrainGaugeReaderSerialNumber = strainGaugeReaderSerialNumber(ii);
    piezoDriverDescriptorList{ii}.PiezoDriverRectangle = ...
        [ (activeXControlUpperLeftCorner + [((ii - 1) * activeXControlSize(1)) 0]) activeXControlSize];
    piezoDriverDescriptorList{ii}.StrainGaugeReaderRectangle = ...
        [ (activeXControlUpperLeftCorner + [((ii - 1) * activeXControlSize(1)) -activeXControlSize(2)]) activeXControlSize];
end

handles.PiezoDriverDescriptorList = piezoDriverDescriptorList;

handles.QpdDriverDescriptor = struct();
handles.QpdDriverDescriptor.SerialNumber = 89825082;
handles.QpdDriverDescriptor.Rectangle =  [ (activeXControlUpperLeftCorner + [(2 * activeXControlSize(1)), -1 * activeXControlSize(2)]) activeXControlSize];

handles.CameraDriverDescriptor = struct();
handles.CameraDriverDescriptor.Rectangle = [500 200 750 500];

handles.PiezoConversionFactorNanometersPerPercent = 226;

handles.samplingFrequency = 100000;
handles.samplingTime = 3;
handles.axis = 0;
handles.stepNumber = 100;
handles.scanFreq = 20;
handles.saveName = 'SaveName.txt';
handles.lineNumber = 100;
handles.lineScanFrequency = 1;
handles.samplesPerLine = 250;
handles.scanAmplitude = .5;
handles.stokesAmplitude = 1.25;
handles.stokesScanNumber = 10;
handles.xSensitivity = 0.001;
handles.ySensitivity = 0.001;
handles.beadRadius = 0.5;
handles.psdMinimumFrequency = 0;
handles.psdMaximumFrequency = 50000;
handles.dataPSD = [];
handles.daqChannels = 0:3;
handles.daqChannelNames = {'X-axis QPD','Y-axis QPD','X-axis Piezo','Y-axis Piezo'};
currentTableData = get(handles.dataTable, 'data');
currentTableData(2, 1) = {sprintf('%e',handles.xSensitivity)};
currentTableData(2, 2) = {sprintf('%e',handles.ySensitivity)};
newTableData = currentTableData;
set(handles.dataTable, 'data', newTableData);

% Choose default command line output for OtkbCalibration
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OtkbCalibration wait for user response (see UIRESUME)
% uiwait(handles.guiFigure);

% --- Outputs from this function are returned to the command line.
function varargout = OtkbCalibration_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

daqreset;
% Get default command line output from handles structure
varargout{1} = handles.output;

%
%
% Initialization
%
%
function turnOn_Callback(hObject, eventdata, handles)
% hObject    handle to turnOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% sets default values

% Initializes Daq
daqreset
handles.daq = InitializeDaqInput('nidaq','Dev1',0:3, handles.daqChannelNames,1000,'Immediate',100);
handles.daqOutput = InitializeDaqOutput('nidaq','Dev1',0:1,{'X-axis Drive','Y-axis Drive'},1000,'Immediate',inf);
guidata(hObject, handles);

daqreset
handles.PiezoDriverDescriptorList = InitializePiezoDrivers(handles.PiezoDriverDescriptorList, handles.guiFigure);
handles.QpdDriverDescriptor = InitializeQpdDriver(handles.QpdDriverDescriptor, handles.guiFigure);
handles.CameraDriverDescriptor = InitializeCameraDriver(handles.CameraDriverDescriptor, handles.guiFigure);

% Update handles structure
guidata(hObject, handles);


function NudgePiezo_Callback(hObject, eventdata, handles)
% hObject    handle to xDisplacement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xDisplacement as text
%        str2double(get(hObject,'String')) returns contents of xDisplacement as a double
buttonTag = get(hObject, 'Tag');

displacement = str2double(get(handles.xDisplacement, 'String'));

if(buttonTag(2) == 'M')
    displacement = -displacement;
end

for ii = 1:length(handles.PiezoDriverDescriptorList)
    if((buttonTag(1) == handles.PiezoDriverDescriptorList(ii)) && ...
           handles.PiezoDriverDescriptorList(ii).StrainGauge )
        [~, currentPosition] = invoke( ...
            handles.PiezoDriverDescriptorList(ii), ...
            'GetPosOutput', 0, 0);
        newPosition = CalculatePosition(xDisplacement,226,currentPosition);
        invoke(handles.piezoControlX, 'SetPosOutput', 0, newPosition);
    end
end
% PiezoVoltage = PiezoDisplacement(xDisplacement,226,currentPosition);
% invoke(handles.piezoControlX, 'SetPosOutput', 0, PiezoVoltage);
% guidata(hObject, handles);


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

%Gets axis selected
popUpMenuList = get(hObject,'String');
axis = get(hObject,'Value');
%Stores axis in handles.axis
switch popUpMenuList{axis}
    case 'X'
        handles.axis = 0;
    case 'Y'
        handles.axis = 1;
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in positionCalibrationStart.
function positionCalibrationStart_Callback(hObject, eventdata, handles)
% hObject    handle to positionCalibrationStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Configures Daq Output
lineNumber = handles.lineNumber;
lineScanFrequency = handles.lineScanFrequency;
samplesPerLine = handles.samplesPerLine;
scanAmplitude = handles.scanAmplitude;
slowScanFrequency = lineScanFrequency/(lineNumber*2);
sampleRate = samplesPerLine*lineScanFrequency;
timeBase = (0:(1/sampleRate):(1/slowScanFrequency));

fastAxisDriveVoltageWave = (scanAmplitude * sin(2*pi*lineScanFrequency*timeBase))';
slowAxisDriveVoltageWave = (scanAmplitude * cos(2*pi*slowScanFrequency*timeBase))';

%Sets Daq to 0 and resets daq output
daqreset
handles.daqOutput = InitializeDaqOutput('nidaq','Dev1',0:1,{'X-axis Drive','Y-axis Drive'},1000,'Immediate',inf);
ZeroOutput(handles)
% Configures Daq input for measuring starting positions
daqreset
handles.daq = InitializeDaqInput('nidaq','Dev1',handles.daqChannels, handles.daqChannelNames,1000,'Immediate',100);
% Gets starting positions
start(handles.daq)
wait(handles.daq, 1.1)
data = getdata(handles.daq);
xPositionReadout = data(:,3)';
yPositionReadout = data(:,4)';
global currentPositionX
global currentPositionY
currentPositionX = mean(xPositionReadout);
currentPositionY = mean(yPositionReadout);
% Sets proper axis
if handles.axis == 0
    triggerChannel = handles.daq.Channel(3);
    triggerPosition = (currentPositionX - 0.8*scanAmplitude);
    voltageDriveWaves = [fastAxisDriveVoltageWave slowAxisDriveVoltageWave];
elseif handles.axis == 1
    triggerChannel = handles.daq.Channel(4);
    triggerPosition = (currentPositionY - 0.8*scanAmplitude);
    voltageDriveWaves = [slowAxisDriveVoltageWave fastAxisDriveVoltageWave];
end
handles.daqOutput = InitializeDaqOutput('nidaq','Dev1',0:1,{'X-axis Drive','Y-axis Drive'},sampleRate,'Immediate',inf);
putdata(handles.daqOutput, voltageDriveWaves)

% Creates Data Files for Position Calibration Data
global PositionCalibrationData
PositionCalibrationData = struct();
PositionCalibrationData.XVoltage = zeros(lineNumber,ceil(samplesPerLine*.4));
PositionCalibrationData.YVoltage = zeros(lineNumber,ceil(samplesPerLine*.4));
PositionCalibrationData.QpdXVoltage = zeros(lineNumber,ceil(samplesPerLine*.4));
PositionCalibrationData.QpdYVoltage = zeros(lineNumber,ceil(samplesPerLine*.4));

% Configures Daq input
set(handles.daq, 'SampleRate', sampleRate);
set(handles.daq, 'SamplesPerTrigger', ceil(samplesPerLine*.4));
set(handles.daq,'TriggerChannel',triggerChannel)
set(handles.daq,'TriggerType','Software')
set(handles.daq,'TriggerRepeat',inf)
set(handles.daq,'TriggerFcn',{@XYCalibrationCallback,handles})
set(handles.daq,'TriggerCondition','Rising')
set(handles.daq,'TriggerConditionValue',triggerPosition)

global currentLine
currentLine = 1;
set(handles.xVoltSignalTitle,'string','X-axis Voltage Signal')
set(handles.yVoltSignalTitle,'string','Y-axis Voltage Signal')
guidata(hObject, handles);

start(handles.daqOutput);
start(handles.daq);

global dataAnalyzing
dataAnalyzing = 0;

while dataAnalyzing == 0
    pause(0.02)
end

global xSensitivity
global ySensitivity

handles.xSensitivity = xSensitivity;
handles.ySensitivity = ySensitivity;

%Puts sensitivity values in table
currentTableData = get(handles.dataTable, 'data');
currentTableData(2, 1) = {sprintf('%e',handles.xSensitivity)};
currentTableData(2, 2) = {sprintf('%e',handles.ySensitivity)};
newTableData = currentTableData;
set(handles.dataTable, 'data', newTableData);

% Update handles structure
guidata(hObject, handles);

function samplingFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to samplingFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of samplingFrequency as text
%        str2double(get(hObject,'String')) returns contents of samplingFrequency as a double
handles.samplingFrequency = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function samplingFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to samplingFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function samplingTime_Callback(hObject, eventdata, handles)
% hObject    handle to samplingTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of samplingTime as text
%        str2double(get(hObject,'String')) returns contents of samplingTime as a double
handles.samplingTime = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function samplingTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to samplingTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in waveformAndPSD.
function waveformAndPSD_Callback(hObject, eventdata, handles)
% hObject    handle to waveformAndPSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Configures DAQ card
daqreset
totalSamples = handles.samplingFrequency * handles.samplingTime;
handles.daq = InitializeDaqInput('nidaq','Dev1',handles.daqChannels, handles.daqChannelNames,handles.samplingFrequency,'Immediate',totalSamples);
% starts data acquisition
start(handles.daq);
wait(handles.daq, handles.samplingTime+1);
% takes data
[data,time] = getdata(handles.daq);
correctIndexOfData = handles.axis + 1;
voltageSignal = data(:,correctIndexOfData);
% plots data
hold(handles.yVoltSignal, 'off')
plot(handles.yVoltSignal, time, voltageSignal)
set(handles.yVoltSignalTitle,'string','Waveform Data')
xlabel(handles.yVoltSignal, 'Time(s)')
ylabel(handles.yVoltSignal, 'Voltage(V)')
% plots psd of data
if handles.axis == 0
    calibrationFactor = handles.xSensitivity;
elseif handles.axis ==1
    calibrationFactor = handles.ySensitivity;
end
handles.dataPSD = pwelch(voltageSignal);
equipartitionStiffness = EquipartitionAnalysis(voltageSignal, calibrationFactor);
handles.halfFrequency = handles.samplingFrequency/2.0;
lengthPSD = length(handles.dataPSD);
handles.frequencyAxis = linspace(1, handles.halfFrequency, lengthPSD);
guidata(hObject,handles);
handles.psdMinimumFrequency = max(handles.psdMinimumFrequency,0);
handles.psdMinimumFrequency = min(handles.psdMinimumFrequency,handles.frequencyAxis(end));
handles.psdMaximumFrequency = max(handles.psdMaximumFrequency,0);
handles.psdMaximumFrequency = min(handles.psdMaximumFrequency,handles.frequencyAxis(end));
[minValue, minIndex] = min(abs(handles.frequencyAxis-handles.psdMinimumFrequency));
[maxValue, maxIndex] = min(abs(handles.frequencyAxis-handles.psdMaximumFrequency));
if handles.psdMinimumFrequency > handles.psdMaximumFrequency
    psdRange = maxIndex:minIndex;
end
if handles.psdMinimumFrequency < handles.psdMaximumFrequency
    psdRange = minIndex:maxIndex;
end
loglog(handles.PSD, handles.frequencyAxis(psdRange), handles.dataPSD(psdRange))
hold(handles.PSD, 'on')
xlabel(handles.PSD, 'Frequency(Hz)')
ylabel(handles.PSD, 'PSD(V^2/Hz)')
% Calculates Best Fit Curve for PSD
bestFitParams = FitPsdFunction(handles.frequencyAxis(psdRange), handles.dataPSD(psdRange));
loglog(handles.PSD, handles.frequencyAxis(psdRange), TransferFunc(bestFitParams, handles.frequencyAxis(psdRange)), 'r')
title(handles.PSD, ['Cutoff Frequency = ', num2str(bestFitParams(2))])
hold(handles.PSD, 'off')
currentTableData = get(handles.dataTable, 'data');
rollOffStiffness = abs(bestFitParams(2)*5.27037*10^-5);
currentTableData(4, correctIndexOfData) = {sprintf('%e',rollOffStiffness)};
currentTableData(3, correctIndexOfData) = {sprintf('%e',equipartitionStiffness)};
newTableData = currentTableData;
set(handles.dataTable, 'data', newTableData);
% Saves Data to name specified in save name
dlmwrite(handles.saveName, time, 'precision', '%.6f', 'newline', 'pc')
dlmwrite(handles.saveName, voltageSignal, '-append','roffset', 0, 'delimiter', ' ')
dlmwrite(handles.saveName, handles.frequencyAxis', '-append','roffset', 0, 'delimiter', ' ')
dlmwrite(handles.saveName, handles.dataPSD, '-append','roffset', 0, 'delimiter', ' ')
dlmwrite(handles.saveName, TransferFunc(bestFitParams, handles.frequencyAxis)', '-append','roffset', 0, 'delimiter', ' ')
% Update handles structure
guidata(hObject, handles);

function scanFreq_Callback(hObject, eventdata, handles)
% hObject    handle to scanFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanFreq as text
%        str2double(get(hObject,'String')) returns contents of scanFreq as a double
handles.lineScanFrequency = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function scanFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lineNumber_Callback(hObject, eventdata, handles)
% hObject    handle to lineNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lineNumber as text
%        str2double(get(hObject,'String')) returns contents of lineNumber as a double
handles.lineNumber = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function lineNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lineNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in resetPosition.
function resetPosition_Callback(hObject, eventdata, handles)
% hObject    handle to resetPosition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Sets Center Positions
handles.daqOutput = InitializeDaqOutput('nidaq','Dev1',0:1,{'X-axis Drive','Y-axis Drive'},1000,'Immediate',inf);
ZeroOutput(handles)
invoke(handles.piezoControlX, 'SetPosOutput', 0, 50);
invoke(handles.piezoControlY, 'SetPosOutput', 0, 50);
invoke(handles.piezoControlZ, 'SetVoltOutput', 0, 37.5);
daqreset
guidata(hObject, handles);

% --- Executes on button press in zero.
function zero_Callback(hObject, eventdata, handles)
% hObject    handle to zero (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Switches to Open Loop
invoke(handles.piezoControlX, 'SetControlMode', 0, 1);
invoke(handles.piezoControlY, 'SetControlMode', 0, 1);
% Zeroes volt output
invoke(handles.piezoControlX, 'SetVoltOutput', 0, 0);
invoke(handles.piezoControlY, 'SetVoltOutput', 0, 0);
% Zeroes position
invoke(handles.strainControlX, 'SG_ZeroPosition', 0);
invoke(handles.strainControlY, 'SG_ZeroPosition', 0);
pause(25)
% Switches to Closed loop
invoke(handles.piezoControlX, 'SetControlMode', 0, 2);
invoke(handles.piezoControlY, 'SetControlMode', 0, 2);
% Recenters X and Y piezos
invoke(handles.piezoControlX, 'SetPosOutput', 0, 50);
invoke(handles.piezoControlY, 'SetPosOutput', 0, 50);
% Update handles structure
guidata(hObject, handles);

function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save as text
%        str2double(get(hObject,'String')) returns contents of save as a double
handles.saveName = get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function save_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function guiFigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to guiFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in QPDStart.
function QPDStart_Callback(hObject, eventdata, handles)
% hObject    handle to QPDStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Initiates DAQ card
daqreset
totalSamples = 10;
handles.daq = InitializeDaqInput('nidaq','Dev1',handles.daqChannels, handles.daqChannelNames,100,'Immediate',totalSamples);
set(handles.daq, 'TriggerRepeat', inf);
set(handles.daq, 'TriggerFcn', {@QPDDaqCallback, handles});
set(handles.xVoltSignalTitle,'string','QPD Alignment');
hold(handles.xVoltSignal, 'off')
guidata(hObject, handles)
% Starts Collecting Data
start(handles.daq)
guidata(hObject, handles)

% --- Executes on button press in QPDStop.
function QPDStop_Callback(hObject, eventdata, handles)
% hObject    handle to QPDStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(handles.daq)
grid(handles.xVoltSignal,'off')
guidata(hObject, handles);

function XYCalibrationCallback(hObject, eventdata, handles)
%Acquires Data
[voltageSignalX,voltageSignalY,piezoSignalX,piezoSignalY,mainPiezoSignal] = GetDataFunction(handles);
%Plots Current Line
hold(handles.xVoltSignal, 'off')
hold(handles.yVoltSignal, 'off')
plot(handles.xVoltSignal, mainPiezoSignal, voltageSignalX)
plot(handles.yVoltSignal, mainPiezoSignal, voltageSignalY)
xlabel(handles.xVoltSignal, 'Strain Gauge Voltage (V)')
ylabel(handles.xVoltSignal, 'QPD Voltage(V)')
xlabel(handles.yVoltSignal, 'Strain Gauge Voltage (V)')
ylabel(handles.yVoltSignal, 'QPD Voltage(V)')
set(handles.xVoltSignalTitle,'string','X-axis Voltage Signal');
set(handles.yVoltSignalTitle,'string','Y-axis Voltage Signal');

global PositionCalibrationData
global currentLine
set(handles.currentScanText,'string',sprintf('%d/%d', currentLine,handles.lineNumber));

%Stores Data from Current Line in Handles Structure
PositionCalibrationData.XVoltage(currentLine,:) = piezoSignalX;
PositionCalibrationData.YVoltage(currentLine,:) = piezoSignalY;
PositionCalibrationData.QpdXVoltage(currentLine,:) = voltageSignalX; 
PositionCalibrationData.QpdYVoltage(currentLine,:) = voltageSignalY;

if currentLine == handles.lineNumber
    stop(handles.daq);
    stop(handles.daqOutput);
    ZeroOutput(handles)
    % Plots Position Calibration Surface Plots
    global PositionCalibrationData
    contour(handles.xPositionCalibration, PositionCalibrationData.XVoltage, PositionCalibrationData.YVoltage, PositionCalibrationData.QpdXVoltage)
    contour(handles.yPositionCalibration, PositionCalibrationData.XVoltage, PositionCalibrationData.YVoltage, PositionCalibrationData.QpdYVoltage)
    % Saves Data to a file with name specified in save box
    dlmwrite(handles.saveName, PositionCalibrationData.XVoltage, 'delimiter', ' ', 'precision', 6)
    dlmwrite(handles.saveName, PositionCalibrationData.YVoltage, '-append','roffset', 1, 'delimiter', ' ')
    dlmwrite(handles.saveName, PositionCalibrationData.QpdXVoltage, '-append','roffset', 1, 'delimiter', ' ')
    dlmwrite(handles.saveName, PositionCalibrationData.QpdYVoltage, '-append','roffset', 1, 'delimiter', ' ')
    if handles.axis == 0
        QpdXVoltage = PositionCalibrationData.QpdXVoltage;
        QpdYVoltage = (PositionCalibrationData.QpdYVoltage)';
        XVoltage = PositionCalibrationData.XVoltage;
        YVoltage = (PositionCalibrationData.YVoltage)';
    elseif handles.axis == 1
        QpdXVoltage = (PositionCalibrationData.QpdXVoltage)';
        QpdYVoltage = PositionCalibrationData.QpdYVoltage;
        XVoltage = (PositionCalibrationData.XVoltage)';
        YVoltage = PositionCalibrationData.YVoltage;
    end
    %Finds curve with largest max-min
    [heightX widthX] = size(QpdXVoltage);
    [heightY widthY] = size(QpdYVoltage);
    maxVoltageDifferenceX = 0;
    maxVoltageDifferenceY = 0;
    for i = 1:heightX
        [valueMaxX indexMaxX] = max(QpdXVoltage(i,:));
        [valueMinX indexMinX] = min(QpdXVoltage(i,:));
        if valueMaxX-valueMinX >= maxVoltageDifferenceX
            maxVoltageDifferenceX = valueMaxX - valueMinX;
            maxVoltageXIndex = [i indexMaxX];
            minVoltageXIndex = [i indexMinX];
        end
    end
    for i = 1:heightY
        [valueMaxY indexMaxY] = max(QpdYVoltage(i,:));
        [valueMinY indexMinY] = min(QpdYVoltage(i,:));
        if valueMaxY-valueMinY >= maxVoltageDifferenceY
            maxVoltageDifferenceY = valueMaxY - valueMinY;
            maxVoltageYIndex = [i indexMaxY];
            minVoltageYIndex = [i indexMinY];
        end
    end
    %Designates Calibration Voltage curves and corresponding position curves
    if maxVoltageXIndex(2) > minVoltageXIndex(2)
        xCalibrationCurveVoltage = QpdXVoltage(maxVoltageXIndex(1),minVoltageXIndex(2):maxVoltageXIndex(2));
        xCalibrationCurvePosition = XVoltage(maxVoltageXIndex(1),minVoltageXIndex(2):maxVoltageXIndex(2));
    elseif maxVoltageXIndex(2) < minVoltageXIndex(2)
        xCalibrationCurveVoltage = QpdXVoltage(maxVoltageXIndex(1),maxVoltageXIndex(2):minVoltageXIndex(2));
        xCalibrationCurvePosition = XVoltage(maxVoltageXIndex(1),maxVoltageXIndex(2):minVoltageXIndex(2));
    end
    if maxVoltageYIndex(2) > minVoltageYIndex(2)
        yCalibrationCurveVoltage = QpdYVoltage(maxVoltageYIndex(1),minVoltageYIndex(2):maxVoltageYIndex(2));
        yCalibrationCurvePosition = YVoltage(maxVoltageYIndex(1),minVoltageYIndex(2):maxVoltageYIndex(2));
    elseif maxVoltageYIndex(2) < minVoltageYIndex(2)
        yCalibrationCurveVoltage = (QpdYVoltage(maxVoltageYIndex(1),maxVoltageYIndex(2):minVoltageYIndex(2)))';
        yCalibrationCurvePosition = (YVoltage(maxVoltageYIndex(1),maxVoltageYIndex(2):minVoltageYIndex(2)))';
    end
    %Finds line of best fit for the calibration curve
    coefficientOfDeterminationX = 0;
    coefficientOfDeterminationY = 0;
    if handles.axis == 0
        while coefficientOfDeterminationX < 0.98
            xCalibrationCurveVoltage = xCalibrationCurveVoltage(2:length(xCalibrationCurveVoltage)-1);
            xCalibrationCurvePosition = xCalibrationCurvePosition(2:length(xCalibrationCurvePosition)-1);
            currentR2X = regstats(xCalibrationCurveVoltage, xCalibrationCurvePosition, 'linear','rsquare');
            coefficientOfDeterminationX = currentR2X.rsquare;
            bestFitLineX = polyfit(xCalibrationCurvePosition',xCalibrationCurveVoltage',1);
        end
        while coefficientOfDeterminationY < 0.97
            yCalibrationCurveVoltage = yCalibrationCurveVoltage(2:length(yCalibrationCurveVoltage)-1);
            yCalibrationCurvePosition = yCalibrationCurvePosition(2:length(yCalibrationCurvePosition)-1);
            currentR2Y = regstats(yCalibrationCurveVoltage, yCalibrationCurvePosition, 'linear','rsquare');
            coefficientOfDeterminationY = currentR2Y.rsquare;
            bestFitLineY = polyfit(yCalibrationCurvePosition',yCalibrationCurveVoltage',1);
        end
    elseif handles.axis == 1
        while coefficientOfDeterminationX < 0.97
            xCalibrationCurveVoltage = xCalibrationCurveVoltage(2:length(xCalibrationCurveVoltage)-1);
            xCalibrationCurvePosition = xCalibrationCurvePosition(2:length(xCalibrationCurvePosition)-1);
            currentR2X = regstats(xCalibrationCurveVoltage, xCalibrationCurvePosition, 'linear','rsquare');
            coefficientOfDeterminationX = currentR2X.rsquare;
            bestFitLineX = polyfit(xCalibrationCurvePosition',xCalibrationCurveVoltage',1);
        end
        while coefficientOfDeterminationY < 0.98
            yCalibrationCurveVoltage = yCalibrationCurveVoltage(2:length(yCalibrationCurveVoltage)-1);
            yCalibrationCurvePosition = yCalibrationCurvePosition(2:length(yCalibrationCurvePosition)-1);
            currentR2Y = regstats(yCalibrationCurveVoltage, yCalibrationCurvePosition, 'linear','rsquare');
            coefficientOfDeterminationY = currentR2Y.rsquare;
            bestFitLineY = polyfit(yCalibrationCurvePosition',yCalibrationCurveVoltage',1);
        end
    end
    %Converts slope from being in volts/volt (since position is measured in
    %volts) to being in volts/nm
    global xSensitivity
    global ySensitivity
    xSensitivity = abs(bestFitLineX(1)/2260);
    ySensitivity = abs(bestFitLineY(1)/2260);
    
    %Plots best fit line against calibration curve
    plot(handles.xVoltSignal, xCalibrationCurvePosition, xCalibrationCurveVoltage)
    hold(handles.xVoltSignal, 'on')
    plot(handles.xVoltSignal, xCalibrationCurvePosition, bestFitLineX(1)*xCalibrationCurvePosition + bestFitLineX(2))
    plot(handles.yVoltSignal, yCalibrationCurvePosition, yCalibrationCurveVoltage)
    hold(handles.yVoltSignal, 'on')
    plot(handles.yVoltSignal, yCalibrationCurvePosition, bestFitLineY(1)*yCalibrationCurvePosition + bestFitLineY(2))
    
    global dataAnalyzing
    dataAnalyzing = 1;
else
   currentLine = currentLine + 1;
end

function QPDDaqCallback(hObject, eventdata, handles)

%Acquires data and plots
while(handles.daq.SamplesAvailable > 20)
    getdata(handles.daq);
end
data = getdata(handles.daq);
xData = (data(:,1))';
yData = (data(:,2))';
xMax = max(abs(xData));
yMax = max(abs(yData));
voltageRange = max(xMax, yMax) + 0.25;
plot(handles.xVoltSignal, -xData, -yData,'LineWidth',3,'Marker','x')
axis(handles.xVoltSignal, [-voltageRange voltageRange -voltageRange voltageRange]);
grid(handles.xVoltSignal,'on')
drawnow

% --- Executes on button press in posCalibrationStop.
function posCalibrationStop_Callback(hObject, eventdata, handles)
% hObject    handle to posCalibrationStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stop(handles.daq)
stop(handles.daqOutput)
ZeroOutput(handles)
daqreset
guidata(hObject,handles);

function scanAmplitude_Callback(hObject, eventdata, handles)
% hObject    handle to scanAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scanAmplitude as text
%        str2double(get(hObject,'String')) returns contents of scanAmplitude as a double
handles.scanAmplitude = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function scanAmplitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scanAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function samplesPerLine_Callback(hObject, eventdata, handles)
% hObject    handle to samplesPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of samplesPerLine as text
%        str2double(get(hObject,'String')) returns contents of samplesPerLine as a double
handles.samplesPerLine = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function samplesPerLine_CreateFcn(hObject, eventdata, handles)
% hObject    handle to samplesPerLine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function stokesAmplitude_Callback(hObject, eventdata, handles)
% hObject    handle to stokesAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stokesAmplitude as text
%        str2double(get(hObject,'String')) returns contents of stokesAmplitude as a double
handles.stokesAmplitude = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function stokesAmplitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stokesAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function stokesScanNumber_Callback(hObject, eventdata, handles)
% hObject    handle to stokesScanNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stokesScanNumber as text
%        str2double(get(hObject,'String')) returns contents of stokesScanNumber as a double
handles.stokesScanNumber = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function stokesScanNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stokesScanNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in stokesStart.
function stokesStart_Callback(hObject, eventdata, handles)
% hObject    handle to stokesStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Configures Daq Output
scanNumber = handles.stokesScanNumber;
lineScanFrequency = handles.lineScanFrequency;
samplesPerLine = handles.samplesPerLine;
scanAmplitude = handles.stokesAmplitude;
sampleRate = samplesPerLine*lineScanFrequency;
timeBaseScan = (0:(1/sampleRate):(1/lineScanFrequency)-1/sampleRate);
timeBase = zeros(1,scanNumber*samplesPerLine);
for i = 1:scanNumber
    timeBase(1, ((i-1)*samplesPerLine+1):i*samplesPerLine) = timeBaseScan;
end
driveVoltageWave = zeros(1, scanNumber*samplesPerLine);
driveVoltageWave(1,:) = (scanAmplitude * sin(2*pi*lineScanFrequency*timeBase))';

%Sets Daq to 0 and resets daq output
daqreset
if handles.axis == 0
    handles.daqOutput = InitializeDaqOutput('nidaq','Dev1',0,{'X-axis Drive'},1000,'Immediate',inf);
elseif handles.axis == 1
    handles.daqOutput = InitializeDaqOutput('nidaq','Dev1',1,{'Y-axis Drive'},1000,'Immediate',inf);
end
putsample(handles.daqOutput, 0)

% Configures Daq input for measuring starting positions
daqreset
handles.daq = InitializeDaqInput('nidaq','Dev1',handles.daqChannels, handles.daqChannelNames,1000,'Immediate',100);

% Gets starting positions
start(handles.daq)
wait(handles.daq, 1.1)
data = getdata(handles.daq);
xPositionReadout = data(:,3)';
yPositionReadout = data(:,4)';
xDisplacementReadout = data(:,1)';
yDisplacementReadout = data(:,2)';
currentPositionX = mean(xPositionReadout);
currentPositionY = mean(yPositionReadout);
xRestDisplacement = mean(xDisplacementReadout);
yRestDisplacement = mean(yDisplacementReadout);
driveVoltageWave = driveVoltageWave';

%Reconfigures output and executes putdata
if handles.axis == 0
    handles.daqOutput = InitializeDaqOutput('nidaq','Dev1',0,{'X-axis Drive'},sampleRate,'Immediate',inf);
elseif handles.axis == 1
    handles.daqOutput = InitializeDaqOutput('nidaq','Dev1',1,{'Y-axis Drive'},sampleRate,'Immediate',inf);
end
putdata(handles.daqOutput, driveVoltageWave)

% Configures Daq input
set(handles.daq, 'SampleRate', sampleRate);
set(handles.daq, 'SamplesPerTrigger', samplesPerLine*scanNumber+1);
set(handles.daq,'TriggerType','Immediate')
guidata(hObject, handles);

start(handles.daqOutput);
start(handles.daq);
wait(handles.daq, scanNumber/lineScanFrequency + 1)

stop(handles.daqOutput);
stop(handles.daq);
putsample(handles.daqOutput,0)

[voltageSignalX,voltageSignalY,piezoSignalX,piezoSignalY,mainPiezoSignal] = GetDataFunction(handles);

if handles.axis == 0
    voltageSignalMain = voltageSignalX;
    mainRestDisplacement = xRestDisplacement;
    calibrationValue = handles.xSensitivity;
    plottingAxis = handles.xVoltSignal;
    axisTitle = handles.xVoltSignalTitle;
    axisTitleString = 'X-axis Displacement(m) vs. Velocity (m/s)';
elseif handles.axis == 1
    voltageSignalMain = voltageSignalY;
    mainRestDisplacement = yRestDisplacement;
    calibrationValue = handles.ySensitivity;
    plottingAxis = handles.yVoltSignal;
    axisTitle = handles.yVoltSignalTitle;
    axisTitleString = 'Y-axis Displacement(m) vs. Velocity (m/s)';
end

voltageSignalMain = voltageSignalMain - mainRestDisplacement;
[alpha, velocity, displacement] = ComputeAlpha(mainPiezoSignal*2.26*10^-6, voltageSignalMain./calibrationValue, handles.beadRadius*10^-6, 0.89*10^-3, 1/sampleRate);

% Saves Data to a file with name specified in save box
dlmwrite(handles.saveName, voltageSignalMain, 'delimiter', ' ', 'precision', 6)
dlmwrite(handles.saveName, mainPiezoSignal, '-append','roffset', 1, 'delimiter', ' ')
dlmwrite(handles.saveName, velocity, '-append','roffset', 1, 'delimiter', ' ')
dlmwrite(handles.saveName, displacement, '-append','roffset', 1, 'delimiter', ' ')

%Plots displacement in nm vs velocity in nm/s
hold(plottingAxis, 'off')
scatter(plottingAxis, velocity, displacement)
set(axisTitle,'string',axisTitleString);

%Puts stiffness values in table
currentTableData = get(handles.dataTable, 'data');
currentTableData(5, handles.axis+1) = {sprintf('%e',alpha)};
newTableData = currentTableData;
set(handles.dataTable, 'data', newTableData);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in stokesStop.
function stokesStop_Callback(hObject, eventdata, handles)
% hObject    handle to stokesStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Stops daq
stop(handles.daq)
stop(handles.daqOutput)

%Sets volt output to 0
putsample(handles.daqOutput, 0);

%Resets Daq
daqreset

%Updates Handles
guidata(hObject, handles);

function ZeroOutput(handles)
putsample(handles.daqOutput, [0 0]);

function xSensitivityBox_Callback(hObject, eventdata, handles)
% hObject    handle to xSensitivityBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xSensitivityBox as text
%        str2double(get(hObject,'String')) returns contents of xSensitivityBox as a double
handles.xSensitivity = str2double(get(hObject,'String'));
currentTableData = get(handles.dataTable, 'data');
currentTableData(2, 1) = {handles.xSensitivity};
newTableData = currentTableData;
set(handles.dataTable, 'data', newTableData);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function xSensitivityBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xSensitivityBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ySensitivityBox_Callback(hObject, eventdata, handles)
% hObject    handle to ySensitivityBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ySensitivityBox as text
%        str2double(get(hObject,'String')) returns contents of ySensitivityBox as a double
handles.ySensitivity = str2double(get(hObject,'String'));
currentTableData = get(handles.dataTable, 'data');
currentTableData(2, 2) = {handles.ySensitivity};
newTableData = currentTableData;
set(handles.dataTable, 'data', newTableData);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ySensitivityBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ySensitivityBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [alpha, velocity, displacement] = ComputeAlpha(stagePosition, beadPosition, radius, eta, deltaT)
velocity = diff(stagePosition)./deltaT;
displacement = (beadPosition(2:end)+beadPosition(1:end-1))/2*10^-9;
bestFitLineX = polyfit(velocity, displacement, 1);
alpha = abs(6*pi*eta*radius/bestFitLineX(1)*10^3);

% --- Executes when guiFigure is resized.
function guiFigure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to guiFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in dnaTether.
function dnaTether_Callback(hObject, eventdata, handles)
% hObject    handle to dnaTether (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Configures Daq Output
lineNumber = handles.lineNumber;
lineScanFrequency = handles.lineScanFrequency;
samplesPerLine = handles.samplesPerLine;
scanAmplitude = handles.scanAmplitude;
slowScanFrequency = lineScanFrequency/(lineNumber*2);
sampleRate = samplesPerLine*lineScanFrequency;
timeBase = (0:(1/sampleRate):(1/slowScanFrequency));
fastAxisDriveVoltageWave = (scanAmplitude * sin(2*pi*lineScanFrequency*timeBase))';
slowAxisDriveVoltageWave = (scanAmplitude*.2 * cos(2*pi*slowScanFrequency*timeBase))';

%Sets Daq to 0 and resets daq output
daqreset
handles.daqOutput = InitializeDaqOutput('nidaq','Dev1',0:1,{'X-axis Drive','Y-axis Drive'},1000,'Immediate',inf);
ZeroOutput(handles)

% Configures Daq input for measuring starting positions
daqreset
handles.daq = InitializeDaqInput('nidaq','Dev1',handles.daqChannels, handles.daqChannelNames,1000,'Immediate',100);

% Gets starting positions
start(handles.daq)
wait(handles.daq, 1.1)
data = getdata(handles.daq);
xPositionReadout = data(:,3)';
yPositionReadout = data(:,4)';
global currentPositionX
global currentPositionY
currentPositionX = mean(xPositionReadout);
currentPositionY = mean(yPositionReadout);

% Sets proper axis
if handles.axis == 0
    triggerChannel = handles.daq.Channel(3);
    triggerPosition = (currentPositionX - 0.8*scanAmplitude);
    voltageDriveWaves = [fastAxisDriveVoltageWave slowAxisDriveVoltageWave];
elseif handles.axis == 1
    triggerChannel = handles.daq.Channel(4);
    triggerPosition = (currentPositionY - 0.8*scanAmplitude);
    voltageDriveWaves = [slowAxisDriveVoltageWave fastAxisDriveVoltageWave];
end

handles.daqOutput = InitializeDaqOutput('nidaq','Dev1',0:1,{'X-axis Drive','Y-axis Drive'},sampleRate,'Immediate',inf);
putdata(handles.daqOutput, voltageDriveWaves)

% Creates Data Files for Position Calibration Data
global TetherStretchingData
TetherStretchingData = struct();
TetherStretchingData.XVoltage = zeros(lineNumber,ceil(samplesPerLine*.4));
TetherStretchingData.YVoltage = zeros(lineNumber,ceil(samplesPerLine*.4));
TetherStretchingData.QpdXVoltage = zeros(lineNumber,ceil(samplesPerLine*.4));
TetherStretchingData.QpdYVoltage = zeros(lineNumber,ceil(samplesPerLine*.4));

% Configures Daq input
set(handles.daq, 'SampleRate', sampleRate);
set(handles.daq, 'SamplesPerTrigger', ceil(samplesPerLine*.4));
set(handles.daq,'TriggerChannel',triggerChannel)
set(handles.daq,'TriggerType','Software')
set(handles.daq,'TriggerRepeat',inf)
set(handles.daq,'TriggerFcn',{@TetherStretchingCallback,handles})
set(handles.daq,'TriggerCondition','Rising')
set(handles.daq,'TriggerConditionValue',triggerPosition)

global currentLine
currentLine = 1;
set(handles.xVoltSignalTitle,'string','X-axis Voltage Signal')
set(handles.yVoltSignalTitle,'string','Y-axis Voltage Signal')
guidata(hObject, handles);
start(handles.daqOutput);
start(handles.daq);
global dataAnalyzing
dataAnalyzing = 0;

while dataAnalyzing == 0
    pause(0.02)
end

%Starts Z scanning
global tetherLine
timeBase = (0:1/sampleRate:1/lineScanFrequency);
scanAxisVoltageWave = (scanAmplitude * sin(2*pi*lineScanFrequency*timeBase))';   
nonScanAxisVoltageWave = zeros(size(scanAxisVoltageWave));
nonScanAxisValue = mean(slowAxisDriveVoltageWave((((tetherLine-1)*samplesPerLine)+1):(tetherLine*samplesPerLine)),1);
nonScanAxisVoltageWave(:,:) = nonScanAxisValue;
%Sets up daq output
daqreset
handles.daqOutput = InitializeDaqOutput('nidaq','Dev1',0:1,{'X-axis Drive','Y-axis Drive'},1000,'Immediate',inf);
ZeroOutput(handles)
daqreset
%Sets up daq input
handles.daq = InitializeDaqInput('nidaq','Dev1',handles.daqChannels, handles.daqChannelNames,1000,'Immediate',100);
% Gets starting positions
start(handles.daq)
wait(handles.daq, 1.1)
data = getdata(handles.daq);
xPositionReadout = data(:,3)';
yPositionReadout = data(:,4)';
global currentPositionX
global currentPositionY
currentPositionX = mean(xPositionReadout);
currentPositionY = mean(yPositionReadout);
[null currentPositionZ] = invoke(handles.piezoControlZ, 'GetVoltOutput', 0, 0);
if handles.axis == 0
    triggerChannel = handles.daq.Channel(3);
    triggerPosition = (currentPositionX - 0.8*scanAmplitude);
    voltageDriveWaves = [scanAxisVoltageWave nonScanAxisVoltageWave];
elseif handles.axis == 1
    triggerChannel = handles.daq.Channel(4);
    triggerPosition = (currentPositionY - 0.8*scanAmplitude);
    voltageDriveWaves = [nonScanAxisVoltageWave scanAxisVoltageWave];
end

global zScanNumber
zScanNumber = 40;

global TetherStretchingZData
TetherStretchingZData = struct();
TetherStretchingZData.XVoltage = zeros(zScanNumber,ceil(samplesPerLine*.4));
TetherStretchingZData.YVoltage = zeros(zScanNumber,ceil(samplesPerLine*.4));
TetherStretchingZData.QpdXVoltage = zeros(zScanNumber,ceil(samplesPerLine*.4));
TetherStretchingZData.QpdYVoltage = zeros(zScanNumber,ceil(samplesPerLine*.4));
%Sets up daq output
handles.daqOutput = InitializeDaqOutput('nidaq','Dev1',0:1,{'X-axis Drive','Y-axis Drive'},sampleRate,'Immediate',inf);
putdata(handles.daqOutput, voltageDriveWaves)

%Configures daq input
set(handles.daq, 'SampleRate', sampleRate);
set(handles.daq, 'SamplesPerTrigger', ceil(samplesPerLine*.4));
set(handles.daq,'TriggerChannel',triggerChannel)
set(handles.daq,'TriggerType','Software')
set(handles.daq,'TriggerRepeat',inf)
set(handles.daq,'TriggerFcn',{@TetherStretchingZCallback,handles})
set(handles.daq,'TriggerCondition','Rising')
set(handles.daq,'TriggerConditionValue',triggerPosition)

global zScan
zScan = 1;

[null currentVoltage] = invoke(handles.piezoControlZ, 'GetVoltOutput', 0, 0);
newVoltage = currentVoltage - (500/266.7);
newVoltage = max(0, newVoltage);
newVoltage = min(newVoltage, 75);
invoke(handles.piezoControlZ, 'SetVoltOutput', 0, newVoltage);
guidata(hObject, handles);
while zScan <= zScanNumber
    set(handles.currentScanText,'string',sprintf('%d/%d', zScan,zScanNumber));
    guidata(hObject,handles);
    putdata(handles.daqOutput, voltageDriveWaves)
    global dataAnalyzing
    dataAnalyzing = 0;
    start(handles.daqOutput)
    start(handles.daq)
    while dataAnalyzing == 0;
        pause(0.02)
    end
    zDisplacement = 1000/zScanNumber;
    [null currentVoltage] = invoke(handles.piezoControlZ, 'GetVoltOutput', 0, 0);
    newVoltage = currentVoltage + (zDisplacement/266.7);
    newVoltage = max(0, newVoltage);
    newVoltage = min(newVoltage, 75);
    invoke(handles.piezoControlZ, 'SetVoltOutput', 0, newVoltage);
    guidata(hObject, handles);
    zScan = zScan + 1;
end    
stop(handles.daq);
stop(handles.daqOutput);
ZeroOutput(handles)

% Saves Data to a file with name specified in save box
dlmwrite(handles.saveName, TetherStretchingZData.XVoltage, 'delimiter', ' ', 'precision', 6)
dlmwrite(handles.saveName, TetherStretchingZData.YVoltage, '-append','roffset', 1, 'delimiter', ' ')
dlmwrite(handles.saveName, TetherStretchingZData.QpdXVoltage, '-append','roffset', 1, 'delimiter', ' ')
dlmwrite(handles.saveName, TetherStretchingZData.QpdYVoltage, '-append','roffset', 1, 'delimiter', ' ')

if handles.axis == 0
    QpdXVoltage = TetherStretchingZData.QpdXVoltage;
    QpdYVoltage = (TetherStretchingZData.QpdYVoltage)';
    XVoltage = TetherStretchingZData.XVoltage;
    YVoltage = (TetherStretchingZData.YVoltage)';
elseif handles.axis == 1
    QpdXVoltage = (TetherStretchingZData.QpdXVoltage)';
    QpdYVoltage = TetherStretchingZData.QpdYVoltage;
    XVoltage = (TetherStretchingZData.XVoltage)';
    YVoltage = TetherStretchingZData.YVoltage;
end
zHeight = zeros(1,zScanNumber);
tetherLengths = zeros(1,zScanNumber);
if handles.axis == 0
    qpdAxis = QpdXVoltage;
    piezoAxis = XVoltage;
    axis = handles.xVoltSignal;
elseif handles.axis == 1
    qpdAxis = QpdYVoltage;
    piezoAxis = YVoltage;
    axis = handles.yVoltSignal;
end
for i = 1:zScanNumber
    zHeight(1,i) = (i-20)*1000/zScanNumber;
    [valueMax indexMax] = max(qpdAxis(i,:));
    [valueMin indexMin] = min(qpdAxis(i,:));
    tetherLengths(1,i) = ((abs(piezoAxis(i,indexMax)-piezoAxis(i,indexMin))*2260)-2000*handles.beadRadius)/2;
end

%Plots best tether stretch
plot(axis,zHeight,tetherLengths);
%Sets tether length in static text box
tetherLength = max(tetherLengths);
if tetherLength <= 0
    tetherLength = 'Error, less than 0';
end
set(handles.tetherLength,'string',tetherLength);
invoke(handles.piezoControlZ, 'SetVoltOutput', 0, currentPositionZ);
guidata(hObject, handles);


function TetherStretchingCallback(hObject, eventdata, handles)

%Acquires Data
[voltageSignalX,voltageSignalY,piezoSignalX,piezoSignalY,mainPiezoSignal] = GetDataFunction(handles);

%Plots Current Line
hold(handles.xVoltSignal, 'off')
hold(handles.yVoltSignal, 'off')
plot(handles.xVoltSignal, mainPiezoSignal, voltageSignalX)
plot(handles.yVoltSignal, mainPiezoSignal, voltageSignalY)
set(handles.xVoltSignalTitle,'string','X-axis Voltage Signal');
set(handles.yVoltSignalTitle,'string','Y-axis Voltage Signal');

global TetherStretchingData
global currentLine
set(handles.currentScanText,'string',sprintf('%d/%d', currentLine,handles.lineNumber));

%Stores Data from Current Line in Handles Structure
TetherStretchingData.XVoltage(currentLine,:) = piezoSignalX;
TetherStretchingData.YVoltage(currentLine,:) = piezoSignalY;
TetherStretchingData.QpdXVoltage(currentLine,:) = voltageSignalX; 
TetherStretchingData.QpdYVoltage(currentLine,:) = voltageSignalY;

if currentLine == handles.lineNumber
    stop(handles.daq);
    stop(handles.daqOutput);
    ZeroOutput(handles)
    % Saves Data to a file with name specified in save box
    if handles.axis == 0
        QpdXVoltage = TetherStretchingData.QpdXVoltage;
        QpdYVoltage = (TetherStretchingData.QpdYVoltage)';
        XVoltage = TetherStretchingData.XVoltage;
        YVoltage = (TetherStretchingData.YVoltage)';
    elseif handles.axis == 1
        QpdXVoltage = (TetherStretchingData.QpdXVoltage)';
        QpdYVoltage = TetherStretchingData.QpdYVoltage;
        XVoltage = (TetherStretchingData.XVoltage)';
        YVoltage = TetherStretchingData.YVoltage;
    end
    %Finds curve with largest length
    maxVoltageDifference = 0;
    global tetherLine
    tetherLine = 0;
    if handles.axis == 0
        [heightX widthX] = size(QpdXVoltage);
        for i = 1:heightX
            [valueMaxX indexMaxX] = max(QpdXVoltage(i,:));
            [valueMinX indexMinX] = min(QpdXVoltage(i,:));
            if (abs(XVoltage(i,indexMaxX)-XVoltage(i,indexMinX)) >= maxVoltageDifference) && ((valueMaxX-valueMinX) > 1.5)
                maxVoltageDifference = abs(XVoltage(i,indexMaxX)-XVoltage(i,indexMinX));
                tetherLine = i;
            end
        end
    elseif handles.axis == 1
        [heightY widthY] = size(QpdYVoltage);
            for i = 1:heightY
            [valueMaxY indexMaxY] = max(QpdYVoltage(i,:));
            [valueMinY indexMinY] = min(QpdYVoltage(i,:));
            if (abs(YVoltage(i,indexMaxY)-XVoltage(i,indexMinY)) >= maxVoltageDifference) && ((valueMaxY-valueMinY) > 1.5)
                maxVoltageDifference = abs(YVoltage(i,indexMaxY)-XVoltage(i,indexMinY));
                tetherLine = i;
            end
        end
    end
    %Plots best tether stretch
    if handles.axis == 0
        mainPiezoSignal = XVoltage(tetherLine,:);
        mainQpdSignal = QpdXVoltage(tetherLine,:);
        axis = handles.xVoltSignal;
    elseif handles.axis == 1
        mainPiezoSignal = YVoltage(tetherLine,:);
        mainQpdSignal = QpdYVoltage(tetherLine,:);
        axis = handles.yVoltSignal;
    end
    plot(axis,mainPiezoSignal,mainQpdSignal);
    global dataAnalyzing
    dataAnalyzing = 1;
else
   currentLine = currentLine + 1;
end

function beadRadius_Callback(hObject, eventdata, handles)
% hObject    handle to beadRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of beadRadius as text
%        str2double(get(hObject,'String')) returns contents of beadRadius as a double
handles.beadRadius = str2double(get(hObject,'String'));
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function beadRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beadRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TetherStretchingZCallback(hObject, eventdata, handles)

%Acquires Data
[voltageSignalX,voltageSignalY,piezoSignalX,piezoSignalY,mainPiezoSignal] = GetDataFunction(handles);

%Plots Current Line
hold(handles.xVoltSignal, 'off')
hold(handles.yVoltSignal, 'off')
plot(handles.xVoltSignal, mainPiezoSignal, voltageSignalX)
plot(handles.yVoltSignal, mainPiezoSignal, voltageSignalY)
set(handles.xVoltSignalTitle,'string','X-axis Voltage Signal');
set(handles.yVoltSignalTitle,'string','Y-axis Voltage Signal');

global TetherStretchingZData
global zScan

%Stores Data from Current Line in Handles Structure
TetherStretchingZData.XVoltage(zScan,:) = piezoSignalX;
TetherStretchingZData.YVoltage(zScan,:) = piezoSignalY;
TetherStretchingZData.QpdXVoltage(zScan,:) = voltageSignalX; 
TetherStretchingZData.QpdYVoltage(zScan,:) = voltageSignalY;

stop(handles.daq);
stop(handles.daqOutput);

global dataAnalyzing
dataAnalyzing = 1;

% Computes the piezo voltage needed to achieve a given displacement
function PiezoVoltage = PiezoDisplacement(Displacement,VoltageConversionFactor, CurrentVoltage)
PiezoVoltage = CurrentVoltage + (Displacement/VoltageConversionFactor);
PiezoVoltage = max(0, PiezoVoltage);
PiezoVoltage = min(PiezoVoltage, 75);

function daqOutput = InitializeDaqOutput(daqName,daqDevice,channels, channelNames,sampleRate,triggerType,repeatOutput)

daqOutput = analogoutput(daqName, daqDevice);
addchannel(daqOutput,channels,channelNames);
set(daqOutput, 'SampleRate', sampleRate);
set(daqOutput, 'TriggerType',triggerType);
set(daqOutput, 'RepeatOutput',repeatOutput);

function daqInput = InitializeDaqInput(daqName,daqDevice,channels, channelNames,sampleRate,triggerType,samplesPerTrigger)

daqInput = analoginput(daqName, daqDevice);
addchannel(daqInput,channels,channelNames);
set(daqInput, 'SampleRate', sampleRate);
set(daqInput, 'SamplesPerTrigger', samplesPerTrigger);
set(daqInput,'TriggerType',triggerType);

function psdMinFreq_Callback(hObject, eventdata, handles)
% hObject    handle to psdMinFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psdMinFreq as text
%        str2double(get(hObject,'String')) returns contents of psdMinFreq as a double
handles.psdMinimumFrequency = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function psdMinFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psdMinFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function psdMaxFreq_Callback(hObject, eventdata, handles)
% hObject    handle to psdMaxFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psdMaxFreq as text
%        str2double(get(hObject,'String')) returns contents of psdMaxFreq as a double
handles.psdMaximumFrequency = str2double(get(hObject,'String'));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function psdMaxFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psdMaxFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in setPsdRange.
function setPsdRange_Callback(hObject, eventdata, handles)
% hObject    handle to setPsdRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if not(isempty(handles.dataPSD))
    handles.psdMinimumFrequency = max(handles.psdMinimumFrequency,0);
    handles.psdMinimumFrequency = min(handles.psdMinimumFrequency,handles.frequencyAxis(end));
    handles.psdMaximumFrequency = max(handles.psdMaximumFrequency,0);
    handles.psdMaximumFrequency = min(handles.psdMaximumFrequency,handles.frequencyAxis(end));
    [minValue, minIndex] = min(abs(handles.frequencyAxis-handles.psdMinimumFrequency));
    [maxValue, maxIndex] = min(abs(handles.frequencyAxis-handles.psdMaximumFrequency));
    if handles.psdMinimumFrequency > handles.psdMaximumFrequency
        psdRange = maxIndex:minIndex;
    end
    if handles.psdMinimumFrequency < handles.psdMaximumFrequency
        psdRange = minIndex:maxIndex;
    end
    loglog(handles.PSD, handles.frequencyAxis(psdRange), handles.dataPSD(psdRange))
    hold(handles.PSD, 'on')
    xlabel(handles.PSD, 'Frequency(Hz)')
    ylabel(handles.PSD, 'PSD(V^2/Hz)')
    % Calculates Best Fit Curve for PSD
    bestFitParams = FitPsdFunction(handles.frequencyAxis(psdRange), handles.dataPSD(psdRange));
    loglog(handles.PSD, handles.frequencyAxis(psdRange), TransferFunc(bestFitParams, handles.frequencyAxis(psdRange)), 'r')
    title(handles.PSD, ['Cutoff Frequency = ', num2str(bestFitParams(2))])
    hold(handles.PSD, 'off')
    currentTableData = get(handles.dataTable, 'data');
    rollOffStiffness = abs(bestFitParams(2)*5.27037*10^-5);
    correctIndexOfData = handles.axis + 1;
    currentTableData(4, correctIndexOfData) = {sprintf('%e',rollOffStiffness)};
    newTableData = currentTableData;
    set(handles.dataTable, 'data', newTableData);
    
    guidata(hObject,handles)
end

function [voltageSignalX,voltageSignalY,piezoSignalX,piezoSignalY,mainPiezoSignal] = GetDataFunction(handles)
data = getdata(handles.daq);
voltageSignalX = (data(:,1))';
voltageSignalY = (data(:,2))';
piezoSignalX = (data(:,3))';
piezoSignalY = (data(:,4))';
if handles.axis == 0
    mainPiezoSignal = piezoSignalX;
elseif handles.axis == 1
    mainPiezoSignal = piezoSignalY;
end
