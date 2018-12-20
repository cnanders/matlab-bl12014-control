% This is a bridge between hardware device and MATLAB UI

    
classdef DymoLabelWriter450 < mic.Base
    
    
    properties (Constant)
        cName = 'DYMO-LabelWriter-450'
    end
    
    properties 
        hLabel
        api
    end
    
    properties (Access = private)
        
         cLabelTemplate      = 'WaferLabel.label'

         cWaferID            = '12345'
         cPrescription       = 'none'
         cSize               = 'n/a'
         cDose               = 'n/a'
         cFocus              = 'n/a'
         cIllumination       = 'None Specified'
         cPEB                = 'None specified'
         cDev                = 'None specified'
         cField              = 'None specified'
         cResist             = 'None specified'
         cSublayer           = 'None specified'
         cResistThickness    = 'None specified'
         
    end
    
    methods
        
        function this = DymoLabelWriter450(varargin)
           
             for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
             end
             
             this.init();
        end
        
        function setField(this, varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                    
                end
             end
        end
        
        function printLabel(this)
            this.updateFields();
            this.api.Print(1,true);
        end
        
        function updateFields(this)
            this.hLabel.SetField('Wafer_ID',        this.cWaferID);
            this.hLabel.SetField('Prescription',    this.cPrescription);
            this.hLabel.SetField('Size',            this.cSize);
            this.hLabel.SetField('CD_Step',         this.cDose);
            this.hLabel.SetField('CF_Step_tol',     this.cFocus);
            this.hLabel.SetField('Illumination',    this.cIllumination);
            this.hLabel.SetField('PEB',             this.cPEB);
            this.hLabel.SetField('Dev',             this.cDev);
            this.hLabel.SetField('Mask_Field',      this.cField);
            this.hLabel.SetField('Resist',          this.cResist);
            this.hLabel.SetField('Sub',             this.cSublayer);
            this.hLabel.SetField('Resist_Thickness', this.cResistThickness);
        end
        
        
        function init(this)
            this.api = actxserver('DYMO.DymoAddIn');
            this.hLabel = actxserver('DYMO.DymoLabels');
            
            % get direct path to file:
            cDirThis = fileparts(mfilename('fullpath'));
            this.api.Open(fullfile(cDirThis, this.cLabelTemplate));
        end
        
        function disconnect(this)
            this.api = [];
            this.hLabel = {};
        end
        
     
        
    end
    
    
    
     
    
end

