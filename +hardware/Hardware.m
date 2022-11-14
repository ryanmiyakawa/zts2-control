% MET5 hardware class.  Contains getters for all hardware handles.
%
% Every hardware communication requires the addition of four things:
%
% 1) Corresponding "comm" property (e.g., commMfDriftMonitorMiddleware) represeting
% the stored handle to the hardware component
%
% 2) Getter function: should return the comm if it is already initialized,
% otherwise should initialize it and then return it
%
% 3) Delete function: disconnects device and unsets the comm property.
%
% 4) Modify the path variable structure to ensure your getter is properly
% scoped.
%

%%%

classdef Hardware < mic.Base
        
    properties (Constant)
        

        cTcpipSmarActZP         = '192.168.20.24'
        cTcpipSmarActGrating    = '192.168.20.25'

        cGratingStageLocation   = 'network:sn:MCS2-00005705';
        cWaferStageLocation     = 'network:sn:MCS2-00005706';
        cDiodeStageLocation     = 'network:sn:MCS2-00005707';
        cPinholeStageLocation   = 'network:sn:MCS2-00005708';
        cTurningMirrorLocation  = 'network:sn:MCS2-00005709';

        
    end
    
	properties
        clock
        
        % {cxro.common.device.motion.Stage 1x1}
        commGratingStage
        commDiodeStage
        commPinholeStage
        commTurningMirrorStage
        commWaferStage

        % Temporarily:{lsicontrol.virtualDevice.virtualPVCam}
        commPIMTECamera
        
        commZPStage
       
                
    end
    

    
    properties (Access = private)
        
        
    end
    
        
    

    
    methods
        
        % Constructor
        function this = Hardware(varargin)
            
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_PROPERTY);
                if this.hasProp( varargin{k})
                    this.msg(sprintf(' settting %s', varargin{k}), this.u8_MSG_TYPE_VARARGIN_SET);
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
            
            if ~isa(this.clock, 'mic.Clock')
                error('clock must be mic.Clock');
            end
            
            this.init();
        end
    
        % Destructor
        function delete(this)

            this.commGratingStage = [];
            this.commDiodeStage = [];
            this.commPinholeStage = [];
            this.commTurningMirrorStage = [];
            this.commWaferStage = [];

            this.commGratingStage= [];
            this.commPIMTECamera = [];
            this.commZPStage = [];
            
        end



        % ZTS2 stages
        function comm = getTurningMirrorStage(this)
            if this.getIsConnectedTurningMirrorStage()
                comm = this.commTurningMirrorStage;
            else
                comm = this.commTurningMirrorStageVirtual;
            end            
        end

        function comm = getPinholeStage(this)
            if this.getIsConnectedPinholeStage()
                comm = this.commPinholeStage;
            else
                comm = this.commPinholeStageVirtual;
            end            
        end

        function comm = getWaferStage(this)
            if this.getIsConnectedWaferStage()
                comm = this.commWaferStage;
            else
                comm = this.commWaferStageVirtual;
            end            
        end

        function comm = getGratingStage(this)
            if this.getIsConnectedGratingStage()
                comm = this.commGratingStage;
            else
                comm = this.commGratingStageVirtual;
            end            
        end

        function comm = getDiodeStage(this)
            if this.getIsConnectedDiodeStage()
                comm = this.commDiodeStage;
            else
                comm = this.commDiodeStageVirtual;
            end            
        end

        
        
        %% MF Drift Monitor (different than MfDriftMonitor Middleware)
        
        function l = getIsConnectedMfDriftMonitor(this)
            if this.notEmptyAndIsA(this.commMfDriftMonitor, 'cxro.met5.device.mfdriftmonitor.MfDriftMonitorCorbaProxy')
                l = true;
            else
                l = false;
            end

        end
        
        function connectMfDriftMonitor(this)
            if isempty(this.jMet5Instruments)
                this.getjMet5Instruments();
           end

           try
                this.commMfDriftMonitor = this.jMet5Instruments.getMfDriftMonitor();
                this.commMfDriftMonitor.connect();
           catch mE
                error(getReport(mE));
           end
        end
        
        function disconnectMfDriftMonitor(this)
            this.commMfDriftMonitor = [];
        end
         
        function comm = getMfDriftMonitor(this)
            if this.getIsConnectedMfDriftMonitor()
                comm = this.commMfDriftMonitor;
                return;
            end
            comm = this.commMfDriftMonitorVirtual;
        end
        
        
        
        
        
        function connectSmarActVPFM(this)
            
            this.getjMet5Instruments();
             try
                
                this.commSmarActVPFM = this.jMet5Instruments.getVPfmStage();
                
                % FIX ME 2019.07.10
                this.commSmarActVPFM.connect();
                %this.commSmarActVPFM.reset();
                %this.commSmarActVPFM.initializeAxes().get();
                %this.commSmarActVPFM.moveAxisAbsolute(0, 0);
                
            catch mE
                
                error(getReport(mE));
            end
        end
        
        function disconnectSmarActVPFM(this)
             if this.getIsConnectedSmarActVPFM()
                 this.commSmarActVPFM.disconnect();
             end
            this.commSmarActVPFM = [];
        end
               
        


        function lVal = getIsConnectedKeithley6482Wafer(this)
            lVal = false;
        end
        
       
    end
    
    methods (Access = private)
        
        
        
        %% Init  functions
        % Initializes directories and any helper classes 
        function init(this)
            
            % {char 1xm} - base directory for configuration and library files
            % for cwcork's cxro.met5.Instruments class

            % Hardware will load the following paths and genpaths on init:

            this.commDiodeStage = smaract.MCS2();
            this.commWaferStage = smaract.MCS2();
            this.commPinholeStage = smaract.MCS2();
            this.commTurningMirrorStage = smaract.MCS2();
            this.commGratingStage = smaract.MCS2();


        end
        
  
        
        function addJavaPathIfNecessary(this, cPath)
            cecPaths = javaclasspath('-dynamic');
            
            if ~isempty(cecPaths)
                ceMatches = mic.Utils.filter(cecPaths, @(cVal) strcmpi(cVal, cPath));
                if ~isempty(ceMatches)
                    return
                end
            end
            
            fprintf('bl12014.hardware.addJavaPathIfNecessary adding:\n%s\n', cPath);
            javaaddpath(cPath);
            
        end
        
        
                

    end % private
    
    
end