classdef InlineGSLogical < mic.interface.device.GetSetLogical


    properties (Access = private)
        fhGet = @()[]
        fhSet = @()[]
        fhIsInitialized = @()false
        fhInitialize = @()[]
    end
    
    methods
        
        function this = InlineGSLogical(varargin)
            for k = 1 : 2: length(varargin)
                % this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp(varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}), 3);
                    this.(varargin{k}) = varargin{k + 1};
                else
                    switch varargin{k}
                        case 'fhGet'
                            this.fhGet = varargin{k + 1};
                        case 'fhSet'
                            this.fhSet = varargin{k + 1};
                        case 'fhIsInitialized'
                            this.fhIsInitialized = varargin{k + 1};
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
        
        % This will home the stage
        function initialize(this)
            this.fhInitialize();
        end
        
        function l = isInitialized(this)
           l = this.fhIsInitialized();
        end
        
        

        
    end
        
    
end

