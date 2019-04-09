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
        
    end
    
   
    methods
       % constructor 
       function obj = BL12PicoExitSlit()
          
       end
       
       
       % destructor        
       function delete(obj)
       end
       % timer callback        
       
       function [e,estr] = checkServer(obj)
           e = [];
           estr = '';
       end
       
       function [pos,e,estr]=getPos(obj,mot)
           pos = obj.dPos(mot - 3);
           e = [];
           estr = '';
       end
       
       function [pos,e,estr]=getPosRaw(obj,mot)
           pos = obj.dPos(mot - 3);
           e = [];
           estr = '';
       end
       
       function [s,e,estr]=getState(obj)
           s = -1;
           e = [];
           estr = '';
       end
       
       function [ret,e,estr]=moveto(obj,mot,pos)
           obj.dPos(mot - 3) = pos;
           ret = [];
           e = [];
           estr = '';
          
       end
       
       function [ret,e,estr]=movetoRaw(obj,mot,pos)
           obj.dPos(mot - 3) = pos;
           ret = [];
           e = [];
           estr = '';
       end
       
       function [e,estr] = stopAll(obj)
           e = [];
           estr = '';
           
       end
       
       function [e,estr] = abortAll(obj)
           e = [];
           estr = '';
       end
       
       function [slit,e,estr] = getSlitGap(obj)
           slit = struct();
           slit.gap = (obj.dPos(1) + obj.dPos(3) - obj.dPos(2) - obj.dPos(4)) / 2;
           e = [];
           estr = '';
       end
       
       function [e,estr] = setSlitGap(obj,gapTarget)
           obj.dPos(1) = gapTarget / 2;
           obj.dPos(2) = - gapTarget / 2;
           obj.dPos(3) = gapTarget / 2;
           obj.dPos(4) = - gapTarget / 2;
           e = [];
           estr = '';
       end
    end
    
    
    methods (Access = private)
    end  
end

