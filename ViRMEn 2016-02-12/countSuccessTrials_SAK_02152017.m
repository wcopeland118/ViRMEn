count=0;
clear a;
a = struct2cell(dataCell);
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