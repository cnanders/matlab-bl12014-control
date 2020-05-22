classdef DCT2Diode < mic.Base
    
    properties
        
        % {mic.ui.device.GetNumber 1x1}
        uiVolts
        uiCurrent % calculated
        uiFluxDensity % calculated
        
        uiPopupSensitivity
        uiPopupAperture
        
        
    end
    
    
    
    properties (Access = protected)
        
        clock
       
        % {function_handle}
        % getter for voltage of data translation channel
        fhGetVolts
        % setter for the sensitivity of a SR570 current preamplifier
        fhSetSensitivity
        
        dSensitivityOfDiode = 0.1 % A/W
        
    end
    
    properties (SetAccess = private)
        
        cName = 'dct2-diode-'
        cTitle = 'Diode Test'
        dHeight = 180
        dWidth = 290
        
        % GetSetNumber config
        dWidthName = 100
        
        d
        
        hPanel
    end
    
    methods
        
        function this = DCT2Diode(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            %{
            if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
            %}
            
            
            if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('clock must be mic.Clock | mic.ui.Clock');
            end
            
            this.init();
        
        end
        
                
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', this.cTitle,...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
            dLeft = 0;
            dTop = 20;
            dSep = 30;
            
            dWidth = 100;
            dHeight = 24;
            
            this.uiPopupSensitivity.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            
            
            
            this.uiVolts.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiCurrent.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            
            
            this.uiPopupAperture.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            this.uiFluxDensity.build(this.hPanel, dLeft, dTop);
            dTop = dTop + dSep;
            
            
            
            
        end
        
        
        
        function delete(this)
   
        end  
        
        function cec = getSaveLoadProps(this)
            cec = {...
                'uiPopupSensitivity', ...
                'uiPopupAperture', ...
                'uiVolts', ...
                'uiCurrent' ...
             };
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
        
    end
    
    
    methods (Access = private)
        
             
        function initUiVolts(this)
            
            this.msg('initUiVolts()');
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-volts.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            ceProps = this.getGetNumberProps();
            this.uiVolts = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                ceProps{:}, ...
                'cName', [this.cName, 'measur-point-volts'], ...
                'config', uiConfig, ...
                'cLabel', 'MeasurPoint', ...
                'fhGet', @() this.fhGetVolts(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true ...
            );
        end
        
        function initUiCurrent(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-current.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            ceProps = this.getGetNumberProps();
            this.uiCurrent = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                ceProps{:}, ...
                'cName', [this.cName, 'current-calc'], ...
                'config', uiConfig, ...
                'cLabel', 'Current (calc)', ...
                'fhGet', @() this.getCurrent(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true ...
            );
        end
        
        function ce = getGetNumberProps(this)
            ce = {...
                'dWidthName', this.dWidthName, ...
                'dWidthUnit', 100, ...
                'lShowLabels', false, ...
                'lShowRange', false, ...
                'lShowStores', false, ...
                'lShowZero', false, ...
                'lShowRel', false, ...
           };
            
        end
        
        function initUiFluxDensity(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-number', ...
                'config-flux-density.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
        
            ceProps = this.getGetNumberProps();
            this.uiFluxDensity = mic.ui.device.GetNumber(...
                'clock', this.clock, ...
                ceProps{:}, ...
                'cName', [this.cName, 'flux-density-calc'], ...
                'config', uiConfig, ...
                'cLabel', 'Flux Density (calc)', ...
                'fhGet', @() this.getFluxDensity(), ...
                'fhIsVirtual', @() false, ...
                'lUseFunctionCallbacks', true ...
            );
        end
        
        % Returns the calculated current in A into the SR570
        % using voltage from data translation and sensitivity from the SR570
        function d = getCurrent(this)
            d = this.uiVolts.getValCal('V') * this.uiPopupSensitivity.get().dVal;
        end
        
        % Returns the flux density on the diode in mj/cm2/s
        function d = getFluxDensity(this)
            dAmps = this.getCurrent();
            dWatts = dAmps / this.dSensitivityOfDiode;
            d = dWatts * 1e3 / this.uiPopupAperture.get().dVal;
        end
            
            
        
        % Returns a cell array of structures. Each structure contains a
        % cLabel and dVal field corresponding to each sensitivity setting
        % of the SR570 in units of A/V
        function ceOptions = getSensitivities(this)
                     
            
            dScales = [1e-12, 1e-9, 1e-6, 1e-3];
            dBases = [1 2 5];
            dOrders = [1 1e1 1e2];
            ceLabels = {...
                'pA/V', ...
                'nA/V', ...
                'uA/V', ...
                'mA/V' ...
            };
            
            ceOptions = cell(1, 30);
            
            u8Level = 0; % the SR570 uses levels 0 - 29 see manual page 10
            
            for m = 1 : length(dScales)
                for l = 1 : length(dOrders)
                    if m == 4 && l > 1
                        continue; % skip  orders 1e1 and 1e2 for the mA scale
                    end
                    for k = 1 : length(dBases)

                        cLabel = sprintf('%1.0f %s', dBases(k) * dOrders(l), ceLabels{m});
                        dVal = dScales(m) * dBases(k) * dOrders(l);
                        
                        stOption = struct( ...
                            'cLabel', cLabel, ...
                            'dVal', dVal, ...
                            'dLevel', u8Level ... 
                        );
                    
                        ceOptions{u8Level + 1} = stOption;
                        u8Level = u8Level + 1;
                    end
                end
            end
                                         
        end 
        
        
        function onChangeSensitivity(this, src, evt)
            % Call out to the hardware
            this.fhSetSensitivity(this.uiPopupSensitivity.get().dLevel);
        end
        
        function initUiSensitivity(this)
            
            
            this.uiPopupSensitivity = mic.ui.common.PopupStruct( ...
                'fhDirectCallback', @this.onChangeSensitivity, ...
                'cField', 'cLabel', ...
                'cLabel', 'SR570 Sensitivity', ...
                'lTwoCol', true, ...
                'dWidthLabel', 175, ...
                'lShowLabel', false, ...
                'ceOptions', this.getSensitivities() ...
            );
        end
        
        function initUiAperture(this)
            
            % Values are area in cm2
            ceOptions = {...
                struct('cLabel', '1 cm', 'dVal', 1), ...
                struct('cLabel', '500 um', 'dVal', 0.002) ...
            };
        
            this.uiPopupAperture = mic.ui.common.PopupStruct( ...
                'lTwoCol', true, ...
                'cLabel', 'Aperture', ...
                'dWidthLabel', 175, ...
                'lShowLabel', false, ...
                'ceOptions', ceOptions ...
            );
        end
        
        
        function init(this)
            
            this.msg('init()');
            this.initUiAperture();
            this.initUiSensitivity();
            this.initUiVolts();
            this.initUiFluxDensity();
            this.initUiCurrent();
            
        end
        
        function onFigureCloseRequest(this, src, evt)
            this.msg('closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
        end
        
        
        
        
    end
    
    
end
