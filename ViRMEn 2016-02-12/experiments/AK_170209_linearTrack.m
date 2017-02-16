function code = AK_170209_linearTrack
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
vr.minLength = 0.05;			% SAK 02172017 - sets minimum maze length
vr.lengthFactor = vr.minLength;		% SAK 02172017 - initializes to minimum length
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

vr.minWallLength = eval(vr.exper.variables.wallLengthMin);
vr.wallLength = str2double(vr.exper.variables.wallLength);
vr.startLocation = [0,470,-60,0];
vr.startLocationCurrent = vr.startLocation;
% front wall is at 500
% 460+10 to accomodate edge radius of 9.9
% vr.worlds{1}.startLocation;
% startLocation is buried in linearTrack.mat:exper.worlds.startLocation

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

vr = checkManualReward(vr);
vr = updateTextDisplay_AK(vr);

% states: TRIAL -> INIT_ITI-> ITI -> INIT_TRIAL -> TRIAL
switch vr.STATE
    case 'TRIAL'
        % check for sucessful completion of trial
        
        vr.faceBackwards = vr.position(4) > 3.14/2 && vr.position(4) < 3*3.14/2;  
        if vr.position(2) > 485 && ~vr.faceBackwards
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
            elseif vr.lengthFactor <vr.minLength	% SAK 02162017 -- added a variable to control minimum maze length 
                vr.lengthFactor = vr.minLength;		% SAK 02162017 
            end
            
            % set up world
            % ATK - not happy with this, but a quick fix isn't easy
            length_temp = vr.minWallLength + (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
            vr.startLocationCurrent(2) = vr.startLocation(2) - (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
            vr.exper.variables.wallLengthMin = num2str(length_temp); %this actually changes the back wall
            % note that vr.minWallLength is always 40, even though the
            % exper var changes
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
