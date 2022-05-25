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
            pos(5, :) = (-5 * pos(3, :) + pos(1, :)) / 5; % drift x
            pos(6, :) = (-5 * pos(4, :) + pos(2, :)) / 5; % drift y
            
            
        end
        
        function d = getRawOfHeightSensorFromFileData(ceData)
            
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
        
        % Returns {double 4xm} x and y position of reticle and wafer in nm
        % @param {ArrayList<SampleData> 1x1} samples - sample data
        % @return {double 6xm} - position data of reticle and wafer nm
        % @return(1, :) {double 1xm} - xReticle
        % @return(2, :) {double 1xm} - yReticle
        % @return(3, :) {double 1xm} - xWafer
        % @return(4, :) {double 1xm} - yWafer
        % @return(5, :) {double 1xm} - driftX
        % @return(6, :) {double 1xm} - driftY

        function pos = getDmiPositionFromSampleData(samples)
            
            
            dmi = bl12014.MfDriftMonitorUtilities.getRawOfDmiFromSampleData(samples);
            
            % dmi axes come in units of 1.5 angstroms
            % convert to nm
                                  
            dDMI_SCALE = 632.9907/4096; 
                                 
            dErrU_ret = dmi(1, :);
            dErrV_ret = dmi(2, :);
            dErrU_waf = dmi(3, :);
            dErrV_waf = dmi(4, :);
            
            pos = zeros(4, samples.size());

            pos(1, :) = dDMI_SCALE * 1/sqrt(2) * (dErrU_ret + dErrV_ret); % x ret
            pos(2, :) = -dDMI_SCALE * 1/sqrt(2) * (dErrU_ret - dErrV_ret); % y ret
            pos(3, :) = -dDMI_SCALE * 1/sqrt(2) * (dErrU_waf + dErrV_waf); % x wafer
            pos(4, :) = dDMI_SCALE * 1/sqrt(2) * (dErrU_waf - dErrV_waf); % y wafer
            
            % Drift signal of aerial image is the 
            % drift signal we use for reticle correction divided by
            % the magnification 
            pos(5, :) = (-5 * pos(3, :) + pos(1, :)) / 5; % drift x
            pos(6, :) = (-5 * pos(4, :) + pos(2, :)) / 5; % drift y
            
            
            %{ 
            From Java code
            double errX =  5 * xWafer + xReticle;
            double errY = -5 * yWafer + yReticle;
            %}
            
            
        end
        
        % Returns {double 4xm} x and y position of reticle and wafer in nm
        % @param {ArrayList<SampleData> 1x1} samples - sample data
        % @return {double 4xm} - position data of reticle and wafer nm
        % @return(1, :) {double 1xm} - uReticle
        % @return(2, :) {double 1xm} - vReticle
        % @return(3, :) {double 1xm} - uWafer
        % @return(4, :) {double 1xm} - vWafer

        function d = getRawOfDmiFromSampleData(samples)
            
            % Reshape to a 4xn matrix of doubles.  
            
            % Mirrors are mounted 45 degrees relative to x and y
            % row1 = uReticle
            % row2 = vReticle
            % row3 = uWafer
            % row4 = vWafer
            
            % samples is zero-indexed because uses Java interface
            d = zeros(4, samples.size());
            for n = 0 : samples.size() - 1
                d(:, n + 1) = double(samples.get(n).getDmiData());
            end
                  
           
        end
        
        
        function d = getRawOfHeightSensorFromSampleData(samples)
            
            d = zeros(36, samples.size());
            
            % Samples.get() is zero-indexed since implementing java
            % interface
            for n = 0 : samples.size() - 1
                d(1 : 24, n + 1) = samples.get(n).getHsData();
            end
            
            % Rows 25 - 36 contain average of "cap a" and "cap b" over 
            % a 1000 us acquisition window
            for n = 1 : 12
                d(24 + n, :) = (d(n, :) + d(n + 12, :)) / 2;
            end
                                                    
        end
        
        % Returns a {double 6xm} time series of height zensor z in nm of
        % all six channels
        % @param {ArrayList<SampleData> 1x1} samples - sample data
        % @return {double 6xm} - height sensor z (nm) of six channels at 1 kHz
        % @return(1, :) {double 1xm} - z 5:30 (ch 1)
        % @return(2, :) {double 1xm} - z 9:30 (ch 2)
        % @return(3, :) {double 1xm} - z 1:30 (ch 3)
        % @return(4, :) {double 1xm} - ang 0:30 (ch 4)
        % @return(5, :) {double 1xm} - ang 4:30 (ch 5)
        % @return(6, :) {double 1xm} - ang 8:30 (ch 6)
        function z = getHeightSensorZFromSampleData(samples)
            
            
            m_per_diff_over_sum = 120e-6/2;  

            hsraw = zeros(24, samples.size());
            
            % Samples.get() is zero-indexed since implementing java
            % interface
            for n = 0 : samples.size() - 1
                hsraw(:, n + 1) = samples.get(n).getHsData();
            end
            
            
            top = zeros(6, samples.size());
            bot = zeros(6, samples.size());
                
            % Build a map of array index to physical configuration
            
            % time 0 us - 500 us use side "a" capacitor
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

            % time 500 us - 1000 us use side "b" capacitor
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
            
            % Average ADC values from each cap to get 1 ms of data
            
            top(1, :) = (hsraw(stMap.ch1top1, :) + hsraw(stMap.ch1top2, :)) / 2;
            top(2, :) = (hsraw(stMap.ch2top1, :) + hsraw(stMap.ch2top2, :)) / 2;
            top(3, :) = (hsraw(stMap.ch3top1, :) + hsraw(stMap.ch3top2, :)) / 2;
            top(4, :) = (hsraw(stMap.ch4top1, :) + hsraw(stMap.ch4top2, :)) / 2;
            top(5, :) = (hsraw(stMap.ch5top1, :) + hsraw(stMap.ch5top2, :)) / 2;
            top(6, :) = (hsraw(stMap.ch6top1, :) + hsraw(stMap.ch6top2, :)) / 2; 

            bot(1, :) = (hsraw(stMap.ch1bot1, :) + hsraw(stMap.ch1bot2, :)) / 2;
            bot(2, :) = (hsraw(stMap.ch2bot1, :) + hsraw(stMap.ch2bot2, :)) / 2;
            bot(3, :) = (hsraw(stMap.ch3bot1, :) + hsraw(stMap.ch3bot2, :)) / 2;
            bot(4, :) = (hsraw(stMap.ch4bot1, :) + hsraw(stMap.ch4bot2, :)) / 2;
            bot(5, :) = (hsraw(stMap.ch5bot1, :) + hsraw(stMap.ch5bot2, :)) / 2;
            bot(6, :) = (hsraw(stMap.ch6bot1, :) + hsraw(stMap.ch6bot2, :)) / 2;   
            
            diff = top - bot;
            sum = top + bot;
            dos = double(diff)./double(sum);
            z = dos * m_per_diff_over_sum * 1e9;
            
            % Ch "7" is average of three central
            z(7, :) = (z(1, :) + z(2, :) + z(3, :))/3;
        end
        
        % @param {char 1xm} cStage - 'wafer' or 'reticle'
        % @param {char 1xm} cFolder - path to FEM log folder
        % @param {handle 1x1} hX - handle to axes to plot x data
        % @param {handle 1x1} hY - handle to axes to plot y data
        function plotDriftOfStageDuringFEM(cStage, cPathOfDir, hX, hY)
            
            cSortBy = 'date';
            cSortMode = 'ascend';
            cFilter = '*.txt';
            cecFiles = mic.Utils.dir2cell(...
                cPathOfDir, ...
                cSortBy, ...
                cSortMode, ...
                cFilter ...
            );

            dDriftX = zeros(1, length(cecFiles)); 
            dDriftY = zeros(1, length(cecFiles));

            dFocus = zeros(1, length(cecFiles)); 
            dDose = zeros(1, length(cecFiles)); 


            for j = 1 : length(cecFiles) 

                cName = cecFiles{j};
                cPath = fullfile(cPathOfDir, cName);

                ceData = bl12014.MfDriftMonitorUtilities.getDataFromLogFile(cPath);
                ceData = bl12014.MfDriftMonitorUtilities.removePartialsFromFileData(ceData);
                dDmi = bl12014.MfDriftMonitorUtilities.getDmiPositionFromFileData(ceData);

                switch cStage
                    case 'reticle'
                        dX = dDmi(1, :);
                        dY = dDmi(2, :);
                    case 'wafer'
                        dX = dDmi(3, :);
                        dY = dDmi(4, :);
                
                end
                
                % Perform linear fit then get magnitude of the fit

                dSamples = 1:length(dX);
                dPX = polyfit(dSamples, dX, 1);
                dPY = polyfit(dSamples, dY, 1);
                dXFit = polyval(dPX, dSamples);
                dYFit = polyval( dPY, dSamples);


                %dDriftX(j) = max(dXfit) - min(dXfit);
                % dDriftY(j) = max(dYfit) - min(dYfit);
                
                dDriftX(j) = dXFit(end) - dXFit(1);
                dDriftY(j) = dYFit(end) - dYFit(1);
   
                [dDoseNow, dFocusNow] = bl12014.MfDriftMonitorUtilities.getDoseAndFocusFromLogFilename(cName);
                dFocus(j) = dFocusNow;
                dDose(j) = dDoseNow;

            end

            % unset index shot, written first
           
            dDriftX(1) = [];
            dDriftY(1) = [];
            
            dFocus(1) = [];
            dDose(1) = [];

            % build fem matrix

            dNumDose = max(dDose);
            dNumFocus = max(dFocus);

            dDriftXFem = zeros(dNumFocus, dNumDose);
            dDriftYFem = zeros(dNumFocus, dNumDose);
           

            for j = 1 : length(dDriftX)    
                dDriftXFem(dFocus(j), dDose(j)) = dDriftX(j);
                dDriftYFem(dFocus(j), dDose(j)) = dDriftY(j);
            end

            cColormapNormal = 'parula';


            imagesc(hX, dDriftXFem)
            colorbar(hX)
            colormap(hX,  cColormapNormal) 
            cTitle = [...
                'X drift (nm) ', ...
                sprintf('avg = %1.2f, ', mean2(dDriftXFem)), ...
                sprintf('std = %1.2f, ', std2(dDriftXFem)), ...
                sprintf('min = %1.2f, ', min(min(dDriftXFem))), ...
                sprintf('max = %1.2f', max(max(dDriftXFem))) ...
            ];
            title(hX, cTitle);
            xlabel(hX, 'Dose Col')
            ylabel(hX, 'Focus Col')

            % Y
            imagesc(hY, dDriftYFem)
            colorbar(hY)
            colormap(hY, cColormapNormal) 
            cTitle = [...
                'Y drift (nm) ', ...
                sprintf('avg = %1.2f, ', mean2(dDriftYFem)), ...
                sprintf('std = %1.2f, ', std2(dDriftYFem)), ...
                sprintf('min = %1.2f, ', min(min(dDriftYFem))), ...
                sprintf('max = %1.2f', max(max(dDriftYFem))) ...
            ];
            title(hY, cTitle);
            xlabel(hY, 'Dose Col')
            ylabel(hY, 'Focus Col')

            
        end
        
        % Creates a quiver plot of the drift of a stage (wafer or reticle)
        % from a folder of FEM DMI logs
         % @param {char 1xm} cStage - 'wafer' or 'reticle'
        % @param {char 1xm} cFolder - path to FEM log folder
        % @param {handle 1x1} h - handle to axes to plot
        function quiverDriftOfStageDuringFEM(varargin)
            
            % Input parsing
            p = inputParser;
            addParameter(p, 'cStage', 'wafer', @(x) ischar(x));
            addParameter(p, 'cPathOfDir', '', @(x) ischar(x));
            addParameter(p, 'h', @(x) isscalar(x) && ishandle(x));
            addParameter(p, 'cTitle', 'Drift', @(x) ischar(x));
            addParameter(p, 'lShowLabels', true, @(x) islogical(x));
            addParameter(p, 'lShowAxis', true, @(x) islogical(x));
            addParameter(p, 'lShowTitle', true, @(x) islogical(x));
            addParameter(p, 'lNormalize', false, @(x) islogical(x));
            addParameter(p, 'dMax', 10, @(x) isnumeric(x));
            addParameter(p, 'lShowColorbar', true, @(x) islogical(x));
            addParameter(p, 'dWidthOfAxesBorder', 1, @(x) isnumeric(x));

            parse(p, varargin{:});
            
            cStage = p.Results.cStage;
            cPathOfDir = p.Results.cPathOfDir;
            h = p.Results.h;
            cTitle = p.Results.cTitle;
            lShowLabels = p.Results.lShowLabels;
            lShowAxis = p.Results.lShowAxis;
            lShowTitle = p.Results.lShowTitle;
            lNormalize = p.Results.lNormalize;
            dMax = p.Results.dMax;
            lShowColorbar = p.Results.lShowColorbar;
            dWidthOfAxesBorder = p.Results.dWidthOfAxesBorder;
            
            if ~lShowAxis
                axis(h, 'off')
            end
            

            
            cSortBy = 'date';
            cSortMode = 'ascend';
            cFilter = '*.txt';
            cecFiles = mic.Utils.dir2cell(...
                cPathOfDir, ...
                cSortBy, ...
                cSortMode, ...
                cFilter ...
            );

            dDriftX = zeros(1, length(cecFiles)); 
            dDriftY = zeros(1, length(cecFiles));

            dFocus = zeros(1, length(cecFiles)); 
            dDose = zeros(1, length(cecFiles)); 
            
            if length(cecFiles) == 0
                return
            end
            


            for j = 1 : length(cecFiles) 

                cName = cecFiles{j};
                cPath = fullfile(cPathOfDir, cName);

                ceData = bl12014.MfDriftMonitorUtilities.getDataFromLogFile(cPath);
                ceData = bl12014.MfDriftMonitorUtilities.removePartialsFromFileData(ceData);
                dDmi = bl12014.MfDriftMonitorUtilities.getDmiPositionFromFileData(ceData);

                switch cStage
                    case 'reticle'
                        dX = dDmi(1, :);
                        dY = dDmi(2, :);
                    case 'wafer'
                        dX = dDmi(3, :);
                        dY = dDmi(4, :);
                
                end
                
                % Perform linear fit then get magnitude of the fit

                dSamples = 1:length(dX);
                dPX = polyfit(dSamples, dX, 1);
                dPY = polyfit(dSamples, dY, 1);
                dXFit = polyval(dPX, dSamples);
                dYFit = polyval( dPY, dSamples);


                %dDriftX(j) = max(dXfit) - min(dXfit);
                % dDriftY(j) = max(dYfit) - min(dYfit);
                
                dDriftX(j) = dXFit(end) - dXFit(1);
                dDriftY(j) = dYFit(end) - dYFit(1);
   
                [dDoseNow, dFocusNow] = bl12014.MfDriftMonitorUtilities.getDoseAndFocusFromLogFilename(cName);
                dFocus(j) = dFocusNow;
                dDose(j) = dDoseNow;

            end

            % unset index shot, written first
           
            dDriftX(1) = [];
            dDriftY(1) = [];
            
            dFocus(1) = [];
            dDose(1) = [];
            
            % build fem matrix

            dNumDose = max(dDose);
            dNumFocus = max(dFocus);

            dDriftXFem = zeros(dNumFocus, dNumDose);
            dDriftYFem = zeros(dNumFocus, dNumDose);
            dDriftXYFem = zeros(dNumFocus, dNumDose);
           

            for j = 1 : length(dDriftX)    
                dDriftXFem(dFocus(j), dDose(j)) = dDriftX(j);
                dDriftYFem(dFocus(j), dDose(j)) = dDriftY(j);
                dDriftXYFem(dFocus(j), dDose(j)) = sqrt(dDriftX(j)^2 + dDriftY(j)^2);
            end

            
            dLimits = [0 max(max(dDriftXYFem))];
            if lNormalize
                dLimits(2) = dMax;
            end

            cColormapNormal = 'cool';
            imagesc(dDriftXYFem, dLimits);
            
            if lShowColorbar
                colorbar(h)
            end
            
            colormap(h,  cColormapNormal) 
            hold on;
            
            quiver(h, dDose, dFocus, dDriftX, dDriftY, 'k');
            set(h, 'ydir', 'reverse');
            %{
            if lShowTitle
                cTitle = [...
                    'Drift (nm) ', ...
                    sprintf('avg = %1.2f, ', mean2(dDriftXYFem)), ...
                    sprintf('std = %1.2f, ', std2(dDriftXYFem)), ...
                    sprintf('min = %1.2f, ', min(min(dDriftXYFem))), ...
                    sprintf('max = %1.2f', max(max(dDriftXYFem))) ...
                ];
                title(h, cTitle);
            end
            %}
            if lShowTitle
                title(h, cTitle);
            end
            if lShowLabels
                xlabel(h, 'Dose')
                ylabel(h, 'Focus')
            end
            
            if ~lShowAxis
                % axis(h, 'off')
                set(h, 'xtick', [], 'ytick', []);
                
            end

            set(h, 'LineWidth', dWidthOfAxesBorder)
           

            
        end
        

        % Returns the low frequency velocity (nm) of the aerial image relative to the
        % wafer over the last 1 second. 
        % @param {ArrayList<SampleData> 1x1} samples - sample data
        
        function [dVelX, dVelY] = getVelocityOfAerialImageFromSampleData(samples)
            
            dDmi = bl12014.MfDriftMonitorUtilities.getDmiPositionFromSampleData(samples);
            
            % linear fit and then  peak to valley
            dTime = [0 : length(dDmi(5, :)) - 1] * 1e-3;

            dCoeffX = polyfit(dTime, dDmi(5, :), 1);
            dCoeffY = polyfit(dTime, dDmi(6, :), 1);

            dFitX = polyval(dCoeffX, dTime);
            dFitY = polyval(dCoeffY, dTime);

            dVelX = max(dFitX) - min(dFitX);
            dVelY = max(dFitY) - min(dFitY);                         
           
        end
        
        % Returns the low frequency acceleration (nm) of the aerial image relative to the
        % wafer over the last 1 second. 
        % @param {ArrayList<SampleData> 1x1} samples - sample data
        
        function [dAccX, dAccY] = getAccelerationOfAerialImageFromSampleData(samples)
            
            dDmi = bl12014.MfDriftMonitorUtilities.getDmiPositionFromSampleData(samples);
            
            % 2nd order fit and then return 2 x 2nd order coefficient
            dTime = [0 : length(dDmi(5, :)) - 1] * 1e-3;

            dCoeffX = polyfit(dTime, dDmi(5, :), 2);
            dCoeffY = polyfit(dTime, dDmi(6, :), 2);            

            dAccX = 2*dCoeffX(1);
            dAccY = 2*dCoeffY(1);                        
           
        end
        
        
        
        
    end
    
    
end
