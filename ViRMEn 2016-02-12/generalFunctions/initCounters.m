function vr = initCounters(vr)

% vr.inITI = 0;
% vr.numTrials = 0;
% vr.numRewards = 0;
% vr.dp = 0;
% vr.isReward = 0;
% vr.trialIterations = 0;
% vr.wrongStreak = 0;
% vr.inRewardZone = 0;
% vr.filtSpeed = 0;
% vr.targetRevealed = 0;
% vr.sessionStartTime = tic;
% vr.behaviorData = nan(9,1e4);

%initialize counters
vr.streak = 0;
vr.inITI = 0;
vr.isReward = 0;
vr.startTime = now;
vr.trialStartTime = rem(now,1);
vr.numTrials = 0;
vr.numRewards = 0;
vr.trialResults = [];
vr.itiCorrect = 2;
vr.itiMiss = 4;
