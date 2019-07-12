classdef BL12PicoExitSlit < handle
    % Class for bl12pico slit control
    
    properties (SetAccess = public, GetAccess = public)
        CLstatus = 0
    end
    
    properties (Access = private)
        
        % 1 2 3 4
        % upper in
        % lower in
        % upper out
        % lower out
        
        dPos = [175 -175 175 -175];
        
        % {double 1x1} maximum allowed step during closed loop
        dStepMax = 50
        
    end
    
   
    methods
       % constructor 
       function this = BL12PicoExitSlit()
          
       end
       
       
       % destructor        
       function delete(this)
       end
       % timer callback        
       
       function val = getSlitMaxStep(this)
          val = this.dStepMax;
       end
       
       function [e,estr] = setSlitMaxStep(this, val)
           e = [];
           estr = '';
           this.dStepMax = val;
       end
       
       function [e,estr] = checkServer(this)
           e = [];
           estr = '';
       end
       
       function [pos,e,estr]=getPos(this,mot)
           pos = this.dPos(mot - 3);
           e = [];
           estr = '';
       end
       
       function [pos,e,estr]=getPosRaw(this,mot)
           pos = this.dPos(mot - 3);
           e = [];
           estr = '';
       end
       
       function [s,e,estr]=getState(this)
           s = -1;
           e = [];
           estr = '';
       end
       
       function [ret,e,estr]=moveto(this,mot,pos)
           this.dPos(mot - 3) = pos;
           ret = [];
           e = [];
           estr = '';
          
       end
       
       function [ret,e,estr]=movetoRaw(this,mot,pos)
           this.dPos(mot - 3) = pos;
           ret = [];
           e = [];
           estr = '';
       end
       
       function [e,estr] = stopAll(this)
           e = [];
           estr = '';
           
       end
       
       function [e,estr] = abortAll(this)
           e = [];
           estr = '';
       end
       
       function [slit,e,estr] = getSlitGap(this)
           slit = struct();
           slit.gap = (this.dPos(1) + this.dPos(3) - this.dPos(2) - this.dPos(4)) / 2;
           e = [];
           estr = '';
       end
       
       function [e,estr] = setSlitGap(this,gapTarget)
           this.dPos(1) = gapTarget / 2;
           this.dPos(2) = - gapTarget / 2;
           this.dPos(3) = gapTarget / 2;
           this.dPos(4) = - gapTarget / 2;
           e = [];
           estr = '';
       end
    end
    
    
    methods (Access = private)
    end  
end

