classdef InlineGSNumber < mic.interface.device.GetSetNumber


    properties (Access = private)
        fhSet
        fhGet
        fhIsReady = @()true
        fhIsInitialized = @()true
        fhInitialize = @()true
        fhStop = @()true
    end
    
    methods
        
        function this = InlineGSNumber(varargin)
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp(varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                else
                    switch varargin{k}
                        case 'fhSet'
                            this.fhSet = varargin{k + 1};
                        case 'fhGet'
                            this.fhGet = varargin{k + 1};
                        case 'fhIsReady'
                            this.fhIsReady = varargin{k + 1};
                        case 'fhIsInitialized'
                            this.fhIsInitialized = varargin{k + 1};
                        case 'fhStop'
                            this.fhStop = varargin{k + 1};
                        case 'fhInitialize'
                            this.fhInitialize = varargin{k + 1};
                    end
                    
                end
            end
        end
        
        function d = get(this)
            d = this.fhGet();
        end
        
        function set(this, dVal)
            this.fhSet(dVal);
        end
        
        function l = isReady(this)
            l = this.fhIsReady();
        end
        
        function stop(this)
            this.fhStop();
        end
        
        % This will home the stage
        function initialize(this)
            this.fhInitialize()
        end
        
        function l = isInitialized(this)
           l = this.fhIsInitialized();
        end
        
        

        
    end
        
    
end

