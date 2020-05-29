classdef DCTExposures < mic.Base
        
    properties (Constant)
               
    end
    
	properties
        
       
    end
    
    properties (SetAccess = private)
        
        
        
    end
    
    properties (Access = private)
                                
        % Store exposure data in a cell.  Each item of the cell is an array that 
        % contains:
        %
        %   dX - center
        %   dY - center 
        %   dWidth
        %   dHeight
        %   dDose mJ/cm2 

        ceExposures = {}
        ceExposuresPre = {} % use for the preview when building prescriptions
        ceExposuresScan = {} % use to show what the scan will execute
       
    end
    
        
    events
        
        
    end
    

    
    methods
        
        
        function this = DCTExposures(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
 
        end
        
        function addExposureToPre(this, dData)
            this.ceExposuresPre{length(this.ceExposuresPre) + 1} = dData;
        end
        
        function purgeExposuresPre(this)
            this.ceExposuresPre = {};
        end
        
        function addExposureToScan(this, dData)
            this.ceExposuresScan{length(this.ceExposuresScan) + 1} = dData;
        end
        
        function purgeExposuresScan(this)
            this.ceExposuresScan = {};
        end
                
        function addExposure(this, dData)
            this.ceExposures{length(this.ceExposures) + 1} = dData;
        end
        
        function purgeExposures(this)
            this.ceExposures = {};
        end
        
        
        function addFakePre(this)
            
            dHeight = 1e-3;
            dWidth = 1e-3;
            
            dNumX = 10;
            dNumY = 4;
            dStartX = -5e-3;
            dStartY = -15e-3;
            dStepX = 2e-3;
            dStepY = 2e-3;
                        
            dDoseStart = 20;
            dDoseStep = 0.5;
            dCount = 1;
            
            for row = 1 : dNumY
                for col = 1 : dNumX
                    this.addExposureToPre([
                        dStartX + col * dStepX, ...
                        dStartY + row * dStepY, ...
                        dWidth, ...
                        dHeight, ...
                        dDoseStart + dCount * dDoseStep
                    ])
                    dCount = dCount + 1;
                end
            end
        end
        
        function addFakeScan(this)
            
            dHeight = 5e-3;
            dWidth = 4e-3;
            
            dNumX = 3;
            dNumY = 6;
            dStartX = 5e-3;
            dStartY = 5e-3;
            dStepX = -6e-3;
            dStepY = -6e-3;
                        
            dDoseStart = 10;
            dDoseStep = 0.5;
            dCount = 1;
            
            for row = 1 : dNumY
                for col = 1 : dNumX
                    this.addExposureToScan([
                        dStartX + col * dStepX, ...
                        dStartY + row * dStepY, ...
                        dWidth, ...
                        dHeight, ...
                        dDoseStart + dCount * dDoseStep
                    ])
                    dCount = dCount + 1;
                end
            end
        end
        
        function addFakeExposures(this)
            
            dHeight = 5e-3;
            dWidth = 2e-3;
            
            dNumX = 10;
            dNumY = 4;
            dStartX = 10e-3;
            dStartY = 10e-3;
            dStepX = 6e-3;
            dStepY = 6e-3;
                        
            dDoseStart = 10;
            dDoseStep = 1;
            dCount = 1;
            
            for row = 1 : dNumY
                for col = 1 : dNumX
                    this.addExposure([
                        dStartX + col * dStepX, ...
                        dStartY + row * dStepY, ...
                        dWidth, ...
                        dHeight, ...
                        dDoseStart + dCount * dDoseStep
                    ])
                    dCount = dCount + 1;
                end
            end
        end
        
        function ced = getExposures(this)
            ced = this.ceExposures;
        end
        
        function ced = getExposuresPre(this)
            ced = this.ceExposuresPre;
        end
        
        function ced = getExposuresScan(this)
            ced = this.ceExposuresScan;
        end
        
        function setSizeOfApertureForScan(this, dWidth, dHeight)
            cedExposures = this.getExposuresScan();
            this.purgeExposuresScan();
            for n = 1 : length(cedExposures)
                dExposure = cedExposures{n};
                dExposureNew = [
                    dExposure(1), ...
                    dExposure(2), ...
                    dWidth, ...
                    dHeight, ...
                    dExposure(5) ...
                ];
                this.addExposureToScan(dExposureNew);
            end
        end
        
        function setSizeOfApertureForPre(this, dWidth, dHeight)
            cedExposures = this.getExposuresPre();
            this.purgeExposuresPre();
            for n = 1 : length(cedExposures)
                dExposure = cedExposures{n};
                dExposureNew = [
                    dExposure(1), ...
                    dExposure(2), ...
                    dWidth, ...
                    dHeight, ...
                    dExposure(5) ...
                ];
                this.addExposureToPre(dExposureNew);
            end
        end
        
    end
    
    methods (Access = private)
        
        
        
        
        
    end % private
    
    
end