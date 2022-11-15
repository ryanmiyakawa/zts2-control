classdef GetSetLogical < mic.interface.device.GetSetLogical

    % deviceVirtual

    properties (Access = private)
        lVal = false
        lIsInitialized = false


        fhOnConnect     = @() []
        fhOnDisconnect  = @() []
        fhIsConnected   = @() false

        gslc
    end
            
    methods
        
        function this = GetSetLogical(varargin)
        
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}),  this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end

            this.gslc = struct;
            this.gslc.fhGet = @this.fhIsConnected;
            this.gslc.fhSetTrue = @this.fhOnConnect;
            this.gslc.fhSetFalse = @this.fhOnDisconnect;

            this.setDevice(this.gslc);
            this.turnOn();
        end

        function l = get(this)
            l = this.fhGet();
        end

        function set(this, lVal)
            if lVal
                this.fhSetTrue();
            else
                this.fhSetFalse();
            end
        end
        
        function initialize(this)
            this.lIsInitialized = true;
        end

        function l = isInitialized(this)
           l = this.lIsInitialized;
        end

    end %methods
end %class
    

            
            
            
        