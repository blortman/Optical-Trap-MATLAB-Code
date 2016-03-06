function out = InitializeCameraDriver(CameraDriverDescriptor, GuiFigureHandle)

% if(handles.cameraControl == 0)
%     cameraRectangle = get(handles.uipanelCameraDisplay, 'Position');
%     handles.cameraControl = actxcontrol( ...
%         'uc480.uc480Ctrl.1', cameraRectangle, handles.figureMain);
%     invoke(handles.cameraControl, 'InitCamera', 1);
%     invoke(handles.cameraControl, 'SetColorMode', 6);
%     invoke(handles.cameraControl, 'EnableAutoExposure', 1);
%     invoke(handles.cameraControl, 'EnableAutoGain', 1);
%     invoke(handles.cameraControl, ...
%         'SetAOI', 2, 390, 500, 262, 500);
%end

CameraDriverDescriptor.ActiveXControl = actxcontrol( ...
    'uc480.uc480Ctrl.1', ...
    CameraDriverDescriptor.Rectangle, ...
    GuiFigureHandle);
invoke(CameraDriverDescriptor.ActiveXControl, 'InitCamera', 1);
invoke(CameraDriverDescriptor.ActiveXControl, 'SetColorMode', 6);
invoke(CameraDriverDescriptor.ActiveXControl, 'EnableAutoExposure', 1);
invoke(CameraDriverDescriptor.ActiveXControl, 'EnableAutoGain', 1);

out = CameraDriverDescriptor;