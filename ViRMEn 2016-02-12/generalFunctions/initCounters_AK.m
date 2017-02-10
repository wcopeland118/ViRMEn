function vr = initCounters_AK(vr)

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

