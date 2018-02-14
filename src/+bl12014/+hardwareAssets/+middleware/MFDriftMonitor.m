% This is a bridge between hardware device and MATLAB UI

classdef MFDriftMonitor < mic.Base
    
    
    properties (Constant)
        u8RETICLE_U     = 1;
        u8RETICLE_V     = 2;
        u8WAFER_U       = 3;
        u8WAFER_V       = 4;
        
        u8FITMODEL_CUBIC_FIT           = 0
        u8FITMODEL_CUBIC_INTERPOLATION = 1
        
        u8HSMODEL_GEOMETRIC   = 0
        u8HSMODEL_CALIBRATION = 1
        
        
        dDMI_SCALE      = 1.5/10; % dmi axes come in units of 1.5 angstroms
                                  % Convert to nm
        
        % HS Geometry.  Important only for geometric interpolant
        dLaserAngle         = pi/180; % 1 degree
        dChannelOffsets     = [0, 0, 0, 5, 5, 5] * 1000; %um
        dChannelAngles      = [0, 2*pi/3, 4*pi/3, 0, 2*pi/3, 4*pi/3];
    end
    
    properties (Access = private)
        cInterpolantConfigDir     = ...
            fullfile(fileparts(mfilename('fullpath')),...
            '..', '..', '..', 'config', 'interpolants');

        clock
        lHasOwnClock = false
        
        % Update and interpolate intervals
        dUpdateInterval = 2
        
        
        
        % Handle to the MFDriftMonitor java interface
        javaAPI

        % Number of samples to average
        dNumSampleAverage = 10
            
        % Interpolant structure computed from calibration data
        stInterpolant = struct
        
        % Data: Internally keep track of all HS and DMI data
        dHSChannelData = [0 0 0 0 0 0]'
        dDMIData = [0 0 ; 0 0]
        
        % Computed Heigth sensor positions, [Rx, Ry, Z]
        dHSPositions = [0, 0, 0]'
        
        % Interpolants:
        stGeometricInterpolant
        stCalibrationInterpolant
        stCalbrationInterpolant
        

        
        % Default interpolant anme
        cDefaultData = fullfile(fileparts(mfilename('fullpath')),...
            '..', '..', '..', 'config', 'interpolants', 'default-geometric-data.mat')

        
        u8FitModel
        u8HSModel 
    end
    
    methods
        
        function this = MFDriftMonitor(varargin)
            
             for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
             end
            

            % Inital models
            this.u8FitModel = this.u8FITMODEL_CUBIC_INTERPOLATION;
            this.u8HSModel  = this.u8HSMODEL_GEOMETRIC;
            
            % Loads calibration data.  Set this on init
            stData = load(this.cDefaultData); 
            this.initCalibrationInterpolant(stData);
            this.initGeometricInterpolant();
            
            % If there is no clock then make one:
            if isempty(this.clock)
                this.lHasOwnClock = true;
                this.clock = mic.Clock('MFDriftMonitorTimer', 2);
            end
            
            % Init clock update tasks:
            this.clock.add(@this.onClock, this.id(), this.dUpdateInterval);
            
        end
        
         function delete(this)

           % Clean up clock tasks
            if isvalid(this.clock) && ...
               this.clock.has(this.id())
                this.clock.remove(this.id());
            end
            
            if(this.lHasOwnClock )
                this.clock.stop();
                delete(this.clock);
                fprintf('Deleting MFDriftMonitorClock');
            end
            

            
        end
        
        
        function connect(this)
            if ~this.isConnected()
                this.javaAPI.connect();
            end
        end
        
        function disconnect(this)
            if this.isConnected()
                this.javaAPI.disconnect();
            end
        end
        
        function setDMIZero(this)
            this.javaAPI.dmiResetPosition();
        end
        
        function lVal = isConnected(this)
            lVal = this.javaAPI.isConnected();
        end
        
        function setSampleAverage(this, dNumSampleAverage)
            this.dNumSampleAverage = dNumSampleAverage;
        end
        
        function dNumSampleAverage = getSampleAverage(this)
            dNumSampleAverage = this.dNumSampleAverage;
        end
        
        function setModelType(this, u8ModelType)
            switch u8ModelType
                case this.u8FITMODEL_CUBIC_FIT
                    this.u8FitModel = this.u8FITMODEL_CUBIC_FIT;
                case this.u8FITMODEL_CUBIC_INTERPOLATION
                    this.u8FitModel = this.u8FITMODEL_CUBIC_INTERPOLATION;
            end
        end
        
        function u8ModelType = getModelType(this)
            u8ModelType = this.u8FitModel;
        end
       

                
        function l = isReady(this)
            l = this.javaAPI.isMonitoring();  
        end
        
        function dVal = getHeightSensorValue(this, u8Channel)
            switch u8Channel
                case {1, 2, 3, 4, 5, 6}
                    dVal = this.dHSChannelData(u8Channel);
                case {7, 8, 9}
                    dVal = this.dHSPositions(u8Channel - 6);
            end
        end
        
        function dVal = getDMIValue(this, u8Channel)
            switch u8Channel
                case {1, 2}
                    dVal = this.dDMIData(1, u8Channel);
                case {3, 4}
                    dVal = this.dDMIData(2, u8Channel - 2);
                    
                otherwise
                    fprintf('shouldnt get here, channel = %d\n', u8Channel);
                    dVal = 0;
            end
        end
        
        function loadInterpolant(this, cName)
            load(fullfile(this.cInterpolantConfigDir, [cName, '.mat']));
            this.stActiveInterpolant = stInterpolant;
        end
        
        
    end
    
    
    methods (Access = protected)
        
        function onClock(this)
            % First update Channel data:
            this.updateChannelData();
            
            % Next update HS positions:
