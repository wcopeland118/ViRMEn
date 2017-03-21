
clear a;
a = struct2cell(dataCell);

towerTrials = 0;
noTowerTrials = 0;
rewardsTower = 0;
rewardsNoTower = 0;
if isfield(a{2},'Tower')
    for i = 1:length(a)-1 % first entry is conds (should fix)
        trial=cell2mat(a(i+1));
        if trial.Tower
            towerTrials = towerTrials+1;
            if trial.success
                rewardsTower = rewardsTower+1;
            end
        else
            noTowerTrials = noTowerTrials+1;
            if trial.success
                rewardsNoTower = rewardsNoTower+1;
            end
        end
    end
    numTrials = length(a)-1;
    rewardsAll = rewardsTower+rewardsNoTower;
    disp([num2str(rewardsAll) '/'  num2str(numTrials)]);
    disp(['Tower Percentage:' num2str(rewardsTower/towerTrials)]);
    disp(['No Tower Percentage:' num2str(rewardsNoTower/noTowerTrials)]);
    disp(['Overal:' num2str(rewardsAll/numTrials)]);
else
    for i = 1:(length(a)-1)
        success= cell2mat(a(i+1));
        if success.success
            count = count+1;
        end
    end
    count
    totalTrialNum = length(a)-1
    percentCorrect = count/totalTrialNum
    finalLength = a{end}.pathLength


end