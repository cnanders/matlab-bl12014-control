% This class is Antoine's idea of a direct translator of Carl's classes to
% MATLAB.  The idea is to expose all relevant methods from Java into MATLAB
% so that this translation can be directly tested.  
%
% In terms of MIC, this can be plugged directly into the UI interface,
% although for coupled axes, it may require an additional bridge.
%
% To defer connection to stage, pass a function handle that can return the
% stage into the property fhStageGetter.  This allows instances of
% CXROJavaStageAPI to be created with the ability to defer connection to
% their stages.
%
% General use case for this class is:
%
% 1) Instantiate passing either jStage or fhStageGetter (function when
% called returns stage. Public property isStageDefined will return false
% until stage is defined.
%
% 2) Call connect(): connects to stage, getting stage using fhStageGetter
% if the stage is not yet defined
%
% 3) Stage may need indexing, check with isInitialized(), then use method
% home() to initialize


classdef CXROJavaStageAPI < handle
    properties(Constant)
        RESULTENUM = {'OK', '', 'BUSY', 'UNREACHABLE', 'LIMIT_ERROR', ...
                        'STOPPED', 'LOCKED', 'DISABLED', 'UNINITIALIZED', 'DISCONNECTED'};
    end
    properties
        jStage = []
        cJarPath
        isStageDefined = false
        
        fhStageGetter % Allows for the deferred initialization of stage
    end
    
    methods
        % Constructor:
        function this = CXROJavaStageAPI(varargin)
            for k = 1:2:length(varargin)
                this.(varargin{k}) = varargin{k+1};
            end
            
            if ~isempty(this.jStage)
                this.isStageDefined = true;
            end
        end
        
        function setStage(this, oStage)
            if isa(oStage, 'function_handle')
                this.jStage = oStage();
            else
                this.jStage = oStage;
            end
        end
        
        function lOut = connect(this)
            if isempty(this.jStage)
                this.jStage = this.fhStageGetter();
                this.isStageDefined = true;
            end
            lOut = this.connectStage();
        end
        
        function disconnect(this)
            this.disconnectStage();
        end
        
        function lOut = isConnected(this)
            lOut = this.isStageConnected();
        end
        
        function stop(this)
            this.abortAxesMove();
        end
        
        function setAxesPosition(this, dDest)
            this.moveAxesAbsolute(dDest);
        end
        
        function setAxisPosition(this, dAxis, dDest)
            this.moveAxisAbsolute(dAxis, dDest);
        end
        
        function dOut = getAxesPosition(this)
            dOut = this.getAxesPositionAPI();
        end
        
        function dOut = getAxisPosition(this, dAxis)
            dOut = this.getAxisPositionAPI(dAxis);
        end
        
        function home(this)
            this.initializeAxes();
        end
        
        function lOut = isInitialized(this)
            lOut = this.getAxesIsInitialized();
        end
        
        function lOut = isReady(this)
            lOut = this.getAxesIsReady();
        end
        
    end
    
    % Direct wrapped API methods:
    methods  (Access = private)
        
        
        
        % Inherited from device:
        function lOut = connectStage(this)
            lOut = this.jStage.connect();
        end
        
        function disconnectStage(this)
            this.jStage.disconnect();
        end
        
        function cName = getDeviceName(this)
            cName = this.jStage.getDeviceName();
        end
        
        function lOut = isStageConnected(this)
            lOut = this.jStage.isConnected();
        end
        
        function ping(this)
            this.jStage.ping();
        end
        
        function reset(this)
            this.jStage.reset();
        end
        
        % stage methods:
        function [result, msg] = abortAxesMove(this)
            result = this.jStage.abortAxesMove();
            msg = this.RESULTENUM{result - 1};
        end
        
        function [result, msg] = abortAxisMove(this, dAxis)
            result = this.jStage.abortAxisMove(dAxis - 1);
            msg = this.RESULTENUM{result - 1};
        end
        
        function [result, msg] = disableAxes(this)
            result = this.jStage.disableAxes();
            msg = this.RESULTENUM{result - 1};
        end
        
        function [result, msg] = disableAxis(this, dAxis)
            result = this.jStage.disableAxis(dAxis - 1);
            msg = this.RESULTENUM{result - 1};
        end
        
        function [result, msg] = enableAxes(this)
            result = this.jStage.enableAxes();
            msg = this.RESULTENUM{result - 1};
        end
        
        function [result, msg] = enableAxis(this, dAxis)
            result = this.jStage.enableAxis(dAxis - 1);
            msg = this.RESULTENUM{result - 1};
        end
        
        function dDest = getAxesDestination(this)
            dDest = this.jStage.getAxesDestination();
        end
        
        function lOut = getAxesIsAtLimit(this)
            lOut = this.jStage.getAxesIsAtLimit();
        end
        
        function lOut = getAxesIsBusy(this)
            lOut = this.jStage.getAxesIsBusy();
        end
        
        function lOut = getAxesIsEnabled(this)
            lOut = this.jStage.getAxesIsEnabled();
        end
        
        function lOut = getAxesIsInitialized(this)
            lOut = this.jStage.getAxesIsInitialized();
        end
        
        function lOut = getAxesIsLinear(this)
            lOut = this.jStage.getAxesIsLinear();
        end
        
        function lOut = getAxesIsMoving(this)
            lOut = this.jStage.getAxesIsMoving();
        end
        
        function lOut = getAxesIsReachable(this) %Determine if the destination is reachable, all axes.
            lOut = this.jStage.getAxesIsReachable();
        end
        
        function lOut = getAxesIsReady(this)
            lOut = this.jStage.getAxesIsReady();
        end
        
        function cOut = getAxesNames(this)
            cOut = this.jStage.getAxesNames();
        end
        
        function dOut = getAxesPositionAPI(this)
            dOut = this.jStage.getAxesPosition();
        end
        
        function statusAr = getAxesStatus(this)
            statusAr = this.jStage.getAxesStatus();
        end
        
        function byteAr = getAxesSwitches(this)
            byteAr = this.jStage.getAxesSwitches();
        end
        
        function dOut = getAxisDestination(this, dAxis)
            dOut = this.jStage.getAxisDestination(dAxis - 1);
        end
        
        function lOut = getAxisIsAtLimit(this, dAxis)
            lOut = this.jStage.getAxisIsAtLimit(dAxis - 1);
        end
        
        function lOut = getAxisIsBusy(this, dAxis)
            lOut = this.jStage.getAxisIsBusy(dAxis - 1);
        end
        
        function lOut = getAxisIsEnabled(this, dAxis)
            lOut = this.jStage.getAxisIsEnabled(dAxis - 1);
        end
        
        function lOut = getAxisIsInitialized(this, dAxis)
            lOut = this.jStage.getAxisIsInitialized(dAxis - 1);
        end
        
        function lOut = getAxisIsLinear(this, dAxis)
            lOut = this.jStage.getAxisIsLinear(dAxis - 1);
        end
        
        function lOut = getAxisIsMoving(this, dAxis)
            lOut = this.jStage.getAxisIsMoving(dAxis - 1);
        end
        
        function lOut = getAxisIsReachable(this, dAxis)
            lOut = this.jStage.getAxisIsreachable(dAxis - 1);
        end
        
        
        function lOut = getAxisIsReady(this)
            lOut = this.jStage.getAxisIsReady();
        end
        
        function cOut = getAxisName(this, dAxis)
            cOut = getAxisName(dAxis - 1);
        end
        
        function dOut = getAxisPositionAPI(this, dAxis)
            dOut = this.jStage.getAxisPosition(dAxis - 1);
        end
        
        function status = getAxisStatus(this, dAxis)
            status = this.jStage.getAxisStatus(dAxis - 1);
        end
        
        function byte = getAxisSwitches(this, dAxis)
            byte = this.jStage.getAxisSwitches(dAxis - 1);
        end
        
        function dOut = getSize(this)
            dOut = double(this.jStage.getSize());
        end
        
        function future = initializeAxes(this)
            future = this.jStage.initializeAxes();
        end
        
        function future = initializeAxis(this, dAxis)
            future = this.jStage.initializeAxis(dAxis - 1);
        end
        
        function future = moveAxesAbsolute(this, dDest)
            future = this.jStage.moveAxesAbsolute(dDest);
        end
        
        function future = moveAxesRelative(this, dDest)
            future = this.jStage.moveAxesRelative(dDest);
        end
        function future = moveAxisAbsolute(this, dAxis, dDest)
            future = this.jStage.moveAxisAbsolute(dAxis - 1, dDest);
        end
        
        function future = moveAxisRelative(this, dAxis, dDest)
            future = this.jStage.moveAxisRelative(dAxis - 1, dDest);
        end
        function [result, msg] = setAxesDestination(this, dDest)
            result = this.jStage.setAxesDestination(dDest);
            msg = this.RESULTENUM{result - 1};
        end

        function setAxesPositionAPI(this)
            this.jStage.setAxesPosition();
        end
        
        function [result, msg] = setAxisDestination(this, dAxis, dDest)
            result = this.jStage.setAxisDestination(dAxis - 1, dDest);
            msg = this.RESULTENUM{result - 1};
        end
        
        function 	setAxisPositionAPI(this, dAxis, dPos)
            this.jStage.setAxisPosition(dAxis - 1, dPos);
        end
        
        function [result, msg] = stopAxesMove(this)
            result = this.jStage.stopAxesMove();
            msg = this.RESULTENUM{result - 1};
        end
 
        function [result, msg] = stopAxisMove(this, dAxis)
            result = this.jStage.stopAxisMove(dAxis - 1);
            msg = this.RESULTENUM{result - 1};
        end
        
        
    end
end