% This is a bridge between hardware device and MATLAB UI

    
classdef PLCCamera < mic.Base
    
    
    properties (Constant)
        cName = 'camera-name'
        
        ceValidNames = {'TEST', 'FID1', 'FID2', 'UNI'}
        ceKnownCameraIDs = {'UI225xSE-M R3_4102612161',...
            'UI225xSE-M R3_4102658006',...
            'UI225xSE-M R3_4102612163',...
            'UI225xSE-M R3_4102612164'...
            }
        
        
        
    end
    
    properties 
        cCameraID = 'none'
        dCameraIndex = -1
        hCamera
    end
    
    properties (Access = private)
        clock
        hAdapterHandle
        hTargetAxes
        dCapturePeriod = 1;
        
        
    end
    
    methods
        
        % Must construct with cName equal to one of the following: (TEST,
        % FID1, FID2, UNI)
        function this = PLCCamera(cName, varargin)
            if ~any(strcmp(this.ceValidNames,cName))
                error('Not a valid camera name, use: {TEST, FID1, FID2, UNI}\n');
            end
            
            % Look up camera ID
            this.cCameraID = this.ceKnownCameraIDs{strcmp(this.ceValidNames,cName)};
           
             for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
             end
             
             this.init();
        end
        
        function init(this)
            this.hAdapterHandle = imaqhwinfo('winvideo');
            this.setCameraHandle();
        end
        
        function refreshCameraList(this)
            this.hAdapterHandle = imaqhwinfo('winvideo');
            this.setCameraHandle();
            stDeviceInfo = this.hAdapterHandle.DeviceInfo;
            fprintf('\nDetected %d camera(s) with IDs:\n', length(stDeviceInfo));
            
            for k = 1:length(stDeviceInfo)
                fprintf('\t%s (%s)\n', stDeviceInfo(k).DeviceName, ...
                        this.ceValidNames{strcmp(this.ceKnownCameraIDs, stDeviceInfo(k).DeviceName)});
            end
        end
        
        function idx = setCameraHandle(this)
            idx = -1;
            this.hAdapterHandle = imaqhwinfo('winvideo');
            stDeviceInfo = this.hAdapterHandle.DeviceInfo;
            for k = 1:length(stDeviceInfo)
                if strcmp(this.cCameraID, stDeviceInfo(k).DeviceName)
                    idx = k;
                end
            end
            this.dCameraIndex = idx;
            this.hCamera = videoinput('winvideo', idx);
        end
        
        function startCaptureStream(this)
            
        end
        
        function stopCaptureStream(this)
            
        end
        
        function snap(this)
            imagesc(getsnapshot(this.hCamera));
        end
        
    end
    
    
    
     
    
end