%             this.updateHSPositions();
            
        end
        
        % Updates HS and DMI data from actual device
        function updateChannelData(this)
            dSampleAve = this.javaAPI.getSampleDataAvg(this.dNumSampleAverage);
            
            % Set HS data:
            
                % CWC has calibrated slopes and offsets so that return value is
                % angstroms away from design focal point
%                 dHSRawData = dSampleAve.getHsData();
                this.dHSChannelData = this.javaAPI.hsGetPositions(dSampleAve);
                
            
            % Set DMI data:
             
                % Here we need to extract from sample itself since CWC
                % function takes difference between Ret and Wafer
                dDMIRawData = double(dSampleAve.getDmiData());
                  
                dErrU_ret = dDMIRawData(this.u8RETICLE_U);
                dErrV_ret = dDMIRawData(this.u8RETICLE_V);
                
                dErrU_waf = dDMIRawData(this.u8WAFER_U);
                dErrV_waf = dDMIRawData(this.u8WAFER_V);
                
                dXDat_ret = this.dDMI_SCALE * 1/sqrt(2) * (dErrU_ret + dErrV_ret);
                dYDat_ret = this.dDMI_SCALE * 1/sqrt(2) * (dErrU_ret - dErrV_ret);
                
                dXDat_waf = this.dDMI_SCALE * 1/sqrt(2) * (dErrU_waf + dErrV_waf);
                dYDat_waf = this.dDMI_SCALE * 1/sqrt(2) * (dErrU_waf - dErrV_waf);
                
                this.dDMIData = [dXDat_ret, dYDat_ret; dXDat_waf, dYDat_waf];

        end
        
        function updateHSPositions(this)
            switch this.u8HSModel
                case this.u8HSMODEL_GEOMETRIC
                    stFitModel = this.stGeometricInterpolant;
                    
                case this.u8HSMODEL_CALIBRATION
                    stFitModel = this.stCalibrationInterpolant;
            end
            
            switch this.u8FitModel
                case this.u8FITMODEL_CUBIC_INTERPOLATION
                    g = @(R) stFitModel.fhCubicInterpolant(R(1), R(2), R(3));
                    
                case this.u8FITMODEL_CUBIC_FIT
                    g = @(R) stFitModel.fhCubicFit(R(1), R(2), R(3));
                    
            end
            
            E = @(R) sqrt(sum(abs((g(R)' - this.dHSChannelData)).^2));
            
            % Find initial guess using linear estimator
            x0 = stFitModel.fhLinEst(this.dHSChannelData);

            options = optimset('TolX', 1e-5, 'TolFun', 1e-6);
            [X,FVAL,EXITFLAG,OUTPUT] = fminsearch(E, x0(2:end), options);

            this.dHSPositions = X;

            
        end
        
        

        

        function initCalibrationInterpolant(this, stCalibrationData)
            
            % Calibration interpolant
            
            % Load height sensor data.
            RxIdx   =  stCalibrationData.RxIdx; % Rx values of calibration in mrad
            RyIdx   =  stCalibrationData.RyIdx; % Ry values of calibration in mrad
            zIdx    =  stCalibrationData.zIdx; % Z values of calibration in um

            [RX, RY, Z] = ndgrid(RxIdx, RyIdx, zIdx);

            % Channel readings is a N x 6 array where N =
            %                   length(zIdx)*length(RxIdx)*length(RyIdx)
            %
            % Ordering of channel readings should follow [RX(:) RY(:) Z(:)]
            % where [RX, RY, Z] = ndgrid(RxIdx, RyIdx, zIdx);
            
            dChannelReadings = stCalibrationData.dChannelReadings;
            
            % Build Interpolants:

            % Gridded interpolant
            V = cell(1, 6);
            siCh = {};
            [sr, sc, s3] = size(RX);

            for k = 1:6
                V{k} = reshape(dChannelReadings(:,k), sr, sc, s3);
                siCh{k} = griddedInterpolant(RX, RY, Z, V{k}, 'cubic'); %#ok<AGROW>
            end

            fhCubicInterpolant = @(rx, ry, z) cellfun(@(lambdaCH) lambdaCH(rx, ry, z), siCh);

            dN = length(RX(:));

            % Build T matrices:
            T1 = [ones(dN, 1), RX(:), RY(:), Z(:)];
            T2 = [ones(dN, 1), RX(:), RX(:).^2, RY(:), RY(:).^2, Z(:), Z(:).^2];
            T3 = [ones(dN, 1), RX(:), RX(:).^2, RX(:).^3, RY(:), RY(:).^2, RY(:).^3, Z(:), Z(:).^2, Z(:).^3];

            % Solve least squares solution for coefficients:
            k1 = T1 \ dChannelReadings;
            k2 = T2 \ dChannelReadings;
            k3 = T3 \ dChannelReadings;

            fhLinEst    = @(dChanVals) k1' \ dChanVals;
            fhLinFit    = @(rx, ry, z) [1, rx,  ry,  z]*k1;
            fhQuadFit   = @(rx, ry, z) [1, rx, rx^2, ry, ry^2,z, z^2]*k2;
            fhCubicFit  = @(rx, ry, z) [1, rx, rx^2, rx^3, ry, ry^2, ry^3, z, z^2, z^3]*k3;
            
            this.stCalibrationInterpolant = struct;
            
            this.stCalibrationInterpolant.fhLinEst            = fhLinEst;
            this.stCalibrationInterpolant.fhCubicFit          = fhCubicFit;
            this.stCalibrationInterpolant.fhCubicInterpolant  = fhCubicInterpolant;
            
            
        end
        
        
        function initGeometricInterpolant(this)
            
            % Measured height per channel:
            
            dX = @(Rx, Ry, z, k) ...
                (z + this.dChannelOffsets(k) * tan(this.dLaserAngle)) .* ...
                1./(sec(this.dChannelAngles(k)) .* tan(this.dLaserAngle) + tan(Ry) - tan(Rx) .* tan(this.dChannelAngles(k)));
            
            dY = @(Rx, Ry, z, k) dX(Rx, Ry, z, k) .* tan(this.dChannelAngles(k));
            
            
            dZ = @(Rx, Ry, z0, k) ...
                z0 - tan(Ry).*dX(Rx, Ry, z0, k) + tan(Rx).*dY(Rx, Ry, z0, k);
            
            
            fhCh = @(Rx, Ry, z, k) ...
                dZ(Rx/1000, Ry/1000, z, k);
            
            
            fhChannelReadings = @(Rx, Ry, z) [fhCh(Rx, Ry, z, 1), fhCh(Rx, Ry, z, 2), fhCh(Rx, Ry, z, 3),...
                fhCh(Rx, Ry, z, 4), fhCh(Rx, Ry, z, 5), fhCh(Rx, Ry, z, 6)];
            
            % Generate simulated height sensor data.
            zIdx = -50:4:50;
            RxIdx = linspace(-2, 2, 41); % mRad
            RyIdx = linspace(-2, 2, 41); % mRad

            [RX, RY, Z] = ndgrid(RxIdx, RyIdx, zIdx);

            dChannelReadings = fhChannelReadings(RX(:), RY(:), Z(:));
            
            % Build Interpolants:

            % Gridded interpolant
            V = cell(1, 6);
            siCh = {};
            [sr, sc, s3] = size(RX);

            for k = 1:6
                V{k} = reshape(dChannelReadings(:,k), sr, sc, s3);
                siCh{k} = griddedInterpolant(RX, RY, Z, V{k}, 'cubic'); %#ok<AGROW>
            end

            fhCubicInterpolant = @(rx, ry, z) cellfun(@(lambdaCH) lambdaCH(rx, ry, z), siCh);

            % Build 1-, 2-, 3-D Fit models
            [sr, sc, s3] = size(RX);
            dN = length(RX(:));

            % Build T matrices:
            T1 = [ones(dN, 1), RX(:), RY(:), Z(:)];
            T2 = [ones(dN, 1), RX(:), RX(:).^2, RY(:), RY(:).^2, Z(:), Z(:).^2];
            T3 = [ones(dN, 1), RX(:), RX(:).^2, RX(:).^3, RY(:), RY(:).^2, RY(:).^3, Z(:), Z(:).^2, Z(:).^3];

            % Solve least squares solution for coefficients:
            k1 = T1 \ dChannelReadings;
            k2 = T2 \ dChannelReadings;
            k3 = T3 \ dChannelReadings;

            fhLinEst    = @(dChanVals) k1' \ dChanVals;
            fhLinFit    = @(rx, ry, z) [1, rx,  ry,  z]*k1;
            fhQuadFit   = @(rx, ry, z) [1, rx, rx^2, ry, ry^2,z, z^2]*k2;
            fhCubicFit  = @(rx, ry, z) [1, rx, rx^2, rx^3, ry, ry^2, ry^3, z, z^2, z^3]*k3;
            
            this.stGeometricInterpolant = struct;
            
            this.stGeometricInterpolant.fhLinEst            = fhLinEst;
            this.stGeometricInterpolant.fhCubicFit          = fhCubicFit;
            this.stGeometricInterpolant.fhCubicInterpolant  = fhCubicInterpolant;
            
            this.stGeometricInterpolant.RxIdx   = RxIdx;
            this.stGeometricInterpolant.RyIdx   = RyIdx;
            this.stGeometricInterpolant.zIdx    = zIdx;
            this.stGeometricInterpolant.dChannelReadings = dChannelReadings;
            
            
        end
        
        
       
    end
    
    
     
    
end

