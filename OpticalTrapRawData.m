classdef OpticalTrapRawData < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        RawData = [];
        SampleRate = 0;
        LaserPower = 0;
        
        MaximumSamples = 1000;

        DataLength = 0;
        QpdVoltage;
        StageVoltage;
        ParticlePosition;
        StagePosition;
        QpdResponsivity = [0 0];
        StageResponsivity = [2.22e-6 2.22e-6];
    end
    
    methods
        function this = set.MaximumSamples(this, value)
            if(length(this.RawData) > value)
                this.RawData = this.RawData((end-value):end,:);
            end
        end
        
        function value = get.DataLength(this)
            value = length(this.RawData);
        end
        
        function value = get.QpdVoltage(this)
            if(~isempty(this.RawData))
                value = this.RawData(:,1:2);
            else
                value = [];
            end
        end
        
        function value = get.StageVoltage(this)
            if(~isempty(this.RawData))
                value = this.RawData(:,3:4);
            else
                value = [];
            end
        end
        
        function value = get.StagePosition(this)
            value = this.StageVoltage * diag(this.StageResponsivity);
        end
        
        function value = get.ParticlePosition(this)
            value = this.QpdVoltage * diag(this.QpdResponsivity);
        end
        
        function AddSamples(this, RawData)
            if(length(this.RawData) >= this.MaximumSamples)
                this.RawData = this.RawData((end-this.MaximumSamples+1):end,:);
            else
                samplesToDrop = max(1, length(this.RawData) - this.MaximumSamples + length(this.RawData) + 1);
                this.RawData = vertcat( this.RawData(samplesToDrop:end,:), RawData);
            end

        end
    end
    
end

