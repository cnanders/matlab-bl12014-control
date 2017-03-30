classdef ProcessTool < mic.Base
    
    % rcs
    
	properties
        
        uieUser
        uieBase                 % checkbox
        uieUL1Name
        uieUL1Thick
        uieUL1PABTemp
        uieUL1PABTime
        uieUL2Name
        uieUL2Thick
        uieUL2PABTemp
        uieUL2PABTime
        uieResistName
        uieResistThick
        uieResistPABTemp
        uieResistPABTime
        uieResistPEBTemp
        uieResistPEBTime
        uieDevName
        uieDevTime
        uieRinseName
        uieRinseTime
        dWidth = 335
        dHeight = 400
        
        uitQA
  
    end
    
    properties (SetAccess = private)
    
    end
    
    properties (Access = private)
                      
        hPanel
        hAxes
        uitPre
        dHeightEdit = 24;
        
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
            st.user = this.uieUser.get();
            st.base = this.uieBase.get();                
            st.ul1Name = this.uieUL1Name.get();
            st.ul1Thick = this.uieUL1Thick.get();
            st.ul1PabTemp = this.uieUL1PABTemp.get();
            st.ul1PabTime = this.uieUL1PABTime.get();
            st.ul2Name = this.uieUL2Name.get();
            st.ul2Thick = this.uieUL2Thick.get();
            st.ul2PabTemp = this.uieUL2PABTemp.get();
            st.ul2PabTime = this.uieUL2PABTime.get();
            st.resistName = this.uieResistName.get();
            st.resistThick = this.uieResistThick.get();
            st.resistPabTemp = this.uieResistPABTemp.get();
            st.resistPabTime = this.uieResistPABTime.get();
            st.resistPebTemp = this.uieResistPEBTemp.get();
            st.resistPebTime = this.uieResistPEBTime.get();
            st.devName = this.uieDevName.get();
            st.devTime = this.uieDevTime.get();
            st.rinseName = this.uieRinseName.get();
            st.rinseTime = this.uieRinseTime.get();
            
        end
        
        function load(this, st)
            
           this.uieUser.set(st.user);
           this.uieBase.set(st.base);                
           this.uieUL1Name.set(st.ul1Name);
           this.uieUL1Thick.set(st.ul1Thick);
           this.uieUL1PABTemp.set(st.ul1PabTemp);
           this.uieUL1PABTime.set(st.ul1PabTime);
           this.uieUL2Name.set(st.ul2Name);
           this.uieUL2Thick.set(st.ul2Thick);
           this.uieUL2PABTemp.set(st.ul2PabTemp);
           this.uieUL2PABTime.set(st.ul2PabTime);
           this.uieResistName.set(st.resistName);
           this.uieResistThick.set(st.resistThick);
           this.uieResistPABTemp.set(st.resistPabTemp);
           this.uieResistPABTime.set(st.resistPabTime);
           this.uieResistPEBTemp.set(st.resistPebTemp);
           this.uieResistPEBTime.set(st.resistPebTime);
           this.uieDevName.set(st.devName);
           this.uieDevTime.set(st.devTime);
           this.uieRinseName.set(st.rinseName);
           this.uieRinseTime.set(st.rinseTime);
            
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
                'Title', 'Process',...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb([dLeft dTop this.dWidth this.dHeight], hParent) ...
            );
			drawnow;
                        
           
            dPadX = 10;
            dWidthName = 120;
            dWidthThick = 55;
            dWidthTemp = 55;
            dWidthTime = 55;
                     
            dTop = 20;
            dSep = 55;

            

            % Build filter Hz, Volts scale and time step

            
            this.uieUser.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                this.dHeightEdit ...
            );
        
            dTop = dTop + dSep;
            
            this.uieUL1Name.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                this.dHeightEdit ...
            );
        
            this.uieUL1Thick.build( ...
                this.hPanel, ...
                2*dPadX + dWidthName, ...
                dTop, ...
                dWidthThick, ...
                this.dHeightEdit ...
            );
        
            this.uieUL1PABTemp.build( ...
                this.hPanel, ...
                3*dPadX + dWidthName + dWidthThick, ...
                dTop, ...
                dWidthTemp, ...
                this.dHeightEdit ...
            );
        
            this.uieUL1PABTime.build( ...
                this.hPanel, ...
                4*dPadX + dWidthName + dWidthThick + dWidthTemp, ...
                dTop, ...
                dWidthTime, ...
                this.dHeightEdit ...
            );
        
        
        
            dTop = dTop + dSep;
            
            this.uieUL2Name.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthName, ...
                this.dHeightEdit ...
            );
        
            this.uieUL2Thick.build( ...
                this.hPanel, ...
                2*dPadX + dWidthName, ...
                dTop, ...
                dWidthThick, ...
                this.dHeightEdit ...
            );
        
            this.uieUL2PABTemp.build( ...
                this.hPanel, ...
                3*dPadX + dWidthName + dWidthThick, ...
                dTop, ...
                dWidthTemp, ...
                this.dHeightEdit ...
            );
        
            this.uieUL2PABTime.build( ...
                this.hPanel, ...
                4*dPadX + dWidthName + dWidthThick + dWidthTemp, ...
                dTop, ...
                dWidthTime, ...
                this.dHeightEdit ...
            );
        
            dTop = dTop + dSep;
            
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
        
            this.uieResistPABTemp.build( ...
                this.hPanel, ...
                3*dPadX + dWidthName + dWidthThick, ...
                dTop, ...
                dWidthTemp, ...
                this.dHeightEdit ...
            );
        
            this.uieResistPABTime.build( ...
                this.hPanel, ...
                4*dPadX + dWidthName + dWidthThick + dWidthTemp, ...
                dTop, ...
                dWidthTime, ...
                this.dHeightEdit ...
            );
        
            
        
        
            dTop = dTop + dSep;
            
            
            this.uieResistPEBTemp.build( ...
                this.hPanel, ...
                dPadX, ...
                dTop, ...
                dWidthTemp, ...
                this.dHeightEdit ...
            );
        
            this.uieResistPEBTime.build( ...
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
                305, ...
                dTop + 15, ...
                20, ...
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
            
            this.uieUser            = mic.ui.common.Edit('cLabel', 'User', 'cType', 'c');
            this.uieBase            = mic.ui.common.Edit('cLabel', 'Base', 'cType', 'c');              
            this.uieUL1Name         = mic.ui.common.Edit('cLabel', 'UL 1', 'cType', 'c');
            this.uieUL1Thick        = mic.ui.common.Edit('cLabel', 'Thick (nm)', 'cType', 'u8');
            this.uieUL1PABTemp      = mic.ui.common.Edit('cLabel', 'PAB Temp', 'cType', 'u8');
            this.uieUL1PABTime      = mic.ui.common.Edit('cLabel', 'PAB Time', 'cType', 'u8');
            this.uieUL2Name         = mic.ui.common.Edit('cLabel', 'UL 2', 'cType', 'c');
            this.uieUL2Thick        = mic.ui.common.Edit('cLabel', 'Thick (nm)', 'cType', 'u8');
            this.uieUL2PABTemp      = mic.ui.common.Edit('cLabel', 'PAB Temp', 'cType', 'u8');
            this.uieUL2PABTime      = mic.ui.common.Edit('cLabel', 'PAB Time', 'cType', 'u8');
            this.uieResistName      = mic.ui.common.Edit('cLabel', 'Resist', 'cType', 'c');
            this.uieResistThick     = mic.ui.common.Edit('cLabel', 'Thick (nm)', 'cType', 'u8');
            this.uieResistPABTemp   = mic.ui.common.Edit('cLabel', 'PAB Temp', 'cType', 'u8');
            this.uieResistPABTime   = mic.ui.common.Edit('cLabel', 'PAB Time', 'cType', 'u8');
            this.uieResistPEBTemp   = mic.ui.common.Edit('cLabel', 'PEB Temp', 'cType', 'u8');
            this.uieResistPEBTime   = mic.ui.common.Edit('cLabel', 'PEB Time', 'cType', 'u8');
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
            this.uieUL1Name.set('NCX011');
            this.uieUL1Thick.set(uint8(20));
            this.uieUL1PABTemp.set(uint8(200));
            this.uieUL1PABTime.set(uint8(90));
            this.uieResistName.set('Fuji-1201E');
            this.uieResistThick.set(uint8(35));
            this.uieResistPABTemp.set(uint8(110));
            this.uieResistPABTime.set(uint8(60));
            this.uieResistPEBTemp.set(uint8(100));
            this.uieResistPEBTime.set(uint8(60));
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
            this.uieUL1Name.hide();
            this.uieUL1Thick.hide();
            this.uieUL1PABTemp.hide();
            this.uieUL1PABTime.hide();
            this.uieUL2Name.hide();
            this.uieUL2Thick.hide();
            this.uieUL2PABTemp.hide();
            this.uieUL2PABTime.hide();
            this.uieResistName.hide();
            this.uieResistThick.hide();
            this.uieResistPABTemp.hide();
            this.uieResistPABTime.hide();
            this.uieResistPEBTemp.hide();
            this.uieResistPEBTime.hide();
            this.uieDevName.hide();
            this.uieDevTime.hide();
            this.uieRinseName.hide();
            this.uieRinseTime.hide();
            
        end
        
        
        function showAll(this)
            
            this.uieUser.show();
            this.uieBase.show();             
            this.uieUL1Name.show();
            this.uieUL1Thick.show();
            this.uieUL1PABTemp.show();
            this.uieUL1PABTime.show();
            this.uieUL2Name.show();
            this.uieUL2Thick.show();
            this.uieUL2PABTemp.show();
            this.uieUL2PABTime.show();
            this.uieResistName.show();
            this.uieResistThick.show();
            this.uieResistPABTemp.show();
            this.uieResistPABTime.show();
            this.uieResistPEBTemp.show();
            this.uieResistPEBTime.show();
            this.uieDevName.show();
            this.uieDevTime.show();
            this.uieRinseName.show();
            this.uieRinseTime.show();
            
        end
        
        function styleVerifiedAll(this)
            
            this.uieUser.styleVerified();
            this.uieBase.styleVerified();             
            this.uieUL1Name.styleVerified();
            this.uieUL1Thick.styleVerified();
            this.uieUL1PABTemp.styleVerified();
            this.uieUL1PABTime.styleVerified();
            this.uieUL2Name.styleVerified();
            this.uieUL2Thick.styleVerified();
            this.uieUL2PABTemp.styleVerified();
            this.uieUL2PABTime.styleVerified();
            this.uieResistName.styleVerified();
            this.uieResistThick.styleVerified();
            this.uieResistPABTemp.styleVerified();
            this.uieResistPABTime.styleVerified();
            this.uieResistPEBTemp.styleVerified();
            this.uieResistPEBTime.styleVerified();
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