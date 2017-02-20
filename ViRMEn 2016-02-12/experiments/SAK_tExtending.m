function code = SAK_tExtending
%T-maze with extending length, error block mouse at start position

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
vr.adjustmentFactor = 0.01;
vr.lengthFactor = 0;
vr.trialTimeout = 60;
vr.itiDur = 1;

% experimental condition labeel
vr.conds = {'tExtending'};

% initialization funcions
vr = initializePath_AK(vr); % set up paths for output
vr = initTextboxes(vr); % live textboxes
vr = initDAQ_AK(vr); % NI-DAQ, session based
vr = initCounters_AK(vr); 

% Initialize world object handles
vr.adjustmentFactor = 0.01;
vr.minWallLength = eval(vr.exper.variables.wallLengthMin);
vr.lengthFactor = 0;
vr.startLocation = vr.worlds{1}.startLocation;
vr.startLocationCurrent = vr.startLocation;

vr.percentCorrect = 0;
vr.numRightTurns = 0;
vr.numBlackTurns = 0;
vr.trialWindowLRAnswer = zeros(1,20);
vr.trialWindowLRChoice = zeros(1,20);
vr.trialWindowBWAnswer = zeros(1,20);
vr.trialWindowBWChoice = zeros(1,20);

%Define indices of walls
vr.cueWallLeftBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.cueWallLeftBlack,:);
vr.cueWallLeftWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.cueWallLeftWhite,:);
vr.cueWallRightBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.cueWallRightBlack,:);
vr.cueWallRightWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.cueWallRightWhite,:);
vr.backWall = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.backWall,:);
vr.armWallRightWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.armWallRightWhite,:);
vr.armWallRightBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.armWallRightBlack,:);
vr.armWallLeftBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.armWallLeftBlack,:);
vr.armWallLeftWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.armWallLeftWhite,:);
vr.towerRight = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.towerRight,:);
vr.towerLeft = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.towerLeft,:);
vr.delayWallRight = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.delayWallRight,:);
vr.delayWallLeft = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.delayWallLeft,:);
vr.startLocationCurrent = vr.worlds{1}.startLocation;

vr.backWallOriginal = vr.worlds{1}.surface.vertices(:,vr.backWall(1):vr.backWall(2));
vr.wallLength = str2double(vr.exper.variables.wallLength);
vr.length = str2double(vr.exper.variables.wallLengthMin);

vr.edgeIndBackWall = vr.worlds{1}.objects.edges(vr.worlds{1}.objects.indices.backWall,1);
vr.backWallEdges = vr.worlds{1}.edges.endpoints(vr.edgeIndBackWall,:);

