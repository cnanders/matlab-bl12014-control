classdef MDMCurrent < mic.Base
    
    properties
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiCurrent
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 510
                
        hPanel
        
        % {bl12014.Hardware 1x1}
        hardware
        
        dIndexOfBuffer = -1
        
    end
    
    properties (SetAccess = private)
        
        cName = 'mdm-current-'
        dHeight = 100
    end
    
    methods
        
        function this = MDMCurrent(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            
            if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
        
        end
        
    
        
                
        function build(this, hParent, dLeft, dTop)
            
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'MDM',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
            dLeft = 0;
            dTop = 15;
            dSep = 30;
            
          
            this.uiCurrent.build(this.hPanel, dLeft, dTop);
            dTop = dTop + 15 + dSep;
            

            
        end
        
        
       
        
        
        function delete(this)
            
            
            
        end   
        
        function st = save(this)
            st = struct();
            st.uiStageX = this.uiStageX.save();
        end
        
        function load(this, st)
            if isfield(st, 'uiStageY')
                this.uiStageX.load(st.uiStageX)
            end
        end
        
        
    end
    
    methods (Access = private)
        
        
        
         
        function initUiCurrent(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-mdm-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiCurrent = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                'lShowLabels', false, ...
                'dWidthName', 115, ...
                'dWidthPadUnit', 120, ...
                'fhGet', @() this.getCurrent, ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true, ...
                'cName', [this.cName, 'mdm-current'], ...
                'config', uiConfig, ...
                'cLabel', 'Current' ...
            );
        end

        function current = getCurrent(this)
%             current = this.hardware.getDoseMonitor().getCharge(this.hardware.getSR570MDM().getSensitivity());

             if this.dIndexOfBuffer == -1
                [dIndexStart, this.dIndexOfBuffer] = this.hardware.getDataTranslation().getIndiciesOfScanBuffer();
             end
            
            [results, this.dIndexOfBuffer] = this.hardware.getDataTranslation.getScanDataAheadOfIndex(this.dIndexOfBuffer);                
            [dRows, dCols] = size(results);

            if dRows == 0
                current = 0;
                return % no new data
            end



            % HARDWARE HAS A CHANNEL ZERO - SO DUMB
            % CHANNEL 0 ON THE DEVICE IS INDEX 1 OF THE MATLAB LIST
            dValues = [];

            
%             dtTimes(dLength + 1 : dLength + dRows) = datetime(results(:,49), 'ConvertFrom', 'posixtime');
            dValues(1, 1 : dRows) = results(:, 36); % CH 35 on hardware matlab index shifted 1
            dValues(2, 1 : dRows)  = results(:, 37); % ch 36 on hardware 37 is the DMI laser ref
            dValues(3,  1 : dRows) = results(:, 39); % ch 38 on hardware
            dValues(4, 1 : dRows) = results(:, 40); % ch 39 on hardware
            
            current = mean(results(:,40));
                
        end
        
        
        
        function init(this)
            
            this.msg('init');
            
            this.initUiCurrent();
           
        end
        
         
        
    end
    
    
end

