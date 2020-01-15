classdef PlotParamOfMultipleFemLogs
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        dData
        cField = 'dz_wafer_fine_nm';
    end
    
    methods
        
        function this = PlotParamOfMultipleFemLogs(varargin)
            
            % Override properties with varargin
            for k = 1 : 2: length(varargin)
                this.(varargin{k}) = varargin{k + 1};
            end
            
            [cDirThis, cName, cExt] = fileparts(mfilename('fullpath'));
            
            % Allow the user to choose multiple directories from fem-scans
            cPath = fullfile(cDirThis, '..', 'src', 'save', 'fem-scans');
            cSortBy = 'date';
            cSortMode = 'descend';
            cFilter = '*.mat';


            ceDirs = uigetdir2(cPath, 'Choose directories');
           
            dData = [];
           
            for n = 1 : length(ceDirs)
                cPath = fullfile(ceDirs{n}, 'result.json');
                try

                    fid = fopen(cPath, 'r');
                    cText = fread(fid, inf, 'uint8=>char');
                    fclose(fid);
                    stResult = jsondecode(cText')
                    dResult =  this.getValuesFromResultStruct(stResult, this.cField);
                    dData(n, :) = dResult';
                    
                catch mE
                end
            end
           
            this.dData = dData;
            figure
            plot(dData');
            
        end
        
        % Returns a {struct 1x1} where each prop is a list of values of
        % of a saved result property.  The result structure loaded from
        % .json has a values field that is a cell of structures or a list
        % of structures (for log files created since 2019.11.05)
        function dOut = getValuesFromResultStruct(this, st, cField)
            
            % Initialize the structure
            ceValues = this.getNonEmptyValues(st.values);
            dOut = zeros(size(ceValues));
            
            % Write values
            
            for idxValue = 1 : length(ceValues)
                
                if iscell(ceValues)
                    stValue = ceValues{idxValue};
                else
                    stValue = ceValues(idxValue);
                end
                dOut(idxValue) = stValue.(cField);
            end
            
            
        end
        
        
        function ce = getNonEmptyValues(this, ceValues)
                        
            % Use logical indexing
            if iscell(ceValues)
                lIsStruct = cellfun(@isstruct, ceValues);
                ce = ceValues(lIsStruct);
            else
                ce = ceValues;
            end
            
        end
        
        
        
    end
    
end

