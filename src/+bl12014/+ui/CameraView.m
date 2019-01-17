classdef CameraView < HandlePlus
 
    properties (Constant)
        
        dPupilScale = 1.1;
        dPupilPixels = 220;
        dScale = 0.6;
        dPixels = [1288 728];
        
    end
    
    properties
        
        uipType
        cName

        hFigure
        hPanel1x1
        hPanel2x2

        hAxes1x1
        hAxes2x2A
        hAxes2x2B
        hAxes2x2C
        hAxes2x2D

        hImage2x2A
        hImage2x2B
        hImage2x2C
        hImage2x2D
       
    end
    
    properties (Access = private)
        
        
        
        vi % Eventually replace with a cell array of videoinput cevi
        vi2
        
        
    end
    
    events
        
        eLowLimitChange
        eHighLimitChange
        eCalibrationChange
        
    end
    
    
    methods
        
        function this = CameraView(cName)
        
           
            this.cName = cName;            
            this.init();
        end
                
        
        function build(this)
        % BUILD Builds the UI element controls in a separate window
        %   PupilFill.Build()
        %
        % See also PUPILFILL, INIT, DELETE
            
            % Figure
            this.hFigure = figure( ...
                'NumberTitle', 'off',...
                'MenuBar', 'none',...
                'Name',  this.cName,...
                'Position', [20 50 800 500],... % left bottom width height
                'Resize', 'off',...
                'HandleVisibility', 'on',... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.cb ...
                );
            
            drawnow;
            
            this.uipType.build(this.hFigure, 10, 10, 100, Utils.dEDITHEIGHT);
            this.buildPanel1x1();
            % this.buildPanel2x2();
            
        end

    end
    
    methods (Access = private)
        
        
         function cb(this, src, evt)
            
            switch src
                case this.hFigure
                    this.closeRequestFcn();
                    
            end
            
        end
        
        
    
        
        function closeRequestFcn(this)
            this.msg('CameraView.closeRequestFcn()');
            delete(this.hFigure);
            
            % this.saveState();
            
        end
        
        
        
        function buildPanel2x2(this)
            
            this.msg('CameraView.buildPanel2x2()');
           
            if ishandle(this.hFigure)
                                
                res = get(this.vi, 'VideoResolution'); 
                bands = get(this.vi, 'NumberOfBands');
                
                dWidth = this.dScale*res(1);
                dHeight = this.dScale*res(2);
                
                this.hPanel2x2 =  uipanel(...
                    'Parent',               this.hFigure,...
                    'Units',                'pixels', ...
                    'Title',                '2 x 2', ...
                    'Clipping',             'on', ...
                    'BackgroundColor',      [1 0 0], ...
                    'Position',             Utils.lt2lb([10 50 dWidth dHeight], this.hFigure) ...
                );
                drawnow; 
                
                % Build axes
                
                this.hAxes2x2A = axes(...
                    'Parent',               this.hPanel2x2, ...
                    'Units',                'pixels',...
                    'Position',             Utils.lt2lb([0 0 dWidth/2 dHeight/2], this.hPanel2x2), ...
                    'DataAspectRatio',      [1 1 1], ...
                    'HandleVisibility',     'on', ...
                    'XColor',               [1 1 1], ...
                    'YColor',               [1 1 1], ...
                    'Color',                [0.5 0.5 0.5], ...
                    'Visible',              'on'...
                );
                drawnow;
            
                this.hAxes2x2B = axes(...
                    'Parent',               this.hPanel2x2, ...
                    'Units',                'pixels', ...
                    'Position',             Utils.lt2lb([dWidth/2 0 dWidth/2 dHeight/2], this.hPanel2x2), ...
                    'DataAspectRatio',      [1 1 1], ...
                    'XColor',               [0 0 0], ...
                    'YColor',               [0 0 0], ...
                    'HandleVisibility',     'on', ...
                    'Color',                [0.2 0.2 0.2], ...
                    'Visible',              'on'...
                );
            
                this.hAxes2x2C = axes(...
                    'Parent',               this.hPanel2x2, ...
                    'Units',                'pixels', ...
                    'Position',             Utils.lt2lb([0 dHeight/2 dWidth/2 dHeight/2], this.hPanel2x2), ...
                    'DataAspectRatio',      [1 1 1], ...
                    'HandleVisibility',     'on', ...
                    'Color',                [0.2 0 0], ...
                    'Visible',              'on'...
                );
            
                this.hAxes2x2D = axes(...
                    'Parent',               this.hPanel2x2, ...
                    'Units',                'pixels', ...
                    'Position',             Utils.lt2lb([dWidth/2 dHeight/2 dWidth/2 dHeight/2], this.hPanel2x2), ...
                    'DataAspectRatio',      [1 1 1], ...
                    'HandleVisibility',     'on', ...
                    'Visible',              'on'...
                );
            
                this.hImage2x2A = image(...
                    zeros(res(2), res(1), bands), ...
                    'Parent', this.hAxes2x2A ...
                );
            
                this.hImage2x2B = image(...
                    zeros(res(2), res(1), bands), ...
                    'Parent', this.hAxes2x2B ...
                );
            
                this.hImage2x2C = image(...
                    zeros(res(2), res(1), bands), ...
                    'Parent', this.hAxes2x2C ...
                );
            
                this.hImage2x2D = image(...
                    zeros(res(2), res(1), bands), ...
                    'Parent', this.hAxes2x2D ...
                );
            
                preview(this.vi, this.hImage2x2A); 
                preview(this.vi2, this.hImage2x2B); 
            
            
                % Assign images to each axes
                
                
                
            end
        end
        
        
        function buildPanel1x1(this)
           
           this.msg('CameraView.buildPanel1x1()');

            
            if ishandle(this.hFigure)
                
                res = get(this.vi, 'VideoResolution'); 
                bands = get(this.vi, 'NumberOfBands');
                
                dWidth = this.dScale*res(1);
                dHeight = this.dScale*res(2);
               
                
                this.hPanel1x1 =  uipanel(...
                    'Parent',               this.hFigure,...
                    'Units',                'pixels',...
                    'Title',                '1 x 1',...
                    'Clipping',             'on',...
                    'Position',              Utils.lt2lb([10 50 dWidth dHeight], this.hFigure) ...
                );
                drawnow;
                
                this.hAxes1x1 = axes(...
                    'Parent',               this.hPanel1x1, ...
                    'Position',             Utils.lt2lb([0 0 dWidth dHeight], this.hPanel1x1), ...
                    'Units',                'pixels', ...
                    'DataAspectRatio',      [1 1 1], ...
                    'HandleVisibility',     'on', ...
                    'Visible',              'on'...
                );
                
            end
        end
        
        
        
        function init(this)
            
            this.uipType = UIPopup({'Single', '2 x 2'}, 'Select Display Type', true);
            addlistener(this.uipType, 'eChange', @this.handleType);
            
            % Temp image acquisition stuff.  Need to have point grey
            % plugged in
            
            imaqreset
            this.vi = videoinput('gige', 1);
            this.vi2 = videoinput('macvideo', 1);
                        
        end
        
        
        function handleType(this, src, evt)
            
            this.msg('CameraView.handleType()');
            
            % Build the sub-panel based on popup type 
            switch this.uipType.u8Selected
                case uint8(1)
                    % 1 x 1
                    this.hideOtherTypePanels(this.hPanel1x1);
                    if ishandle(this.hPanel1x1)
                        set(this.hPanel1x1, 'Visible', 'on');
                    else
                        this.buildPanel1x1();
                    end
                    
                case uint8(2)
                    % 2 x 2
                    this.hideOtherTypePanels(this.hPanel2x2);
                    if ishandle(this.hPanel2x2)
                        set(this.hPanel2x2, 'Visible', 'on');
                    else
                        this.buildPanel2x2();
                    end
            end
            
            
        end
        
        
        function hideOtherTypePanels(this, h)
            
            % @parameter h
            %   type: handle
            %   desc: handle of the panel that you don't want to hide
            
            this.msg( ...
                sprintf( ...
                    'CameraView.hideOtherTypePanels() h = %1.0f', ...
                    h ...
                ) ...
            );
            
            
            % USE CAUTION!  h may be empty when we pass it in
            
            if (~isempty(h) && ishandle(h))

                % cell of handles of each panel
                ceh = { ...
                    this.hPanel1x1, ...
                    this.hPanel2x2, ...
                };

                % loop through all panels
                for n = 1:length(ceh)            

                    ishandle(ceh{n})
                        
                    if  ishandle(ceh{n}) & ...
                        strcmp(get(ceh{n}, 'Visible'), 'on') & ...
                        (isempty(h) | ceh{n} ~= h)
                        this.msg(sprintf('CameraView.hideOtherTypePanels() hiding %s panel', this.uipType.ceOptions{uint8(n)}));
                        set(ceh{n}, 'Visible', 'off');
                    end
                end
            else
                this.msg('PupilFill.hideOtherTypePanels() h == not a handle');
            end
            
        end

    end

end
        
        
        