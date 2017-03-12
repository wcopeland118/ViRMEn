function code = SAK_Continuity_2Cond
% Continuity   Code for the ViRMEn experiment Continuity.
%   code = Continuity Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.

% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT

% --- INITIALIZATION code: executes before the ViRMEN engine starts.
function vr = initializationCodeFun(vr)

% set parameters
vr.debugMode = true;
vr.mouseNum = 999;
vr.trialTimeout = 120;
vr.itiDur = 2;  % increased itiDur from 1 to 3 to discourage initial running of mice at start
vr.friction = 1; % define friction that will reduce velocity by 0% during collisions

% experimental condition labeel
vr.conds = {'Continuity'};

% initialization funcions
vr = initializePath_AK(vr); % set up paths for output
vr = initTextboxes(vr); % live textboxes
vr = initDAQ_AK(vr); % NI-DAQ, session based
vr = initCounters_AK(vr); 

vr.startLocation = vr.worlds{1}.startLocation;          % Specified in the world
vr.startLocationCurrent = vr.startLocation;

vr.worlds{1}.surface.visible(:) = 0;
%Define indices of walls
vr.LeftWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftWallBlack,:);
vr.RightWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightWallBlack,:);
vr.BackWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.BackWallBlack,:);
vr.LeftWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftWallWhite,:);
vr.RightWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightWallWhite,:);
vr.BackWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.BackWallWhite,:);

% Fixed t-Arm color white on L, black on R
vr.RArmWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightArmWallBlack,:);
vr.REndWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.RightEndWallBlack,:) ;
vr.RTopWallBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopWallRightBlack,:) ;
vr.LArmWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftArmWallWhite,:) ;
vr.LEndWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.LeftEndWallWhite,:) ;
vr.LTopWallWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.TTopWallLeftWhite,:);
vr.worlds{1}.surface.visible([vr.RArmWallBlack(1):vr.RArmWallBlack(2) ...
                              vr.REndWallBlack(1):vr.REndWallBlack(2) ...
                              vr.RTopWallBlack(1):vr.RTopWallBlack(2) ...
                              vr.LArmWallWhite(1):vr.LArmWallWhite(2) ...
                              vr.LEndWallWhite(1):vr.LEndWallWhite(2) ...
                              vr.LTopWallWhite(1):vr.LTopWallWhite(2) ]) = 1;

% White dot tower on left
vr.whiteLeftTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.WhiteLeftTower,:);
vr.whiteLeftTowerOn = vr.whiteLeftTower(1):vr.whiteLeftTower(2);
% Black dot tower on right
vr.blackRightTower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.BlackRightTower,:);
vr.blackRightTowerOn = vr.blackRightTower(1):vr.blackRightTower(2);

%Define linear track portion of the maze
vr.blackRight = [vr.LeftWallBlack(1):vr.LeftWallBlack(2) vr.RightWallBlack(1):vr.RightWallBlack(2) ...
    vr.BackWallBlack(1):vr.BackWallBlack(2)];

vr.whiteLeft = [vr.LeftWallWhite(1):vr.LeftWallWhite(2) vr.RightWallWhite(1):vr.RightWallWhite(2) ...
    vr.BackWallWhite(1):vr.BackWallWhite(2)];

vr.oneTower = 1;    % Presentation of one tower
vr.cuePos = randi([1 2],1);
if vr.cuePos == 1       % Right Stim
    vr.worlds{1}.surface.visible([vr.blackRight vr.blackRightTowerOn]) = 1;
elseif vr.cuePos == 2   % Left stim
    vr.worlds{1}.surface.visible([vr.whiteLeft vr.whiteLeftTowerOn]) = 1;
else
    error('No World');
end

vr.position = vr.startLocationCurrent;
vr.dp = 0;
vr.startTime = now;
vr.trialTimer = tic;
vr.trialTime = 0;
vr.success = 0;
vr.isStimR = 0;
vr.STATE = 'TRIAL';

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
vr = checkManualReward(vr);
vr = updateTextDisplay_AK(vr);

