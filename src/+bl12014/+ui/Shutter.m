classdef Shutter < mic.Base
    
    properties
        
        
        wagoSolenoid
        measPoint
        
        % {< mic.interface.device.GetSetNumber}
        device
        
        % {bl12014.device.ShutterVirtual}
        deviceVirtual
        
        % {mic.ui.device.GetSetNumber 1x1}}
        uiShutter
        
        
    end
    
    properties (Access = private)
        
        clock
        dWidth = 580
        dHeight = 66
        hFigure
        
        configStageY
        configMeasPointVolts
        
    end
    
    methods
        
        function this = Shutter(varargin)
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            this.init();
        
        end
        
       
        
        
        function build(this)
            
            this.msg('Shutter.build()');
            
            if ishghandle(this.hFigure)
                cMsg = sprintf(...
                    'Shutter.build() ishghandle(%1.0f) === true', ...
                    this.hFigure ...
                );
                this.msg(cMsg);
                % Bring to front
                figure(this.hFigure);
                return
            end
            
            dScreenSize = get(0, 'ScreenSize');
            
            this.hFigure = figure( ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Name', 'Shutter Control', ...
                'Position', [ ...
                    (dScreenSize(3) - this.dWidth)/2 ...
                    (dScreenSize(4) - this.dHeight)/2 ...
                    this.dWidth ...
                    this.dHeight ...
                 ],... % left bottom width height
                'Resize', 'off', ...
                'HandleVisibility', 'on', ... % lets close all close the figure
                'Visible', 'on',...
                'CloseRequestFcn', @this.onFigureCloseRequest ...
            );
                        
            drawnow;

            dTop = 10;
            dLeft = 10;
            dSep = 30;
            
            this.uiShutter.build(this.hFigure, dLeft, dTop);
            dTop = dTop + 15 + dSep;
                        
        end
        
        
        
        
        function delete(this)
            
            this.msg('delete');
            
            % Delete the figure
            
            if ishandle(this.hFigure)
                delete(this.hFigure);
            end
            
            
        end    
        
        
    end
    
    
    methods (Access = private)
        
         function initShutter(this)
            
            cPathConfig = fullfile(...
                bl12014.Utils.pathUiConfig(), ...
                'get-set-number', ...
                'config-shutter.json' ...
            );
        
            uiConfig = mic.config.GetSetNumber(...
                'cPath',  cPathConfig ...
            );
            
            this.uiShutter = mic.ui.device.GetSetNumber(...
                'clock', this.clock, ...
                'cName', 'shutter', ...
                'config', uiConfig, ...
                'cLabel', 'Shutter', ...
                'dWidthUnit', 120, ...
                'lShowRel', false, ...
                'lShowJog', false, ...
                'lShowZero', false, ...
                'lShowStores', false ...
            );
        
            this.uiShutter.setDeviceVirtual(this.deviceVirtual);
        end
        
        function initDeviceShutterVirtual(this)
            this.deviceVirtual = bl12014.device.ShutterVirtual();
        end
        
        
        function init(this)
            this.msg('init()');
            
            this.initDeviceShutterVirtual();
            this.initShutter();
        end
        
        function onFigureCloseRequest(this, src, evt)
            this.msg('closeRequestFcn()');
            delete(this.hFigure);
            this.hFigure = [];
        end
        
        
        
        
    end
    
    
end

