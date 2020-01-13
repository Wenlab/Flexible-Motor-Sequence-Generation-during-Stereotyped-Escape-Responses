function [ B,FrameRate ] = quick_calibration
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
%B=zeros(1,num);
for i=start_frame:nFrames   
        num=i-start_frame+1;
        if mod(num,interval)==0
            
            microns=microns+1;
            mov(microns).cdata = double(read(xyloObj,(i-interval/2)));

            temp=zeros((vidWidth-1),vidHeight);
            sumrow=zeros(1,(vidWidth-1));
            for w=1:(vidWidth-1)
                for h=1:vidHeight
                    temp(w,h)=(mov(microns).cdata(w,h)-mov(microns).cdata(w+1,h))^2;
                end
                sumrow(w)=sum(temp(w,:));
            end
            B(microns)=sum(sumrow);
            
            fprintf('The micron is %d .\n',microns);
        end
        

    
end

plot(B);