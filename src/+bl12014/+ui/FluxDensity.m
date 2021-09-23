classdef FluxDensity < mic.Base
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        uiEditMeasured
        uiEditOverfill
        uiEditReflectivityClear
        uiEditReflectivityField
        uiEditTransmissionDiode
        
        uiCheckboxCorrectForALS
        
        uiEditCharge
        uiEditDose
        uiSequenceCalibrate
        
        uiTextMult
        uiTextDivide
        uiTextInfo
        uiTextALSCorrection
        
        dWidth = 380
        dHeight = 165
        
        cName = 'flux-density-calculator'

       
        
    end
    
    properties (Access = private)
        hPanel
        
         % must pass these in
        uiClock
        clock
        hardware
        uiTuneFluxDensity
        uiShutter
        
    end
    
    methods
        function this = FluxDensity(varargin)
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
             
             if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
             end
            
              if ~isa(this.clock, 'mic.Clock') && ~isa(this.clock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
            
            if ~isa(this.uiTuneFluxDensity, 'bl12014.ui.TuneFluxDensity')
                error('uiTuneFluxDensity must be bl12014.ui.TuneFluxDensity');
            end
            
             if ~isa(this.uiShutter, 'bl12014.ui.Shutter')
                error('uiShutter must be bl12014.ui.Shutter');
            end
            
            
                        
            this.init();
        end
        
        function setMeasured(this, dVal)
           
            this.uiEditMeasured.set(dVal);
            
        end
        
        % returns {double 1x1} mJ/cm2/s with all corrections added
        function d = get(this)
            
            d = this.uiEditMeasured.get() ...
                * this.uiEditOverfill.get() ...
                / this.uiEditReflectivityClear.get() ...
                * this.uiEditReflectivityField.get() ...
                / this.uiEditTransmissionDiode.get();
            
            
            if this.uiCheckboxCorrectForALS.get()
                
                dCurrentOfALSNow = this.hardware.getDCTCorbaProxy().SCA_getBeamCurrent(); % mA
                %dCurrentOfALSNow = this.hardware.getALS().getCurrentOfRing();
                
                dALSRatio =  dCurrentOfALSNow / this.uiTuneFluxDensity.getCurrentOfALSCalibrated();
                d = d * dALSRatio;
             end
            
        end
        
         function onClock(this, ~, ~)
           
            this.updateTitle()
            this.updateTextInfo()
            this.updateTextALSCorrected()
        
         end 
        
         function updateTextALSCorrected(this)
             
            dCurrentOfALSNow = this.hardware.getDCTCorbaProxy().SCA_getBeamCurrent(); % mA
            cVal = sprintf('%1.1f mA now vs. %1.1f mA @cal', ...
                dCurrentOfALSNow, ...
                this.uiTuneFluxDensity.getCurrentOfALSCalibrated() ...
            );
            this.uiTextALSCorrection.set(cVal);
         end
         
        
        function build(this, hParent, dLeft, dTop)
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Flux Density Corrected',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop ...
                this.dWidth ...
                this.dHeight], hParent) ...
            );
        
            dTop = 20;
            dLeft = 10;
            dWidthEdit = 55;
            dWidthText = 20;
            dPad = 10;
            dTopText = 20 + 15;
            
            this.uiEditMeasured.build(this.hPanel, dLeft, dTop, dWidthEdit, 24);
            dLeft = dLeft + dWidthEdit;
            
            this.uiTextMult.build(this.hPanel, dLeft, dTopText, dWidthText, 24);
            dLeft = dLeft + dWidthText;
            
            this.uiEditOverfill.build(this.hPanel, dLeft, dTop, dWidthEdit, 24);
            dLeft = dLeft + dWidthEdit ;
            
            this.uiTextDivide.build(this.hPanel, dLeft, dTopText, dWidthText, 24);
            dLeft = dLeft + dWidthText;
            
            this.uiEditReflectivityClear.build(this.hPanel, dLeft, dTop, dWidthEdit, 24);
            dLeft = dLeft + dWidthEdit;
            
            this.uiTextMult.build(this.hPanel, dLeft, dTopText, dWidthText, 24);
            dLeft = dLeft + dWidthText;
            
            this.uiEditReflectivityField.build(this.hPanel, dLeft, dTop, dWidthEdit, 24);
            dLeft = dLeft + dWidthEdit;
            
            this.uiTextDivide.build(this.hPanel, dLeft, dTopText, dWidthText, 24);
            dLeft = dLeft + dWidthText;
            
            this.uiEditTransmissionDiode.build(this.hPanel, dLeft, dTop, dWidthEdit, 24);

            dLeft = 10;
            dTop = dTop + 45;
            
            this.uiCheckboxCorrectForALS.build(this.hPanel, dLeft, dTop, 200, 24);
            this.uiTextALSCorrection.build(this.hPanel, dLeft + 110, dTop + 4, 250, 24);
            dTop = dTop + 20;
            
            
            this.uiTextInfo.build(this.hPanel, dLeft, dTop, 300, 24);
            
            dTop = dTop + 20;
            dWidthEdit=120;
            dWidthSep = 10;
            this.uiEditCharge.build(this.hPanel, dLeft, dTop, dWidthEdit, 24);
            dLeft = dLeft + dWidthEdit + dWidthSep;
            this.uiEditDose.build(this.hPanel, dLeft, dTop, dWidthEdit, 24);            
                        dLeft = dLeft + dWidthEdit + dWidthSep;
            this.uiSequenceCalibrate.build(this.hPanel, dLeft, dTop + 13, 100);
                        dLeft = 0;

            this.uiClock.add(@this.onClock, this.id(), 1);

        end
        
        function updateTitle(this)
            if isempty(this.hPanel)
                return
            end
            
            cVal = sprintf('Flux Density Calc. (%1.1f mJ/cm2/s on %s @ %1.1f ALSmA)', ...
                this.uiTuneFluxDensity.getFluxDensityCalibrated(), ...
                this.uiTuneFluxDensity.getTimeCalibrated(), ...
                this.uiTuneFluxDensity.getCurrentOfALSCalibrated() ...
            );
            
            set(this.hPanel, 'Title', cVal);
        end
        
        function updateTextInfo(this)
            cVal = sprintf('Output used by FEM: %1.2f mJ/cm2/s', this.get());
            this.uiTextInfo.set(cVal);
        end
        
        function onChange(this, src, evt)
            this.onClock(src, evt);
        end
        
        function adjustFluxDensity(this)
            
            % dT = time shutter is opened for charge accumulation
            % dC = measured charge fom exposure of dT seconds
            % dC2 = charge from UI
            % dT2 = time to get to charge dC2
            % dD = dose from UI
            % dF = flux density (the thing we will programmatically set)

            
             dT = 3; % s
             dC = this.hardware.getDoseMonitor().getCharge(this.hardware.getSR570MDM().getSensitivity());
             
             % convert measured charge into millions of electrons since
             % that is what the UI is
             dC = dC / 1e6;
             
             dC2 = this.uiEditCharge.get();
             dD = this.uiEditDose.get(); 
             
             % Two equations, two unknowns
             % Can define a "photocurrent" in units of electrons/s
             % I = dC/dT (electrons/sec measured)
             % Number of seconds to accumulate dC2 electrons =
             % dT2 = dC2 / I 
             % Dose delivered in dT2 seconds using current flux density
             % dF * dT2
             % 2) dT2 * dF = dD
             % Solve for dF
             % time to get to the charge from the UI
             
                          
             % then we want dT2 * time dF to be equal to dD
             
             dF = dD * dC / (dC2 * dT);
             this.uiEditMeasured.set(dF);
            
            
        end
        
        
        function task = getSequenceCalibrate(this)
            
            
            % Create a task to trigger the shutter
            
            fhExecute = @() ...
                mic.Utils.evalAll(...
                    @() this.uiShutter.uiShutter.setDestCal(...
                        3 * 1e3, ...
                        'ms' ...
                    ), ...
                    @() this.uiShutter.uiShutter.moveToDest() ...
                );
            
            
        
            
            task1 = mic.Task(...
                'fhExecute', fhExecute, ...
                'fhAbort', @() [], ...
                'fhIsExecuting', @() false, ...
                'fhIsDone', @() this.uiShutter.uiShutter.isReady(), ...
                'fhGetMessage', @() 'Open shutter 3s' ... 
            );
            
            task2 = mic.Task(...
                'fhExecute', @() this.adjustFluxDensity, ...
                'fhGetMessage', @() 'Adjusting flux density' ...
            );
        
        ceTasks = {...
            task1, ...
            task2
       };
        
   task = mic.TaskSequence(...
                'cName', 'flux-density-mdm-adjust', ...
                'clock', this.clock, ...
                'ceTasks', ceTasks, ...
                'dPeriod', 0.5, ...
                'fhGetMessage', @() 'Calibrate' ...
            );
                

                        
        end
        
        
        function init(this)
            
            this.uiEditCharge = mic.ui.common.Edit(...
                'cType', 'd', ...
                'cLabel', 'MDM (Melectrons)' ...
            );
        
            this.uiEditDose    = mic.ui.common.Edit(...
                'cType', 'd', ...
                'cLabel', 'Dose (mJ/cm2)' ...
            );
        
            this.uiSequenceCalibrate = mic.ui.TaskSequence(...
                'cName', [this.cName, 'ui-sequence-calibrate'], ...
                'task', this.getSequenceCalibrate(), ...
                'lShowIsDone', false, ...
                'clock', this.uiClock ...
            );
       
            this.uiEditMeasured = mic.ui.common.Edit(...
                'fhDirectCallback', @this.onChange, ...
                'cType', 'd', ...
                'cLabel', 'Measured' ...
            );
            this.uiEditOverfill = mic.ui.common.Edit(...
                'fhDirectCallback', @this.onChange, ...
                'cType', 'd', ...
                'xMax', 1, ...
                'xMin', 0, ...
                'cLabel', 'Overfill' ...
            );
            this.uiEditReflectivityClear = mic.ui.common.Edit(...
                'fhDirectCallback', @this.onChange, ...
                'cType', 'd', ...
                'xMax', 1, ...
                'xMin', 0, ...
                'cLabel', 'Refl. Clear' ...
            );
        
            this.uiEditReflectivityField = mic.ui.common.Edit(...
                 'fhDirectCallback', @this.onChange, ...
                 'cType', 'd', ...
                'xMax', 1, ...
                'xMin', 0, ...
                'cLabel', 'Refl. Field' ...
            );
            
            this.uiEditTransmissionDiode = mic.ui.common.Edit(...
                 'fhDirectCallback', @this.onChange, ...
                 'cType', 'd', ...
                'xMax', 1, ...
                'xMin', 0, ...
                'cLabel', 'Diode Factor' ...
            );
        
        
            this.uiCheckboxCorrectForALS = mic.ui.common.Checkbox(...
                'cLabel', 'Correct for ALS', ...
                'fhDirectCallback', @this.onChange ...
            );
           
            this.uiTextMult = mic.ui.common.Text('cVal', 'x', 'cAlign', 'center');
            this.uiTextDivide = mic.ui.common.Text('cVal', '/', 'cAlign', 'center');
            this.uiTextInfo = mic.ui.common.Text('cVal', 'Pending ...', 'cFontWeight', 'bold');
            this.uiTextALSCorrection = mic.ui.common.Text('cVal', 'xxx mA now vs. xxx mA @cal');

            this.uiEditMeasured.set(23.4);
            this.uiEditOverfill.set(1);
            this.uiEditReflectivityClear.set(1);
            this.uiEditReflectivityField.set(1);
            this.uiEditTransmissionDiode.set(1);
            


        end
        
        function cec = getSaveLoadProps(this)
           
            cec = {...
                'uiEditMeasured', ...
                'uiEditOverfill', ...
                'uiEditReflectivityClear', ...
                'uiEditReflectivityField', ...
                'uiEditTransmissionDiode', ...
                'uiCheckboxCorrectForALS', ...
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
end

