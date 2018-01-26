classdef App < mic.Base
        
    properties (Constant)
       
        dHeight         = 550
        dWidth          = 250
        
        cTcpipHostLC400M142 = '192.168.10.22'
        cTcpipHostLC400MA = '192.168.20.42' % supposed to be .20 but that was not working

        
    end
    
	properties
        
        uiNetworkCommunication
        uiBeamline
        uiShutter
        uiM141
        uiM142
        uiM143
        uiD141
        uiD142
        uiVibrationIsolationSystem
        uiReticle
        uiWafer
        uiPowerPmacStatus
        uiPrescriptionTool           
        uiScan
        uiTempSensors
        uiFocusSensor
        uiLSIControl = {};
        uiLSIAnalyze = {};
        uiScannerM142
        uiScannerMA
        
        % Eventually make private.
        % Exposing for troubleshooting
        clock

        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
         
        dHeightEdit = 24
        dWidthButtonButtonList = 200
        cTitleButtonList = 'UI'
        hFigure
        cDirThis
        cDirSave
        uiButtonList
        
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = App(varargin)
            
            cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSave = fullfile( ...
                cDirThis, ...
                '..', ...
                '..', ...
                'save', ...
                'app' ...
            );
        
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
            
        end
        
          
        function sayHi(this)
            this.msg('Hi!');
        end
        
        function build(this, hParent, dLeft, dTop)
            this.uiButtonList.build(hParent, dLeft, dTop);
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            this.msg('delete');
            
            this.saveStateToDisk();

            
            % Delete the figure
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            % Delete the device UI controls
            delete(this.uiNetworkCommunication)
            delete(this.uiShutter)
            delete(this.uiM141)
            delete(this.uiM142)
            delete(this.uiM143)
            delete(this.uiD141)
            delete(this.uiD142)
            delete(this.uiVibrationIsolationSystem)
            delete(this.uiReticle)
            delete(this.uiWafer)
            delete(this.uiScannerMA)
            delete(this.uiScannerM142)
            delete(this.uiPrescriptionTool)           
            delete(this.uiScan) 
            delete(this.uiTempSensors)
            delete(this.uiFocusSensor)
            
            % Delete the clock
            delete(this.clock);
                       
        end         

    end
    
    methods (Access = private)
        
        function onFemToolSizeChange(this, src, evt)
            
            % evt has a property stData
            %   dX
            %   dY
            
            
            this.msg('onFemToolSizeChange');
            %disp(evt.stData.dX)
            %disp(evt.stData.dY)
            
            this.uiWafer.uiAxes.deleteFemPreviewPrescription();
            this.uiWafer.uiAxes.addFemPreviewPrescription(evt.stData.dX, evt.stData.dY);
        end
        
        function init(this)
            
            this.clock = mic.Clock('Master');
            this.uiNetworkCommunication = bl12014.ui.NetworkCommunication('clock', this.clock);
            this.uiVibrationIsolationSystem = bl12014.ui.VibrationIsolationSystem('clock', this.clock);
            this.uiBeamline = bl12014.ui.Beamline('clock', this.clock);
            this.uiShutter = bl12014.ui.Shutter('clock', this.clock);
            this.uiD141 = bl12014.ui.D141('clock', this.clock);
            this.uiD142 = bl12014.ui.D142('clock', this.clock);
            this.uiM141 = bl12014.ui.M141('clock', this.clock);
            this.uiM142 = bl12014.ui.M142('clock', this.clock);
            this.uiM143 = bl12014.ui.M143('clock', this.clock);
            this.uiReticle = bl12014.ui.Reticle('clock', this.clock);
            this.uiWafer = bl12014.ui.Wafer('clock', this.clock);
            this.uiPowerPmacStatus = bl12014.ui.PowerPmacStatus('clock', this.clock);
            this.uiTempSensors = bl12014.ui.TempSensors('clock', this.clock);
            this.uiFocusSensor = bl12014.ui.FocusSensor('clock', this.clock);
            this.uiScannerM142 = bl12014.ui.Scanner(...
                'clock', this.clock, ...
                'cName', 'M142 Scanner' ...
            );
            this.uiScannerMA = bl12014.ui.Scanner(...
                'clock', this.clock, ...
                'cName', 'MA Scanner' ...
            );
            
            % LSI UIs exist separately.  Check if exists first though
            % because not guaranteed to have this repo:
            try 
            this.uiLSIControl = lsicontrol.ui.LSI_Control('clock', this.clock);
            this.uiLSIAnalyze = lsianalyze.ui.LSI_Analyze();
            catch me
                error(lasterr);
                % Don't have LSIControl installed
            end
            
            %{
            this.uiScannerMA = ScannerControl(...
                'clock', this.clock, ...
                'cDevice', 'MA', ...
                'cLC400TcpipHost', this.cTcpipHostLC400MA ...
            );
            this.uiScannerM142 = ScannerControl(...
                'clock', this.clock, ...
                'cDevice', 'M142', ...
                'dThetaX', 43.862, ... % Tilt about x-axis
                'cLC400TcpipHost', this.cTcpipHostLC400M142 ...
            );
            %}
            this.uiPrescriptionTool = bl12014.ui.PrescriptionTool();
            this.uiScan = bl12014.ui.Scan(...
                'clock', this.clock, ...
                'uiShutter', this.uiShutter, ...
                'uiReticle', this.uiReticle, ...
                'uiWafer', this.uiWafer ...
            );

            addlistener(this.uiPrescriptionTool.uiFemTool, 'eSizeChange', @this.onFemToolSizeChange);
            addlistener(this.uiPrescriptionTool, 'eNew', @this.onPrescriptionToolNew);
            addlistener(this.uiPrescriptionTool, 'eDelete', @this.onPrescriptionToolDelete);
           
            % Cannot directly pass the function handle of the build method
            % of the bl12014.ui.* instances but I found that passing an
            % anonymous function that calls bl12014.ui.*.build() works
            %
            % Does not work: function handle of method of property
            % st.fhOnClick = @this.uiBeamline.build;
            %
            % Does work: anonymous function that calls uiBeamline.build()
            % st.fhOnClick = @() this.uiBeamline.build()
              
            
            stNetworkCommunication = struct(...
                'cLabel',  'Network Status', ...
                'fhOnClick',  @() this.uiNetworkCommunication.build(), ...
                'cTooltip',  'Network Status' ...
            );
        
            stBeamline = struct(...
                'cLabel',  'Beamline', ...
                'fhOnClick',  @() this.uiBeamline.build(), ...
                'cTooltip',  'Beamline' ...
            );
            
            stShutter = struct(...
            'cLabel',  'Shutter', ...
            'fhOnClick',  @() this.uiShutter.build(), ...
            'cTooltip',  'Beamline');
            
            stD141 = struct(...
            'cLabel',  'D141', ...
            'fhOnClick',  @() this.uiD141.build(), ...
            'cTooltip',  'D141');
                        
            stM141 = struct(...
            'cLabel',  'M141', ...
            'fhOnClick',  @() this.uiM141.build(), ...
            'cTooltip',  'Beamline');
        
        
            stD142 = struct(...
            'cLabel',  'D142', ...
            'fhOnClick',  @() this.uiD142.build(), ...
            'cTooltip',  'D142');
            
            stM142 = struct(...
            'cLabel',  'M142', ...
            'fhOnClick',  @() this.uiM142.build(), ...
            'cTooltip',  'Beamline');
            
            stM143 = struct(...
            'cLabel',  'M143', ...
            'fhOnClick',  @() this.uiM143.build(), ...
            'cTooltip',  'Beamline');
        
            stVibrationIsolationSystem = struct(...
            'cLabel',  'Vibration Isolation System', ...
            'fhOnClick',  @() this.uiVibrationIsolationSystem.build(), ...
            'cTooltip',  'Vibration Isolation System');
        
            stReticle = struct(...
            'cLabel',  'Reticle', ...
            'fhOnClick',  @() this.uiReticle.build(), ...
            'cTooltip',  'Beamline');
            
            stWafer = struct(...
            'cLabel',  'Wafer', ...
            'fhOnClick',  @() this.uiWafer.build(), ...
            'cTooltip',  'Beamline');
        
            stPowerPmacStatus = struct(...
                'cLabel',  'Power PMAC Status', ...
                'fhOnClick',  @() this.uiPowerPmacStatus.build(), ...
                'cTooltip',  'Power PMAC Status' ...
            );
            
            stPrescriptionTool = struct(...
            'cLabel',  'Pre Tool', ...
            'fhOnClick',  @()this.uiPrescriptionTool.build(), ...
            'cTooltip',  'Beamline');
        
            stTempSensors = struct( ...
                'cLabel',  'Temp Sensors', ...
                'fhOnClick',  @()this.uiTempSensors.build(), ...
                'cTooltip',  'Temp Sensors (Mod3, POB)' ...
            );
                        
            stScannerMA = struct(...
            'cLabel',  'MA Scanner', ...
            'fhOnClick',  @() this.uiScannerMA.build(), ...
            'cTooltip',  'Beamline');
            
            stScannerM142 = struct(...
            'cLabel',  'M142 Scanner', ...
            'fhOnClick',  @() this.uiScannerM142.build(), ...
            'cTooltip',  'Beamline');
            
            
            stExptControl = struct(...
            'cLabel',  'Expt. Control', ...
            'fhOnClick',  @() this.uiScan.build(), ...
            'cTooltip',  'Beamline');
        
            stFocusSensor = struct(...
                'cLabel',  'Focus Sensor', ...
                'fhOnClick',  @() this.uiFocusSensor.build(), ...
                'cTooltip',  'Focus Sensor'...
            );
            
            stLSIControl =  struct(...
                'cLabel',  'LSI Control', ...
                'fhOnClick',  @() this.uiLSIControl.build(), ...
                'cTooltip',  'LSI Control'...
            );
        
            stLSIAnalyze =  struct(...
                'cLabel',  'LSI Analysis GUI', ...
                'fhOnClick',  @() this.uiLSIAnalyze.build(0, -200), ...
                'cTooltip',  'LSI Analysis GUI'...
            );
        
            % stFieldScanner, ...

            stButtons = [
              stNetworkCommunication, ...
              stBeamline, ...
              stM141, ...
              stD141, ...
              stM142, ...
              stScannerM142, ...
              stD142, ...
              stM143, ...
              stVibrationIsolationSystem, ...
              stScannerMA, ...
              stReticle, ...
              stWafer, ...
              stPowerPmacStatus, ...
              stPrescriptionTool, ...
              stExptControl, ...
              stTempSensors, ...
              stFocusSensor, ...
              stLSIControl, ...
              stLSIAnalyze
           ];
            
            this.uiButtonList = mic.ui.common.ButtonList(...
                'stButtonDefinitions', stButtons, ...
                'cTitle', this.cTitleButtonList, ...
                'dWidthButton', this.dWidthButtonButtonList ...
            );
        
            this.loadStateFromDisk();

        end
        
        
        function onCloseRequestFcn(this, src, evt)
            this.msg('closeRequestFcn()');
            % purge;
            delete(this.hFigure);
            % this.saveState();
        end
            
        function onPrescriptionToolNew(this, src, evt)
            this.uiScan.refreshPrescriptions();
        end
        
        function onPrescriptionToolDelete(this, src, evt)
            this.uiScan.refreshPrescriptions();
        end
        
        function onPupilFillNew(this, src, evt)
            % uil property is private, so I exposed a public method
            this.uiPrescriptionTool.pupilFillSelect.refreshList();
        end
        
        function onPupilFillDelete(this, src, evt)
            % uil property is private, so I exposed a public method
            this.uiPrescriptionTool.pupilFillSelect.refreshList();
        end
        
        
        function st = save(this)
             st = struct();
             st.uiPrescriptionTool = this.uiPrescriptionTool.save();
             st.uiScannerMA = this.uiScannerMA.save();
             st.uiScannerM142 = this.uiScannerM142.save();
             st.uiScan = this.uiScan.save();
        end
        
        function load(this, st)
                        
            if isfield(st, 'uiPrescriptionTool') 
                this.uiPrescriptionTool.load(st.uiPrescriptionTool);
            end
            
            if isfield(st, 'uiScannerMA')
                this.uiScannerMA.load(st.uiScannerMA);
            end
            if isfield(st, 'uiScannerM142')
                this.uiScannerM142.load(st.uiScannerM142);
            end
            
            if isfield(st, 'uiScan')
                this.uiScan.load(st.uiScan)
            end
        end
        
        function saveStateToDisk(this)
            st = this.save();
            save(this.file(), 'st');
        end
        
        function loadStateFromDisk(this)
            if exist(this.file(), 'file') == 2
                this.msg('loadStateFromDisk()');
                load(this.file()); % populates variable st in local workspace
                this.load(st);
            end
        end
        
        function c = file(this)
            mic.Utils.checkDir(this.cDirSave);
            c = fullfile(...
                this.cDirSave, ...
                ['saved-state', '.mat']...
            );
        end
        
    end % private
    
    
end