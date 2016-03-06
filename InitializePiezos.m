function HandlesOut = InitializePiezos(HandlesIn)

controllerId = HandlesIn.PiezoControllerId;
activeXControl = zeros(1,length(controllerId));

for ii = 1:length(controllerId)
    activeXControl(ii) = actxcontrol('MGPIEZO.MGPiezoCtrl.1', [950 134 100 66], handles.guiFigure);
    set(activeXControl(ii), 'HWSerialNum', 81817001);
    invoke(activeXControl(ii), 'StartCtrl');
end

HandlesOut = HandlesIn;
HandlesOut.PiezoControllerId = controllerId;
HandlesOut.PiezoActiveXControl = activeXControl;
