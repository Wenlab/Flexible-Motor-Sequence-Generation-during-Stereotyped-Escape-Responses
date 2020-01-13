
answer=inputdlg('Enter the total number of volumes to load');
numVolume=str2num(answer{1});

img_Stack=cell(numVolume,1);

[filename,pathname]  = uigetfile({'*.mat'}); 
fname=[pathname filename(1:end-8)]; 
%exclude the last eight character "000#.mat"

for j=1:numVolume
    
    fname1=strcat(fname,num2str(j,'%04d'),'.mat');
    load(fname1,'imgStack');
    img_Stack{j,1}=imgStack;
end

