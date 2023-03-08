classdef MultiAxisStage <  mic.Base
    
    properties (Access = private)
        clock                      % Clock
       
        
    end


    properties
        uiConnect
        uiAxes
        uicConfigs

        deviceAPI 

        dNumChannels = 1

        % Paths
        cConfigBasePath = '.'

        % UI params
        dWidthName = 130
        lShowLabels = false
        lShowDevice = false
        lShowStageInitButton = false
        lShowStores = false
        cName = 'MultiAxisStage'
        cLabel = 'MultiAxisStage'
        ceStagelabels = {'X', 'Y', 'Z'}

        % Axes params
        lValidateByConfigRange = true
        lShowAxisInit = true
        lShowZero = false
        lShowRel = false
        
    end

            
    methods
        


        
        % Initializes a UI for a stage with multiple axes.  Requires the following props:
        %   cName: name of the stage
        %   cLabel: display label of stage
        %   deviceAPI: 
        function this = MultiAxisStage(varargin)

            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end       

            this.init()
        end


        function syncDestinations(this)
            for k = 1:this.dNumChannels
                this.uiAxes{k}.syncDestination();
            end
        end

        function positions = getRawPositions(this)
            positions = zeros(1, this.dNumChannels);
            for k = 1:this.dNumChannels
                positions(k) = this.uiAxes{k}.getDestRaw();
            end
        end

        function setRawPositions(this, positions)
            for k = 1:this.dNumChannels
                this.uiAxes{k}.setDestRaw(positions(k));
                this.uiAxes{k}.syncDestination();
            end
        end

        function dAxisPos = build(this, hpParent, dLeft, dAxisPos, dMultiAxisSeparation)
            this.uiConnect.build(hpParent, dLeft, dAxisPos);
            dAxisPos = dAxisPos + 20;
            for k = 1:this.dNumChannels
                this.uiAxes{k}.build(hpParent, ...
                    dLeft, dAxisPos);
                dAxisPos = dAxisPos + dMultiAxisSeparation;
            end
            dAxisPos = dAxisPos + 20;
        end
      
        

    end %methods
    
    methods (Access = protected)
        
      
        function init(this)

            % Init stage configurations
            for k = 1:this.dNumChannels
                this.uicConfigs{k} =  mic.config.GetSetNumber(...
                    'cPath', fullfile(this.cConfigBasePath, sprintf('%s-%d.json', this.cName, k))...
                );
            end

            % Init connection UI
            ceVararginCommandToggle = {...
                'cTextTrue', 'Disconnect', ...
                'cTextFalse', 'Connect' ...
            };

            this.uiConnect = mic.ui.device.GetSetLogical(...
                'clock', this.clock, ...
                'ceVararginCommandToggle', ceVararginCommandToggle, ...
                'dWidthName', this.dWidthName, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowDevice', this.lShowDevice, ...
                'lShowInitButton', this.lShowStageInitButton, ...
                'cName', sprintf('uiConnect-%s', this.cName), ...
                'cLabel', this.cLabel ...
            );

            this.uiConnect.setDevice( ...
                micPlus.device.InlineGSLogical(...
                    'fhGet', @()this.deviceAPI.getIsConnected(), ...
                    'fhSetTrue', @()micPlus.Utils.evalAll({@()this.deviceAPI.connect(), @()this.setStageDevicesAndEnable()}),...
                    'fhSetFalse', @()micPlus.Utils.evalAll({@()this.deviceAPI.disconnect(), @()this.disconnectStageUI()}),...
                    'fhIsInitialized', @()this.deviceAPI.getIsReferenced(-1), ...
                    'fhInitialize', @()this.deviceAPI.findReferenceMark(-1) ...
                )...
           )

           this.uiConnect.turnOn();

           % Init axes UI
           for k = 1:this.dNumChannels
            this.uiAxes{k} = mic.ui.device.GetSetNumber( ...
                'cName', sprintf('%s-axis-%s', this.cName, this.ceStagelabels{k}), ...
                'clock', this.clock, ...
                'cLabel', this.ceStagelabels{k}, ...
                'lShowLabels', this.lShowLabels, ...
                'lShowStores', this.lShowStores, ...
                'lShowInitButton', this.lShowAxisInit, ...
                'lValidateByConfigRange', this.lValidateByConfigRange, ...
                'lShowZero', this.lShowZero, ...
                'lShowRel', this.lShowRel, ...
                'lShowStores', this.lShowStores, ...
                'config', this.uicConfigs{k} ...
                );
            end


        end
        
        
        function onClock(this)
        end

        function setStageDevicesAndEnable(this)
            for k = 1:this.dNumChannels
                u32ChannelNumber = k - 1;

                % Make inline device
                this.uiAxes{k}.setDevice(...
                    micPlus.device.InlineGSNumber(...
                        'fhSet', @(dVal)this.deviceAPI.goToPositionAbsolute(u32ChannelNumber, dVal), ...
                        'fhGet', @()this.deviceAPI.getPosition(u32ChannelNumber), ...
                        'fhIsReady', @()~this.deviceAPI.getIsMoving(u32ChannelNumber), ...
                        'fhIsInitialized', @()this.deviceAPI.getIsReferenced(u32ChannelNumber), ...
                        'fhStop', @()this.deviceAPI.stop(u32ChannelNumber), ...
                        'fhInitialize', @()this.deviceAPI.findReferenceMark(u32ChannelNumber) ...
                 )...
                );
                this.uiAxes{k}.turnOn();
                this.uiAxes{k}.syncDestination();
            end

        end
        function disconnectStageUI(this)
            for k = 1:this.dNumChannels
                this.uiAxes{k}.turnOff();
                this.uiAxes{k}.setDevice([]);
            end
            
            % Disconnect the stage:
            this.deviceAPI.disconnect();
        end


    end

   
end %class
    

            
            
            
        