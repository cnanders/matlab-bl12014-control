classdef Uniformity < mic.Base
    
    properties
        
        cName = 'Uniformity'
        

        % UI:
        uieUnitVectorRx
        uieUnitVectorRy

        uiePathToImagesDir
        uieHexapodDelay

        uieCenterPixelR
        uieCenterPixelC

        uieIntrinsicDwellTime
        uieCSV

        uibOpenDir
        uibSetDirToLatest
        uibLoadImages

        uibNextImg
        uibPrevImg

        uibComputeCombo

        % Labels
        uitUnitVector
        uitCenterPixel
        uitActiveImgText



        uilCombos

        

        % Axes
        haImages
        haXSec
        haFieldUniformity
        haFieldUniformityAgg

        haRecipe

        uipSetup
        uipProfiles
        uipCompute
        
        cDirUniformity
        cDirSrc
        cDirThis

        dImgs = []
        dImgsField = []
        dImgsFieldRound = []
        dCenterIdx
        dActiveIdx = 1

        dResultVec = []
        dResultIdx = 1


    end
    
    properties (Access = private)
        
        clock
        uiClock
        
        dWidthName = 200
        dWidth = 1850;
        dHeight = 1040;
        
        
    end
    
    
    methods
        
        function letMeIn(this)
            this.msg('letMeIn()');
        end
        
        function this = Uniformity(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            
            
            this.cDirThis = fileparts(mfilename('fullpath'));
            this.cDirSrc = fullfile(this.cDirThis, '..', '..');
            
            this.init();
            
        end
        

        
        
        function build(this, hParent, dLeft, dTop)
            
            this.buildSetup(hParent, dLeft, dTop)
            this.buildProfiles(hParent, dLeft, dTop + 125)
            this.buildCompute(hParent, dLeft, dTop + 125)
            
        end
        
       
                
       
        
        function delete(this)
            
            
            
            
        end
        
        
       
        function onLoadLatest(this, src, evt)
            
        
            
            
            
        end
        
       
        
    end
    
    methods (Access = private)

        function buildSetup(this, hParent, dLeft, dTop)

            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Setup',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop + 10 ...
                this.dWidth - 20 ...
                150], hParent) ...
                );
            
            dLeft = dLeft + 20;
            
            
            
            dTop = dTop + 30;
            this.uiePathToImagesDir.build(hParent, dLeft, dTop, 300, 30);

            dTop = dTop + 10;
            this.uibOpenDir.build(hParent, dLeft + 310, dTop, 100, 30);
            this.uibSetDirToLatest.build(hParent, dLeft + 420, dTop, 100, 30);
            
            this.uibLoadImages.build(hParent, dLeft + 530, dTop, 100, 30);

            dTop = dTop + 45;
            this.uitUnitVector.build(hParent, dLeft, dTop, this.dWidthName, 30);
            
            dTop = dTop + 20;
            this.uieUnitVectorRx.build(hParent, dLeft, dTop, 100, 30);
            this.uieUnitVectorRy.build(hParent, dLeft + 110, dTop, 100, 30);

            dLeft = dLeft + 220;
            dTop = dTop - 20
            this.uitCenterPixel.build(hParent, dLeft, dTop, this.dWidthName, 30);

            dTop = dTop + 20;
            this.uieCenterPixelR.build(hParent, dLeft, dTop, 100, 30);
            this.uieCenterPixelC.build(hParent, dLeft + 110, dTop, 100, 30);

            
        end

        function buildCompute(this, hParent, dLeft, dTop)

            dPanelHeight = 700;
            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Compute',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                this.dWidth - 680 ...
                dTop + 50 ...
                560 ...
                    dPanelHeight], hParent) ...
                );



            this.uieIntrinsicDwellTime.build(hPanel, 20, 70, 100, 30);
                
            dTop = dTop + 40;
            this.uibComputeCombo.build(hPanel,  20, dTop, 100, 30);

            dTop = dTop + 40;
            this.uilCombos.build(hPanel, 20, dTop, 500, 150);

            dTop = dTop + 170;
            this.uieCSV.build(hPanel, 20, dTop, 500, 100);
            this.uieCSV.setMin(0);
            this.uieCSV.setMax(2);

        end

        function buildProfiles(this, hParent, dLeft, dTop)
            
            dPanelHeight = 700;
            hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Profiles',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([ ...
                dLeft ...
                dTop + 50 ...
                this.dWidth - 700 ...
                    dPanelHeight], hParent) ...
                );


            this.uibPrevImg.build(hPanel, dLeft + 20, 15, 40, 30);
            this.uitActiveImgText.build(hPanel, dLeft + 85, 17, 60, 30);
            this.uibNextImg.build(hPanel, dLeft + 130, 15, 40, 30);
            
            dTop = dTop + 40;
            dLeft = dLeft + 20;
            
            
            this.haImages = axes(...
                'Parent', hPanel, ...
                'Units', 'pixels', ...
                'Position', [ ...
                    dLeft , ...
                        dPanelHeight - 310, ...
                    500, ...
                    250] ...
                );
            
            this.haXSec = axes(...
                'Parent', hPanel, ...
                'Units', 'pixels', ...
                'Position', [ ...
                    dLeft + 550, ...
                        dPanelHeight - 310, ...
                    500, ...
                        250] ...
                );

            this.haFieldUniformity = axes(...
                'Parent', hPanel, ...
                'Units', 'pixels', ...
                'Position', [ ...
                    dLeft, ...
                        dPanelHeight - 450, ...
                    750, ...
                    90] ...
                );

            this.haFieldUniformityAgg = axes(...
                'Parent', hPanel, ...
                'Units', 'pixels', ...
                    'Position', [ ...
                        dLeft, ...
                            dPanelHeight - 600, ...
                        750, ...
                        90] ...
                    );
        this.haRecipe = axes(...
                        'Parent', hPanel, ...
                        'Units', 'pixels', ...
                            'Position', [ ...
                                dLeft + 800, ...
                                    dPanelHeight - 600, ...
                                250, ...
                                250] ...
                            );
        
        end
        
        
        function init(this)
            
          
            this.msg('init()');
            
            
            % Init labels:
            this.uitUnitVector = mic.ui.common.Text(...
                'cVal', 'Unit Vector',...
                'dFontSize', 14 ...
                );


            this.uitCenterPixel = mic.ui.common.Text(...
                'cVal', 'Center Pixel',...
                'dFontSize', 14 ...
                );

            this.uitActiveImgText = mic.ui.common.Text(...
                'cVal', sprintf('%d/%d', this.dActiveIdx, size(this.dImgs, 3)),...
                'dFontSize', 14 ...
                );
            
            % Init edit boxes:
            
            this.uieUnitVectorRx = mic.ui.common.Edit(...
                'cLabel', 'Rx', ...
                'cType', 'd' ...
                );
            this.uieUnitVectorRy = mic.ui.common.Edit(...
                'cLabel', 'Ry', ...
                'cType', 'd' ...
                );

            this.uieCenterPixelR = mic.ui.common.Edit(...
                'cLabel', 'Center Pixel R', ...
                'cType', 'd' ...
                );
            this.uieCenterPixelC = mic.ui.common.Edit(...
                'cLabel', 'Center Pixel C', ...
                'cType', 'd' ...
                );

            this.uiePathToImagesDir = mic.ui.common.Edit(...
                'cLabel', 'Path to Images Dir', ...
                'cType', 'c' ...
                );

            this.uieHexapodDelay = mic.ui.common.Edit(...
                'cLabel', 'Hexapod Delay (ms)', ...
                'cType', 'd' ...
                );

            this.uibOpenDir = mic.ui.common.Button(...
                'cText', 'Open Dir...', ...
                'fhDirectCallback', @this.onOpenDir ...
                );
            this.uibSetDirToLatest = mic.ui.common.Button(...
                'cText', 'Set Dir to Latest', ...
                'fhDirectCallback', @this.onSetDirToLatest ...
                );
            this.uibLoadImages = mic.ui.common.Button(...
                'cText', 'Load Images', ...
                'fhDirectCallback', @this.onLoadImages ...
                );
            this.uibNextImg = mic.ui.common.Button(...
                'cText', 'Next', ...
                'fhDirectCallback', @(src, evt) this.changeIndex(1) ...
                );
            this.uibPrevImg = mic.ui.common.Button(...
                'cText', 'Prev', ...
                'fhDirectCallback', @(src, evt) this.changeIndex(-1) ...
                );

            this.uibComputeCombo = mic.ui.common.Button(...
                'cText', 'Compute Combo', ...
                'fhDirectCallback', @this.onComputeCombo ...
                );
           

            this.uieIntrinsicDwellTime = mic.ui.common.Edit(...
                'cLabel', 'Intrinsic Dwell Time (ms)', ...
                'cType', 'd' ...
                );
            
            this.uilCombos =  mic.ui.common.List(...
                'lShowMove', false, ...
                'lShowRefresh', false, ...
                'lShowDelete', false, ...
                'cLabel', 'Wobble pairs', ...
                'fhOnChange', @this.handleSelectCombo ...
                );
            % Create multiline:
            this.uieCSV = mic.ui.common.Edit(...            
                'cLabel', 'CSV', ...
                    'xMax', 2, ...
                    'xMin', 0, ...
                'cType', 'c' ...
            );


            % Set default values:
            this.uieHexapodDelay.set(500);

            if (this.uieUnitVectorRx.get() == 0)
                this.uieUnitVectorRx.set(0.005);
            end
            if (this.uieUnitVectorRy.get() == 0)
                this.uieUnitVectorRy.set(0.005);
            end

            if (this.uieCenterPixelR.get() == 0)
                this.uieCenterPixelR.set(935);
            end
            if (this.uieCenterPixelC.get() == 0)
                this.uieCenterPixelC.set(485);
            end

            if (this.uieIntrinsicDwellTime.get() == 0)
                this.uieIntrinsicDwellTime.set(500);
            end
            
            
        end


        function onComputeCombo(this, src, evt)
            
            dFluxCenter = sum(sum(squeeze(this.dImgsField(:,:,this.dCenterIdx))));
            dMaxCenter = max(max(squeeze(this.dImgsField(:,:,this.dCenterIdx))));
           
            % Reshape the first 2 dimensions of the field uniformity images into a line:
            C = zeros(size(this.dImgsField, 3), size(this.dImgsField, 1) * size(this.dImgsField, 2) );
            for k = 1:size(this.dImgsFieldRound, 3)
                C(k, :) = reshape(this.dImgsField(:,:,k), 1, []);
            end
           
            % Define the target flat curve
            b = dMaxCenter*ones(size(C,2), 1);

            D = C';

            % Loop through choosing pairs of images and find best combination and coefficients:
            dResultVec = [];
            ct = 1;
            for k = 1:size(D, 2)
                for m = k+1:size(D, 2)
                    dCombo = [D(:, k), D(:, m)];
                    % Solve for the coefficients using non-negative least squares

                    dCoeff = lsqnonneg(dCombo, b);
                    dError = norm(b - dCombo * dCoeff);
                    
                    dResultVec(ct, 1) = dError;
                    dResultVec(ct, 2:3) = dCoeff;
                    dResultVec(ct, 4:5) = [k, m];


                    % Compute relative flux
                    dFluxLeft = sum(sum(squeeze(this.dImgsField(:,:,k))));
                    dFluxRight = sum(sum(squeeze(this.dImgsField(:,:,m))));
                    dDoseFac = (dFluxLeft * dCoeff(1)/(dCoeff(1) + dCoeff(2)) + dFluxRight * dCoeff(2)/(dCoeff(1) + dCoeff(2)))/dFluxCenter;
                    dResultVec(ct, 6) = dDoseFac;

                    % Compute uniformity:
                    dAgg = dCoeff(1)*this.dImgsField(:,:,k) + dCoeff(2)*this.dImgsField(:,:,m);


                    dUniformity = std(dAgg(:))/median(dAgg(:));
                    dResultVec(ct, 7) = dUniformity;
                    
                    ct = ct + 1;
                end
            end

            % Sort result vector by error:
            this.dResultVec = sortrows(dResultVec, 1);
            this.dResultIdx = 1;


            % store in list:
            this.uilCombos.setOptions({...
                sprintf('Error\t\t\t Coeff1   Coeff2   Img1     Img2    DoseFac   Uniformity') ...
                });
            for k = 1:15
                dResultVec = this.dResultVec(k, :);
                
                cVal = sprintf('%.0f\t %.3f\t    %.3f\t    %0.2d\t      %0.2d\t  %.3f\t %.3f', dResultVec);
                this.uilCombos.append(cVal);
            end
                
            this.uilCombos.setSelectedIndexes(uint8(2));

            
            this.handleSelectCombo();
        end

        function handleSelectCombo(this, src, evt)

            % Get the selected index:
            dIdx = double(this.uilCombos.getSelectedIndexes());
            if isempty(dIdx)
                dIdx = 2;
            end
            if length(dIdx) > 1
                dIdx = dIdx(end);
            end
            if dIdx < 2
                dIdx = 2;
            end
            this.dResultIdx = dIdx - 1;

            
            dCoefficients   = this.dResultVec(this.dResultIdx, 2:3);
            dBestIndex      = this.dResultVec(this.dResultIdx, 4:5);

            % Build CSV string:
            
            % Make sure the lower of the two coefficients is on the left
            if dCoefficients(1) > dCoefficients(2)
                dCoefficients   = flip(dCoefficients);
                dBestIndex      = flip(dBestIndex);
            end

            % Set the smaller dwell to 25 ms:
            dDwell1 = 25;
            dDwell2 = dCoefficients(2) * dDwell1 / dCoefficients(1) + this.uieIntrinsicDwellTime.get() * (dCoefficients(2) - dCoefficients(1));

            dIdx1 = dBestIndex(1) - this.dCenterIdx;
            dIdx2 = dBestIndex(2) - this.dCenterIdx;

            cCSV = sprintf('Rx (deg),Ry (deg),Dwell Time(ms) \n ');
            cCSV = [cCSV, sprintf('%.4f,%.4f,%d\n', ...
                            this.uieUnitVectorRx.get() * dIdx1, ...
                            this.uieUnitVectorRy.get() * dIdx1, ...
                            round(dDwell1))];
            cCSV = [cCSV, sprintf('%.4f,%.4f,%d', ...
                            this.uieUnitVectorRx.get() * dIdx2, ...
                            this.uieUnitVectorRy.get() * dIdx2, ...
                            round(dDwell2))];
            % Set csv:
            this.uieCSV.set(cCSV);

            % plot combination:
            dAgg = dCoefficients(1)*this.dImgsField(:,:,dBestIndex(1)) + dCoefficients(2)*this.dImgsField(:,:,dBestIndex(2));

            dAgg = dAgg / median(dAgg(:));
            dAgg = round(dAgg * 10)/ 10;

            axes(this.haFieldUniformityAgg);

            imagesc(dAgg);
            title('Field Uniformity Aggregate');
            colorbar;

            axes(this.haRecipe);
            dElms = zeros(size(this.dImgsField, 3), 1);
            dElms(dBestIndex(1)) = dCoefficients(1);
            dElms(dBestIndex(2)) = dCoefficients(2);
            stem(dElms, 'linewidth', 3);

            
        end

        function onOpenDir(this, src, evt)
            
            cPath = uigetdir('C:\Users\metmatlab\Pictures\MOD3-Uniformity-Cam-Wobble\');
            if cPath == 0
                return;
            end
            this.uiePathToImagesDir.set(cPath);
        end


        function onLoadImages(this, src, evt)
            
            cPath = this.uiePathToImagesDir.get();
            if isempty(cPath)
                msgbox('Please set the path to the images directory');
                return;
            end
            
            cPath = fullfile(cPath, '*.bmp');
            cFiles = dir(cPath);
            
            if isempty(cFiles)
                msgbox('No images found in the directory');
                return;
            end
            
            % Load the images
            this.dImgs = zeros( 151, 301, length(cFiles));
            this.dCenterIdx = ceil(length(cFiles)/2);

            % sort files by name:
            % Extract the names into a cell array
            names = {cFiles.name};

            % Convert the names to numerical values
            % Assuming the names are numbers stored as strings
            numValues = cellfun(@(x) str2double(regexp(x, '-?\d+(?=\.bmp)', 'match', 'once')), names);
            
            % Sort the numerical values and get the sorting indices
            [~, sortIdx] = sort(numValues);

            % Reorder the original array of structs
            cFiles = cFiles(sortIdx);

            
            for k = 1:length(cFiles)
                cFile = fullfile(cFiles(k).folder, cFiles(k).name);
                [~, d, ~] = fileparts(cFile);
                if (d == '0')
                    this.dCenterIdx = k;
                end
                this.msg(sprintf('Loading %s', cFile));
                img = medfilt2(sum(double(imread(cFile)), 3));
                this.msg(sprintf('Loaded %s', cFile));

                % Crop image to 150 x 300 px region around center pixel:
                dCenterR = this.uieCenterPixelR.get();
                dCenterC = this.uieCenterPixelC.get();
                img = img(dCenterR - 75:dCenterR + 75, dCenterC - 150:dCenterC + 150);

                this.dImgs(:,:,k) = img;
            end
            
            dBack = this.dImgs(:, [1:10, 290:300], :);
            dBack = mean(dBack(:));
            
            for k = 1:length(cFiles)
                this.dImgs(:,:,k) = this.dImgs(:,:,k) - dBack;
               
            end
            this.dImgs(this.dImgs < 0) = 0;

            % Grab inner 200 x 30 pixels of these images:
            this.dImgsField = this.dImgs(61:90, 51:250, :);
            this.dImgsFieldRound = zeros(size(this.dImgsField));

            % Normalize the field uniformity images:
            for k = 1:size(this.dImgsField, 3)
                
                dImg = this.dImgsField(:,:,k);
                dImg = dImg / median(dImg(:));                
                dImg = round(dImg * 10)/ 10;
                
                % Quantize images in steps of 0.1:
                this.dImgsFieldRound(:,:,k) = dImg;
            end

            this.dActiveIdx = this.dCenterIdx;

           

            this.updatePlots();
        end
        
        function changeIndex(this, increment)
            this.dActiveIdx = this.dActiveIdx + increment;
            if this.dActiveIdx < 1
                this.dActiveIdx = 1;
            end
            if this.dActiveIdx > size(this.dImgs, 3)
                this.dActiveIdx = size(this.dImgs, 3);
            end
            this.updatePlots();

        end

        function updatePlots(this)

            if isempty(this.dImgs)
                return;
            end

            % Update index label:
            this.uitActiveImgText.set(sprintf('%d/%d', this.dActiveIdx, size(this.dImgs, 3)));
            
            % Update the images plot
            axes(this.haImages);
            imagesc(squeeze(this.dImgs(:, :, this.dActiveIdx)));
            title(sprintf('Image %d', this.dActiveIdx));

            % Update the field uniformity plot
            axes(this.haFieldUniformity);
            imagesc(squeeze(this.dImgsFieldRound(:, :, this.dActiveIdx)));
            title('Field Uniformity');
            colorbar
            
            % Update the x-section plot
            axes(this.haXSec);
            
            xSecs = squeeze(mean((this.dImgs(70:80, :, :)), 1));



            % Plot all of xSecs but plot the active index a thicker line:
            hold off;
            for k = 1:size(xSecs, 2)
                if k == this.dActiveIdx
                    plot(xSecs(:, k), 'LineWidth', 4);
                else
                    plot(xSecs(:, k));
                end
                hold on;
            end
            hold off
            title('X-Section');
            
            
            
           

        end
      
        
        
        
    end
    
    
end

