% Shutter -> 3
% MOXA channel 1 -> 2

classdef Uniformity < mic.Base
    
    properties

        % Uniformity cam transforms.  These are defined by the relative positions of the 3 cameras.  See Fiducialization keynote
        % for more details.  Transforms compute the stage coordinates as seen by the uniformity camera from the stage coordinates
        % as seen by the left and right fidcuial cameras.  

        l2u = @(x) [x(1) + 67.67, x(2) + .405]
        r2u = @(x) [x(1) - 68.17, x(2) + 0.265]

        fid1R = 10;
        fid2R = 10;
        fid1C = -17.2;
        fid2C = 37.2;

        cFidPath     = ...
            fullfile(fileparts(mfilename('fullpath')),...
            '..', '..',  'config', 'fiducial-config');


        dImgROIWidth = 300 % width of the cropped part of the image
        dImgROIHeight = 150 % height of the cropped part of the image

        dFieldWidthPx = 200
        dFieldHeightPx = 30
        
        cName = 'Uniformity'
        

        % UI:
        uieUnitVectorRx
        uieUnitVectorRy

        uiePathToImagesDir
        uieHexapodDelay

        uieCenterPixelR
        uieCenterPixelC

        uieROIR1
        uieROIR2
        uieROIC1
        uieROIC2

        uieIntrinsicDwellTime
        uieMinDwellTime
        uieCSV

        uibOpenDir
        uibSetDirToLatest
        uibLoadImages

        uibNextImg
        uibPrevImg

        uibComputeCombo

        % Labels
        uitUnitVector
        uitCenterPixel
        uitActiveImgText
        uitROI



        uilCombos

        hardware
        uiReticleCoarseStage

        % {bl12014.ui.Shutter 1x1}
        uiShutter

        uiWobbleWorkingMode
        

        % Axes
        haImages
        haXSec
        haFieldUniformity
        haFieldUniformityAgg

        haRecipe

        uipSetup
        uipProfiles
        uipCompute
        
        cDirUniformity
        cDirSrc
        cDirThis

        dTaskImgs = {}
        lTaskAcquireSuccess

        dImgs = []
        dImgsField = []
        dImgsFieldRound = []
        dCenterIdx
        dActiveIdx = 1

        dResultVec = []
        dResultIdx = 1

        % Tab group:
        uitgMode
        ceTabList = {'Uniformity Cam', 'Wobble setup', 'Fiducialization'}


        lShowDevice = false
        lShowLabels = false
        lShowInitButton = false     


        % Uniformity tab

        hCameraUniformity
        uiIsCameraAvailable
        uiIsCameraConnected
        uiIsCameraPreviewing
        uibAcquire
        uieSaveImage
        uibSave

        dImg = []


        uibRefreshIMAQ
        haUniformityCamAxes
        
        %Fiducial tab:
        
        % cameras:
        hWinCamUniformity
        hWinCamFid1
        hWinCamFid2

        lIsSetFid1 = false
        lIsSetFid2 = false

        uibClearFiducials
        uiSetFid1
        uiSetFid2


    end
    
    properties (Access = private)
        
        clock
        uiClock
        
        dWidthName = 200
        dWidth = 1850;
        dHeight = 1040;
        
        
    end
    
    
    methods
        
        function letMeIn(this)
            this.msg('letMeIn()');
        end
        
        function this = Uniformity(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            
            
            this.cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSrc = fullfile(this.cDirThis, '..', '..');
            
            this.init();
            
        end
        

        
        
        function build(this, hParent, dLeft, dTop)

            % Build topline:

            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Global',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth - 20 ...
                190], hParent) ...
                );

            dLTop = 10 ;
            this.uitCenterPixel.build(hPanel, dLeft, dLTop, this.dWidthName, 30);

            this.uitUnitVector.build(hPanel, dLeft + 300, dLTop, this.dWidthName, 30);


            dLTop = dLTop + 20;
            this.uieCenterPixelR.build(hPanel, dLeft, dLTop, 100, 30);
            this.uieCenterPixelC.build(hPanel, dLeft + 110, dLTop, 100, 30);

            this.uieUnitVectorRx.build(hPanel, dLeft + 300, dLTop, 100, 30);
            this.uieUnitVectorRy.build(hPanel, dLeft + 410, dLTop, 100, 30);

            dLTop = dLTop - 10;
            dLLeft = dLeft + 800;
            this.uiReticleCoarseStage.build(hPanel, dLLeft, dLTop - 7);
            dLLeft = dLeft;
            dLTop = dLTop + 60;
            this.uiWobbleWorkingMode.build(hPanel, dLLeft, dLTop);
            dLLeft = dLLeft + 300;
            this.uiShutter.build(hPanel, dLLeft, dLTop)
            dLLeft = dLeft;
            dLTop = dLTop + 70;
            this.uibRefreshIMAQ.build(hPanel, dLLeft, dLTop, 100, 30);

            



            % Build main tabs:
            this.uitgMode.build(hParent, dLeft, dTop + 210, this.dWidth, this.dHeight - 120);

            % Build uniformity cam tab:
            this.buildUniformityCamPanel(this.uitgMode.getTabByIndex(1), dLeft, dTop);

            
            this.buildSetup(this.uitgMode.getTabByIndex(2), dLeft, dTop)
            this.buildProfiles(this.uitgMode.getTabByIndex(2), dLeft, dTop + 70)
            this.buildCompute(this.uitgMode.getTabByIndex(2), dLeft, dTop + 70)
            
            this.buildFiducialization(this.uitgMode.getTabByIndex(3), dLeft, dTop);


            % this.uitgMode.selectTabByIndex(2);
            
        end
        
       
                
       
        
        function delete(this)
            
            
            
            
        end
        
        
       
        function onLoadLatest(this, src, evt)
            
        
            
            
            
        end

        function cStr = getWobbleCSV(this, lUseIndex, dDose, dFocus)

            dNDose = length(dDose);
            dNFocus = length(dFocus);

            % Create a matrix of the dose and focus values:
            [dDoseMat, dFocusMat] = meshgrid(dDose, dFocus);


            dDoseLinear = reshape(dDoseMat', 1, []);

            ceLabels = {};
            for k = 1:dNFocus
                for m = 1:dNDose
                    ceLabels{end + 1} = sprintf('F%dD%d', (k), (m));
                end
            end

            % Add index shot if needed:
            if lUseIndex
                mMid = ceil(length(dDose)/2);
                dDoseLinear = [dDose(mMid), dDoseLinear];
                ceLabels = [{'Index'}, ceLabels];
            end


            % Look up highlighted uniformity combinations:
            ceCombo = this.dResultVec(this.dResultIdx, :);

            dCoeff = ceCombo{2};
            dIdx = ceCombo{3};
            % Normalize coefficients:
            dCoeff = dCoeff / sum(dCoeff);

            % Get unit vectors:
            dUx = this.uieUnitVectorRx.get();
            dUy = this.uieUnitVectorRy.get();

            cStr = 'index,name';
            for k = 1:length(dCoeff)
                cStr = [cStr, sprintf(',pose%d_rx,pose%d_ry,pose_%d_t_ms', k, k, k)];
            end

            for k = 1:length(dDoseLinear)
                cRow = this.getWobbleRow(k, dDoseLinear(k), dCoeff, dIdx, dUx, dUy, ceLabels{k});
                cStr = [cStr, cRow];
            end

        end

        function cRow = getWobbleRow(this, id, dDose, dCoef, dIdx, dUx, dUy, cLabel)
            % Multiply coefficients by dose:
            dWobbleDwells = dCoef * dDose;
            cRow = sprintf('\n%d,%s', id, cLabel);

            % Build dwell strings:
            for k = 1:length(dWobbleDwells)
                dRx = dUx * (dIdx(k) - this.dCenterIdx);
                dRy = dUy * (dIdx(k) - this.dCenterIdx);

                cRow = [cRow, sprintf(',%.3f,%.3f,%d', dRx, dRy, round(1000 * dWobbleDwells(k)))];
            end

        end

        function st = save(this)
            cecProps = this.getSaveLoadProps();
           
           st = struct();
           for n = 1 : length(cecProps)
               cProp = cecProps{n};
               if this.hasProp( cProp)
                   st.(cProp) = this.(cProp).save();
               end
           end

            
       end
       
       function load(this, st)
                       
           cecProps = this.getSaveLoadProps();
           for n = 1 : length(cecProps)
              cProp = cecProps{n};
              if isfield(st, cProp)
                  if this.hasProp( cProp )
                       this.(cProp).load(st.(cProp))
                  end
              end
           end
           
       end

       function cec = getSaveLoadProps(this)
        cec = {...
            'uieUnitVectorRx', ...
            'uieUnitVectorRy', ...
            'uiePathToImagesDir', ...
            'uieHexapodDelay', ...
            'uieCenterPixelR', ...
            'uieCenterPixelC', ...
            'uieROIR1', ...
            'uieROIR2', ...
            'uieROIC1', ...
            'uieROIC2', ...
            'uieIntrinsicDwellTime', ...
            'uieMinDwellTime' ...
         };
    end
        
       
        
    end
    
    methods (Access = private)
        
        function buildFiducialization(this, hParent, dLeft, dTop)

            % this.uiReticleCoarseStage.build(hParent, 10, 10);
            % this.uibRefreshIMAQ.build(hParent, 10, 100);
            this.hWinCamFid2.build(hParent, dLeft, dTop);
            dLeft = dLeft + 505;
            this.hWinCamUniformity.build(hParent, dLeft, dTop);
            dLeft = dLeft + 505;
            this.hWinCamFid1.build(hParent, dLeft, dTop);
            dLeft = dLeft + 505;


            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Set Fiducials',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop  ...
                250 ...
                600], hParent) ...
                );
            
            dTop = 40;
            dLeft = 10;
            this.uibClearFiducials.build(hPanel, 10, dTop, 200, 30);
            dTop = dTop + 50;
            this.uiSetFid1.build(hPanel, dLeft, dTop);
            dTop = dTop + 50;
            this.uiSetFid2.build(hPanel, dLeft, dTop);
            
        end

        function buildUniformityCamPanel(this, hParent, dLeft, dTop)


            
            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Camera',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop  ...
                this.dWidth - 40 ...
                580], hParent) ...
                );

            this.haUniformityCamAxes = axes(...
                'Parent', hPanel, ...
                'Units', 'pixels', ...
                'Position', [ ...
                    40 , ...
                        40, ...
                    1000, ...
                    500] ...
                );

            dLeft = 1050;
            dTop = 40;
            dTop = dTop + 30;
            this.uiIsCameraAvailable.build(hPanel, dLeft, dTop);
            dTop = dTop + 30;
            this.uiIsCameraConnected.build(hPanel, dLeft, dTop);
            dTop = dTop + 30;


            this.uiIsCameraPreviewing.build(hPanel, dLeft, dTop);


            this.uibAcquire.build(hPanel, dLeft + 230 + 105, dTop, 100, 24);
            dTop = dTop + 50;
            dLeft = dLeft + 5;
            this.uieSaveImage.build(hPanel, dLeft, dTop, 200, 30);
            this.uibSave.build(hPanel, dLeft + 210, dTop + 10, 100, 30);

            
        end


        function buildSetup(this, hParent, dLeft, dTop)

            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Setup',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop + 10 ...
                this.dWidth - 20 ...
                110], hParent) ...
                );
            
            dLeft = dLeft + 20;
            
            
            
            dTop = 20
            this.uiePathToImagesDir.build(hParent, dLeft, dTop, 300, 30);

            dTop = dTop + 10;
            this.uibOpenDir.build(hParent, dLeft + 310, dTop, 100, 30);
            this.uibSetDirToLatest.build(hParent, dLeft + 420, dTop, 100, 30);
            
            this.uibLoadImages.build(hParent, dLeft + 530, dTop, 100, 30);



            dLeft = dLeft + 650;
            dTop = dTop - 20;
            this.uitROI.build(hParent, dLeft, dTop, this.dWidthName, 30);

            dTop = dTop + 20;
            this.uieROIC1.build(hParent, dLeft, dTop, 100, 30);
            this.uieROIC2.build(hParent, dLeft + 110, dTop, 100, 30);
            this.uieROIR1.build(hParent, dLeft + 220, dTop, 100, 30);
            this.uieROIR2.build(hParent, dLeft + 330, dTop, 100, 30);




            
        end

        function buildCompute(this, hParent, dLeft, dTop)



            dPanelHeight = 700;
            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Compute',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                this.dWidth - 680 ...
                dTop + 50 ...
                560 ...
                    dPanelHeight], hParent) ...
                );


            dTop = 50;
            
            this.uieIntrinsicDwellTime.build(hPanel, 20, dTop, 100, 30);
            this.uieMinDwellTime.build(hPanel, 140, dTop, 100, 30);

            dTop = dTop + 60;
            this.uibComputeCombo.build(hPanel,  20, dTop, 100, 30);

            dTop = dTop + 40;
            this.uilCombos.build(hPanel, 20, dTop, 500, 150);

            dTop = dTop + 170;
            this.uieCSV.build(hPanel, 20, dTop, 500, 100);
            this.uieCSV.makeMax();

           

        end

        function buildProfiles(this, hParent, dLeft, dTop)
            
            dPanelHeight = 700;
            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Profiles',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop + 50 ...
                this.dWidth - 700 ...
                    dPanelHeight], hParent) ...
                );


            this.uibPrevImg.build(hPanel, dLeft + 20, 15, 40, 30);
            this.uitActiveImgText.build(hPanel, dLeft + 85, 17, 60, 30);
            this.uibNextImg.build(hPanel, dLeft + 130, 15, 40, 30);
            
            dTop = dTop + 40;
            dLeft = dLeft + 20;
            
            
            this.haImages = axes(...
                'Parent', hPanel, ...
                'Units', 'pixels', ...
                'Position', [ ...
                    dLeft , ...
                        dPanelHeight - 310, ...
                    500, ...
                    250] ...
                );
            
            this.haXSec = axes(...
                'Parent', hPanel, ...
                'Units', 'pixels', ...
                'Position', [ ...
                    dLeft + 550, ...
                        dPanelHeight - 310, ...
                    500, ...
                        250] ...
                );

            this.haFieldUniformity = axes(...
                'Parent', hPanel, ...
                'Units', 'pixels', ...
                'Position', [ ...
                    dLeft, ...
                        dPanelHeight - 450, ...
                    750, ...
                    90] ...
                );

            this.haFieldUniformityAgg = axes(...
                'Parent', hPanel, ...
                'Units', 'pixels', ...
                    'Position', [ ...
                        dLeft, ...
                            dPanelHeight - 600, ...
                        750, ...
                        90] ...
                    );
        this.haRecipe = axes(...
                        'Parent', hPanel, ...
                        'Units', 'pixels', ...
                            'Position', [ ...
                                dLeft + 800, ...
                                    dPanelHeight - 600, ...
                                250, ...
                                250] ...
                            );
        
        end
        
        
        function init(this)
            
          
            this.msg('init()');

            this.uiWobbleWorkingMode = bl12014.ui.SMSMoxaComm(...
                'cName', [this.cName, 'wobble-working-mode'], ...
                'uiClock', this.uiClock, ...
                'hardware', this.hardware, ...
                'clock', this.clock ...
            );

            this.uiShutter = bl12014.ui.Shutter(...
                'clock', this.clock, ...
                'uiClock', this.uiClock, ...
                'hardware', this.hardware ...
            );
            
            this.uiReticleCoarseStage = bl12014.ui.ReticleCoarseStage(...
                'cName', [this.cName, 'reticle-coarse-stage'], ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
                );

            this.hCameraUniformity = imaqcam.ImaqCam(...
                'cCameraName', 'UI225xSE-M R3_4102658007', ...
                'cProtocol', 'winvideo', ...
                'dROI', [335,  190,   300,   150], ...
                'cFrameFormat', 'RGB24_1600x1200' ...
                );
            
            % specialized win cams for fid tab:
            this.hWinCamUniformity = bl12014.ui.WinCam(...
                'cCameraName', 'UI225xSE-M R3_4102658007', ...
                'cName', 'Uniformity-Camera', ...
                'hardware', this.hardware, ...
                'uiClock', this.uiClock, ...
                'dROI', [335,  190,   300,   150], ...
                'cName', 'Uniformity Camera', ...
                'dWidth', 500, ...
                'dHeight', 600, ...
                'dAxesAspectRatio', 2, ...
                'clock', this.clock ...
                );
            
            this.hWinCamFid1 = bl12014.ui.WinCam(...
                'cCameraName', 'UI225xSE-M R3_4102658006', ...
                'cName', 'fid-cam-1', ...
                'cLabel', 'Right Fiducial Cam (1)', ...
                'dRotation', 90, ...
                'lFlipud', true, ...
                'dROI', [200, 0, 1200, 1200], ...
                'hardware', this.hardware, ...
                'uiClock', this.uiClock, ...
                'cName', 'fid-cam-1', ...
                'cLabel', 'Fiducial Cam 1', ...
                'dWidth', 500, ...
                'dHeight', 600, ...
                'clock', this.clock ...
                );
            
            this.hWinCamFid2 = bl12014.ui.WinCam(...
                'cCameraName', 'UI225xSE-M R3_4102658008', ...
                'cName', 'fid-cam-2', ...
                'cLabel', 'Left Fiducial Cam (2)', ...
                'hardware', this.hardware, ...
                'uiClock', this.uiClock, ...
                'dRotation', -90, ...
                'lFlipud', true, ...
                'dROI', [200, 0, 1200, 1200], ...
                'cName', 'Fiducial Cam 2', ...
                'dWidth', 500, ...
                'dHeight', 600, ...
                'clock', this.clock ...
                );

            this.uiIsCameraAvailable = mic.ui.device.GetLogical(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hCameraUniformity.isAvailable(), ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'camera-available'], ...
                'cLabel', 'Uniformity Camera Available' ...
            );

            this.uiIsCameraConnected = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hCameraUniformity.isConnected(), ...
                'fhSet', @(lVal) mic.Utils.ternEval(...
                    lVal, ...
                    @() this.hCameraUniformity.connect(), ...
                    @() this.hCameraUniformity.disconnect() ...
                ), ...
                'lUseFunctionCallbacks', true, ...
                'ceVararginCommandToggle', {'cTextTrue', 'Disconnect', 'cTextFalse', 'Connect'}, ...
                'cName', [this.cName, 'camera-connected'], ...
                'cLabel', 'Uniformity Camera Connected' ...
            );

            this.uiIsCameraPreviewing = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ... 
                'lShowDevice', this.lShowDevice, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowInitButton', this.lShowInitButton, ...
                'fhGet', @() this.hCameraUniformity.isPreviewing(), ...
                'fhSet', @(lVal) this.onClickPreview(lVal), ...
                'lUseFunctionCallbacks', true, ...
                'ceVararginCommandToggle', {'cTextTrue', 'Stop', 'cTextFalse', 'Preview'}, ...
                'cName', [this.cName, 'camera-previewing'], ...
                'cLabel', 'Preview' ...
            );
        
        

            this.uitgMode = mic.ui.common.Tabgroup('ceTabNames', this.ceTabList);
            
            
            % Init labels:
            this.uitUnitVector = mic.ui.common.Text(...
                'cVal', 'Unit Vector',...
                'dFontSize', 14 ...
                );


            this.uitCenterPixel = mic.ui.common.Text(...
                'cVal', 'Center Pixel',...
                'dFontSize', 14 ...
                );

            this.uitROI = mic.ui.common.Text(...
                'cVal', 'Uniformity ROI',...
                'dFontSize', 14 ...
                );

            this.uitActiveImgText = mic.ui.common.Text(...
                'cVal', sprintf('%d/%d', this.dActiveIdx, size(this.dImgs, 3)),...
                'dFontSize', 14 ...
                );
            
            % Init edit boxes:
            
            this.uieUnitVectorRx = mic.ui.common.Edit(...
                'cLabel', 'Rx', ...
                'cType', 'd' ...
                );
            this.uieUnitVectorRy = mic.ui.common.Edit(...
                'cLabel', 'Ry', ...
                'cType', 'd' ...
                );

            this.uieCenterPixelR = mic.ui.common.Edit(...
                'cLabel', 'Center Pixel R', ...
                'cType', 'd' ...
                );
            this.uieCenterPixelC = mic.ui.common.Edit(...
                'cLabel', 'Center Pixel C', ...
                'cType', 'd' ...
                );

            this.uieROIC1 = mic.ui.common.Edit(...
                'cLabel', 'ROI Left (col)', ...
                'fhDirectCallback', @this.setROI, ...
                'cType', 'd' ...
                );
            this.uieROIC2 = mic.ui.common.Edit(...
                'cLabel', 'ROI Right (col)', ...
                'fhDirectCallback', @this.setROI, ...
                'cType', 'd' ...
                );
                
            this.uieROIR1 = mic.ui.common.Edit(...
                'cLabel', 'ROI Top (row)', ...
                'fhDirectCallback', @this.setROI, ...
                'cType', 'd' ...
                );
            this.uieROIR2 = mic.ui.common.Edit(...
                'cLabel', 'ROI Bot (row)', ...
                'fhDirectCallback', @this.setROI, ...
                'cType', 'd' ...
                );

            this.uiePathToImagesDir = mic.ui.common.Edit(...
                'cLabel', 'Path to Images Dir', ...
                'cType', 'c' ...
                );

            this.uieSaveImage = mic.ui.common.Edit(...
                'cLabel', 'Image name', ...
                'cType', 'c' ...
            );
            this.uibSave = mic.ui.common.Button(...
                'cText', 'Save Image', ...
                'fhDirectCallback', @this.onSaveImage ...
                );
            this.uibAcquire = mic.ui.common.Button(...
                'cText', 'Acquire', ...
                'fhDirectCallback', @this.onAcquire ...
            );

            this.uieHexapodDelay = mic.ui.common.Edit(...
                'cLabel', 'Hexapod Delay (ms)', ...
                'cType', 'd' ...
                );

            this.uibOpenDir = mic.ui.common.Button(...
                'cText', 'Load Dir...', ...
                'fhDirectCallback', @this.onOpenDir ...
                );
            this.uibSetDirToLatest = mic.ui.common.Button(...
                'cText', 'Set Dir to Latest', ...
                'fhDirectCallback', @this.onSetDirToLatest ...
                );
            this.uibLoadImages = mic.ui.common.Button(...
                'cText', 'Reload Images', ...
                'fhDirectCallback', @this.onLoadImages ...
                );
            this.uibNextImg = mic.ui.common.Button(...
                'cText', 'Next', ...
                'fhDirectCallback', @(src, evt) this.changeIndex(1) ...
                );
            this.uibPrevImg = mic.ui.common.Button(...
                'cText', 'Prev', ...
                'fhDirectCallback', @(src, evt) this.changeIndex(-1) ...
                );

            this.uibComputeCombo = mic.ui.common.Button(...
                'cText', 'Recompute combinations', ...
                'fhDirectCallback', @this.onComputeCombo ...
                );
           

            this.uieIntrinsicDwellTime = mic.ui.common.Edit(...
                'cLabel', 'Intrinsic Dwell Time (ms)', ...
                'cType', 'd' ...
                );
            this.uieMinDwellTime = mic.ui.common.Edit(...
                'cLabel', 'Minimum Dwell Time (ms)', ...
                'cType', 'd' ...
                );
            
            this.uilCombos =  mic.ui.common.List(...
                'lShowMove', false, ...
                'lShowRefresh', false, ...
                'lShowDelete', false, ...
                'cLabel', 'Wobble pairs', ...
                'fhOnChange', @this.handleSelectCombo ...
                );
            % Create multiline:
            this.uieCSV = mic.ui.common.Edit(...            
                'cLabel', 'CSV', ...
                    'xMax', 2, ...
                    'xMin', 0, ...
                'cType', 'c' ...
            );


            this.uibRefreshIMAQ = mic.ui.common.Button(...
                'cText', 'Refresh IMAQ', ...
                'dColor', [1, .7, .7], ...
                'fhDirectCallback', @this.onRefreshIMAQ ...
                );

            this.uibClearFiducials = mic.ui.common.Button(...
                'cText', 'Clear Fiducials', ...
                'fhDirectCallback', @this.onClearFiducials ...
                );

            ceVararginCommandToggle = {...
                'cTextTrue', 'Clear LF', ...
                'cTextFalse', 'Set LF' ...
            };

            this.uiSetFid1 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'dWidthName', 80, ... 
                'lShowInitButton', false, ...
                'fhGet', @() this.lIsSetFid1, ...
                'fhSet', @(lVal) this.onSetFiducial(1, lVal), ...
                'lUseFunctionCallbacks', true, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'cName', [this.cName, 'set-fid-1'], ...
                'cLabel', 'Left Fid' ...
            );

            ceVararginCommandToggle = {...
                'cTextTrue', 'Clear RF', ...
                'cTextFalse', 'Set RF' ...
            };

            this.uiSetFid2 = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'dWidthName', 80, ... 
                    'lShowInitButton', false, ...
                'fhGet', @() this.lIsSetFid2, ...
                'fhSet', @(lVal) this.onSetFiducial(2, lVal), ...
                'lUseFunctionCallbacks', true, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'cName', [this.cName, 'set-fid-2'], ...
                'cLabel', 'Right Fid' ...
            );



            % Set default values:
            this.uieHexapodDelay.set(500);
            this.uieMinDwellTime.set(300);

            if (this.uieUnitVectorRx.get() == 0)
                this.uieUnitVectorRx.set(0.005);
            end
            if (this.uieUnitVectorRy.get() == 0)
                this.uieUnitVectorRy.set(0.005);
            end

            if (this.uieCenterPixelR.get() == 0)
                this.uieCenterPixelR.set(935);
            end
            if (this.uieCenterPixelC.get() == 0)
                this.uieCenterPixelC.set(485);
            end

            if (this.uieIntrinsicDwellTime.get() == 0)
                this.uieIntrinsicDwellTime.set(500);
            end

            if (this.uieROIC1.get() == 0)
                this.uieROIC1.set(935);
            end
            if (this.uieROIC2.get() == 0)
                this.uieROIC2.set(485);
            end
            if (this.uieROIR1.get() == 0)
                this.uieROIR1.set(200);
            end
            if (this.uieROIR2.get() == 0)
                this.uieROIR2.set(15);
            end

            
            
        end

        function onClearFiducials(this, src, evt)
            this.lIsSetFid1 = false;
            this.lIsSetFid2 = false;
        end

        function onSetFiducial(this, idx, lVal)
            if lVal
                dX = this.uiReticleCoarseStage.uiX.getValCal('mm');
                dY = this.uiReticleCoarseStage.uiY.getValCal('mm');


                % Read file into json:
                fid = fopen(fullfile(this.cFidPath, 'fiducials.json'), 'r');
                cJson = fread(fid, inf, '*char');
                st = jsondecode(cJson');
                fclose(fid);

                if idx == 1
                    % Transform into the coordinate system of the camera:
                    du = this.l2u([dX, dY]);

                    st.fid1.X = du(1);
                    st.fid1.Y = du(2);
                    st.fid1.R = this.fid1R;
                    st.fid1.C = this.fid1C;

                    % Show question dlg confirming fiducialization:
                    cMsg = sprintf('This will set the left fiducial to (%.3f, %.3f).  Is this correct?', du(1), du(2));
                    cTitle = 'Set Left Fiducial';
                    cAnswer = questdlg(cMsg, cTitle, 'Yes', 'No', 'No');
                    if ~strcmp(cAnswer, 'Yes')
                        return
                    end

                    this.lIsSetFid1 = true;
                else
                    % Transform into the coordinate system of the camera:
                    du = this.r2u([dX, dY]);

                    st.fid2.X = du(1);
                    st.fid2.Y = du(2);
                    st.fid2.R = this.fid2R;
                    st.fid2.C = this.fid2C;
                    
                     % Show question dlg confirming fiducialization:
                     cMsg = sprintf('This will set the right fiducial to (%.3f, %.3f).  Is this correct?', du(1), du(2));
                     cTitle = 'Set Left Fiducial';
                     cAnswer = questdlg(cMsg, cTitle, 'Yes', 'No', 'No');
                     if ~strcmp(cAnswer, 'Yes')
                         return
                     end

                    this.lIsSetFid2 = true;
                end

                % Write back to file and also write to /backups/fid-[date].json:
                fid = fopen(fullfile(this.cFidPath, 'fiducials.json'), 'w');
                fwrite(fid, jsonencode(st));
                fclose(fid);

                cDate = datestr(now, 'yyyy-mm-dd-HH-MM-SS');
                fid = fopen(fullfile(this.cFidPath, 'backups', sprintf('fid-%s.json', cDate)), 'w');
                fwrite(fid, jsonencode(st));
                fclose(fid);

            else 
                if idx == 1
                    this.lIsSetFid1 = false;
                else
                    this.lIsSetFid2 = false;
                    
                end
                
                
            end
        end

        function onClickPreview(this, lVal)

            if lVal
                axes(this.haUniformityCamAxes);
                hold off
                this.hCameraUniformity.preview(this.haUniformityCamAxes);
                hold on
                this.plotUniformityGuides();
            else
                this.hCameraUniformity.stopPreview();
            end
            

        end

        function lVal = onAcquire(this, src, evt)
            lVal = false;
            if ~this.hCameraUniformity.isConnected()
                msgbox('Camera not connected');
                return
            end
            if this.hCameraUniformity.isPreviewing()
                this.hCameraUniformity.stopPreview();
            end

            this.dImg = this.hCameraUniformity.acquire();

            % Crop to this.dImgROIWidth x this.dImgROIHeight centered on the center pixel:
            dR1 = this.uieCenterPixelR.get() - this.dImgROIHeight/2;
            dR2 = this.uieCenterPixelR.get() + this.dImgROIHeight/2;
            dC1 = this.uieCenterPixelC.get() - this.dImgROIWidth/2;
            dC2 = this.uieCenterPixelC.get() + this.dImgROIWidth/2;

%             this.dImg = this.dImg(dR1:dR2, dC1:dC2, :);



            axes(this.haUniformityCamAxes);
            hold off;
            imagesc(this.dImg);
            hold on
            this.plotUniformityGuides();

            lVal = true
        end

        function acquireFromTask(this)

            this.lTaskAcquireSuccess = false;
            lTaskAcquireSuccess = this.onAcquire();

            this.dTaskImgs{end + 1} = this.dImg;


        end 

        function onSaveImage(this, src, evt)
            if ~this.hCameraUniformity.isConnected()
                msgbox('Camera not connected');
                return
            end
            if this.hCameraUniformity.isPreviewing()
                this.hCameraUniformity.stopPreview();
            end

            data = this.dImg;
            cPath = this.uiePathToImagesDir.get();
            cName = this.uieSaveImage.get();
            [cPath, cName] = uigetfile([cPath, cName], 'Save Image');
            if cPath == 0
                return
            end
            imwrite(data, [cPath, cName]);
        end

        function setROI(this, src, evt)


        end

        function onRefreshIMAQ(this, src, evt)
            this.hCameraUniformity.refreshIMAQ();
        end

        function plotUniformityGuides(this)

                dCr = 75;
                dCc = 150;
                
                % Plot the center pixel:
                plot(this.haUniformityCamAxes, dCc, dCr, 'r+', 'MarkerSize', 10, 'LineWidth', 2);
    
                % Plot field:
                rectangle(this.haUniformityCamAxes, 'Position', ...
                    [dCc - this.dFieldWidthPx/2, dCr - this.dFieldHeightPx/2, this.dFieldWidthPx, this.dFieldHeightPx], 'EdgeColor', 'r', 'linewidth', 2);

                % Draw ellipse that is 250 px x 125 px centered on the center pixel:
                ellipseWidth = 250;
                ellipseHeight = 125;
                rectangle(this.haUniformityCamAxes, 'Position', ...
                    [dCc - ellipseWidth/2, dCr - ellipseHeight/2, ellipseWidth, ellipseHeight], ...
                    'Curvature', [1, 1], 'EdgeColor', 'y', 'LineWidth', 2);


                % Draw a horizontal line and verticle line through the center pixel:
                plot(this.haUniformityCamAxes, [dCc, dCc], [dCr - 50, dCr + 50], 'g', 'LineWidth', 1.5);
                plot(this.haUniformityCamAxes, [dCc - 50, dCc + 50], [dCr, dCr], 'g', 'LineWidth', 1.5);

        end


        function onComputeCombo(this, src, evt)
            
            dFluxCenter = sum(sum(squeeze(this.dImgsField(:,:,this.dCenterIdx))));
            dMaxCenter = max(max(squeeze(this.dImgsField(:,:,this.dCenterIdx))));
           
            % Reshape the first 2 dimensions of the field uniformity images into a line:
            C = zeros(size(this.dImgsField, 3), size(this.dImgsField, 1) * size(this.dImgsField, 2) );
            for k = 1:size(this.dImgsFieldRound, 3)
                C(k, :) = reshape(this.dImgsField(:,:,k), 1, []);
            end
           
            % Define the target flat curve
            b = dMaxCenter*ones(size(C,2), 1);
            D = C';

            
            dResultVec = {};

            dResultIdeal = this.computeIdeal(D, b, dFluxCenter);
            dResultPairs = this.computePairs(D, b, dFluxCenter, 15);
            dResultTriples = this.computeTriples(D, b, dFluxCenter, 10);

            % Append the results to the result vector:
            dResultVec = [dResultVec; dResultIdeal; dResultPairs; dResultTriples];

             % Sort result vector by error:
             this.dResultVec = sortrows(dResultVec, 1);
             this.dResultIdx = 1;
 
             % store in list:
             ceResults = {...
                 sprintf('Error\t\t\t Coefficeints  Image-idx    DoseFac   Uniformity') ...
                 };
 
             dNumResults = 25;
 
 
             for k = 1:dNumResults
                 dResultVec = this.dResultVec(k, :);

                % Join the coefficients (unknown length) into a string:
                dCoeff = dResultVec{2};
                dCoeffStr = '[';
                for m = 1:length(dCoeff)
                    dCoeffStr = [dCoeffStr, sprintf('%.3f\t', dCoeff(m))];
                end
                dCoeffStr = [dCoeffStr, ']'];

                % Join the image indices  (unknown length)  into a string:
                dIndex = dResultVec{3};
                dIndexStr = '[';
                for m = 1:length(dIndex)
                    dIndexStr = [dIndexStr, sprintf('%d\t', dIndex(m))];
                end
                dIndexStr = [dIndexStr, ']'];
                
                 cVal = sprintf('%.0f\t  %s\t    %s\t   %.3f\t %.3f', dResultVec{1}, dCoeffStr, dIndexStr, dResultVec{4}, dResultVec{5});
                 ceResults{end + 1} = cVal;
             end
             
             this.uilCombos.setOptions(ceResults);
             this.uilCombos.setSelectedIndexes(uint8(2));

            
            this.handleSelectCombo();
        end

        function dResultVec = computeIdeal(this, D, b, dFluxCenter)
            dResultVec = {};
            ct = 1;

            dCoeff = lsqnonneg(D, b);
            dError = norm(b - D * dCoeff);
            dResultVec{ct, 1} = dError;

            idx = dCoeff > 0;
            dResultVec{ct, 2} = dCoeff(idx);
            dResultVec{ct, 3} = find(idx);
            ids = dResultVec{ct, 3};

            dFlux = 0;

            dCoefSum = sum(dCoeff);
            for k = 1:length(ids)
                dFlux = dFlux + dCoeff(ids(k))/dCoefSum * sum(sum(squeeze(this.dImgsField(:,:,ids(k)))));
            end
            dDoseFac = dFlux/dFluxCenter;

            dResultVec{ct, 4} = dDoseFac;

            % Compute uniformity:
            dAgg = 0;
            for k = 1:length(ids)
                dAgg = dAgg + dCoeff(ids(k))*this.dImgsField(:,:,dResultVec{ct, 3}(k));
            end

            dUniformity = std(dAgg(:))/median(dAgg(:));
            dResultVec{ct, 5} = dUniformity;


        end
           

        function dResultVec = computePairs(this, D, b, dFluxCenter, dMaxResults)
            dResultVec = {};
            % Loop through choosing pairs of images and find best combination and coefficients:

            ct = 1;
            for k = 1:size(D, 2)
                for m = k+1:size(D, 2)
                    dCombo = [D(:, k), D(:, m)];
                    % Solve for the coefficients using non-negative least squares

                    dCoeff = lsqnonneg(dCombo, b);
                    dError = norm(b - dCombo * dCoeff);
                    
                    dResultVec{ct, 1} = dError;
                    dResultVec{ct, 2} = dCoeff;
                    dResultVec{ct, 3} = [k, m];


                    % Compute relative flux
                    dFluxLeft = sum(sum(squeeze(this.dImgsField(:,:,k))));
                    dFluxRight = sum(sum(squeeze(this.dImgsField(:,:,m))));
                    dDoseFac = (dFluxLeft * dCoeff(1)/(dCoeff(1) + dCoeff(2)) + dFluxRight * dCoeff(2)/(dCoeff(1) + dCoeff(2)))/dFluxCenter;
                    dResultVec{ct, 4} = dDoseFac;

                    % Compute uniformity:
                    dAgg = dCoeff(1)*this.dImgsField(:,:,k) + dCoeff(2)*this.dImgsField(:,:,m);


                    dUniformity = std(dAgg(:))/median(dAgg(:));
                    dResultVec{ct, 5} = dUniformity;
                    
                    ct = ct + 1;
                end
            end

            dResultVec = sortrows(dResultVec, 1);

            % Limit the number of results:
            dResultVec = dResultVec(1:dMaxResults, :);

        end

        function dResultVec = computeTriples(this, D, b, dFluxCenter, dMaxResults)
            dResultVec = {};
            % Loop through choosing pairs of images and find best combination and coefficients:

            ct = 1;
            for k = 1:size(D, 2)
                for m = k+1:size(D, 2)
                    for l = m+1:size(D, 2)
                        dCombo = [D(:, k), D(:, m), D(:, l)];
                        % Solve for the coefficients using non-negative least squares

                        dCoeff = lsqnonneg(dCombo, b);
                        dError = norm(b - dCombo * dCoeff);

                        dResultVec{ct, 1} = dError;
                        dResultVec{ct, 2} = dCoeff;
                        dResultVec{ct, 3} = [k, m, l];

                
                        % Compute relative flux
                        dFluxLeft = sum(sum(squeeze(this.dImgsField(:,:,k))));
                        dFluxRight = sum(sum(squeeze(this.dImgsField(:,:,m))));
                        dDoseFac = (dFluxLeft * dCoeff(1)/(dCoeff(1) + dCoeff(2)) + dFluxRight * dCoeff(2)/(dCoeff(1) + dCoeff(2)))/dFluxCenter;
                        dResultVec{ct, 4} = dDoseFac;

                        % Compute uniformity:
                        dAgg = dCoeff(1)*this.dImgsField(:,:,k) + dCoeff(2)*this.dImgsField(:,:,m);


                        dUniformity = std(dAgg(:))/median(dAgg(:));
                        dResultVec{ct, 5} = dUniformity;
                        
                        ct = ct + 1;
                    end
                end
            end
            dResultVec = sortrows(dResultVec, 1);

            % Limit the number of results:
            dResultVec = dResultVec(1:dMaxResults, :);
        end

        function handleSelectCombo(this, src, evt)

            % Get the selected index:
            dIdx = double(this.uilCombos.getSelectedIndexes());
            if isempty(dIdx)
                dIdx = 2;
            end
            if length(dIdx) > 1
                dIdx = dIdx(end);
            end
            if dIdx < 2
                dIdx = 2;
            end
            this.dResultIdx = dIdx - 1;

            
            dCoefficients   = this.dResultVec{this.dResultIdx, 2};
            dBestIndex      = this.dResultVec{this.dResultIdx, 3};

            % Build CSV string:
            
            % Make sure the lower of the two coefficients is on the left
            % if dCoefficients(1) > dCoefficients(2)
            %     dCoefficients   = flip(dCoefficients);
            %     dBestIndex      = flip(dBestIndex);
            % end

            % % Set the smaller dwell to 25 ms:
            % dDwell1 = this.uieMinDwellTime.get();
            % dDwell2 = dCoefficients(2) * dDwell1 / dCoefficients(1) + this.uieIntrinsicDwellTime.get() * (dCoefficients(2) - dCoefficients(1));

            % dIdx1 = dBestIndex(1) - this.dCenterIdx;
            % dIdx2 = dBestIndex(2) - this.dCenterIdx;

            % cCSV = sprintf('Rx (deg),Ry (deg),Dwell Time(ms) \n ');
            % cCSV = [cCSV, sprintf('%.4f,%.4f,%d\n', ...
            %                 this.uieUnitVectorRx.get() * dIdx1, ...
            %                 this.uieUnitVectorRy.get() * dIdx1, ...
            %                 round(dDwell1))];
            % cCSV = [cCSV, sprintf('%.4f,%.4f,%d', ...
            %                 this.uieUnitVectorRx.get() * dIdx2, ...
            %                 this.uieUnitVectorRy.get() * dIdx2, ...
            %                 round(dDwell2))];
            % % Set csv:
            % this.uieCSV.set(cCSV);
            % this.uieCSV.makeMax();

            % plot combination:
            dAgg = 0;
            for k = 1:length(dBestIndex)
                dAgg = dAgg + dCoefficients(k)*this.dImgsField(:,:,dBestIndex(k));
            end

            dAgg = dAgg / median(dAgg(:));
            dAgg = round(dAgg * 10)/ 10;

            axes(this.haFieldUniformityAgg);

            imagesc(dAgg);
            title('Field Uniformity Aggregate');
            colorbar;

            axes(this.haRecipe);
            dElms = zeros(size(this.dImgsField, 3), 1);

            for k = 1:length(dCoefficients)
                dElms(dBestIndex(k)) = dCoefficients(k);
            end 
            stem(dElms/sum(dElms), 'linewidth', 3);

            
        end

        function onOpenDir(this, src, evt)
            
            cPath = uigetdir('C:\Users\metmatlab\Pictures\MOD3-Uniformity-Cam-Wobble\');
            if cPath == 0
                return;
            end
            this.uiePathToImagesDir.set(cPath);
            this.onLoadImages();
        end


        function onLoadImages(this, src, evt)
            
            cPath = this.uiePathToImagesDir.get();
            if isempty(cPath)
                msgbox('Please set the path to the images directory');
                return;
            end
            
            cPath = fullfile(cPath, '*.bmp');
            cFiles = dir(cPath);
            
            if isempty(cFiles)
                msgbox('No images found in the directory');
                return;
            end
            
            % Load the images
            this.dImgs = zeros( 151, 301, length(cFiles));
            this.dCenterIdx = ceil(length(cFiles)/2);

            % sort files by name:
            % Extract the names into a cell array
            names = {cFiles.name};

            % Convert the names to numerical values
            % Assuming the names are numbers stored as strings
            numValues = cellfun(@(x) str2double(regexp(x, '-?\d+(?=\.bmp)', 'match', 'once')), names);
            
            % Sort the numerical values and get the sorting indices
            [~, sortIdx] = sort(numValues);

            % Reorder the original array of structs
            cFiles = cFiles(sortIdx);

            
            for k = 1:length(cFiles)
                cFile = fullfile(cFiles(k).folder, cFiles(k).name);
                [~, d, ~] = fileparts(cFile);
                if (d == '0')
                    this.dCenterIdx = k;
                end
                this.msg(sprintf('Loading %s', cFile));
                img = medfilt2(sum(double(imread(cFile)), 3));
                this.msg(sprintf('Loaded %s', cFile));

                % Crop image to 150 x 300 px region around center pixel:
                dCenterR = this.uieCenterPixelR.get();
                dCenterC = this.uieCenterPixelC.get();

                % Grab 150 x 300 pixels around the center pixel:
                img = img(dCenterR - this.dImgROIHeight/2:dCenterR + this.dImgROIHeight/2,...
                                     dCenterC - this.dImgROIWidth/2:dCenterC + this.dImgROIWidth/2);

                this.dImgs(:,:,k) = img;
            end
            
            dBack = this.dImgs(:, [1:10, 290:300], :);
            dBack = mean(dBack(:));
            
            for k = 1:length(cFiles)
                this.dImgs(:,:,k) = this.dImgs(:,:,k) - dBack;
               
            end
            this.dImgs(this.dImgs < 0) = 0;

            % Grab inner 200 x 30 pixels of these images, this is assuming that we have 5 um/px
            this.dImgsField = this.dImgs(61:60 + this.dFieldHeightPx, 51:50 + this.dFieldWidthPx, :);
            this.dImgsFieldRound = zeros(size(this.dImgsField));

            % Normalize the field uniformity images:
            for k = 1:size(this.dImgsField, 3)
                
                dImg = this.dImgsField(:,:,k);
                dImg = dImg / median(dImg(:));                
                dImg = round(dImg * 10)/ 10;
                
                % Quantize images in steps of 0.1:
                this.dImgsFieldRound(:,:,k) = dImg;
            end

            this.dActiveIdx = this.dCenterIdx;

           

            this.updatePlots();
            this.onComputeCombo();
        end
        
        function changeIndex(this, increment)
            this.dActiveIdx = this.dActiveIdx + increment;
            if this.dActiveIdx < 1
                this.dActiveIdx = 1;
            end
            if this.dActiveIdx > size(this.dImgs, 3)
                this.dActiveIdx = size(this.dImgs, 3);
            end
            this.updatePlots();

        end

        function updatePlots(this)

            if isempty(this.dImgs)
                return;
            end

            % Update index label:
            this.uitActiveImgText.set(sprintf('%d/%d', this.dActiveIdx, size(this.dImgs, 3)));
            
            % Update the images plot
            axes(this.haImages);
            imagesc(squeeze(this.dImgs(:, :, this.dActiveIdx)));
            title(sprintf('Image %d', this.dActiveIdx));
            hold on
            plot(150, 75, 'rx', 'MarkerSize', 10);
            hold off

            % Update the field uniformity plot
            axes(this.haFieldUniformity);
            imagesc(squeeze(this.dImgsFieldRound(:, :, this.dActiveIdx)));
            title('Field Uniformity');
            colorbar
            
            % Update the x-section plot
            axes(this.haXSec);
            
            xSecs = squeeze(mean((this.dImgs(70:80, :, :)), 1));



            % Plot all of xSecs but plot the active index a thicker line:
            hold off;
            for k = 1:size(xSecs, 2)
                if k == this.dActiveIdx
                    plot(xSecs(:, k), 'LineWidth', 4);
                else
                    plot(xSecs(:, k));
                end
                hold on;
            end
            hold off
            title('X-Section');
            
            
            
           

        end


       
        

        
        
        
    end
    
    
end

