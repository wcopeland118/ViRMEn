function code = calibrateReward_AK_170209_linearTrack
% Edited from linearTrack (Laura Driscoll)
% First training map 
% Track length extends as mouse learns to run forward

% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

% set parameters
vr.debugMode = false;
vr.mouseNum = 999;
vr.adjustmentFactor = 0.01;
vr.lengthFactor = 0;
vr.trialTimeout = 60;
vr.itiDur = 1;
            
% experimental condition labeel
vr.conds = {'Linear Track'};

% initialization funcions
vr = initializePath_AK(vr); % set up paths for output
vr = initTextboxes(vr); % live textboxes
vr = initDAQ_AK(vr); % NI-DAQ, session based
vr = initCounters_AK(vr); 

% Initialize world object handles

% vr.startLocationCurrent = vr.worlds{1}.startLocation; 

% 85 virmen units is one full rotation of the ball
vr.exper.variables.wallLengthMin = num2str(95);

vr.minWallLength = eval(vr.exper.variables.wallLengthMin);
vr.wallLength = str2double(vr.exper.variables.wallLength);

vr.startLocation = [0,vr.wallLength-85,-60,0.01];
vr.startLocationCurrent = vr.startLocation;
% experiment start parameters
vr.position = vr.startLocationCurrent;
vr.cuePos = 1;
vr.dp = 0;
vr.startTime = now;
vr.trialTimer = tic;
vr.trialTime = 0;
vr.success = 0;
vr.STATE = 'TRIAL';

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% Deliver reward if 'r' key pressed
manualReward = vr.keyPressed == 82; %'r' key
if manualReward
    vr.numRewards = vr.numRewards + 1;
    for j = 1:250
    vr = giveReward_AK(vr,1);   % dispense 250 rewards instead of 1 reward at longer duration.
    end
end

vr = updateTextDisplay_AK(vr);

% states: TRIAL -> INIT_ITI-> ITI -> INIT_TRIAL -> TRIAL
switch vr.STATE
    case 'TRIAL'
        % check for sucessful completion of trial
        if vr.position(2) > 485
            vr = giveReward_AK(vr,1);
            vr.numRewards = vr.numRewards + 1;
            vr.numTrials = vr.numTrials + 1;
            vr.success = 1;
            vr.trialTime = toc(vr.trialTimer);
            vr.STATE = 'INIT_ITI';            
        elseif toc(vr.trialTimer) > vr.trialTimeout
            vr.STATE = 'INIT_ITI';
            vr.trialTime = vr.trialTimeout;
            vr.success = 0;
        end
    case 'INIT_ITI'   
            % blackout screen and start timer
            vr.worlds{1}.surface.visible(:) = 0;
            vr.itiStartTime = tic;
        
            % save previous trial data
            
            % Summary: Success | Trial Time 
            % One cell per trial
            dataStruct=struct('success',vr.success,'trialTime',vr.trialTime,...
                'pathLength',vr.exper.variables.wallLengthMin);
            eval(['trial',num2str(vr.numTrials),'=dataStruct;']);
            % save to temp .mat file
            if exist(vr.pathTempMatCell,'file')
                save(vr.pathTempMatCell,['trial',num2str(vr.numTrials)],'-append');
            else
                save(vr.pathTempMatCell,['trial',num2str(vr.numTrials)]);
            end
            vr.STATE = 'ITI';
    case 'ITI'
            vr.itiTime = toc(vr.itiStartTime);
            if vr.itiTime > vr.itiDur 
                vr.STATE = 'INIT_TRIAL';
            end
    case 'INIT_TRIAL'
            % if mouse completed in less than 20 sec, make the map longer
            % otherwise make it shorter
            if vr.trialTime < 20
                vr.lengthFactor = vr.lengthFactor + vr.adjustmentFactor;
            else
                vr.lengthFactor = vr.lengthFactor - vr.adjustmentFactor;
            end
            
            % but always within bounds 
            if vr.lengthFactor > 1
                vr.lengthFactor = 1;
            elseif vr.lengthFactor <0
                vr.lengthFactor = 0;
            end
            
            % set up world

            length_temp = eval(vr.exper.variables.wallLengthMin) + (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
            vr.startLocationCurrent(2) = vr.worlds{1}.startLocation(2) - (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
            vr.exper.variables.wallLengthMin = num2str(length_temp);         
            vr.worlds{1} = loadVirmenWorld(vr.exper.worlds{1});
            vr.worlds{1}.surface.visible(:) = 0;
            vr.position = vr.startLocationCurrent;
            vr.dp = 0;
            vr.worlds{1}.surface.visible(:) = 1;
            
            % start timer and begin trial
            vr.trialTimer = tic;
            vr.STATE = 'TRIAL';
            
            
    otherwise
        disp('state error!');
        return;
end

%fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI],'float');

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
if ~vr.debugMode
    stop(vr.ai),
    delete(vr.ai),
    delete(vr.ao),
end
vr.exper.variables.wallLengthMin = num2str(vr.minWallLength);
commonTerminationVIRMEN(vr);