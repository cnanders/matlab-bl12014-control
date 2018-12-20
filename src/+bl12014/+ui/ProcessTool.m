classdef ProcessTool < mic.Base
    
    % rcs
    
	properties
        
        uieUser
        uieBase                 % checkbox
        uieUnderlayer1Name
        uieUnderlayer1Thick
        uieUnderlayer1PabTemp
        uieUnderlayer1PabTime
        uieUnderlayer2Name
        uieUnderlayer2Thick
        uieUnderlayer2PabTemp
        uieUnderlayer2PabTime
        uieResistName
        uieResistThick
        uieResistPabTemp
        uieResistPabTime
        uieResistPebTemp
        uieResistPebTime
        uieDevName
        uieDevTime
        uieRinseName
        uieRinseTime
        dWidth = 335
        dHeight = 260
        
        uitQA
  
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                      
        hPanel
        hAxes
        uitPre
        dHeightEdit = 24;
        dWidthBorderPanel = 0
        
    end
    
        
    events
        
        eName
        eChange
        
    end
    

    
    methods
        
        
        function this = ProcessTool()
            this.init();
        end
        
        % @return {struct} state to save
        function st = save(this)
            st = struct();            
            st.cUser = this.uieUser.get();
            st.cBase = this.uieBase.get();  
            
            st.cUnderlayer1Name = this.uieUnderlayer1Name.get();
            st.dUnderlayer1Thick = this.uieUnderlayer1Thick.get();
            st.dUnderlayer1PabTemp = this.uieUnderlayer1PabTemp.get();
            st.dUnderlayer1PabTime = this.uieUnderlayer1PabTime.get();
            
            st.cUnderlayer2Name = this.uieUnderlayer2Name.get();
            st.dUnderlayer2Thick = this.uieUnderlayer2Thick.get();
            st.dUnderlayer2PabTemp = this.uieUnderlayer2PabTemp.get();
            st.dUnderlayer2PabTime = this.uieUnderlayer2PabTime.get();
            
            st.cResistName = this.uieResistName.get();
            st.dResistThick = this.uieResistThick.get();
            st.dResistPabTemp = this.uieResistPabTemp.get();
            st.dResistPabTime = this.uieResistPabTime.get();
            st.dResistPebTemp = this.uieResistPebTemp.get();
            st.dResistPebTime = this.uieResistPebTime.get();
            
            st.cDevName = this.uieDevName.get();
            st.dDevTime = this.uieDevTime.get();
            
            st.cRinseName = this.uieRinseName.get();
            st.dRinseTime = this.uieRinseTime.get();
            
        end
        
        function load(this, st)
            
           this.uieUser.set(st.cUser);
           this.uieBase.set(st.cBase); 
           
           this.uieUnderlayer1Name.set(st.cUnderlayer1Name);
           this.uieUnderlayer1Thick.set(st.dUnderlayer1Thick);
           this.uieUnderlayer1PabTemp.set(st.dUnderlayer1PabTemp);
           this.uieUnderlayer1PabTime.set(st.dUnderlayer1PabTime);
           
           this.uieUnderlayer2Name.set(st.cUnderlayer2Name);
           this.uieUnderlayer2Thick.set(st.dUnderlayer2Thick);
           this.uieUnderlayer2PabTemp.set(st.dUnderlayer2PabTemp);
           this.uieUnderlayer2PabTime.set(st.dUnderlayer2PabTime);
           
           this.uieResistName.set(st.cResistName);
           this.uieResistThick.set(st.dResistThick);
           this.uieResistPabTemp.set(st.dResistPabTemp);
           this.uieResistPabTime.set(st.dResistPabTime);
           this.uieResistPebTemp.set(st.dResistPebTemp);
           this.uieResistPebTime.set(st.dResistPebTime);
           
           this.uieDevName.set(st.cDevName);
           this.uieDevTime.set(st.dDevTime);
           
           this.uieRinseName.set(st.cRinseName);
           this.uieRinseTime.set(st.dRinseTime);
            
        end
        
        
        function makePre(this)
            % hide everything
            this.hideAll();
            if ishandle(this.hPanel)
                set(this.hPanel, 'BackgroundColor', mic.Utils.dColorPre);
            end
            this.uitPre.show();
            
        end
        
        function makeActive(this)
            this.showAll();
            if ishandle(this.hPanel)
                set(this.hPanel, 'BackgroundColor', mic.Utils.dColorActive);
            end
            this.uitPre.hide();
        end
        
        %{
        function makePost(this)
            this.showAll();
            this.styleVerifiedAll();
            if ishandle(this.hPanel)
                set(this.hPanel, 'BackgroundColor', mic.Utils.dColorPost);
            end
            this.uitPre.hide();
        end
        %}
                
        function build(this, hParent, dLeft, dTop)
                        
            
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', 'Resist Process',...
                'Clipping', 'on',...
                'BorderWidth', this.dWidthBorderPanel, ...
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
			drawnow;
                        
           
            dPadX = 10;
            dWidthName = 120;
            dWidthThick = 55;
            dWidthTemp = 55;
            dWidthTime = 55;
                     
            dTop = 20;
            dSep = 38;

            

            % Build filter Hz, Volts scale and time step

            
            this.uieUser.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                this.dHeightEdit ...
            );
        
            dTop = dTop + dSep;
            
            this.uieUnderlayer1Name.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                this.dHeightEdit ...
            );
        
            this.uieUnderlayer1Thick.build( ...
                this.hPanel, ...
                2*dPadX + dWidthName, ...
                dTop, ...
                dWidthThick, ...
                this.dHeightEdit ...
            );
        
            this.uieUnderlayer1PabTemp.build( ...
                this.hPanel, ...
                3*dPadX + dWidthName + dWidthThick, ...
                dTop, ...
                dWidthTemp, ...
                this.dHeightEdit ...
            );
        
            this.uieUnderlayer1PabTime.build( ...
                this.hPanel, ...
                4*dPadX + dWidthName + dWidthThick + dWidthTemp, ...
                dTop, ...
                dWidthTime, ...
                this.dHeightEdit ...
            );
        
        
        
            dTop = dTop + dSep;
            
            %{
            
            this.uieUnderlayer2Name.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                this.dHeightEdit ...
            );
        
            this.uieUnderlayer2Thick.build( ...
                this.hPanel, ...
                2*dPadX + dWidthName, ...
                dTop, ...
                dWidthThick, ...
                this.dHeightEdit ...
            );
        
            this.uieUnderlayer2PabTemp.build( ...
                this.hPanel, ...
                3*dPadX + dWidthName + dWidthThick, ...
                dTop, ...
                dWidthTemp, ...
                this.dHeightEdit ...
            );
        
            this.uieUnderlayer2PabTime.build( ...
                this.hPanel, ...
                4*dPadX + dWidthName + dWidthThick + dWidthTemp, ...
                dTop, ...
                dWidthTime, ...
                this.dHeightEdit ...
            );
        
            dTop = dTop + dSep;
            %}
            
            this.uieResistName.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                this.dHeightEdit ...
            );
        
            this.uieResistThick.build( ...
                this.hPanel, ...
                2*dPadX + dWidthName, ...
                dTop, ...
                dWidthThick, ...
                this.dHeightEdit ...
            );
        
            this.uieResistPabTemp.build( ...
                this.hPanel, ...
                3*dPadX + dWidthName + dWidthThick, ...
                dTop, ...
                dWidthTemp, ...
                this.dHeightEdit ...
            );
        
            this.uieResistPabTime.build( ...
                this.hPanel, ...
                4*dPadX + dWidthName + dWidthThick + dWidthTemp, ...
                dTop, ...
                dWidthTime, ...
                this.dHeightEdit ...
            );
        
            
        
        
            dTop = dTop + dSep;
            
            
            this.uieResistPebTemp.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthTemp, ...
                this.dHeightEdit ...
            );
        
            this.uieResistPebTime.build( ...
                this.hPanel, ...
                2*dPadX + dWidthTemp, ...
                dTop, ...
                dWidthTime, ...
                this.dHeightEdit ...
            );
        
        
            dTop = dTop + dSep;
            
            this.uieDevName.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                this.dHeightEdit ...
            );
        
            this.uieDevTime.build( ...
                this.hPanel, ...
                2*dPadX + dWidthName, ...
                dTop, ...
                dWidthTime, ...
                this.dHeightEdit ...
            );
        
            dTop = dTop + dSep;
            
            this.uieRinseName.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                this.dHeightEdit ...
            );
        
            this.uieRinseTime.build( ...
                this.hPanel, ...
                2*dPadX + dWidthName, ...
                dTop, ...
                dWidthTime, ...
                this.dHeightEdit ...
            );
        
            this.uitQA.build( ...
                this.hPanel, ...
                290, ...
                dTop + 15, ...
                40, ...
                this.dHeightEdit ...
            );
        
            %{
            this.hAxes = axes( ...
                'Parent', this.hPanel, ...
                'Units', 'pixels', ...
                'Position', mic.Utils.lt2lb([0 0 this.dWidth this.dHeight], this.hPanel),...
                'XColor', [0 0 0], ...
                'YColor', [0 0 0], ...
                'HandleVisibility','on', ...
                'DataAspectRatio', [1 1 1], ...
                'PlotBoxAspectRatio', [this.dWidth this.dHeight 1], ...
                'Visible', 'off' ...  % prevents axis lines, tick marks, and labels from being displayed; does not affect children of axes
            );
        
            % Draw a patch on the axes that is transparent
            
            dL = 0;
            dR = this.dWidth;
            dT = this.dHeight;
            dB = 0;

            hPatch = patch( ...
                [dL dL dR dR], ...
                [dB dT dT dB], ...
                hsv2rgb(0.4, 1, 1), ...
                'Parent', this.hAxes, ...
                'FaceAlpha', 0.3 ...
            );
        
            uistack(this.hAxes, 'top');
            %}
        
            
            this.uitPre.build( ...
                this.hPanel, ...
                0, ...
                0, ...
                this.dWidth, ...
                this.dHeight ...
            );
            this.uitPre.hide();
                           
        end
        
        function show(this)            

            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'on');
            end

        end

        function hide(this)

            if ishandle(this.hPanel)
                set(this.hPanel, 'Visible', 'off');
            end

        end
        
                        
        
        %% Destructor
        
        function delete(this)
            
            % Clean up clock tasks
                        
        end
        
        
        
        function handleClock(this)
            
            
            
            
        end
        
            

    end
    
    methods (Access = private)
        
        function init(this)
            
            this.msg('init()');
            this.uieUser            = mic.ui.common.Edit('cLabel', 'User', 'cType', 'c');
            this.uieBase            = mic.ui.common.Edit('cLabel', 'Base', 'cType', 'c');              
            this.uieUnderlayer1Name         = mic.ui.common.Edit('cLabel', 'Underlayer 1', 'cType', 'c');
            this.uieUnderlayer1Thick        = mic.ui.common.Edit('cLabel', 'Thick (nm)', 'cType', 'u8');
            this.uieUnderlayer1PabTemp      = mic.ui.common.Edit('cLabel', 'Pab Temp', 'cType', 'u8');
            this.uieUnderlayer1PabTime      = mic.ui.common.Edit('cLabel', 'Pab Time', 'cType', 'u8');
            this.uieUnderlayer2Name         = mic.ui.common.Edit('cLabel', 'UL 2', 'cType', 'c');
            this.uieUnderlayer2Thick        = mic.ui.common.Edit('cLabel', 'Thick (nm)', 'cType', 'u8');
            this.uieUnderlayer2PabTemp      = mic.ui.common.Edit('cLabel', 'Pab Temp', 'cType', 'u8');
            this.uieUnderlayer2PabTime      = mic.ui.common.Edit('cLabel', 'Pab Time', 'cType', 'u8');
            this.uieResistName      = mic.ui.common.Edit('cLabel', 'Resist', 'cType', 'c');
            this.uieResistThick     = mic.ui.common.Edit('cLabel', 'Thick (nm)', 'cType', 'u8');
            this.uieResistPabTemp   = mic.ui.common.Edit('cLabel', 'Pab Temp', 'cType', 'u8');
            this.uieResistPabTime   = mic.ui.common.Edit('cLabel', 'Pab Time', 'cType', 'u8');
            this.uieResistPebTemp   = mic.ui.common.Edit('cLabel', 'Peb Temp', 'cType', 'u8');
            this.uieResistPebTime   = mic.ui.common.Edit('cLabel', 'Peb Time', 'cType', 'u8');
            this.uieDevName         = mic.ui.common.Edit('cLabel', 'Dev', 'cType', 'c');
            this.uieDevTime         = mic.ui.common.Edit('cLabel', 'Dev Time', 'cType', 'u8');
            this.uieRinseName       = mic.ui.common.Edit('cLabel', 'Rinse Name', 'cType', 'c');
            this.uieRinseTime       = mic.ui.common.Edit('cLabel', 'Rinse Time', 'cType', 'u8');
            this.uitPre             = mic.ui.common.Text(...
                'cVal', '1. Process', ...
                'cAlign', 'center', ...
                'cFontWeight', 'bold', ...
                'cFontSize', 20 ...
            );
        
            this.uitQA = mic.ui.common.Toggle(...
                'cTextTrue', 'X', ...
                'cTextFalse', 'OK' ...
            );
            
            % Defaults
            this.uieUser.set('Development');
            this.uieUnderlayer1Name.set('NCX011');
            this.uieUnderlayer1Thick.set(uint8(20));
            this.uieUnderlayer1PabTemp.set(uint8(200));
            this.uieUnderlayer1PabTime.set(uint8(90));
            this.uieResistName.set('Fuji-1201E');
            this.uieResistThick.set(uint8(35));
            this.uieResistPabTemp.set(uint8(110));
            this.uieResistPabTime.set(uint8(60));
            this.uieResistPebTemp.set(uint8(100));
            this.uieResistPebTime.set(uint8(60));
            this.uieDevName.set('MF26A');
            this.uieDevTime.set(uint8(30));
            this.uieRinseName.set('DIH20');
            this.uieRinseTime.set(uint8(30));
            
            addlistener(this.uitQA, 'eChange', @this.onQA);

            
        end
        
        
        function handleCloseRequestFcn(this, src, evt)
           
        end
        
        function hideAll(this)
            
            this.uieUser.hide();
            this.uieBase.hide();             % checkbox
            this.uieUnderlayer1Name.hide();
            this.uieUnderlayer1Thick.hide();
            this.uieUnderlayer1PabTemp.hide();
            this.uieUnderlayer1PabTime.hide();
            this.uieUnderlayer2Name.hide();
            this.uieUnderlayer2Thick.hide();
            this.uieUnderlayer2PabTemp.hide();
            this.uieUnderlayer2PabTime.hide();
            this.uieResistName.hide();
            this.uieResistThick.hide();
            this.uieResistPabTemp.hide();
            this.uieResistPabTime.hide();
            this.uieResistPebTemp.hide();
            this.uieResistPebTime.hide();
            this.uieDevName.hide();
            this.uieDevTime.hide();
            this.uieRinseName.hide();
            this.uieRinseTime.hide();
            
        end
        
        
        function showAll(this)
            
            this.uieUser.show();
            this.uieBase.show();             
            this.uieUnderlayer1Name.show();
            this.uieUnderlayer1Thick.show();
            this.uieUnderlayer1PabTemp.show();
            this.uieUnderlayer1PabTime.show();
            this.uieUnderlayer2Name.show();
            this.uieUnderlayer2Thick.show();
            this.uieUnderlayer2PabTemp.show();
            this.uieUnderlayer2PabTime.show();
            this.uieResistName.show();
            this.uieResistThick.show();
            this.uieResistPabTemp.show();
            this.uieResistPabTime.show();
            this.uieResistPebTemp.show();
            this.uieResistPebTime.show();
            this.uieDevName.show();
            this.uieDevTime.show();
            this.uieRinseName.show();
            this.uieRinseTime.show();
            
        end
        
        function styleVerifiedAll(this)
            
            this.uieUser.styleVerified();
            this.uieBase.styleVerified();             
            this.uieUnderlayer1Name.styleVerified();
            this.uieUnderlayer1Thick.styleVerified();
            this.uieUnderlayer1PabTemp.styleVerified();
            this.uieUnderlayer1PabTime.styleVerified();
            this.uieUnderlayer2Name.styleVerified();
            this.uieUnderlayer2Thick.styleVerified();
            this.uieUnderlayer2PabTemp.styleVerified();
            this.uieUnderlayer2PabTime.styleVerified();
            this.uieResistName.styleVerified();
            this.uieResistThick.styleVerified();
            this.uieResistPabTemp.styleVerified();
            this.uieResistPabTime.styleVerified();
            this.uieResistPebTemp.styleVerified();
            this.uieResistPebTime.styleVerified();
            this.uieDevName.styleVerified();
            this.uieDevTime.styleVerified();
            this.uieRinseName.styleVerified();
            this.uieRinseTime.styleVerified();
            
        end
        
        function onQA(this, ~, ~)
            
            if this.uitQA.get()
                set(this.hPanel, ...
                    'BackgroundColor', [1 .6 1] ...
                );
            else
                set(this.hPanel, ...
                    'BackgroundColor', [.94 .94 .94] ...
                );
            end
            
        end

    end % private
    
    
end