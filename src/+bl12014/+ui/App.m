classdef App < mic.Base
        
    properties (Constant)
       
        dHeight         = 550
        dWidth          = 140
        
        
    end
	properties
        
        uiBeamline
        uiShutter
        uiM141
        uiM142
        uiM143
        uiD141
        uiD142
        uiReticle
        uiWafer
        uiPupilControl
        uiFieldControl
        uiPrescriptionTool           
        uiScan
        uiTempSensors
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
         
        dHeightEdit = 24
        dWidthButtonButtonList = 100
        cTitleButtonList = 'UI'
        clock
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
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
            
        end
        
          
        function sayHi(this)
            this.msg('Hi!');
        end
        
        function build(this, hParent, dLeft, dTop)
            this.uiButtonList.build(hParent, dLeft, dTop)
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
            delete(this.uiShutter)
            delete(this.uiM141)
            delete(this.uiM142)
            delete(this.uiM143)
            delete(this.uiD141)
            delete(this.uiD142)
            delete(this.uiReticle)
            delete(this.uiWafer)
            delete(this.uiPupilControl)
            delete(this.uiFieldControl)
            delete(this.uiPrescriptionTool)           
            delete(this.uiScan) 
            delete(this.uiTempSensors)
            
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
            this.uiBeamline = bl12014.ui.Beamline('clock', this.clock);
            this.uiShutter = bl12014.ui.Shutter('clock', this.clock);
            this.uiD141 = bl12014.ui.D141('clock', this.clock);
            this.uiD142 = bl12014.ui.D142('clock', this.clock);
            this.uiM141 = bl12014.ui.M141('clock', this.clock);
            this.uiM142 = bl12014.ui.M142('clock', this.clock);
            this.uiM143 = bl12014.ui.M143('clock', this.clock);
            this.uiReticle = bl12014.ui.Reticle('clock', this.clock);
            this.uiWafer = bl12014.ui.Wafer('clock', this.clock);
            this.uiTempSensors = bl12014.ui.TempSensors('clock', this.clock);
            % this.uiPupilControl = ScannerControl(this.clock, 'pupil');
            % this.uiFieldControl = ScannerControl(this.clock, 'field');
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
        
            stReticle = struct(...
            'cLabel',  'Reticle', ...
            'fhOnClick',  @() this.uiReticle.build(), ...
            'cTooltip',  'Beamline');
            
            stWafer = struct(...
            'cLabel',  'Wafer', ...
            'fhOnClick',  @() this.uiWafer.build(), ...
            'cTooltip',  'Beamline');
            
            stPrescriptionTool = struct(...
            'cLabel',  'Pre Tool', ...
            'fhOnClick',  @()this.uiPrescriptionTool.build(), ...
            'cTooltip',  'Beamline');
        
            stTempSensors = struct( ...
                'cLabel',  'Temp Sensors', ...
                'fhOnClick',  @()this.uiTempSensors.build(), ...
                'cTooltip',  'Temp Sensors (Mod3, POB)' ...
            );
            
        
            %{
            stPupilScanner = struct(...
            'cLabel',  'Pupil Scanner', ...
            'fhOnClick',  @() this.uiPupilScanner.build(), ...
            'cTooltip',  'Beamline');
            
            stFieldScanner = struct(...
            'cLabel',  'Field Scanner', ...
            'fhOnClick',  @() this.uiFieldScanner.build(), ...
            'cTooltip',  'Beamline');
            %}
            
            stExptControl = struct(...
            'cLabel',  'Expt. Control', ...
            'fhOnClick',  @() this.uiScan.build(), ...
            'cTooltip',  'Beamline');
            
        
            % stFieldScanner, ...

            stButtons = [
              stBeamline, ...
              stD141, ...
              stM141, ...
              stD142, ...
              stM142, ...
              stM143, ...
              stReticle, ...
              stWafer, ...
              stPrescriptionTool, ...
              stExptControl, ...
              stTempSensors ...
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
             st.uiScan = this.uiScan.save();
             
        end
        
        function load(this, st)
            this.uiPrescriptionTool.load(st.uiPrescriptionTool);
            this.uiScan.load(st.uiScan)
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