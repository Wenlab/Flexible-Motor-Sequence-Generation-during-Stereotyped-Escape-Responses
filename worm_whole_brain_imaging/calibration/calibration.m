function [ BTotal,FrameRate ] = calibration
[filename,pathname]  = uigetfile({'*.avi'});
    
fname = [pathname filename];
xyloObj = VideoReader(fname);

vidWidth = xyloObj.Width;
vidHeight = xyloObj.Height;
FrameRate = xyloObj.FrameRate;
Duration = xyloObj.Duration;
nFrames = Duration*FrameRate;

minutes=floor(Duration/60);
BTotal=cell(minutes,1);

prompt={'start minute','end minute'};
dlg_title='duration';
num_lines=1;
defaultans={'1','5'};
answer=inputdlg(prompt,dlg_title,num_lines,defaultans);
start_time=str2double(answer{1});
end_time=str2double(answer{2})-1;
if end_time+2>Duration
    fprintf('end_time is too high\n');
    return
end
fprintf('Now the video analysis starts at %dth minute, ends at %dth minute.\n',start_time,(end_time+1));

for min=start_time:end_time

    num = 0;
    mov = struct('cdata',zeros(vidHeight,vidWidth,3,'double'),...
        'colormap',[]);
    
    if (min+1)*60<=Duration
        LastFrame=(min+1)*60*FrameRate;
    else
        LastFrame=nFrames;
    end
    
    for i = (min*60*FrameRate+1):LastFrame
        num = num+1;
        mov(num).cdata = double(read(xyloObj,i));
        if mod(num,FrameRate*10)==0
            fprintf('%d second(s) video have been loaded.\n',num/FrameRate);
        end
        if num/FrameRate==60
            break
        end
    end

    B=zeros(1,num);
    temp=zeros((vidWidth-1),vidHeight);
    sumrow=zeros(1,(vidWidth-1));

    for k=1:num
        for i=1:(vidWidth-1)
            for j=1:vidHeight            
                temp(i,j)=(mov(k).cdata(i,j)-mov(k).cdata(i+1,j))^2; 
            end
            sumrow(i)=sum(temp(i,:));
        end
        B(k)=sum(sumrow);
        if mod(k,FrameRate)==0
            fprintf('%d second(s) video have been computed.\n',k/FrameRate);
        end
    end



    plot(B);
    
    ax=gca;
    k=0;
    
    for i=1:num
        if mod(i,FrameRate*10)==0
            k=k+1;
        end
    end

    time10s=floor(num/(FrameRate*10))+1;
    xticksnum=time10s*FrameRate*10;
    xticks=linspace(0,xticksnum,time10s+1);
    ax.XTick=xticks;
    XTickLabel=cell([k+2 1]);

    for i=1:(k+2)
        label10s=[num2str((i-1)*10),'s'];
        XTickLabel{i}=label10s;
    end

    ax.XTickLabel=XTickLabel;
    xlabel('time');
    ylabel('variation');
    saveas(gcf,[pathname 'fig_' num2str(min) '.fig'])

    BTotal{min+1,1}=B;
end

