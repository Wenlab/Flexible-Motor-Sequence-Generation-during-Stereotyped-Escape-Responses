function [ MeanB,BTotal,FrameRate ] = slow_calibration
[filename,pathname]  = uigetfile({'*.avi'});
    
fname = [pathname filename];
xyloObj = VideoReader(fname);

vidWidth = xyloObj.Width;
vidHeight = xyloObj.Height;
FrameRate = xyloObj.FrameRate;
Duration = xyloObj.Duration;
nFrames = Duration*FrameRate;

%BTotal=zeros(nFrames,1);

prompt={'start second'};
dlg_title='duration';
num_lines=1;
defaultans={'1'};
answer=inputdlg(prompt,dlg_title,num_lines,defaultans);
start_time=str2double(answer{1});

fprintf('Now the video analysis starts at %dth second\n',start_time);
start_frame=floor(start_time*FrameRate)+1;

interval=150;%150frames

microns=0;
mov = struct('cdata',zeros(vidHeight,vidWidth,3,'double'),...
    'colormap',[]);

for i=start_frame:nFrames
    num=i-start_frame+1;
    if mod(num,interval)==0
        
        microns=microns+1;
        count=0;
        B=zeros(1,floor(i-interval/4)-floor(i-interval/4*3)+1);
        interval_start=double(floor(i-interval/4*3));
        interval_end=double(floor(i-interval/4));
        
       for j=interval_start:interval_end
            
            count=count+1;
            mov(count).cdata = double(read(xyloObj,j));
            
            temp=zeros((vidWidth-1),vidHeight);
            sumrow=zeros(1,(vidWidth-1));
            for w=1:(vidWidth-1)
                for h=1:vidHeight
                    temp(w,h)=(mov(count).cdata(w,h)-mov(count).cdata(w+1,h))^2;
                end
                sumrow(w)=sum(temp(w,:));
            end
            B(count)=sum(sumrow);
        end

        fprintf('The micron is %d .\n',microns);
        BTotal{microns,1}=B;
    end
    
end

for i=1:microns
    MeanB(i,1)=mean(BTotal{i,1}(1,:),2);
end
plot(MeanB);