% states: TRIAL -> INIT_ITI-> ITI -> INIT_TRIAL -> TRIAL (State Machines)
switch vr.STATE
    case 'TRIAL'    
       % Find instances where the animal reaches either end of the t-arm
       if abs(vr.position(1)) > eval(vr.exper.variables.armLength)/2 && ...
                    vr.position(2) > (eval(vr.exper.variables.MazeLengthAhead))
            % Right choice
            if (vr.position(1) > 0 && vr.cuePos == 1) || ...
                    (vr.position(1) < 0 && vr.cuePos == 2)
                vr = giveReward_AK(vr,1);
                vr.numRewards = vr.numRewards + 1;
                vr.numTrials = vr.numTrials + 1;
                vr.success = 1;
                vr.trialTime = toc(vr.trialTimer);
                vr.STATE = 'INIT_ITI';
            % Wrong choice
            else
                vr.numTrials = vr.numTrials + 1;
                vr.trialTime = toc(vr.trialTimer);
                vr.success = 0;
                vr.STATE = 'INIT_ITI';
            end
        elseif toc(vr.trialTimer) > vr.trialTimeout  % timeout is counted as a failure
                
                vr.numTrials = vr.numTrials + 1;
                vr.trialTime = vr.trialTimeout;
                vr.success = 0;
                vr.STATE = 'INIT_ITI';
        end

        if vr.collision % test if the animal is currently in collision
                % reduce the x and y components of displacement
            vr.dp(1:2) = vr.dp(1:2) * vr.friction;
        end

        if vr.cuePos == 1
           vr.isStimR = 1;   % 1(true) if stimulus was R  
        end
        
        if (vr.cuePos == 1 && vr.success == 1) || (vr.cuePos == 2 && vr.success ==0)
            vr.trialResults(1,size(vr.trialResults,1)+1) = 1;     % counting right preference
        else
            vr.trialResults(1,size(vr.trialResults,1)+1) = 0;
        end
        
    case 'INIT_ITI'
        % blackout screen and start timer
        vr.worlds{1}.surface.visible(:) = 0;
        vr.itiStartTime = tic;

        % Summary: Success | Trial Time 
        % One cell per trial
        dataStruct=struct('success',vr.success,'trialTime',vr.trialTime,...
            'isStimR',vr.isStimR);
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
       % Select cue
       vr.cuePos = randi([1 2],1); 
       % T-arm is always on
       vr.worlds{1}.surface.visible([vr.RArmWallBlack(1):vr.RArmWallBlack(2) ...
                              vr.REndWallBlack(1):vr.REndWallBlack(2) ...
                              vr.RTopWallBlack(1):vr.RTopWallBlack(2) ...
                              vr.LArmWallWhite(1):vr.LArmWallWhite(2) ...
                              vr.LEndWallWhite(1):vr.LEndWallWhite(2) ...
                              vr.LTopWallWhite(1):vr.LTopWallWhite(2) ]) = 1;
        % On alternating trials, add a second tower   
        if vr.oneTower == 0    
            vr.oneTower = 1;   % present one tower
        else
            vr.oneTower = 0;   % present both towers
        end
        
        if vr.cuePos == 1   % Stim -- Right
            vr.worlds{1}.surface.visible(vr.blackRight) = 1;
            if vr.oneTower == 1 
                vr.worlds{1}.surface.visible([vr.blackRightTowerOn]) = 1;
            else
                vr.worlds{1}.surface.visible([vr.blackRightTowerOn vr.whiteLeftTowerOn]) = 1;
            end
        elseif vr.cuePos == 2 % Stim -- Left
            vr.worlds{1}.surface.visible(vr.whiteLeft) = 1;
            if vr.oneTower == 1
                vr.worlds{1}.surface.visible([vr.whiteLeftTowerOn]) = 1;
            else
                vr.worlds{1}.surface.visible([vr.blackRightTowerOn vr.whiteLeftTowerOn]) = 1;
            end
        else
            error('No World');
        end
        vr.position = vr.worlds{1}.startLocation;
   
        vr.dp = 0; %prevents movement
        
        % start timer and begin trial
        vr.trialTimer = tic;
        vr.STATE = 'TRIAL';
      
    otherwise
        disp('state error!');
    return;
end

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
if ~vr.debugMode
    stop(vr.ai),
    delete(vr.ai),
    delete(vr.ao),
end
commonTerminationVIRMEN(vr);