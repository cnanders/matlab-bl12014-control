classdef Camera < HandlePlus
%CAMERA Class for controlling a camera
%
% usage :
%   cam = Camera();
%   cam.preview()
%   cam.settings.Exposure = 3;
%   img = cam.acquire();


    properties (Constant)
    end
    
    properties (Dependent)
    end

    properties
        cName       % name identifier
        hVideo      % video handle
        settings    % camera settings (hadle to getselectedsource )
        filename    % saving filename
        
    end

    properties (SetAccess = private)
        hUI         % UIElement panel, comprising all basic functions
        hAxis       % axes handle, to contain the image handle
        hImage      % image handle, to draw the preview

    end

    properties (Access = private)
        buttonSnap  % snapshot button
        slGain      % slider for gain
        slExposure  % slider for exposure    
    end

    events
    end


        methods
            
        function this = Camera(cName)
        %CAMERA Class constructor    
        %   cam = Camer('name')
        %
        % See also INIT, BUILD, PREVIEW
        
            this.msg('Camera.constructor()'); %TODO remove when finalized
            this.cName = cName;
            this.init();
        end


        function init(this)
        %INIT Initializes the Camera
        %   Camera.init()
        %   primarily used by the constructor
        %   assumes that the videoinput is 'winvideo' 1
        %
        % See also CAMERA, BUILD, DELETE
        
            %FIXME : must be able to select the source
            try
                this.hVideo = videoinput('winvideo', 1);
            catch err
                if strcmp(err.identifier,'imaq:videoinput:noDevices')
                    warning(sprintf('Error while initialazing the video camera ''%s''\n DETAILS : %s',this.cName,err.message));
                end
            end
        end

        function build(this, hParent, dLeft, dTop)
        %BUILD Builds the UIElement for the Camera, with some controls
        %   Camera.build(Parent, dLeft, dTop)
        %
        % See also INIT, PREVIEW, BUILDHISTOGRAM
        
            this.hUI =uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', blanks(0),...
                'Clipping', 'on',...
                'BorderWidth',0,... 'BackgroundColor',[0 0 0],...
                'Position', Utils.lt2lb([dLeft dTop 640 480], hParent) ...
                );

            this.hAxis = axes('Parent', ...
                this.hUI,'Visible','off',...
                'Units','pixels',...
                'Position', Utils.lt2lb([0 0 640 480], this.hUI));
            this.hImage = image('Parent',this.hAxis);    


            this.buttonSnap = uicontrol('Style','pushbutton',...
                'Parent',this.hUI,...
                'String','Snap',...
                'Callback', @this.snapbutton,...
                'Units','pixels',...
                'Position', Utils.lt2lb([0 0 30 15], this.hUI));


            try
            tmp = propinfo(this.settings,'GAIN');
            this.slGain = uicontrol('Style','slider',...
                'Parent', this.hUI,...
                'Callback', @this.updateSettings,...
                'Min',  tmp.ConstraintValue(1),...
                'Value',tmp.DefaultValue,...
                'Max',  tmp.ConstraintValue(2),...
                'SliderStep',[1/(tmp.ConstraintValue(2)-tmp.ConstraintValue(1)) 0.1],...
                'Units', 'pixels',...
                'Position', [640-20 0 10 480] ...
                );
            catch err
                fprintf('Unable to add gain controls\n')
            end

            try
            tmp = propinfo(this.settings,'EXPOSURE');
            this.slExposure = uicontrol('Style','slider',...
                'Parent', this.hUI,...
                'Callback', @this.updateSettings,...
                'Min',  tmp.ConstraintValue(1),...
                'Value',tmp.DefaultValue,...
                'Max',  tmp.ConstraintValue(2),...
                'SliderStep',[1/(tmp.ConstraintValue(2)-tmp.ConstraintValue(1)) 0.1],...
                'Units', 'pixels',...
                'Position', [640-10 0 10 480] ...
                );
            catch err
                fprintf('Unable to add exposure controls\n')
            end
        end

        function image = acquire(this)
        %ACQUIRE Acquires an image
        %   Camera.acquire()
        %
        % See also ...
        
            if ~isempty(this.hVideo)
                image = getsnapshot(this.hVideo);
            end
        end
        
        function BuildHistogram(this)
            hHisto = figure;
            img = this.acquire();
            hist(mean(img(:),3),1:256); axis tight
            xlabel('bins');
            ylabel('counts');
        end

        function updateSettings(this, src, ~)
        %UPDATESETTINGS Callback triggered when a slider is changed
        %   set(this.slGain, 'Callback', @this.updateSettings)
        %
        % See also GETEXPOSURE, SETEXPOSURE
        
            if isequal(src, this.slExposure)
                new_exposure = round(get(this.slExposure, 'Value'));
                fprintf('new exposure : %d\n', new_exposure)
                this.settings.Exposure = new_exposure;
            elseif isequal(src, this.slGain)
                new_gain = round(get(this.slGain, 'Value'));
                fprintf('new gain : %d\n', new_gain)
                this.settings.Gain = round(get(this.slGain, 'Value'));
            end 
        end

        function preview(this)
        %PREVIEW Draws a preview of the camera reading in the UI panel
        %   Camera.preview
        
            if ~isempty(this.hVideo)
                if ~isempty(this.hImage)
                    preview(this.hVideo,this.hImage);
                else
                    preview(this.hVideo);
                end
            end
        end


        function snapbutton(this,src, evt)
        %SNAPBUTTON Callback for the snap button; acquire a full res pic
        %   set(this.buttonSnap, 'Callback', @this.snapbutton)
            image = this.acquire();
            if isempty(this.filename)
                this.filename = 'test';
            end

            current_filename = this.filename;
            i = 1;
            while exist(strcat(current_filename,'.png'), 'file')
                current_filename= sprintf('%s_%i',this.filename,i);
                i = i+1;
            end

            imwrite(image,strcat(current_filename,'.png'),'png')
        end

        function setExposure(this,value)
        %SETEXPOSURE Exposure modifier
        %   Camera.setExposure(uint_newExposure)
        %
        % See also GETEXPOSURE
            this.settings.Exposure = value;
        end

        function value = getExposure(this)
        %GETEXPOSURE Exposure accessor
        %   exp = Camera.exposure()
        %
        % See also SETEXPOSURE
        
            value = this.settings.Exposure;
        end
        
        
        function set.hVideo(this,value)
            this.hVideo = value;
        end
        
        
        function out = get.settings(this)
            out = getselectedsource(this.hVideo);
        end
        
        function set.settings(this, value)
            this.settings = getselectedsource(this.hVideo);
        end


        %% Destructor
        function delete(this)
        %DELETE Class destructor
        %   Camera.delete()
        
            %FIXME does nothing for now
            if ~isempty(this.hVideo)
                delete(this.hVideo)
            end
        end
    end %methods 
end %classdef