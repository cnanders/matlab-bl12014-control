%{
    Camera manager:

The problem with image acquisition is that anytime a new camera is plugged
in, MATLAB needs to have its acquisition reset in order to see it, but this
probably deletes references to existing cameras (update: yes it does)

This means that the only way to detect a new camera is to disconnect
existing connections, then reconnect them afterward
%}

    
classdef PLCCameraManager < mic.Base
    
    
    properties (Constant)
        
        ceValidNames = {'TEST', 'FID1', 'FID2', 'UNI'}
        ceKnownCameraIDs = {...
            'UI225xSE-M R3_4102612161',...
            'UI225xSE-M R3_4102658006',...
            'UI225xSE-M R3_4102612163',...
            'UI225xSE-M R3_4102612164'...
            }

        
    end
    
    properties 
        ceConnectedCameras = {}
        ceAvailableCameras = {}
        cCameraID = 'none'
        dCameraIndex = -1
        hCamera
    end
    
    properties (Access = private)
        clock
        hAdapterHandle
        hTargetAxes
        dCapturePeriod = 1;
        
    end
    
    methods
        
        function this = PLCCameraManager(varargin)
            
             for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
             end
             
             this.init();
        end
        
        function init(this)
            this.reset();
        end
        
        function reset(this)
            fprintf('Resetting IMAQ handle...\n');
            imaqreset
            this.hAdapterHandle = imaqhwinfo('winvideo');

            stDeviceInfo = this.hAdapterHandle.DeviceInfo;
            fprintf('\nDetected %d camera(s) with IDs:\n', length(stDeviceInfo));
            
            this.ceAvailableCameras = {};
            for k = 1:length(stDeviceInfo)
                this.ceAvailableCameras{k} = stDeviceInfo(k).DeviceName; %#ok<AGROW>
                fprintf('\t%s (%s)\n', stDeviceInfo(k).DeviceName, ...
                        this.ceValidNames{strcmp(this.ceKnownCameraIDs, stDeviceInfo(k).DeviceName)});
            end
        end
        
        function idx = setCameraHandle(this)
            this.hAdapterHandle = imaqhwinfo('winvideo');
            stDeviceInfo = this.hAdapterHandle.DeviceInfo;
            for k = 1:length(stDeviceInfo)
                if strcmp(this.cCameraID, stDeviceInfo(k).DeviceName)
                    idx = k;
                end
            end
            this.dCameraIndex = idx;
            this.hCamera = videoinput('winvideo', idx);
        end
        
     
        
    end
    
    
    
     
    
end

