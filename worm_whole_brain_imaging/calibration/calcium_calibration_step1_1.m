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

%%
[Width,Height]=size(img_stack{1,1});
ImgSum=zeros(Width,Height);
for num=1:length(img_stack)
    for i=1:Width
        for j=1:Height
            ImgSum(i,j)=ImgSum(i,j)+double(img_stack{num,1}(i,j));
        end
    end
end
ImgAve=ImgSum/length(img_stack);
imagesc(ImgAve);
pause(3);

%%

Max=0;
for i=1:Width
    for j=1:Height
        if Max<ImgAve(i,j)
            Max=ImgAve(i,j);
        end
    end
end

for i=1:Width
    for j=1:Height
        Mask(i,j)=ImgAve(i,j)/Max;
    end
end
imagesc(Mask);
pause(3);


