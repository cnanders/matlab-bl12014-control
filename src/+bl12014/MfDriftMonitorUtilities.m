classdef MfDriftMonitorUtilities

    
    %% Constant Properties
    properties (Constant)
        
    end

    %% Static Methods
    methods (Static)
        
        
        % returns {cell  N x (12 + 12 + 4)} where each column is a list of
        % samples of a sensor at 1 kHz.  The mapping of sensor to column is
        %{
        // first 500 us
        stMap.ch6top1 = 1;
        stMap.ch6bot1 = 2;
        stMap.ch5top1 = 3;
        stMap.ch5bot1 = 4;
        stMap.ch4top1 = 5;
        stMap.ch4bot1 = 6;
        stMap.ch3top1 = 7;
        stMap.ch3bot1 = 8;
        stMap.ch2top1 = 9;
        stMap.ch2bot1 = 10;
        stMap.ch1top1 = 11;
        stMap.ch1bot1 = 12;

        // second 500 us
        stMap.ch6top2 = 13;
        stMap.ch6bot2 = 14;
        stMap.ch5top2 = 15;
        stMap.ch5bot2 = 16;
        stMap.ch4top2 = 17;
        stMap.ch4bot2 = 18;
        stMap.ch3top2 = 19;
        stMap.ch3bot2 = 20;
        stMap.ch2top2 = 21;
        stMap.ch2bot2 = 22;
        stMap.ch1top2 = 23;
        stMap.ch1bot2 = 24;

        stMap.dmi1 = 25;
        stMap.dmi2 = 26;
        stMap.dmi3 = 27;
        stMap.dmi4 = 28;
        %}
        function ceData = getDataFromLogFile(cPath)
            
            hFile = fopen(cPath);

            % %d = signed integer, 32-bit
            cFormat = [...
                '%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,', ...
                '%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,', ...
                '%d,%d,%d,%d' ...
            ];

            ceData = textscan(...
                hFile, cFormat, -1, ...
                'headerlines', 1 ...
            );
        
            fclose(hFile);
            
        end
        
        
        % To deal with data from the test routines on met5vme that
        % usually contain partial data, truncate all sample
        % arrays to the length of dmi4 sample appay
        % @param {cell} - the return of getDataFromLogFile 
            
        function ceData = removePartialsFromFileData(ceData)
            
            numSamples = length(ceData{28});
            for n = 1 : length(ceData)
                while length(ceData{n}) > numSamples
                    ceData{n}(end) = [];
                end
            end
            
        end
        
        % returns {double 7 x N} where each row is the z position in nm of
        % a height sensor channel at 1 kHz.   row 7 is the average of the three
        % central channels
        function z = getHeightSensorZFromFileData(ceData)
            
            m_per_diff_over_sum = 120e-6/2; 
            
            stMap = struct();
            
            stMap.ch6top1 = 1;
            stMap.ch6bot1 = 2;
            stMap.ch5top1 = 3;
            stMap.ch5bot1 = 4;
            stMap.ch4top1 = 5;
            stMap.ch4bot1 = 6;
            stMap.ch3top1 = 7;
            stMap.ch3bot1 = 8;
            stMap.ch2top1 = 9;
            stMap.ch2bot1 = 10;
            stMap.ch1top1 = 11;
            stMap.ch1bot1 = 12;

            stMap.ch6top2 = 13;
            stMap.ch6bot2 = 14;
            stMap.ch5top2 = 15;
            stMap.ch5bot2 = 16;
            stMap.ch4top2 = 17;
            stMap.ch4bot2 = 18;
            stMap.ch3top2 = 19;
            stMap.ch3bot2 = 20;
            stMap.ch2top2 = 21;
            stMap.ch2bot2 = 22;
            stMap.ch1top2 = 23;
            stMap.ch1bot2 = 24;

            % side === indicates to the capacitor used.  Do not confuse this with
            % "side" of the diode.  "a", and "b" refer to "top" and "bottom" halves of
            % the dual-diode, respectively
            % A single measurement returns the "capacitor/side" of the ADC, and the
            % counts from the top and bottom of each diode of each channel

            % average the values from each cap within the 1 ms acquisition period

            % top
            top(1, :) = (ceData{stMap.ch1top1} + ceData{stMap.ch1top2}) / 2;
            top(2, :) = (ceData{stMap.ch2top1} + ceData{stMap.ch2top2}) / 2;
            top(3, :) = (ceData{stMap.ch3top1} + ceData{stMap.ch3top2}) / 2;
            top(4, :) = (ceData{stMap.ch4top1} + ceData{stMap.ch4top2}) / 2;
            top(5, :) = (ceData{stMap.ch5top1} + ceData{stMap.ch5top2}) / 2;
            top(6, :) = (ceData{stMap.ch6top1} + ceData{stMap.ch6top2}) / 2; 

            % bottom
            bot(1, :) = (ceData{stMap.ch1bot1} + ceData{stMap.ch1bot2}) / 2;
            bot(2, :) = (ceData{stMap.ch2bot1} + ceData{stMap.ch2bot2}) / 2;
            bot(3, :) = (ceData{stMap.ch3bot1} + ceData{stMap.ch3bot2}) / 2;
            bot(4, :) = (ceData{stMap.ch4bot1} + ceData{stMap.ch4bot2}) / 2;
            bot(5, :) = (ceData{stMap.ch5bot1} + ceData{stMap.ch5bot2}) / 2;
            bot(6, :) = (ceData{stMap.ch6bot1} + ceData{stMap.ch6bot2}) / 2;    

            diff = top - bot;
            sum = top + bot;
            dos = double(diff)./double(sum);
            z = dos * m_per_diff_over_sum * 1e9;
            
            % Ch "7" is average of three central
            z(7, :) = (z(1, :) + z(2, :) + z(3, :))/3;
        end
        
        % returns {double 6 x N} each row is 1 kHz data.  The mapping of
        % row to hardware is
        % 1: X reticle
        % 2: Y reticle
        % 3: X wafer
        % 4: Y wafer
        % 5: X aerial image relative to wafer (drift X)
        % 6: Y aerial image relative to wafer (drift Y)
        function pos = getDmiPositionFromFileData(ceData)
            
            
            stMap = struct();
            stMap.dmi1 = 25;
            stMap.dmi2 = 26;
            stMap.dmi3 = 27;
            stMap.dmi4 = 28;
            
            dDMI_SCALE = 632.9907/4096; % dmi axes come in units of 1.5 angstroms
                                  % Convert to nm
                                 
            dErrU_ret = double(ceData{stMap.dmi1});
            dErrV_ret = double(ceData{stMap.dmi2});
            dErrU_waf = double(ceData{stMap.dmi3});
            dErrV_waf = double(ceData{stMap.dmi4});

            dXDat_ret = dDMI_SCALE * 1/sqrt(2) * (dErrU_ret + dErrV_ret);
            dYDat_ret = -dDMI_SCALE * 1/sqrt(2) * (dErrU_ret - dErrV_ret);
            dXDat_waf = -dDMI_SCALE * 1/sqrt(2) * (dErrU_waf + dErrV_waf);
            dYDat_waf = dDMI_SCALE * 1/sqrt(2) * (dErrU_waf - dErrV_waf);

            pos(1, :) = dXDat_ret;
            pos(2, :) = dYDat_ret;
            pos(3, :) = dXDat_waf; 
            pos(4, :) = dYDat_waf;
            
            % see getDmiPositionFromSampleData
            pos(5, :) = (5 * pos(3, :) + pos(1, :)) / 5; % drift x
            pos(6, :) = (-5 * pos(4, :) + pos(2, :)) / 5; % drift y
            
            
        end
        
        function d = getRawOfHeightSensorFromFileData(this, ceData)
            
            d = zeros(24, length(ceData{28})); 
            for n = 1 : 24
                d(n, :) = ceData{n};
            end
            
            % Rows 25 - 36 contain average of "cap a" and "cap b" over 
            % a 1000 us acquisition window
            for n = 1 : 12
                d(24 + n, :) = (d(n, :) + d(n + 12, :)) / 2;
            end
            
            
        end
        
        
        function d = getRawOfDmiFromFileData(ceData)
            
            stMap = struct();
            stMap.dmi1 = 25;
            stMap.dmi2 = 26;
            stMap.dmi3 = 27;
            stMap.dmi4 = 28;
                                 
            d(1, :) = double(ceData{stMap.dmi1});
            d(2, :) = double(ceData{stMap.dmi2});
            d(3, :) = double(ceData{stMap.dmi3});
            d(4, :) = double(ceData{stMap.dmi4});
            
        end
        
        function [dDose, dFocus] = getDoseAndFocusFromLogFilename(cName)
            
            cExpression = 'dose';
            [startIndex, endIndex] = regexp(cName, cExpression);
            dDose = str2num(cName(endIndex + 1 : endIndex + 1 + 1));


            cExpression = 'focus';
            [startIndex, endIndex] = regexp(cName, cExpression);
            dFocus = str2num(cName(endIndex + 1 : endIndex + 1 + 1));

        end
        
        
        
    end
    
    
end
