classdef ReticleFiducializedMove < mic.Base
    
    properties
        
        uiRow
        uiCol
        
    end
    
    
    properties (SetAccess = private)
        
        dWidth = 960
        dHeight = 170
        
        cName = 'Reticle-fiducialized-move'
        
        lShowRange = true
        lShowStores = false
        
        uiPositionRecaller
        
        % Holds fiducial information in struct
        stFiducials
        
        % Labels for fiducial sets
        uitFid1 
        uitFid2 
        
        % Edit boxes for [R,C]
        uieR1
        uieC1
        uieR2
        uieC2

        uieOffsetX
        uieOffsetY
        
        % Change of basis matrix, [r;c] -> [x;y]
        T = []
        fhRC2XY = @(x) x
        fhXY2RC = @(x) x
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiX
        
        % {mic.ui.device.GetSetNumber 1x1}
        uiY
        
        uibSetFid1
        
        
        
        uibSetFid2
        
        cFidStore     = ...
            fullfile(fileparts(mfilename('fullpath')),...
            '..', '..',  'config', 'fiducial-config', 'fiducials.json');
        
    end
    
    properties (Access = private)
        
        clock
        uitgMain
        hPanel
        dWidthName = 50
        dWidthRange = 80;
        
        dCellLength = 2.5
    
        % {bl12014.Hardware 1x1}
        hardware

    end
    
    methods
        
        function this = ReticleFiducializedMove(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock | mic.ui.Clock');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            if ~isa(this.uiX, 'mic.ui.device.GetSetNumber')
                error('uiX must be mic.ui.GetSetNumber');
            end
            
            if ~isa(this.uiY, 'mic.ui.device.GetSetNumber')
                error('uiY must be mic.ui.GetSetNumber');
            end
            
            
            this.init();
        
        end
        
        
        function turnOn(this)
            
            this.uiRow.turnOn();
            this.uiCol.turnOn();
            
        end
        
        function turnOff(this)
            this.uiRow.turnOff();
            this.uiCol.turnOff();
            
        end
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Reticle Fiducialized Move',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
			drawnow;            

            dTop = 50;
            dLeft = 10;
            dSep = 24;
            
            this.uitgMain.build(this.hPanel, 10, 20, 570, 130);
            
            uitMove = this.uitgMain.getTabByName('Fiducialized Move');
            uitSet = this.uitgMain.getTabByName('Set Fiducials');
            
            this.uiRow.build(uitMove, dLeft, dTop);
            
            dTop = dTop + 10;
            this.uiCol.build(uitMove, dLeft, dTop);
            dTop = dTop + dSep;
            
           
            dLeft = 590;
            dTop = 15;
            dWidth = 360;
            this.uiPositionRecaller.build(this.hPanel, dLeft, dTop, dWidth, 145);
            
            dTop = 5;
            dLeft = 10;
            dSep = 24;
            
            this.uieR1.build(uitSet, dLeft, dTop, 40, 25);
            this.uieC1.build(uitSet, dLeft + 60, dTop, 40, 25);
            this.uieOffsetX.build(uitSet, dLeft + 120, dTop, 50, 25);
            % this.uibSetFid1.build(uitSet, dLeft + 120, dTop + 10, 100, 30);
            this.uitFid1.build(uitSet, dLeft + 240, dTop + 15, 250, 30);
            
            dTop = dTop + 40;
            
            this.uieR2.build(uitSet, dLeft, dTop, 40, 25);
            this.uieC2.build(uitSet, dLeft + 60, dTop, 40, 25);
            this.uieOffsetY.build(uitSet, dLeft + 120, dTop, 50, 25);
            % this.uibSetFid2.build(uitSet, dLeft + 120, dTop + 10, 100, 30);
            this.uitFid2.build(uitSet, dLeft + 240, dTop + 15, 250, 30);
            
           
            

            
        end
        
        function delete(this)
            
            this.msg('delete');
            
            this.uiRow =  [];
            this.uiCol = [];
                        
            % Delete the figure
            
            if ishandle(this.hPanel)
                delete(this.hPanel);
            end
            
            
        end  
        
        
        function st = save(this)
            st = struct();
            st.uiX = this.uiRow.save();
            st.uiY = this.uiCol.save();

            st.uieOffsetX = this.uieOffsetX.save();
            st.uieOffsetY = this.uieOffsetY.save();
        end
        
        function load(this, st)
            if isfield(st, 'uiRow')
                this.uiRow.load(st.uiRow)
            end
            
            if isfield(st, 'uiCol')
                this.uiCol.load(st.uiCol)
            end

            if isfield(st, 'uieOffsetX')
                this.uieOffsetX.load(st.uieOffsetX)
            else
                this.uieOffsetX.set(0)
            end

            if isfield(st, 'uieOffsetY')
                this.uieOffsetY.load(st.uieOffsetY)
            else 
                this.uieOffsetY.set(0)
            end
            
         
        end
        
        
        
        function makeFiducializedMove(this)
            
            dTargetR = this.uiRow.getDestRaw();
            dTargetC = this.uiCol.getDestRaw();
            
            
            dTargetXY = this.fhRC2XY([dTargetR; dTargetC]);
            dTargetXY = dTargetXY + [this.uieOffsetX.get(); this.uieOffsetY.get()];

            
            % this.hardware.getDeltaTauPowerPmac().setXReticleCoarse(dTargetXY(1));
            % this.hardware.getDeltaTauPowerPmac().setYReticleCoarse(dTargetXY(2));
            this.uiX.setDestCalAndGo(dTargetXY(1), 'mm');
            this.uiY.setDestCalAndGo(dTargetXY(2), 'mm');
            
        
        end

        function setFiducial(this, idx, dX, dY, dR, dC)
            if nargin < 4
                dX = this.hardware.getDeltaTauPowerPmac().getXReticleCoarse();
                dY = this.hardware.getDeltaTauPowerPmac().getYReticleCoarse();
            end
            
            
            switch idx
                case 1
                    if nargin < 6
                        dR = this.uieR1.get();
                        dC = this.uieC1.get();
                    end
                    this.stFiducials.fid1.R = dR;
                    this.stFiducials.fid1.C = dC;
                    this.stFiducials.fid1.X = dX;
                    this.stFiducials.fid1.Y = dY;
                case 2
                    if nargin < 6
                        dR = this.uieR2.get();
                        dC = this.uieC2.get();
                    end
                    this.stFiducials.fid2.R = dR;
                    this.stFiducials.fid2.C = dC;
                    this.stFiducials.fid2.X = dX;
                    this.stFiducials.fid2.Y = dY;
            end
            
            this.syncFiducialsFromStruct(true);
            
        end
        
        
    end
    
    methods (Access = private)
        
        
        function dVal = getFiducializedCoordinates(this, idx)
            
            dX = this.hardware.getDeltaTauPowerPmac().getXReticleCoarse();
            dY = this.hardware.getDeltaTauPowerPmac().getYReticleCoarse();
            
            dX = this.uiX.getValCal('mm');
            dY = this.uiY.getValCal('mm');
            
            dRC =  this.fhXY2RC([dX; dY]);
            dVal = dRC(idx);
            
        end
        
        
        
        
         
        function initUiRow(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-reticle-coarse-stage-fid-row.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiRow = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'dWidthName', this.dWidthName, ...
                'dWidthRange', this.dWidthRange, ...
                'cName', 'reticle-coarse-stage-fid-row', ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'fhGet', @() this.getFiducializedCoordinates(1), ...
                'fhSet', @(dVal) this.makeFiducializedMove(), ...
                'fhIsReady', @() ~this.hardware.getDeltaTauPowerPmac().getIsStartedReticleCoarseXYZTipTilt(), ...
                'fhStop', @() this.hardware.getDeltaTauPowerPmac().stopAll(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Fid Row' ...
            );
        end
        
        function initUiCol(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-reticle-coarse-stage-fid-col.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCol = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', this.dWidthName, ...
                'dWidthRange', this.dWidthRange, ...
                'cName', 'reticle-coarse-stage-fid-col', ...
                'config', uiConfig, ...
                'lShowRange', this.lShowRange, ...
                'lShowStores', this.lShowStores, ...
                'fhGet', @() this.getFiducializedCoordinates(2), ...
                'fhSet', @(dVal) this.makeFiducializedMove(), ...
                'fhIsReady', @() ~this.hardware.getDeltaTauPowerPmac().getIsStartedReticleCoarseXYZTipTilt(), ...
                'fhStop', @() this.hardware.getDeltaTauPowerPmac().stopAll(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cLabel', 'Fid Col' ...
            );
        end
        
        
        function initUiPositionRecaller(this)
            
            cDirThis = fileparts(mfilename('fullpath'));
            cPath = fullfile(cDirThis, '..', '..', 'config', 'position-recaller');
            this.uiPositionRecaller = mic.ui.common.PositionRecaller(...
                'cConfigPath', cPath, ... 
                'cName', [this.cName, '-position-recaller'], ...
                'cTitleOfPanel', 'Position Stores', ...
                'lShowLabelOfList', false, ...
                'hGetCallback', @this.onUiPositionRecallerGet, ...
                'hSetCallback', @this.onUiPositionRecallerSet ...  
            );
        end
        
        % Syncs fiducial text and writes file
        function syncFiducialsFromStruct(this, bWriteFile)
             this.uitFid1.set(sprintf('[%g, %g] set to position [%0.3f, %0.3f]', ...
                 this.stFiducials.fid1.R, this.stFiducials.fid1.C, this.stFiducials.fid1.X, this.stFiducials.fid1.Y ));
             this.uitFid2.set(sprintf('[%g, %g] set to position [%0.3f, %0.3f]', ...
                 this.stFiducials.fid2.R, this.stFiducials.fid2.C, this.stFiducials.fid2.X, this.stFiducials.fid2.Y ));
            
             this.uieR1.set(this.stFiducials.fid1.R);
             this.uieC1.set(this.stFiducials.fid1.C);
             this.uieR2.set(this.stFiducials.fid2.R);
             this.uieC2.set(this.stFiducials.fid2.C);
             
             if bWriteFile
                 fid = fopen(this.cFidStore, 'w');
                 fwrite(fid, jsonencode(this.stFiducials));
                 fclose(fid);
             end
             
            dFidR1 = this.stFiducials.fid1.R;
            dFidR2 = this.stFiducials.fid2.R;
            dFidC1 = this.stFiducials.fid1.C;
            dFidC2 = this.stFiducials.fid2.C;
            dFidX1 = this.stFiducials.fid1.X;
            dFidX2 = this.stFiducials.fid2.X;
            dFidY1 = this.stFiducials.fid1.Y;
            dFidY2 = this.stFiducials.fid2.Y;
            
            % Generate basis vectors (fake since we only have 2 points)
            % assume fixed cell size (basis vector length)
            
            % rc vector:
            vXY = [dFidY2 - dFidY1; dFidX2 - dFidX1];
            vRC = [dFidR1 - dFidR2; dFidC2 - dFidC1] * this.dCellLength;
            
            dAng = -acos(vXY'*vRC/sqrt((vXY'*vXY)*(vRC'*vRC)));
            

            mag = @(x) sqrt(x'*x);
            
            this.T = [[-sin(dAng); -cos(dAng)],[cos(dAng); -sin(dAng)]] * this.dCellLength * mag(vXY)/mag(vRC);
                
            this.fhRC2XY = @(rc) this.T * (rc - [dFidR1; dFidC1]) + [dFidX1; dFidY1] ;
            this.fhXY2RC = @(xy) ((this.T) \ (xy - [dFidX1; dFidY1])) + [dFidR1; dFidC1]; 
             
        end
        
        function init(this)   
            
            this.uitFid1 = mic.ui.common.Text();
            this.uitFid2 = mic.ui.common.Text();
            
            this.uieR1 = mic.ui.common.Edit('cLabel', 'Fid 1 R', 'cType', 'd');
            this.uieC1 = mic.ui.common.Edit('cLabel', 'Fid 1 C', 'cType', 'd');
            this.uieR2 = mic.ui.common.Edit('cLabel', 'Fid 2 R', 'cType', 'd');
            this.uieC2 = mic.ui.common.Edit('cLabel', 'Fid 2 C', 'cType', 'd');

            this.uieOffsetX = mic.ui.common.Edit('cLabel', 'Offset X', 'cType', 'd');
            this.uieOffsetY = mic.ui.common.Edit('cLabel', 'Offset Y', 'cType', 'd');

            
            
            
            % init fiducial config:
            
            fid = fopen(this.cFidStore, 'r');
            if (fid ~= -1)
                cTxt = fread(fid, inf, 'uint8=>char');
                this.stFiducials = jsondecode(cTxt');
                fclose(fid);
            else
                
                error('Could not find reticle fiducial config');
            end
            this.syncFiducialsFromStruct(false);
            
            
            this.msg('init()');
            this.initUiRow();
            this.initUiCol();
            this.initUiPositionRecaller();
            
            this.uitgMain = mic.ui.common.Tabgroup('ceTabNames', {'Fiducialized Move', 'Set Fiducials'});
            
           
            
           
            
            this.uibSetFid1 = mic.ui.common.Button('cText', 'Set Fid 1' , 'fhDirectCallback', @(src,evt) this.setFiducial(1));
            this.uibSetFid2 = mic.ui.common.Button('cText', 'Set Fid 2' , 'fhDirectCallback', @(src,evt) this.setFiducial(2));
           
            
            
        end
        
        
        
        % Return list of values from your app
        function dValues = onUiPositionRecallerGet(this)
            dValues = [...
                this.uiRow.getValRaw(), ...
                this.uiCol.getValRaw() ...
            ];
        end
        
        % Set recalled values into your app
        function onUiPositionRecallerSet(this, dValues)
            
             % Update the UI destinations
            
            this.uiRow.setDestRaw(dValues(1));
            this.uiCol.setDestRaw(dValues(2));
            
            this.makeFiducializedMove();

            
        end
        
        
        
    end
    
    
end

