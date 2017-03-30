classdef Beamline < mic.Base
        
    properties (Constant)
       
        dHeight         = 450
        dWidth          = 140
        
        
    end
	properties
        
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
        uiExptControl         
        uiShutter             
        
        
        
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
         
        dHeightEdit = 24
        
        clock
        hFigure
        
        uibD141
        uibD142
        uibM141
        uibM142
        uibM143
        uibReticle
        uibWafer
        uibPreTool
        uibExptControl
        uibPupilScanner
        uibFieldScanner
        
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = Beamline()
            
            
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
            dSep = 40;
            dLeft = 10;
            
            this.uibD141.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uibD142.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uibM141.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uibM142.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uibM143.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uibReticle.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uibWafer.build(this.hFigure,dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uibPreTool.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uibExptControl.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uibPupilScanner.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
            dTop = dTop + dSep;
            
            this.uibFieldScanner.build(this.hFigure, dLeft, dTop, dWidthButton, this.dHeightEdit);
        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            
            this.msg('delete');
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            %{
            % Clean up clock tasks
            if (isvalid(this.cl))
                this.cl.remove(this.id());
            end
            %}
            
            % Since all child classes refrence the clock, we need to delete
            % it first.  I originally thought this is so the clock wouldn't
            % continue to try to execute tasks that belong to deleted function
            % handles, but this isn't it.
            %
            % When you delete a class, you delete all of its properties.
            % Since we make the clock a property of each child class, it
            % will get deleted when the first child class is deleted (in
            % this case it is the ReticleControl class).  When this happens,
            % all of the other classes will have ...
            % Acutally, it doesn't make sense to me why we have to delete
            % the clock first, but it works.
                
            % Maybe it has something to do with the fact that the clock is
            % a private property of the child classes and when we delete
            % the child class, the reference to the clock persists through
            % the private property?
            %
            % No this is wrong.  Private properties are deleted.  
            
            % Delete the clock
            delete(this.clock);
                       
        end         

    end
    
    methods (Access = private)
        
        function onButtonD141(this, src, evt)
            this.msg('onButtonD141()');
            this.uiD141.build();
        end
        
        function onButtonD142(this, src, evt)
            this.msg('onButtonD142()');
            this.uiD142.build();
        end
        
        function onButtonM141(this, src, evt)
            this.msg('onButtonM141()');
            this.uiM141.build();
        end
        
        function onButtonM142(this, src, evt)
            this.msg('onButtonM142()');
            this.uiM142.build();
        end
        
        function onButtonM143(this, src, evt)
            this.msg('onButtonM143()');
            % this.uiM143.build();
        end
        
        function onButtonReticle(this, src, evt)
            this.msg('onButtonReticle()');
            this.uiReticle.build();
        end
        
        function onButtonWafer(this, src, evt)
            this.msg('onButtonWafer()');
            this.uiWafer.build(); 
        end
        
        function onButtonPreTool(this, src, evt)
            this.msg('onButtonPreTool()');
            this.uiPrescriptionTool.build();
        end
        
        function onButtonExpt(this, src, evt)
            this.msg('onButtonExpt()');
            this.exptControl.build();
        end
        
        function onButtonPupilFill(this, src, evt)
            this.msg('onButtonPupilFill()');
            this.uiPupilControl.build();
        end
        
        function onButtonFieldFill(this, src, evt)
            this.msg('onButtonFieldFill()');
            this.uiFieldControl.build();
        end
        
        function onPreToolSizeChange(this, src, evt)
            
            % evt has a property stData
            %   dX
            %   dY
            
            %{
            this.msg('onPreToolSizeChange');
            disp(evt.stData.dX)
            disp(evt.stData.dY)
            %}
           
            this.uiWafer.updateFEMPreview(evt.stData.dX, evt.stData.dY);
        end
        
        function init(this)
            
            this.clock = mic.Clock('Master');
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
            % this.shutter = Shutter('imaging', this.clock);
            %{
            this.exptControl = ExptControl( ...
                                        'clock', this.clock, ...
                                        'shutter', this.shutter, ...
                                        'wafer', this.uiWafer, ...
                                        'reticle', this.uiReticle, ...
                                        'pupil', this.uiPupilControl);
            %}
            
            %{
            addlistener(this.uiPrescriptionTool.femTool, 'eSizeChange', @this.onPreToolSizeChange);
            addlistener(this.uiPrescriptionTool, 'eNew', @this.onPreToolNew);
            addlistener(this.uiPrescriptionTool, 'eDelete', @this.onPreToolDelete);
            
            addlistener(this.uiPupilControl, 'eNew', @this.onPupilFillNew);
            addlistener(this.uiPupilControl, 'eDelete', @this.onPupilFillDelete);
            %}
            
            this.uibD141 = mic.ui.common.Button('cText', 'D141');
            this.uibD142 = mic.ui.common.Button('cText', 'D142');
            
            this.uibM141 = mic.ui.common.Button('cText', 'M141');
            this.uibM142 = mic.ui.common.Button('cText', 'M142');
            this.uibM143 = mic.ui.common.Button('cText', 'M143');
            
            this.uibReticle = mic.ui.common.Button('cText', 'Reticle');
            this.uibWafer = mic.ui.common.Button('cText', 'Wafer');
            this.uibPreTool = mic.ui.common.Button('cText', 'Pre Tool');
            this.uibPupilScanner = mic.ui.common.Button('cText', 'Pupil Scanner');
            this.uibFieldScanner = mic.ui.common.Button('cText', 'Field Scanner');
            this.uibExptControl = mic.ui.common.Button('cText', 'Expt. Control');
            
            addlistener(this.uibD141, 'eChange', @this.onButtonD141);
            addlistener(this.uibD142, 'eChange', @this.onButtonD142);
            addlistener(this.uibM141, 'eChange', @this.onButtonM141);
            addlistener(this.uibM142, 'eChange', @this.onButtonM142);
            addlistener(this.uibM143, 'eChange', @this.onButtonM143);
            addlistener(this.uibReticle, 'eChange', @this.onButtonReticle);
            addlistener(this.uibWafer,   'eChange', @this.onButtonWafer);
            addlistener(this.uibPreTool,        'eChange', @this.onButtonPreTool);
            addlistener(this.uibExptControl,    'eChange', @this.onButtonExpt);
            addlistener(this.uibPupilScanner,   'eChange', @this.onButtonPupilFill);
            addlistener(this.uibFieldScanner,   'eChange', @this.onButtonFieldFill);

        end
        
        
        function onCloseRequestFcn(this, src, evt)
            this.msg('closeRequestFcn()');
            % purge;
            delete(this.hFigure);
            % this.saveState();
        end
            
        function onPreToolNew(this, src, evt)
            this.exptControl.uilPrescriptions.refresh();
        end
        
        function onPreToolDelete(this, src, evt)
            this.exptControl.uilPrescriptions.refresh();
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