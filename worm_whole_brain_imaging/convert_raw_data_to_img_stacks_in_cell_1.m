function img_Stack=convert_raw_data_to_img_stacks_in_cell(numSlice,mode)
% The numSlice is the number of sclices to scan the whole worm once.
% The mode has only two options: 'linear' and 'triangle' which correspond to scanning waves using in the experiment.

% Each imgStack is one 3D volumn of the whole .tif. If you want to save them as .mat files, you can add the function: write_in_file
% The output is an Mx1 cell array (img_Stack), which is the input to the GUI: "the whole brain imaging".

%Here M is the total number of volumes. Each element in the cell array is a 3D matrix (height x width x numSlice).

[filename,pathname]  = uigetfile({'*.tif'});
fname = [pathname filename];

info = imfinfo(fname);
numFrames=length(info);
numVolume=floor(numFrames/numSlice);

img_Stack=cell(numVolume,1);% This variable is the input to the GUI: "the whole brain imaging"
imgStack = uint16(zeros([info(1).Height,info(1).Width,numSlice]));

v=0;

for j=1:numFrames
    img=imread(fname,j, 'Info', info);
    
    k = mod(j,numSlice);
    orderNum = ceil(j/numSlice);
    if k ~= 0
        k=mode_select(k,j,mode,numSlice);
        imgStack(:,:,k) = img;
    else
        k=mode_select(k,j,mode,numSlice);
        imgStack(:,:,k) = img;
        v=v+1;
        img_Stack{v,1}=imgStack(:,:,1:end);
        write_in_file(info,imgStack,orderNum);
        imgStack = uint16(zeros([size(img),numSlice]));
    end
    
end


end

function k=mode_select(k,frameOrder,mode,numSlice)
if (k==0)
    k = numSlice;
end
if strcmp(mode,'triangle')
    numVolume = ceil(frameOrder/numSlice);
    up = ~mod(numVolume,2);
    if up
        k = numSlice-k+1;
    end
elseif strcmp(mode,'linear')
    
else
    error('The mode has only two options: "linear" and "triangle", which correspond to scanning waves using in the experiment.');
end
end

function write_in_file(info,imgStack,orderNum)
    fname = info.Filename;
    findResult = find(fname == '\');
    lastBackslashIndex = findResult(end);
    fname1 = strcat(fname(1:lastBackslashIndex),'matlab\mcherry',num2str(orderNum, '%04d'),'.mat');
    %the saved data has the format '*0005.mat'
    save(fname1,'imgStack');
    fprintf('%d stacks have been saved \n',orderNum); 
end
