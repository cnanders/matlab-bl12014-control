classdef WaferExposureHistory < mic.Base
        
    properties (Constant)
       
        
        
    end
    
	properties
        
       
    end
    
    properties (SetAccess = private)
        
        
        
    end
    
    properties (Access = private)
                        
        dXFemPreview            % size: [focus x dose] of X positions
        dYFemPreview            % size: [focus x dose] of Y positions
                                % these values are updated whenever the FEM
                                % grid changes
                                
        % {double focus x dose} x positions
        dXFemPreviewScan
        % {double focus x dose} y positions 
        dYFemPreviewScan 
        
        % Store exposure data in a cell.  Each item of the cell is an array that 
        % contains:
        %
        %   dX
        %   dY
        %   dDoseNum        the dose shot num
        %   dFEMDoseNum
        %   dFocusNum       the focus shot num
        %   dFEMFocusNum
        %
        % The dose/focus data is used for color/hue 
        % As each exposure finishes, an array is pushed to to this cell
        
        ceExposure = {}
       
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = WaferExposureHistory(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            
            
            
        end
        
        function [dX, dY] = getCoordinatesOfFemPreview(this)
            dX = this.dXFemPreview;
            dY = this.dYFemPreview;
        end
        
        function [dX, dY] = getCoordinatesOfFemPreviewScan(this)
            dX = this.dXFemPreviewScan;
            dY = this.dYFemPreviewScan;
        end
        
        
        % The FEM preview is not drawn as a single rectangle like it is in
        % MET software.  It is a grid of exposure sites.  You don't pass
        % in information to draw one rectangle, you pass in the x, y
        % meshgrid of the (, y) position on the wafer at every exposure site
        % @param {double focus x dose} dX - x position of
        % every exposure, e.g.:
        %  [-1.1  -0.8   -0.5
        %   -1.1  -0.8   -0.5
        %   -1.1  -0.8   -0.5] * 1e-3
        % @param {double focus x dose} dY - y position of
        % every exposure, e.g.:
        %  [2.2   2.2   2.2
        %   2.1   2.1   2.1
        %   2.0   2.0   2.0] * 1e-3
        % See addFakeFemPreview()
        % This is called from the Prescription tool.  Draws it gray
        
        function addFemPreview(this, dX, dY)
           this.dXFemPreview = dX;
           this.dYFemPreview = dY;
        end 
        
        function deleteFemPreview(this)
            
            this.dXFemPreview = [];
            this.dYFemPreview = [];
        end
        
        function deleteFemPreviewScan(this)
            this.dXFemPreviewScan = [];
            this.dYFemPreviewScan = [];
            
        end
        
        
        % This is from FEM control (draws it magenta)
        function addFemPreviewScan(this, dX, dY)
           this.dXFemPreviewScan = dX;
           this.dYFemPreviewScan = dY;
        end 
                
        % Draw an exposure on the wafer.  It is understood that the
        % exposure is part of a FEM.  Information about the FEM the
        % exposure is part of must be passed in so the colors can be drawn
        % correctly.  May need to edit this at some point to take
        % experimental data of exposure time and stage z of each exposure.
        % @param {double 1x6} dData
        % @param {double 1x1} dData[1] x position of the exposure on the
        % wafer.  OR is it the x position of the stage when the exposure
        % occurs?
        % @param {double 1x1} dData[2] y position of the stage when the
        %   exposure occurs
        % @param {double 1x1} dData[3] dose shot num (used with dData[4]
        %   to calculate the saturation of the fill color 
        % @param {double 1x1} dData[4] FEM dose size
        % @param {double 1x1} dData[5] focus shot num (used with dData[6]
        %   to calculate the hue of the fill color 
        % @param {double 1x1} dData[6] FEM focus size
        function addExposure(this, dData)
            this.ceExposure{length(this.ceExposure) + 1} = dData;
        end
        
        
        function deleteExposures(this)
            this.ceExposure = {};
        end
        
       
                
        
        function addFakeFemPreview(this)
        
            dX          = 0.5e-3; % Dose
            dY          = -0.1e-3; % Focus
            dX0         = .3e-3;
            dY0         = -.3e-3;
            dDoseNum    = 11;
            dFocusNum   = 9;
            
            x = dX0 : dX : dX0 + (dDoseNum - 1) * dX;
            y = dY0 : dY : dY0 + (dFocusNum - 1) * dY;
            
            [xx, yy] = meshgrid(x, y);
            
            this.addFemPreviewPrescription(xx, yy);
            
        end
        
        function addFakeExposures(this)
            
            % For testing
            
            dX          = 0.4e-3;
            dY          = -0.1e-3;
            dX0         = 0e-3;
            dY0         = 1e-3;
            dDoseNum    = 11;
            dFocusNum   = 9;
            
            for focus = 1:dFocusNum
                for dose = 1:dDoseNum
                    this.addExposure([...
                        dX0 + (dose - 1)*dX, ...
                        dY0 + (focus - 1)*dY, ...
                        dose, ...
                        dDoseNum, ...
                        focus, ...
                        dFocusNum ...
                    ]);
                end
            end
        end
        
        function ced = getExposures(this)
            ced = this.ceExposure;
        end
        
                
        

    end
    
    methods (Access = private)
        
        
        
        
        
    end % private
    
    
end