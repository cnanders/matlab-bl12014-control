classdef App < mic.Base
        
    properties (Constant)
       
        dHeight         = 500
        dWidth          = 140
        
        
    end
	properties
        
        uiBeamline
        uiShutter
        uiM141
        uiM142
        % uiM143
        uiD141
        uiD142
        uiReticle
        uiWafer
        uiPupilControl
        uiFieldControl
        uiPrescriptionTool           
        uiScan         

        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
         
        dHeightEdit = 24
        
        clock
        hFigure
        
        uiButtonBeamline
        uiButtonShutter
        uiButtonD141
        uiButtonD142
        uiButtonM141
        uiButtonM142
        uiButtonM143
        uiButtonReticle
        uiButtonWafer
        uiButtonPreTool
        uiButtonScan
        uiButtonPupilScanner
        uiButtonFieldScanner
        
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = App()
            
            
            this.init();
            
        end
        
                
        function build(this)
                        
            % Figure
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'MET5', ...
                'Position', [0 0 this.dWidth this.dHeight], ... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onCloseRequestFcn ...
                );
            
            drawnow;

            dWidthButton = 120;
            dTop = 20;
            dSep = 25;
            dLeft = 10;
            
            this.uiButtonBeamline.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uiButtonShutter.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uiButtonD141.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uiButtonD142.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uiButtonM141.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uiButtonM142.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uiButtonM143.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uiButtonReticle.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uiButtonWafer.build(this.hFigure,dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uiButtonPreTool.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uiButtonScan.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uiButtonPupilScanner.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uiButtonFieldScanner.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            this.msg('delete');
            
            % Delete the figure
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            % Delete the device UI controls
            delete(this.uiShutter)
            delete(this.uiM141)
            delete(this.uiM142)
            % delete(this.uiM143)
            delete(this.uiD141)
            delete(this.uiD142)
            delete(this.uiReticle)
            delete(this.uiWafer)
            delete(this.uiPupilControl)
            delete(this.uiFieldControl)
            delete(this.uiPrescriptionTool)           
            delete(this.uiScan) 
            
            % Delete the clock
            delete(this.clock);
                       
        end         

    end
    
    methods (Access = private)
        
        function onUiButtonBeamline(this, src, evt)
            this.msg('onUiButtonBeamline()');
            this.uiBeamline.build();
        end
        
        function onUiButtonShutter(this, src, evt)
            this.msg('onUiButtonShutter()');
            this.uiShutter.build();
        end
        
        function onUiButtonD141(this, src, evt)
            this.msg('onUiButtonD141()');
            this.uiD141.build();
        end
        
        function onUiButtonD142(this, src, evt)
            this.msg('onUiButtonD142()');
            this.uiD142.build();
        end
        
        function onUiButtonM141(this, src, evt)
            this.msg('onUiButtonM141()');
            this.uiM141.build();
        end
        
        function onUiButtonM142(this, src, evt)
            this.msg('onUiButtonM142()');
            this.uiM142.build();
        end
        
        function onUiButtonM143(this, src, evt)
            this.msg('onUiButtonM143()');
            % this.uiM143.build();
        end
        
        function onUiButtonReticle(this, src, evt)
            this.msg('onUiButtonReticle()');
            this.uiReticle.build();
        end
        
        function onUiButtonWafer(this, src, evt)
            this.msg('onUiButtonWafer()');
            this.uiWafer.build(); 
        end
        
        function onUiButtonPreTool(this, src, evt)
            this.msg('onUiButtonPreTool()');
            this.uiPrescriptionTool.build();
        end
        
        function onUiButtonScan(this, src, evt)
            this.msg('onUiButtonScan()');
            this.uiScan.build();
        end
        
        function onUiButtonPupilFill(this, src, evt)
            this.msg('onUiButtonPupilFill()');
            this.uiPupilControl.build();
        end
        
        function onUiButtonFieldFill(this, src, evt)
            this.msg('onUiButtonFieldFill()');
            this.uiFieldControl.build();
        end
        
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
            % this.uiM143 = bl12014.ui.M143('clock', this.clock);
            this.uiReticle = bl12014.ui.Reticle('clock', this.clock);
            this.uiWafer = bl12014.ui.Wafer('clock', this.clock);
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
            %{
            addlistener(this.uiPrescriptionTool.femTool, 'eSizeChange', @this.onFemToolSizeChange);
            
            
            
            addlistener(this.uiPupilControl, 'eNew', @this.onPupilFillNew);
            addlistener(this.uiPupilControl, 'eDelete', @this.onPupilFillDelete);
            %}
            
            this.uiButtonBeamline = mic.ui.common.Button('cText', 'Beamline');
            this.uiButtonShutter = mic.ui.common.Button('cText', 'Shutter');
            this.uiButtonD141 = mic.ui.common.Button('cText', 'D141');
            this.uiButtonD142 = mic.ui.common.Button('cText', 'D142');
            
            this.uiButtonM141 = mic.ui.common.Button('cText', 'M141');
            this.uiButtonM142 = mic.ui.common.Button('cText', 'M142');
            this.uiButtonM143 = mic.ui.common.Button('cText', 'M143');
            
            this.uiButtonReticle = mic.ui.common.Button('cText', 'Reticle');
            this.uiButtonWafer = mic.ui.common.Button('cText', 'Wafer');
            this.uiButtonPreTool = mic.ui.common.Button('cText', 'Pre Tool');
            this.uiButtonPupilScanner = mic.ui.common.Button('cText', 'Pupil Scanner');
            this.uiButtonFieldScanner = mic.ui.common.Button('cText', 'Field Scanner');
            this.uiButtonScan = mic.ui.common.Button('cText', 'Expt. Control');
            
            
            addlistener(this.uiButtonBeamline, 'eChange', @this.onUiButtonBeamline);
            addlistener(this.uiButtonShutter, 'eChange', @this.onUiButtonShutter);
            addlistener(this.uiButtonD141, 'eChange', @this.onUiButtonD141);
            addlistener(this.uiButtonD142, 'eChange', @this.onUiButtonD142);
            addlistener(this.uiButtonM141, 'eChange', @this.onUiButtonM141);
            addlistener(this.uiButtonM142, 'eChange', @this.onUiButtonM142);
            addlistener(this.uiButtonM143, 'eChange', @this.onUiButtonM143);
            addlistener(this.uiButtonReticle, 'eChange', @this.onUiButtonReticle);
            addlistener(this.uiButtonWafer,   'eChange', @this.onUiButtonWafer);
            addlistener(this.uiButtonPreTool,        'eChange', @this.onUiButtonPreTool);
            addlistener(this.uiButtonScan,    'eChange', @this.onUiButtonScan);
            addlistener(this.uiButtonPupilScanner,   'eChange', @this.onUiButtonPupilFill);
            addlistener(this.uiButtonFieldScanner,   'eChange', @this.onUiButtonFieldFill);

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

    end % private
    
    
end