vr.backWallCurrent = vr.backWallOriginal(2,:) - (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
vr.worlds{1}.surface.vertices(2,vr.backWall(1):vr.backWall(2)) = vr.backWallCurrent;
vr.worlds{1}.edges.endpoints(vr.edgeIndBackWall,[2,4]) = vr.backWallEdges([2,4]) - (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
vr.startLocationCurrent(2) = vr.worlds{1}.startLocation(2) - (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
vr.position = vr.startLocationCurrent;

vr.isReward = 0;
vr.cuePos = randi(4);

switch vr.cuePos
    case 1 %RightBlack
        vr.worlds{1}.surface.visible(vr.cueWallRightWhite(1):vr.cueWallRightWhite(2))= 0;
        vr.worlds{1}.surface.visible(vr.cueWallLeftWhite(1):vr.cueWallLeftWhite(2))= 0;
        vr.worlds{1}.surface.visible(vr.towerLeft(1):vr.towerLeft(2))= 0;
        vr.worlds{1}.surface.visible(vr.armWallRightWhite(1):vr.armWallRightWhite(2))= 0;
        vr.worlds{1}.surface.visible(vr.armWallLeftBlack(1):vr.armWallLeftBlack(2))= 0;
        
    case 2 %RightWhite
        vr.worlds{1}.surface.visible(vr.cueWallRightBlack(1):vr.cueWallRightBlack(2))= 0;
        vr.worlds{1}.surface.visible(vr.cueWallLeftBlack(1):vr.cueWallLeftBlack(2))= 0;
        vr.worlds{1}.surface.visible(vr.towerLeft(1):vr.towerLeft(2))= 0;
        vr.worlds{1}.surface.visible(vr.armWallRightBlack(1):vr.armWallRightBlack(2))= 0;
        vr.worlds{1}.surface.visible(vr.armWallLeftWhite(1):vr.armWallLeftWhite(2))= 0;
        
    case 3 %LeftBlack
        vr.worlds{1}.surface.visible(vr.cueWallRightWhite(1):vr.cueWallRightWhite(2))= 0;
        vr.worlds{1}.surface.visible(vr.cueWallLeftWhite(1):vr.cueWallLeftWhite(2))= 0;
        vr.worlds{1}.surface.visible(vr.towerRight(1):vr.towerRight(2))= 0;
        vr.worlds{1}.surface.visible(vr.armWallRightBlack(1):vr.armWallRightBlack(2))= 0;
        vr.worlds{1}.surface.visible(vr.armWallLeftWhite(1):vr.armWallLeftWhite(2))= 0;
        
    case 4 %LeftWhite
        vr.worlds{1}.surface.visible(vr.cueWallRightBlack(1):vr.cueWallRightBlack(2))= 0;
        vr.worlds{1}.surface.visible(vr.cueWallLeftBlack(1):vr.cueWallLeftBlack(2))= 0;
        vr.worlds{1}.surface.visible(vr.towerRight(1):vr.towerRight(2))= 0;
        vr.worlds{1}.surface.visible(vr.armWallRightWhite(1):vr.armWallRightWhite(2))= 0;
        vr.worlds{1}.surface.visible(vr.armWallLeftBlack(1):vr.armWallLeftBlack(2))= 0;
        
    otherwise
        error('No World');
end
vr.position = vr.startLocationCurrent;
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

    if abs(vr.position(1)) > eval(vr.exper.variables.armLength)/2 && ...
        vr.position(2) > (eval(vr.exper.variables.wallLength) + eval(vr.exper.variables.delayLength))    % delayLength? default value is 0
    
        if (vr.position(1) > 0 && (vr.cuePos == 1 || vr.cuePos == 2)) || ...
                (vr.position(1) < 0 && (vr.cuePos == 3 || vr.cuePos == 4))
                vr = giveReward_AK(vr,1);
                vr.numRewards = vr.numRewards + 1;
                vr.numTrials = vr.numTrials + 1;
                vr.success = 1;
                vr.trialTime = toc(vr.trialTimer);
                vr.STATE = 'INIT_ITI';
        else 
             vr.numTrials = vr.numTrials + 1;
             vr.trialTime = toc(vr.trialTimer);
             vr.success = 0;
             vr.STATE = 'INIT_ITI';
        end
    elseif toc(vr.trialTimer) > vr.trialTimeout
                
                vr.numTrials = vr.numTrials + 1;
                vr.trialTime = vr.trialTimeout;
                vr.success = 0;
                vr.STATE = 'INIT_ITI';
    end
    
    
    if ((vr.cuePos == 4 || vr.cuePos == 3) && vr.isReward ~= 0) || ((vr.cuePos == 1 || vr.cuePos == 2) && vr.isReward == 0)
        vr.numRightTurns = vr.numRightTurns + 1;
        vr.trialWindowLRChoice = [2,vr.trialWindowLRChoice(1:19)];
    else
        vr.trialWindowLRChoice = [1,vr.trialWindowLRChoice(1:19)];
    end
    if ((vr.cuePos == 1 || vr.cuePos == 3) && vr.isReward == 0) || ((vr.cuePos == 2 || vr.cuePos == 4) && vr.isReward ~= 0)
        vr.numBlackTurns = vr.numBlackTurns + 1;
        vr.trialWindowBWChoice = [2,vr.trialWindowBWChoice(1:19)];
    else
        vr.trialWindowBWChoice = [1,vr.trialWindowBWChoice(1:19)];
    end
    
    case 'INIT_ITI'
    % blackout screen and start timer
    vr.worlds{1}.surface.visible(:) = 0;
    vr.itiStartTime = tic;

     % Summary: Success | Trial Time 
            % One cell per trial
            dataStruct=struct('success',vr.success,'trialTime',vr.trialTime,...
                'pathLength',vr.exper.variables.wallLengthMin,'correctR',);
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
            elseif vr.lengthFactor < 0
                vr.lengthFactor = 0;		
            end
        
        vr.trialWindowLRZeros = vr.trialWindowLRChoice - vr.trialWindowLRAnswer;
        vr.percentCorrect = sum(vr.trialWindowLRZeros==0)/length(vr.trialWindowLRAnswer);
        
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
            vr.cuePos = randi(4);
%             vr.cuePos = randi([2 3],1);
        switch vr.cuePos
            case 1 %RightBlack
                vr.worlds{1}.surface.visible(vr.cueWallRightWhite(1):vr.cueWallRightWhite(2))= 0;
                vr.worlds{1}.surface.visible(vr.cueWallLeftWhite(1):vr.cueWallLeftWhite(2))= 0;
                vr.worlds{1}.surface.visible(vr.towerLeft(1):vr.towerLeft(2))= 0;
                vr.worlds{1}.surface.visible(vr.armWallRightWhite(1):vr.armWallRightWhite(2))= 0;
                vr.worlds{1}.surface.visible(vr.armWallLeftBlack(1):vr.armWallLeftBlack(2))= 0;
                vr.trialWindowBWAnswer = [2,vr.trialWindowBWAnswer(1:19)];
                vr.trialWindowLRAnswer = [2,vr.trialWindowLRAnswer(1:19)];
                
            case 2 %RightWhite
                vr.worlds{1}.surface.visible(vr.cueWallRightBlack(1):vr.cueWallRightBlack(2))= 0;
                vr.worlds{1}.surface.visible(vr.cueWallLeftBlack(1):vr.cueWallLeftBlack(2))= 0;
                vr.worlds{1}.surface.visible(vr.towerLeft(1):vr.towerLeft(2))= 0;
                vr.worlds{1}.surface.visible(vr.armWallRightBlack(1):vr.armWallRightBlack(2))= 0;
                vr.worlds{1}.surface.visible(vr.armWallLeftWhite(1):vr.armWallLeftWhite(2))= 0;
                vr.trialWindowBWAnswer = [1,vr.trialWindowBWAnswer(1:19)];
                vr.trialWindowLRAnswer = [2,vr.trialWindowLRAnswer(1:19)];
                
            case 3 %LeftBlack
                vr.worlds{1}.surface.visible(vr.cueWallRightWhite(1):vr.cueWallRightWhite(2))= 0;
                vr.worlds{1}.surface.visible(vr.cueWallLeftWhite(1):vr.cueWallLeftWhite(2))= 0;
                vr.worlds{1}.surface.visible(vr.towerRight(1):vr.towerRight(2))= 0;
                vr.worlds{1}.surface.visible(vr.armWallRightBlack(1):vr.armWallRightBlack(2))= 0;
                vr.worlds{1}.surface.visible(vr.armWallLeftWhite(1):vr.armWallLeftWhite(2))= 0;
                vr.trialWindowBWAnswer = [2,vr.trialWindowBWAnswer(1:19)];
                vr.trialWindowLRAnswer = [1,vr.trialWindowLRAnswer(1:19)];
                
            case 4 %LeftWhite
                vr.worlds{1}.surface.visible(vr.cueWallRightBlack(1):vr.cueWallRightBlack(2))= 0;
                vr.worlds{1}.surface.visible(vr.cueWallLeftBlack(1):vr.cueWallLeftBlack(2))= 0;
                vr.worlds{1}.surface.visible(vr.towerRight(1):vr.towerRight(2))= 0;
                vr.worlds{1}.surface.visible(vr.armWallRightWhite(1):vr.armWallRightWhite(2))= 0;
                vr.worlds{1}.surface.visible(vr.armWallLeftBlack(1):vr.armWallLeftBlack(2))= 0;
                vr.trialWindowBWAnswer = [1,vr.trialWindowBWAnswer(1:19)];
                vr.trialWindowLRAnswer = [1,vr.trialWindowLRAnswer(1:19)];
        
           
        otherwise
                error('No World');
        end
        

        
         % start timer and begin trial
            vr.trialTimer = tic;
            vr.STATE = 'TRIAL';
      otherwise
        disp('state error!');
        return;
    end



% fwrite(vr.fid,[rem(now,1) vr.position([1:2,4]) vr.velocity(1:2) vr.cuePos vr.isReward vr.inITI],'float');

% --- TERMINATION code: executes after the ViRMEn engine stops.
function vr = terminationCodeFun(vr)
if ~vr.debugMode
    stop(vr.ai),
    delete(vr.ai),
    delete(vr.ao),
end
vr.exper.variables.wallLengthMin = num2str(vr.minWallLength);
commonTerminationVIRMEN(vr);






