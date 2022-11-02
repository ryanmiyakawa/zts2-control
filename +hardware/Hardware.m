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
        
        
      
        cTcpipSmarActZP        = '192.168.20.24'
        cTcpipSmarActGrating     = '192.168.20.25'
        
        
    end
    
	properties
        clock
        
        
        % {cxro.common.device.motion.Stage 1x1}
        commGratingStage
        
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
%             
%             this.disconnectWebSwitchEndstation();
%             this.disconnectWebSwitchVis();
            
            this.commGratingStage= [];
            this.commPIMTECamera = [];
            this.commZPStage = [];
            
        end
        
     
   
                
        function comm = getGratingStage(this)
            if this.getIsConnectedGratingStage()
                comm = this.commGratingStage;
            else
                comm = this.commGratingStageVirtual;
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
               
        
        function connectDCTWaferStage(this)
            
            if this.getIsConnectedDCTWaferStage()
                return
            end

            try
                this.getjMet5Instruments();
                this.commDCTWaferStage = this.jMet5Instruments.getDCTWaferStage();
                this.commDCTWaferStage.connect();
                
            catch mE
                this.commDCTWaferStage = [];
                this.msg(mE.msgtext, this.u8_MSG_TYPE_ERROR);
               
            end
            
        end
        
        function comm = getDCTWaferStage(this)
            
            if this.getIsConnectedDCTWaferStage()
                comm = this.commDCTWaferStage;
                return
            end
                
            comm = this.commDCTWaferStageVirtual;
                
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
%             this.commRigolDG1000ZVirtual = rigol.DG1000ZVirtual();
%             this.commKeithley6482WaferVirtual = keithley.Keithley6482Virtual();
%             this.commKeithley6482ReticleVirtual = keithley.Keithley6482Virtual();
%             this.commDeltaTauPowerPmacVirtual = deltatau.PowerPmacVirtual();
%             this.commHydraWaferVirtual = pi.HydraVirtual();
%             this.commDataTranslationVirtual = datatranslation.MeasurPointVirtual();
%             this.commMfDriftMonitorVirtual = bl12014.hardwareAssets.virtual.MFDriftMonitor();
%             this.commMfDriftMonitorMiddlewareVirtual = bl12014.hardwareAssets.virtual.MFDriftMonitorMiddleware(...
%                 'clock', this.clock ...
%             );
%             this.commWebSwitchBeamlineVirtual = controlbyweb.WebSwitchVirtual();
%             this.commWebSwitchEndstationVirtual = controlbyweb.WebSwitchVirtual();
%             this.commWebSwitchVisVirtual = controlbyweb.WebSwitchVirtual();
%             this.commBL1201CorbaProxyVirtual = bl12014.hardwareAssets.virtual.BL1201CorbaProxy();
%             % this.commDCTCorbaProxyVirtual = bl12014.hardwareAssets.virtual.DCTCorbaProxy();
%             this.commSmarActM141Virtual = bl12014.hardwareAssets.virtual.Stage();
%             this.commSmarActVPFMVirtual = bl12014.hardwareAssets.virtual.Stage();
%             this.commWagoD141Virtual = bl12014.hardwareAssets.virtual.WagoD141();
%             this.commExitSlitVirtual = bl12014.hardwareAssets.virtual.BL12PicoExitSlit();
%             this.commGalilD142Virtual = bl12014.hardwareAssets.virtual.Stage();
%             this.commGalilM143Virtual = bl12014.hardwareAssets.virtual.Stage();
%             this.commGalilVisVirtual = bl12014.hardwareAssets.virtual.Stage();
%             
%             
%             this.commDCTWaferStageVirtual = bl12014.hardwareAssets.virtual.Stage();
%             this.commDCTApertureStageVirtual = bl12014.hardwareAssets.virtual.Stage();
%             
%             this.commSR570DCT1Virtual = srs.SR570Virtual();
%             this.commSR570DCT2Virtual = srs.SR570Virtual();
% 
%             this.commMightex1Virtual = mightex.UniversalLedControllerVirtual();
%             this.commMightex2Virtual = mightex.UniversalLedControllerVirtual();
%             
%             this.commNPointM142Virtual = npoint.LC400Virtual();
%             this.commNPointMAVirtual = npoint.LC400Virtual();
%             
%             this.commALSVirtual = cxro.ALSVirtual();
%             
%             this.commNewFocus8742M142Virtual = newfocus.Model8742Virtual();
%             this.commNewFocus8742MAVirtual = newfocus.Model8742Virtual();
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