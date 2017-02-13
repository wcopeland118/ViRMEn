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

end

