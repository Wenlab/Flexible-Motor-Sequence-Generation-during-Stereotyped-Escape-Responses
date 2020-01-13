function [img_stack,fname]=import_micromanager_data()


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

end


%answer = inputdlg({'Start frame', 'End frame','number of neurons to track'}, '', 1);
%istart = str2double(answer{1});
%iend = str2double(answer{2});
%num_pts=str2double(answer{3});

%proof_reading(img_stack,[],fname,istart,iend,num_pts);



    




