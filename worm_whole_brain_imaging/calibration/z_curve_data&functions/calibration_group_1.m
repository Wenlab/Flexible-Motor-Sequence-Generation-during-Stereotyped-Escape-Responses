function BGroup = calibration_group[ BTotal,FrameRate ]
interval=...%the frames per micron

for i=1:length(BTotal)
    k=0;
    for j=1:length(BTotal{i,1}(1,:)
        k=k+1;
        BGroup{k*i}=
        
BTotal{min,1}=B;

%{
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
    %}


end

