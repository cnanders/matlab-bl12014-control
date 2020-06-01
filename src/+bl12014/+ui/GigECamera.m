classdef GigECamera < mic.Base
    
    properties (Constant)
        
        cCONNECT = 'Connect'
        cDISCONNECT = 'Disconnect'
        cCONNECTING = 'Connecting...'   
    end
    properties
        
    end
    
    properties (Access = protected)
        
        cIp = '192.168.30.26'
        
        % {axes 1x1}
        hAxes
        % {need to create an image in the axes to place video feed}
        hImage
        
        camera
        uiButtonConnectCamera
        
        % {double 1x1} define the ROI of the camera sensor that you want to
        % preview.  dOffsetX + dSizeX must be <= the number of x pixels on
        % the sensor.  dOffsetY + dSizeY must be <= the number of y pixels
        % on the sensor
        dOffsetX = 0
        dOffsetY = 0
        dSizeX = 1288
        dSizeY = 728
        
        % {char 1xm} see this.cSTATE_*
        cState
        
        % {function_handle 1x1} this function processes each frame image
        % {data} and returns data or a modified version of it
        fhProcess = @(data) data
        
    end
    
    properties (SetAccess = protected)
        
        cName = 'GigE Camera'
    end
    
    methods
        
        function this = GigECamera(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
        
        
        function createCamera(this)
            
            if ~isempty(this.camera)
                return
            end
            
            try
                this.camera = gigecam(this.cIp);
                
                % Set up ROI on the hardware
                this.camera.OffsetX = this.dOffsetX;
                this.camera.OffsetY = this.dOffsetY;
                this.camera.Width = this.dSizeX;
                this.camera.Height = this.dSizeY;
               
                
            catch mE
                getReport(mE)
                return;
            end
            
        end
        
        function processImageFrame(this, obj, event, himage)
            %rotImg = rot90(event.Data);
            %rotImg = rot90(rotImg);
            set(himage, 'cdata', this.fhProcess(event.Data));
        end
        
        function startVideoPreview(this)
            
            this.createCamera();   
            
            if isempty(this.hImage)
                
                this.hImage = image(...
                    zeros(this.dSizeY, this.dSizeX), ...
                    'Parent', this.hAxes ...
                );
                % Set up the update preview window function to allow
                % preprocessing
                % https://www.mathworks.com/help/imaq/previewing-data.html
                setappdata(this.hImage, 'UpdatePreviewWindowFcn', @this.processImageFrame);
            end
            
            try
                preview(this.camera, this.hImage); 
            catch mE
                error(getReport(mE));
            end
            
        end
        
        function stopVideoPreview(this)
            
            if isempty(this.camera)
                return
            end
            
            try
                closePreview(this.camera);
            catch mE
                getReport(mE)
            end
            
        end
         
        function build(this, hParent, dLeft, dTop, dWidth)
            
            % auto-compute height based on dWidth and the aspect ratio
            % of the ROI
            dHeight = this.dSizeY / this.dSizeX * dWidth;
            dSep = 30;
            
            this.uiButtonConnectCamera.build(hParent, dLeft, dTop, dWidth, 24);
            dTop = dTop + dSep;
            
            this.hAxes = axes(...
                'Parent', hParent, ...
                'Color', [1 1 0.85], ...
                'Box', 'off', ...
                'Units','pixels', ...
                'XColor', 'none', ...
                'YColor', 'none', ...
                'Position', mic.Utils.lt2lb([dLeft dTop dWidth dHeight], hParent), ...
                ... %'DataAspectRatio', [this.dSizeX this.dSizeY 1], ...
                'HandleVisibility', 'on' ...
            );
            
            
        end
        
        function delete(this)
            this.msg('delete()', this.u8_MSG_TYPE_CLASS_DELETE);  
            this.stopVideoPreview();
            
             if ~isempty(this.camera)
                 delete(this.camera)
             end
             
        end  
        
        
        function st = save(this)
            st = struct();
        end
        
        function load(this, st)
            
        end
        
    end
    
    methods (Access = protected)

        function init(this)
            this.msg('init');
            this.uiButtonConnectCamera = mic.ui.common.Button(...
                'cText', this.cCONNECT, ...
                'fhDirectCallback', @this.onButtonConnectCamera ...
            );
        
        end
        
        function onButtonConnectCamera(this, src, evt)
            
            switch src.getText()
                case this.cCONNECT
                    src.setText(this.cCONNECTING);
                    drawnow;
                    this.startVideoPreview();
                    src.setText(this.cDISCONNECT);
                case {this.cCONNECTING, this.cDISCONNECT}
                    this.stopVideoPreview();
                    src.setText(this.cCONNECT);
            end
           
            
        end
        
        
        
    end
    
    
end

