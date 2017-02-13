function vr = checkManualReward(vr)

% Deliver reward if 'r' key pressed
manualReward = vr.keyPressed == 82; %'r' key
if manualReward
    vr.numRewards = vr.numRewards + 1;
    vr = giveReward_AK(vr,1);
end
