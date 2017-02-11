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
vr.debugMode = true;
vr.mouseNum = 999;
vr.adjustmentFactor = 0.01;
vr.lengthFactor = 0;

% experimental condition labeel
vr.conds = {'Linear Track'};

% initialization funcions
vr = initializePath_AK(vr); % set up paths for output
vr = initTextboxes(vr); % live textboxes
vr = initDAQ_AK(vr); % NI-DAQ, session based
vr = initCounters_AK(vr); 



% Define indices of walls
vr.cueWallLeftBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.cueWallLeftBlack,:);
vr.cueWallLeftWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.cueWallLeftWhite,:);
vr.cueWallRightBlack = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.cueWallRightBlack,:);
vr.cueWallRightWhite = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.cueWallRightWhite,:);
vr.frontWall = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.frontWall,:);
vr.backWall = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.backWall,:);
vr.tower = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.tower,:);
vr.delayWallRight = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.delayWallRight,:);
vr.delayWallLeft = vr.worlds{1}.objects.triangles(vr.worlds{1}.objects.indices.delayWallLeft,:);
vr.startLocationCurrent = vr.worlds{1}.startLocation;

vr.minWallLength = eval(vr.exper.variables.wallLengthMin);
vr.backWallOriginal = vr.worlds{1}.surface.vertices(:,vr.backWall(1):vr.backWall(2));
vr.wallLength = str2double(vr.exper.variables.wallLength);

vr.edgeIndBackWall = vr.worlds{1}.objects.edges(vr.worlds{1}.objects.indices.backWall,1);
vr.backWallEdges = vr.worlds{1}.edges.endpoints(vr.edgeIndBackWall,:);

vr.backWallCurrent = vr.backWallOriginal(2,:);

% experiment start parameters
vr.position = vr.startLocationCurrent;
vr.cuePos = 1;

vr.dp = 0;
vr.startTime = now;
vr.trialTimer = tic;

% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)

% check for reward / end of trial
if vr.inITI == 0 && abs(vr.position(2)) > 485
    vr = giveReward_AK(vr,1);
    vr.itiDur = vr.itiCorrect;
    vr.numRewards = vr.numRewards + 1;
    
    vr.worlds{1}.surface.visible(:) = 0;
    vr.itiStartTime = tic;
    vr.inITI = 1;
    vr.numTrials = vr.numTrials + 1;
    vr.cellWrite = true;
else
    vr.isReward = 0;
end

% During inter trial interval:
if vr.inITI == 1
    % save data once per ITI
    if vr.cellWrite
%         [dataStruct] = createSaveStruct(vr.mouseNum,vr.experimenter,...
%             vr.conds,vr.whiteMazes,vr.leftMazes,vr.mazeName,vr.cuePos,vr.leftMazes(vr.cuePos),...
%             vr.whiteMazes(vr.cuePos),vr.isReward,vr.itiCorrect,vr.itiMiss,vr.isReward ~= 0,vr.leftMazes(vr.cuePos)==(vr.isReward~=0),...
%             vr.whiteMazes(vr.cuePos)==(vr.isReward~=0),vr.streak,vr.trialStartTime,rem(now,1),vr.startTime); %#ok<NASGU>
        dataStruct=struct('mouseNum',vr.mouseNum);
        eval(['data',num2str(vr.numTrials),'=dataStruct;']);
        %save datastruct
        if exist(vr.pathTempMatCell,'file')
            save(vr.pathTempMatCell,['data',num2str(vr.numTrials)],'-append');
        else
            save(vr.pathTempMatCell,['data',num2str(vr.numTrials)]);
        end
        vr.cellWrite = false;
    end
    
    % check if ITI should be over
    vr.itiTime = toc(vr.itiStartTime);
    if vr.itiTime > vr.itiDur 
        vr.inITI = 0;
        
        % if mouse completed in less than 20 sec
        % make the map longer
        % otherwise make it shorter
        if toc(vr.trialTimer) < 20
            vr.lengthFactor = vr.lengthFactor + vr.adjustmentFactor;
        elseif toc(vr.trialTimer) > 20
            vr.lengthFactor = vr.lengthFactor - vr.adjustmentFactor;
        end
        % but always within 1 and 0
        if vr.lengthFactor > 1
            vr.lengthFactor = 1;
        elseif vr.lengthFactor <0
            vr.lengthFactor = 0;
        end
        
        % reset to new trial
        length_temp = eval(vr.exper.variables.wallLengthMin) + (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
        vr.startLocationCurrent(2) = vr.worlds{1}.startLocation(2) - (vr.lengthFactor)*(vr.wallLength - vr.minWallLength);
        vr.exper.variables.wallLengthMin = num2str(length_temp);
        vr.worlds{1} = loadVirmenWorld(vr.exper.worlds{1});
        vr.worlds{1}.surface.visible(:) = 0;
        
        vr.position = vr.startLocationCurrent;        
        vr.dp = 0;
        vr.trialTimer = tic;
        vr.worlds{1}.surface.visible(:) = 1;
    end
end

% Update Textboxes
vr = updateTextDisplay_AK(vr);


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