function img_Stack=import_micromanager_data_and_reshape()

if exist('pathname', 'var')
    try
        if isdir(pathname)
            cd(pathname);
        end
    end
end
    
[filename,pathname]  = uigetfile({'*.tif'});
    
fname = [pathname filename];

info = imfinfo(fname);

num_frames=length(info);

img_stack=cell(num_frames,1);

for j=1:num_frames
    
    img_stack{j,1}=imread(fname,j, 'Info', info); 
    
    if mod(j,100)==0
        disp(j);
    end
    
end
   
answer = inputdlg({'Start frame', 'End frame','number of z sections'}, '', 1);
istart = str2double(answer{1});
iend = str2double(answer{2});
num_z=str2double(answer{3});
num_t=floor((iend-istart+1)/num_z);
img_Stack=cell(num_t,1);

answer = inputdlg({'Start z section to project', 'End z zection to project'}, '', 1);
start_z = str2double(answer{1});
end_z = str2double(answer{2});
len_z=end_z-start_z+1;

[n,m]=size(img_stack{1,1});

for k=1:num_t
    
    i=(k-1)*num_z+istart;
    
    img_stack_temp=zeros(n,m,len_z);
                    
    for j=1:len_z
        img_stack_temp(:,:,j)=img_stack{i+start_z+j-2,1};
    end
            
    img_Stack{k,1}=max(img_stack_temp,[],3);
    
end
    









    




