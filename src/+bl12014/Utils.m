classdef Utils
    
    properties
    end
    
    methods (Static)
        
        function c = pathUiConfig(this)
            [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
            c = fullfile(cDirThis, '..', 'config');
                        
        end
    end
    
end

