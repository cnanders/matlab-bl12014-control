classdef WinCam < mic.Base
    
    properties
        
        
        % {mic.ui.device.GetSetNumber 1x1}
        hCameraHandle
        
      
        
    end
    
    properties (SetAccess = private)
        
        dHeight = 600 
        dWidth = 500
        dWidthName = 100
        
        dAxesAspectRatio = 1
        

        lShowDevice = false
        lShowLabels = false
        lShowInitButton = false     
        
        cImgDirRoot


        
        cName = 'win-cam'
        cLabel = 'Camera'
        cCameraName = 'UI225xSE-M R3_4102658007'
        cProtocol = 'winvideo'
        dROI = []
        cFrameFormat = 'RGB24_1600x1200'
        
        uiTextCameraLabel
        uiIsCameraAvailable
        uiIsCameraConnected
        uiIsCameraPreviewing
        uibAcquire
        uieSaveImage
        uibSaveAs
        uibSave
        haUniformityCamAxes

        dRotation = 0;
        lFlipud = false;
        lShowCrosshairs = true;

    end
    
    properties (Access = private)
        
        clock
        uiClock
        
        
        % {< mic.interface.device.GetSetNumber}
        device
        
        % {bl12014.Hardware 1x1}
        hardware
        
        
        
    end
    
    methods
        
        function this = WinCam(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            
            
                        
            this.init();
        
        end
        
        
        

        
        function build(this, hParent, dLeft, dTop)
            

            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', this.cLabel,...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
            dLeft = 30;
            dTop = 10;
            this.uiIsCameraAvailable.build(hPanel, dLeft, dTop);
            dLeft = dLeft + 200;
            this.uiIsCameraPreviewing.build(hPanel, dLeft + 60, dTop);

            dTop = dTop + 30;

            dLeft = dLeft - 200;
            this.uiIsCameraConnected.build(hPanel, dLeft, dTop);

            this.uibAcquire.build(hPanel, dLeft + 330, dTop, 100, 24);
            dTop = dTop + 30;
            dLeft = dLeft + 5;
            
            dTop = dTop + 50;

            dAxesWidth = min(this.dWidth - 100, this.dHeight - 200);
            dAxesHeight = dAxesWidth / this.dAxesAspectRatio;

            this.haUniformityCamAxes = axes(...
                'Parent', hPanel, ...
                'Units', 'pixels', ...
                'Position', [ ...
                    (this.dWidth - dAxesWidth)/2 , ...
                    100 + (this.dAxesAspectRatio - 1)/2 * dAxesHeight, ...
                    dAxesWidth, ...
                    dAxesHeight] ...
                );

            dTop = this.dHeight - 50;

            this.uieSaveImage.build(hPanel, dLeft, dTop, 200, 30);
            this.uibSave.build(hPanel, dLeft + 210, dTop + 10, 100, 30);
            this.uibSaveAs.build(hPanel, dLeft + 320, dTop + 10, 100, 30);

           
                        
        end
        
        
        
        
        function delete(this)
           
            
        end    
        
        
    end
    
    
    methods (Access = private)
        
                
        function init(this)
            this.msg('init()');


            this.hCameraHandle = imaqcam.ImaqCam(...
                'cCameraName', this.cCameraName, ...
                'cProtocol', this.cProtocol, ...
                'dROI', this.dROI, ...
                'cFrameFormat', this.cFrameFormat ...
                );
            
            this.uiTextCameraLabel = mic.ui.common.Text(...
                'cLabel', this.cCameraName, ...
                'lShowLabel', true, ...
                'cVal', '...' ...
            );

            this.uiIsCameraAvailable = mic.ui.device.GetLogical(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hCameraHandle.isAvailable(), ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'camera-available'], ...
                'cLabel', 'Cam Avail' ...
            );

            this.uiIsCameraConnected = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hCameraHandle.isConnected(), ...
                'fhSet', @(lVal) mic.Utils.ternEval(...
                    lVal, ...
                    @() this.hCameraHandle.connect(), ...
                    @() this.hCameraHandle.disconnect() ...
                ), ...
                'lUseFunctionCallbacks', true, ...
                'ceVararginCommandToggle', {'cTextTrue', 'Disconnect', 'cTextFalse', 'Connect'}, ...
                'cName', [this.cName, 'camera-connected'], ...
                'cLabel', 'Cam Connected' ...
            );

            this.uiIsCameraPreviewing = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'dWidthName', 40, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hCameraHandle.isPreviewing(), ...
                'fhSet', @(lVal) this.onClickPreview(lVal), ...
                'lUseFunctionCallbacks', true, ...
                'ceVararginCommandToggle', {'cTextTrue', 'Stop', 'cTextFalse', 'Preview'}, ...
                'cName', [this.cName, 'camera-previewing'], ...
                'cLabel', 'Preview' ...
            );

            this.uieSaveImage = mic.ui.common.Edit(...
                'cLabel', 'Image name', ...
                'cType', 'c' ...
            );
            this.uibSave = mic.ui.common.Button(...
                'cText', 'Save Image', ...
                'fhDirectCallback', @this.onSaveImage ...
                );
            this.uibSaveAs = mic.ui.common.Button(...
                'cText', 'Save As...', ...
                'fhDirectCallback', @this.onSaveAsImage ...
                );
            this.uibAcquire = mic.ui.common.Button(...
                'cText', 'Acquire', ...
                'fhDirectCallback', @this.onAcquire ...
            );
        end


        function onClickPreview(this, lVal)

            if lVal
                axes(this.haUniformityCamAxes);
                this.hCameraHandle.preview(this.haUniformityCamAxes);

                if this.dRotation ~= 0
                    % Rotate axes:
                    view(this.haUniformityCamAxes, [this.dRotation, 90]);
                    
                end
                if this.lFlipud
                    set(this.haUniformityCamAxes, 'YDir', 'normal');
                end

                hold on
                % plot crosshairs:
                if this.lShowCrosshairs
                    dX = this.haUniformityCamAxes.XLim(2)/2;
                    dY = this.haUniformityCamAxes.YLim(2)/2;
                    plot(this.haUniformityCamAxes, [dX, dX], this.haUniformityCamAxes.YLim, 'y');
                    plot(this.haUniformityCamAxes, this.haUniformityCamAxes.XLim, [dY, dY], 'y');
                end
                hold off
            else
                this.hCameraHandle.stopPreview();
            end
            

        end


        function lVal = onAcquire(this, src, evt)
            lVal = false;
            if ~this.hCameraHandle.isConnected()
                msgbox('Camera not connected');
                return
            end
            if this.hCameraHandle.isPreviewing()
                this.hCameraHandle.stopPreview();
            end

            this.dImg = this.hCameraHandle.acquire();


            axes(this.haUniformityCamAxes);
            hold off;
            imagesc(this.dImg);
            hold on

            lVal = true;
        end


        
        function onFigureCloseRequest(this, src, evt)
           
        end
        
        
        
        
    end
    
    
end

