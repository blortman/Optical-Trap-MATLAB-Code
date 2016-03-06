classdef OpticalTrapCalibration < handle & OpticalTrapping.StevesClassTools
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Viscosity = 1e-3;
        Diameter = 1e-6;
        Temperature = 293;
    end
    
    properties (SetAccess = private, GetAccess = public)
        EquipartitionStiffnessCoefficient = [0 0];
        EquipartitionStiffnessCoefficientConfidenceInterval = [0 0];
        PsdStiffnessCoefficient = [0 0];
        PsdStiffnessCoefficientConfidenceInterval = [0 0];
        StokesStiffnessCoefficient = [0 0]
        StokesStiffnessCoefficientConfidenceInterval = [0 0]
        QpdPsdResponsivityCoefficient = [0 0];
        QpdPsdResponsivityCoefficientConfidenceInterval = [0 0];
    
        ThermalCalibrationData = [];
        StokesCalibrationData = [];
        
    end
    
    properties (SetAccess = private, GetAccess = private)
        daqObject = [];
    end
    
    methods
        function self = OpticalTrapCalibration(varargin)
            self.TraceStart();
            p = inputParser;
            p.StructExpand = true;
            p.addParamValue('TraceEnable', true, @(x) islogical(x));
            p.addParamValue('DaqVendor', 'ni', @(x) isstring(x));
            p.addParamValue('DaqDeviceName', 'Dev2', @(x) isstring(x));
            p.addParamValue('DaqChannel', 1, @(x) 1);
            p.parse(varargin{:});

            % transfer property values
            fieldName = fieldnames(p.Results);

            for ii=1:length(fieldName)
                self.(fieldName{ii}) =  p.Results.(fieldName{ii});
            end

            self.TraceEnd();
        end
        
        function Success = Initialize(self)
            Success = false;
            if(isempty(self.daqObject))
                self.TraceStart();
                self.Trace('Initializing analog output');
                try
                    self.daqObject = daq.createSession(self.DaqVendor);
                    self.daqObject.addAnalogOutputChannel(self.DaqDeviceName, self.DaqChannel, 'Voltage');
                    
                    self.Trace(self.daqObject);
                    Success = true;
                catch Exception
                    self.daqObject = [];
                    self.Trace('DAQ initialization failed');
                end
            else
                Success = true;
            end
        end
        
        function SetVoltage(self, Voltage)
            self.TraceStart();
            if(self.Initialize())
                self.daqObject.queueOutputData(Voltage);
                self.daqObject.startForeground();
                self.Trace(['laser control voltage set to ' num2str(Voltage, 3)]);
            else
                self.Trace('daqObject not initialized');
            end
            self.TraceEnd();
        end
        
        function Close(self)
            self.TraceStart();
            if(isobject(self.daqObject))
                if(self.daqObject.isvalid)
                    self.daqObject.release();
                    self.Trace('Daq released');
                end
            else
                self.Trace('Daq uninitialized before close');
            end
            self.TraceEnd();
        end
        
        function delete(self)
            self.TraceStart();
            self.Close();
            self.TraceEnd();
        end
    end
    
end

