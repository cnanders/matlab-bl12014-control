% This is a bridge between hardware device and MATLAB UI

    
classdef PLCCameraDotNet < mic.Base
    
    
    properties (Constant)
        cName = 'camera-name'
        
        %{
            Camera IDs are flashed into each IDS camera as follow:
        
            TEST: 100
            FID1: 2
            FID2: ?
            UNI: 3
        %}
        ceValidNames = {'TEST', 'FID1', 'FID2', 'UNI'}
        dCameraIDs = {100, 2, 1, 3}
        
        
    end
    
    properties 
        dCameraIndex = -1
        hCamera
    end
    
    properties (Access = private)
        clock
        
        hTargetAxes
        dCapturePeriod = 1;
        
        
    end
    
    methods
        
        % Must construct with cName equal to one of the following: (TEST,
        % FID1, FID2, UNI)
        function this = PLCCameraDotNet(cName, varargin)
            if ~any(strcmp(this.ceValidNames,cName))
                error('Not a valid camera name, use: {TEST, FID1, FID2, UNI}\n');
            else
                this.dCameraIndex = this.dCameraIDs{strcmp(this.ceValidNames,cName)};
                fprintf('Successfully connected to camera %s @ device ID %d\n', cName, this.dCameraIndex);
            end

 

            
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
            asm = System.AppDomain.CurrentDomain.GetAssemblies;
            if ~any(arrayfun(@(n) strncmpi(char(asm.Get(n-1).FullName), ...
                    'uEyeDotNet', length('uEyeDotNet')), 1:asm.Length))
                NET.addAssembly(...
                    'C:\Program Files\IDS\uEye\Develop\DotNet\signed\uEyeDotNet.dll');
            end
            %   Create camera object handle
            cam = uEye.Camera( this.dCameraIndex);
            %   Open 1st available camera
            %   Returns if unsuccessful
            if ~strcmp(char(cam.Init), 'SUCCESS')
                error('Could not initialize camera');
            end
            %   Set display mode to bitmap (DiB)
            if ~strcmp(char(cam.Display.Mode.Set(uEye.Defines.DisplayMode.DiB)), ...
                    'SUCCESS')
                error('Could not set display mode');
            end
            %   Set colormode to 8-bit RAW
            if ~strcmp(char(cam.PixelFormat.Set(uEye.Defines.ColorMode.SensorRaw8)), ...
                    'SUCCESS')
                error('Could not set pixel format');
            end
            %   Set trigger mode to software (single image acquisition)
            if ~strcmp(char(cam.Trigger.Set(uEye.Defines.TriggerMode.Software)), 'SUCCESS')
                error('Could not set trigger format');
            end
            
        end
        
        function dNumDevices = getNumCameras(this)
            [a, dNumDevices] = uEye.Info.Camera.GetNumberOfDevices;
        end
        
        function refreshCameraList(this)
            
        end
        
       
        
        function startCaptureStream(this)
            
        end
        
        function stopCaptureStream(this)
            
        end
        
        function snap(this)
            imagesc(getsnapshot(this.hCamera));
        end
        
    end
    
    
    
     
    
end

