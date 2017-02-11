function [vr] = initializePath_AK(vr)
% Initialize virmen path information

%initialize cell info
vr.experimenter = 'ATK';
vr.mazeName = func2str(vr.exper.experimentCode);
vr.exper.variables.mouseNumber = sprintf('%03d',vr.mouseNum); %save mouse num in exper 

%set up path information
if vr.debugMode
    path = ['C:\DATA\Aaron\Debug\Debug_' datestr(now,'yymmdd')];
else
    path = ['C:\DATA\Aaron\Current Mice\AK' sprintf('%03d',vr.mouseNum)];
end
tempPath = 'C:\DATA\Aaron\Temporary';
if ~exist(tempPath,'dir')
    mkdir(tempPath);
end
if ~exist(path,'dir')
    mkdir(path);
end
vr.filenameTempMat = 'tempStorage.mat';
vr.filenameTempMatCell = 'tempStorageCell.mat';
vr.filenameTempDat = 'tempStorage.dat';
vr.filenameMat = ['ATK',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'.mat'];
vr.filenameMatCell = ['ATK',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_Cell.mat'];
vr.filenameDat = ['ATK',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'.dat'];
fileIndex = 0;
fileList = what(path);
while sum(strcmp(fileList.mat,vr.filenameMat)) > 0
    fileIndex = fileIndex + 1;
    vr.filenameMat = ['ATK',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_',num2str(fileIndex),'.mat'];
    vr.filenameMatCell = ['ATK',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_Cell_',num2str(fileIndex),'.mat'];
    vr.filenameDat = ['ATK',vr.exper.variables.mouseNumber,'_',datestr(now,'yymmdd'),'_',num2str(fileIndex),'.dat'];
    fileList = what(path);
end
exper = copyVirmenObject(vr.exper); %#ok<NASGU>
vr.pathTempMat = [tempPath,'\',vr.filenameTempMat];
vr.pathTempMatCell = [tempPath,'\',vr.filenameTempMatCell];
vr.pathTempDat = [tempPath,'\',vr.filenameTempDat];
vr.pathMat = [path,'\',vr.filenameMat];
vr.pathMatCell = [path,'\',vr.filenameMatCell];
vr.pathDat = [path, '\',vr.filenameDat];
save(vr.pathTempMat,'exper');
vr.fid = fopen(vr.pathTempDat,'w');

%save tempFile
save(vr.pathTempMatCell,'-struct','vr','conds');

%{

%initialize reward arm depth
vr.armFac = 3; %armLength/armFac is where reward is given

% Start the DAQ acquisition
if ~vr.debugMode
    daqreset; %reset DAQ in case it's still in use by a previous Matlab program
    vr.ai=daq.createSession('ni'); % connect to the DAQ card
    addAnalogInputChannel(vr.ai,'Dev1',0:2,'Voltage'); % start channels 0:2
    
             %     s = daq.createSession('ni');
            %     s.addAnalogInputChannel('cDAQ1Mod1', 'ai0', 'Voltage');
            %     lh = s.addlistener('DataAvailable', ...
            %         @(src,event) plot(event.TimeStamps, event.Data));
            %     s.startBackground();
            %     delete(lh);
    
    vr.ai.Rate = 1e1; % ATK reduced this so Rate*Duration<8.5E9
    vr.ai.DurationInSeconds  = 1e7;
    
    lh = vr.ai.addlistener('DataAvailable',...
        @(src,event) plot(event.TimeStamps, event.Data));
    vr.ai.startBackground();% start acquisition
    delete(lh);
    addAnalogOutputChannel(vr.ao,'Dev1',0,'Current')
    vr.ao.rate = 1e3;s
end

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

%initialize text boxes
vr.text(1).string = '';
vr.text(1).position = [1 .8];
vr.text(1).size = .02;
vr.text(1).color = [1 0 1];

vr.text(2).string = '';
vr.text(2).position = [1 .7];
vr.text(2).size = .02;
vr.text(2).color = [1 1 0];

vr.text(3).string = '';
vr.text(3).position = [1 .6];
vr.text(3).size = .02;
vr.text(3).color = [0 1 1];

vr.text(4).string = '';
vr.text(4).position = [1 .5];
vr.text(4).size = .02;
vr.text(4).color = [.5 .5 1];

vr.text(5).string = '';
vr.text(5).position = [1 .4];
vr.text(5).size = .02;
vr.text(5).color = [1 0 0];
%}

end

