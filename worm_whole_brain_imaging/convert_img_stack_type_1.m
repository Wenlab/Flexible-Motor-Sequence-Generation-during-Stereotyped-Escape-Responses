function img_Stack=convert_img_stack_type(img_stack,numSlice,mode)

% The numSlice is the number of sclices to scan the whole worm once.
% The mode has only two options: 'linear' and 'triangle' which correspond to scanning waves using in the experiment.



%This modified code is for data saved using micromanager. When we acquire
%long sequences data using micromanager (>10000 frames), the data is
%saved as a few stack files. To run this code, use 
%import_micromanager_data.m and combine_micromanager_data.m to 
%combine the stack files and create a single variable img_stack in the 
%workspace. img_stack is an Nx1 cell array, where N is the total number of
%frames. Each element in the cell array is a 2D matrix (height x width)   

%We next convert the img_stack into an Mx1 cell array (img_Stack), taking into account the ordering of each frame. 
%Here M is the total number of volumes. Each element in the cell array is a 3D matrix (height x
%width x numSlice).Each 3D volume matrix is also saved as an individual mat file.  


%For data saved using LabView, one should first convert the tif image
%sequences files to tif stack using fiji.

info=get_info_of_file(); %find the name of the image_stack
numFrames = length(img_stack);
numVolume=floor(numFrames/numSlice);
img_Stack=cell(numVolume,1);
imgStack = uint16(zeros([size(img_stack{1,1}),numSlice]));
v=0;
for j=1:numFrames
    img = img_stack{j,1};
    
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

function info=get_info_of_file()
    [filename,pathname]  = uigetfile({'*.tif'}); 
    fname = [pathname filename];           
    info = imfinfo(fname);
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
      