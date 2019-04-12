classdef MA < mic.Base
    
    properties (Constant)
        
        
    end
    properties (SetAccess = private)
        
        % {bl12014.ui.Scanner 1x1}
        uiScanner
        
        % {bl12014.ui.GigECamera 1x1}
        uiGigECamera
        
        % {bl12014.ui.MADiagnostics 1x1}
        uiDiagnostics
        
        

        
    end
    
    properties (Access = protected)
        
        % {mic.Clock 1x1} must be provided
        clock
        % {mic.ui.Clock 1x1}
        uiClock
        
        
        % {bl12014.Hardware 1x1}
        hardware
                
    end
    
    properties (SetAccess = protected)
        
        cName = 'MA'
    end
    
    methods
        
        function this = MA(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            
            if ~isa(this.uiClock, 'mic.Clock') && ~isa(this.uiClock, 'mic.ui.Clock')
                error('uiClock must be mic.Clock | mic.ui.Clock');
            end
 
            
             if ~isa(this.hardware, 'bl12014.Hardware')
                error('hardware must be bl12014.Hardware');
            end
                       
            this.init();
        
        end
        
        function d = processImageFrame(this, dData)
            d = rot90(dData);
            d = rot90(d);
        end
                
        function build(this, hParent, dLeft, dTop)
            
            this.uiScanner.build(hParent, dLeft, dTop);
            % this.uiGigECamera.build(hParent, dLeft + 1250, dTop, 480);
            this.uiDiagnostics.build(hParent, dLeft + 1250, 600);
            
        end
        
        function delete(this)
            
            this.msg('delete', this.u8_MSG_TYPE_CLASS_INIT_DELETE);
            delete(this.uiScanner)
            delete(this.uiGigECamera);
            
        end  
        
        
        function st = save(this)
            st = struct();
            st.uiScanner = this.uiScanner.save();
        end
        
        function load(this, st)
            if isfield(st, 'uiScanner') 
                this.uiScanner.load(st.uiScanner);
            end
        end
        
    end
    
    methods (Access = protected)
        
        function init(this)
            
            
            [cDir, cName, cExt] = fileparts(mfilename('fullpath'));
            cDirWaveforms = mic.Utils.path2canonical(fullfile(...
                cDir, ...
                '..', ...
                '..', ...
                'save', ...
                'scanner-ma' ...
            ));
        
            cDirWaveformsStarred = fullfile(...
                cDirWaveforms, ...
                'starred' ...
            );
            
            this.uiScanner = bl12014.ui.Scanner(...
                'fhGetNPoint', @() this.hardware.getNPointMA(), ...
                'cName', 'MA Scanner', ...
                'clock', this.clock, ...
                'uiClock', this.uiClock, ...
                'cDirWaveforms', cDirWaveforms, ...
                'cDirWaveformsStarred', cDirWaveformsStarred, ...
                'dScale', 0.67 ... % 0.67 rel amp = sig 1
            );
            
            %{
            'dOffsetX', 370, ...
                'dOffsetY', 0, ...
                'dSizeX', 500, ...
                'dSizeY', 500, ...
            %}
            
            dSizeX = 1288;
            dSizeY = 728;
            dOffsetX = 100 ; % 350;
            dOffsetY = 0;
            this.uiGigECamera = bl12014.ui.GigECamera( ...
                'fhProcess', @this.processImageFrame, ...
                'dOffsetX', dOffsetX, ...
                'dOffsetY', dOffsetY, ...
                'dSizeX', 700, ... % dSizeX - dOffsetX, ...
                'dSizeY', dSizeY - dOffsetY, ...
                'cIp', '192.168.30.26' ...
            );
        
            this.uiDiagnostics = bl12014.ui.MADiagnostics( ...
                'hardware', this.hardware, ...
                'clock', this.uiClock ...
            );
            
        end
          
        
    end
    
    
end

