% A UI class desgined for saving and loading coupled-axis states to JSON.
% Will build test class soon

classdef PositionRecaller < mic.ui.common.Base

    properties

        hGetCallback
        hSetCallback
        cConfigPath = ''
        
    end


    properties (Access = private)
    
        % Array of structures that stores key-value pairs [{key: ...,
        % value: ...}, {key, ... ]
        
        cName = '' % Need a name for this to keep JSON unique

        cLabel = 'Position Recaller'
        
        stPositionsArray = struct([])
        
        cJsonPath
        
        uiList
        uibSave
        uibLoad
        
        lDisableSave = false
        lShowLoadButton = true
        lLoadOnSelect = false

        % type micPlus.ui.MultiAxisStage for quick init
        uiStage
        
        uiePosName
        
        hPanel
        
        lShowLabelOfList = true
        cTitleOfPanel = ''
        
        dWidthLoadSave = 90
        
        
    end
 

    properties (SetAccess = private)
        
       
    end

    events
    end

    %%
    methods
        
        % constructor
        function this = PositionRecaller(varargin)
            for k = 1:2:length(varargin)
                this.(varargin{k}) = varargin{k+1};
            end

            % Create get and set handlers automatically from stage:
            if ~isempty(this.uiStage)
                this.initFromStage();
            end
            
            if isempty(this.cConfigPath)
                error('PositionRecaller: Must specify a configuration path: cConfigPath');
            end
            if isempty(this.cName)
                error('PositionRecaller: Must specify a unique name for storing JSON');
            end
            
           
            this.uiList = mic.ui.common.List(...
                'cLabel', this.cLabel, ...
                'lShowRefresh', false, ...
                'lShowLabel', this.lShowLabelOfList, ...
                'fhOnChange', @this.onListChange, ...
                'fhDirectCallback', @this.syncAndSave);
            
            % Try loading corresponding JSON

            this.cJsonPath = fullfile(this.cConfigPath, [this.cName '-recall.json']);
            fid = fopen(this.cJsonPath, 'r');
            if (fid ~= -1)
                cTxt = fread(fid, inf, 'uint8=>char');
                if size(cTxt, 1) > size(cTxt,2)
                    cTxt = cTxt';
                end
                
                this.stPositionsArray = jsondecode(cTxt);
                fclose(fid);
            end
            
            
            if ~isempty(this.stPositionsArray)
                this.uiList.setOptions(this.makeOptionsfromPositions());
            end
            
            
            this.uibSave = mic.ui.common.Button(...
                'cText', 'Save', 'fhDirectCallback', @this.savePosition ...
            );
            this.uibLoad = mic.ui.common.Button(...
                'cText', 'Load', 'fhDirectCallback', @this.loadPosition ...
            );
        

            this.uiePosName = mic.ui.common.Edit('cLabel', 'Save As:', 'cType', 'c');

        
        end

        function initFromStage(this)
            this.hGetCallback = @() this.uiStage.getRawPositions();
            this.hSetCallback = @(positions) this.uiStage.setRawPositions(positions);
        end
        
        function setSaveName(this, cVal)
            this.uiePosName.set(cVal);
        end

        % Build
        function build(this, hParent, dLeft, dTop, dWidth, dHeight)

            % build panel:
            this.hPanel = uipanel(...
                'Parent', hParent,...
                'Units', 'pixels',...
                'Title', this.cTitleOfPanel,...
                'Clipping', 'on',...
                'Position', mic.Utils.lt2lb(...
                    [ ...
                        dLeft ...
                        dTop ...
                        dWidth ...
                        dHeight ...
                    ], ...
                    hParent ...
                ) ...
            );
            
            dWidthList = dWidth - this.dWidthLoadSave - 30;
            this.uiList.build(this.hPanel, 10, 20, dWidthList, dHeight - 75); % dWidth/2 + 25
           
            
            dTop = 20;
            dLeft = dWidth - this.dWidthLoadSave - 10;
            
            
            if this.lShowLoadButton
                this.uibLoad.build(this.hPanel,  dLeft, dTop, this.dWidthLoadSave, 20);
                dTop = dTop + 24;
            end
            
            if ~this.lDisableSave
                
                this.uiePosName.build(this.hPanel,  dLeft, dTop, this.dWidthLoadSave, 20);
                dTop = dTop + 40;
                
                this.uibSave.build(this.hPanel,  dLeft, dTop, this.dWidthLoadSave, 20);
                this.uiePosName.set('New');
            end
        end

        function onListChange(this, src, evt)
            if this.lLoadOnSelect
                this.loadPosition();
            end
        end
        
        function syncAndSave(this)
            ceListOptions = this.uiList.getOptions();
            
            if (~isempty(ceListOptions))
                for k = 1:length(ceListOptions)
                    stNewOptionsArray(k) = struct('key', ceListOptions{k}); %#ok<AGROW>
                end
            else
                stNewOptionsArray = struct([]);
            end
            
            % For each new option, loop through old options and transfer
            
            for k = 1:length(stNewOptionsArray)
                cKey = stNewOptionsArray(k).key;
                
                for m = 1:length(this.stPositionsArray)
                    if strcmp(cKey, this.stPositionsArray(m).key) % then transfer value
                        stNewOptionsArray(k).value = this.stPositionsArray(m).value; %#ok<AGROW>
                    end
                end
            end

            this.stPositionsArray = stNewOptionsArray;
            
            % save back to file:
            cJsonEncodedOptions = jsonencode(this.stPositionsArray);
            fid = fopen(this.cJsonPath, 'w+');
            fprintf(fid, cJsonEncodedOptions);
            fclose(fid);
            
        end
        
        function programmaticSave(this, cStoreName)
            this.uiePosName.set(cStoreName);
            this.savePosition();
        end
        
        function savePosition(this, ~, ~)
            cPosName = this.uiePosName.get();
            
            % load options
            listOptions = this.uiList.getOptions();
            
            % check if this name already exists:
            for k = 1:length(listOptions)
                if strcmpi(cPosName, listOptions{k})
                    error('Already a position with this name');
                end
            end
            
            
            listOptions{end+1} = cPosName;
            this.uiList.setOptions(listOptions);
            
            % make structure:
            st = struct();
            st.key = cPosName;
            st.value = this.hGetCallback();
                        
            % need to do this to avoid subscript dimension mismatches:
            if (isempty(this.stPositionsArray))
                 this.stPositionsArray = st;
            else
                this.stPositionsArray(end + 1) = st;
            end
            
            this.syncAndSave();
        end
        
        function loadPosition(this, ~, ~)
            % get selected option:
            cecSelectedVal = this.uiList.get();
            cSelectedVal = cecSelectedVal{1};
            
            
            % find this entry in our options list:
            val = [];
            for k = 1:length(this.stPositionsArray)
                if strcmpi(this.stPositionsArray(k).key, cSelectedVal)
                    val = this.stPositionsArray(k).value;
                    break;
                end
            end
            if isempty(val)
                error ('no matching value found');
            end
            
            this.hSetCallback(val);
        end
        
   
        
        function letMeIn(this)
           1; 
        end
        
  
        

    end

    methods (Access = protected)

        function ceOptions = makeOptionsfromPositions(this)
            ceOptions = {};
            for k = 1:length(this.stPositionsArray)
                ceOptions{k} = this.stPositionsArray(k).key;
            end
        end
        


    end
end