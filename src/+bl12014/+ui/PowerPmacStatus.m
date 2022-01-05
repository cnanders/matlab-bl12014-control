classdef PowerPmacStatus < mic.Base
    
    properties (Access = private)
        
        dWidth = 2350
        dHeight = 840
        
        dTopLabels = 50
        dTopUi = 80;
               
    end
    
    properties
              
        % These are the UI for activating the hardware that gives the 
        % software real data
        
        
        
        % {cell of mic.ui.device.GetLogical m x n}
        uiGetLogicals = {}
        
        % {cell of mic.ui.common.Text 1 x m}
        uiTexts = {}
        
        % {cell of cell 1 x m}
        ceceTypes
        
        cName = 'Power PMAC Status (Updates every sec)'
        hParent
        
        clock
        dWidthName = 135
        lShowDevice = false
        lShowInitButton = false
        
        %{ cell of char 1xm } list of titles of each status category
        cecTitles 
        
        dWidthColSep = 25
        
        
    end
    
    properties (Access = private)
        
        % {bl12014.Hardware 1x1}
        hardware
        
    end
    
    
    methods
        
        function this = PowerPmacStatus(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.ceceTypes = bl12014.device.GetLogicalFromDeltaTauPowerPmac.ceceTypes;
            this.cecTitles = {
                'CS Error', ...
                'CS Status', ...
                'Mtr Error', ...
                'Mtr Stat Moving', ...
                'Mtr Stat Open Loop', ...
                'Mtr Stat Neg Lim', ...
                'Mtr Stat Pos Lim', ...
                'Encoder Error', ...
                'Global Error', ...
                'IO Info', ...
                'MET50 Error' ...
            };
        
        
            if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock | mic.ui.Clock');
            end
            
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            
            this.init();
            
        end
        
        
        function connectDeltaTauPowerPmac(this, comm)

            for m = 1 : length(this.ceceTypes)
                for n = 1 : length(this.ceceTypes{m}) 
                    device = bl12014.device.GetLogicalFromDeltaTauPowerPmac(...
                        comm, ...
                        this.ceceTypes{m}{n}...
                    );
                    this.uiGetLogicals{m}{n}.setDevice(device);
                    this.uiGetLogicals{m}{n}.turnOn();
                    % fprintf('connectCommDeltaTauPowerPmacToUiPowerPmacStatus %s\n', this.ceceTypes{m}{n});
                end
            end
        end
        
        
        function disconnectDeltaTauPowerPmac(this)
            
            % Disconnect uiApp.uiPowerPmacStatus
            for m = 1 : length(this.ceceTypes)
                for n = 1 : length(this.ceceTypes{m}) 
                    this.uiGetLogicals{m}{n}.turnOff();
                    this.uiGetLogicals{m}{n}.setDevice([]);
                end
            end
        end
        
        
        
        
        
        function buildUiGetLogicals(this)
            
            dTopStart = this.dTopUi;
            dTop = dTopStart;
            dLeft = 10;
            dSep = 30;
            
            for m = 1 : length(this.ceceTypes)
                for n = 1 : length(this.ceceTypes{m})
                    this.uiGetLogicals{m}{n}.build(this.hParent, dLeft, dTop);
                    dTop = dTop + dSep;
                end
                
                % Update dLeft (shift to right)
                dLeft = dLeft + this.dWidthName + this.dWidthColSep + 10;
                % Reset dTop
                dTop = dTopStart;
            end
            
        end
        
        function buildUiTexts(this)
            
            dTopStart = this.dTopLabels;
            dTop = dTopStart;
            dLeft = 10;
            
            for m = 1 : length(this.ceceTypes)
                    
                this.uiTexts{m}.build(this.hParent, dLeft, dTop, this.dWidthName, 20);
                % Update dLeft (shift to right)
                dLeft = dLeft + this.dWidthName + this.dWidthColSep + 10;
                
            end
            
        end
        
          
        
        function build(this, hParent, dLeft, dTop)
            
            this.hParent = hParent;
            this.buildUiTexts();
            this.buildUiGetLogicals();
                        
                       
        end
        
        function delete(this)
            
            
            
        end    
        
        
    end
    
    methods (Access = private)
        
                
        function init(this)
            
            this.msg('init()');
            this.initUiGetLogicals(); 
            this.initUiTexts();
            
        end
        
        function initUiTexts(this)
            
            for m = 1 : length(this.cecTitles)
                this.uiTexts{m} = mic.ui.common.Text(...
                    'cVal', this.cecTitles{m}, ...
                    'dFontSize', 12, ...
                    'cFontWeight', 'bold' ...
                );
            end
        end
        
        
        function initUiGetLogicals(this)
            
            this.msg('initGetLogicals()');
            
            u8WordsToSkip = bl12014.device.GetLogicalFromDeltaTauPowerPmac.u8WordsToSkip;
            
            for m = 1 : length(this.ceceTypes)
                for n = 1 : length(this.ceceTypes{m})                    
                    if n == 1
                        % Initialize cell array
                        this.uiGetLogicals{m} = {};
                    end
            
                    lShowLabels = false;                    

                    cPathConfig = fullfile(...
                        bl12014.Utils.pathUiConfig(), ...
                        'get-logical', ...
                        'config-ppmac-status.json' ...
                    );
                    config = mic.config.GetSetLogical(...
                        'cPath', cPathConfig ...
                    );

                    % Make label
                    ceWords = strsplit(this.ceceTypes{m}{n}, '-');
                    cLabel = strjoin(ceWords(u8WordsToSkip(m):end), ' ');
                    
                    % Leverage the logic I build for the original device
                    % to call through hardware
                    
                    device = bl12014.device.GetLogicalDeltaTauPowerPmacFromHardware(...
                        this.hardware, ...
                        this.ceceTypes{m}{n}...
                    );
                
                
                    this.uiGetLogicals{m}{n} = mic.ui.device.GetLogical(...
                       'clock', this.clock, ...
                       'config', config, ...
                       'dWidthName', this.dWidthName, ... 
                       'lShowDevice', this.lShowDevice, ...
                       'lShowLabels', lShowLabels, ...
                       'lShowInitButton', this.lShowInitButton, ...
                       'cAlign', 'right', ...
                       'fhGet', @device.get, ...
                       'fhIsVirtual', @() false, ...
                       'lUseFunctionCallbacks', true, ...
                       'cName', this.ceceTypes{m}{n}, ...
                       'cLabel', cLabel ...
                    );
                end
            end            
        end
        
        
        
    end
    
    
end

