clearvars
mintime = 1.5;
deleteth = 0.05;
backtimemax = 200;
smoothpara = 5;
smallsmoothpara = 5;
trial = 1:17;
trialnum = length(trial);
gcamp_ref = cell(1,trialnum);
gcamp_ori = cell(1,trialnum);
ratio = cell(1,trialnum);
ratio_smo = cell(1,trialnum);
ratio_nor = cell(1,trialnum);
dRR0 = cell(1,trialnum);
smo = cell(1,trialnum);
time = cell(1,trialnum);
rampturn = cell(1,trialnum);
rampnoturn = cell(1,trialnum);
for i = trial
    temp = xlsread('data.xlsx',i);
    temp(1,1) = NaN;
    gcamp_ref{i} = temp(:,2);
    gcamp_ori{i} = temp(:,1);
    ratio{i} = gcamp_ori{i}./gcamp_ref{i};
    time{i} = xlsread('time.xlsx',i);
    totaltime(i) = length(gcamp_ref{i});
end
%totaltime = length(gcamp_ref{1});
for i = trial
    %{
    ratio_smo{i} = NaN*zeros(totaltime(i),1);
    for j = 1:size(time{i},2)
        ratio_smo{i}( (time{i}(1,j)+1) : (time{i}(2,j))  ) = smooth(ratio{i}( (time{i}(1,j)+1) : (time{i}(2,j))  ),smoothpara);
    end 
    %}
    %ratio_smo{i} = smooth(ratio{i},smoothpara);
    ratio_smo{i} = ratio{i};
    if i ==1 
        j = 2;
        ratio_smo{i}( (time{i}(1,j)+1) : (time{i}(2,j))  ) = smooth(ratio{i}( (time{i}(1,j)+1) : (time{i}(2,j))  ),smallsmoothpara);
    end
    if i ==16
        j = 3;
        ratio_smo{i}( (time{i}(1,j)+1) : (time{i}(2,j))  ) = smooth(ratio{i}( (time{i}(1,j)+1) : (time{i}(2,j))  ),smallsmoothpara);
        j = 7;
        ratio_smo{i}( (time{i}(1,j)+1) : (time{i}(2,j))  ) = smooth(ratio{i}( (time{i}(1,j)+1) : (time{i}(2,j))  ),smallsmoothpara);
    end
	NotANum = isnan(ratio{i});
    NaNPos = find( NotANum ==1 );
    for j = 1:length( NaNPos )
        ratio_smo{i}( NaNPos(j) ) = NaN;
    end
    mintemp = min(ratio{i});
    maxtemp = max(ratio{i});
    smo{i} = ( ratio_smo{i} - mintemp ) ./ ( maxtemp - mintemp );
    mintemp = min(ratio{i});
    maxtemp = max(ratio{i});
    ratio_nor{i} = ( ratio{i} - mintemp ) ./ ( maxtemp - mintemp );
    %smo{i} = ( ratio_smo{i} - mintemp ) ./ mintemp ;
    mintemp = min(ratio{i});
    maxtemp = max(ratio{i});
    %dRR0{i} = ( ratio_smo{i} - mintemp ) ./ ( maxtemp - mintemp );
    dRR0{i} = ( ratio{i} - mintemp ) ./ mintemp ;
end
time{2} = [time{2};NaN*zeros(1,5)];
time{14} = [time{14};NaN*zeros(1,5)];

for i = trial
    if i>=4 & i<=7
        frame = 20;
    else
        frame = 50;
    end
    for j = 1:size(time{i},2)
        if isnan(time{i}(1,j)) == 0
            if isnan(time{i}(3,j)) == 1
                Y = smo{i}( (time{i}(1,j)+1) : (time{i}(2,j))  );
                %Y = dRR0{i}( (time{i}(1,j)+1) : (time{i}(2,j))  );
                testlength = length(Y);
                X = 1:(testlength);
                X = [ones(testlength,1),X'/50];
                [b1, bint1,r1,rint1,stats1] = regress(Y,X,0.05);
                %if stats1(3)>=deleteth
                if testlength >= mintime*frame
                    rampnoturn{i} = [rampnoturn{i},b1(2)];
                end
                %end
                else
                Y = smo{i}( (time{i}(1,j)+1) : (time{i}(2,j))  );
                %Y = dRR0{i}( (time{i}(1,j)+1) : (time{i}(2,j))  );
                testlength = length(Y);
                X = 1:(testlength);
                X = [ones(testlength,1),X'/50];
                [b2, bint2,r2,rint2,stats2] = regress(Y,X,0.05);
                %if stats2(3)>=deleteth
                if testlength >= mintime*frame
                    rampturn{i} = [rampturn{i},b2(2)];
                end
                %end
            end
        end
    end
end

%%
for i = 4:7
    rampnoturn{i} = rampnoturn{i}/2.5;
    rampturn{i} = rampturn{i}/2.5;
end
i = 0;
for j = trial
    if j==2|j==9|j==10|j==14
        noturn{i} = [noturn{i},rampnoturn{j}];
        turn{i} = [turn{i},rampturn{j}];
    else
        i = i + 1;
        noturn{i} = rampnoturn{j};
        turn{i} = rampturn{j};
    end
end

set(0,'DefaultFigureVisible', 'on');
figure
hold on
for i = 1:length(turn)
    if length(noturn{i}) >= 2 & length(turn{i}) >= 2
        errorbar([0+i/50,1+i/50],[mean(noturn{i}),mean(turn{i})],[std(noturn{i})/sqrt(length(noturn{i})),std(turn{i})/sqrt(length(turn{i}))]);
    end
end
%legend('w1','w2','w4','w5','w6','w7','w8','w9','w10');
title('AIB ramping rate compare');
ylabel('normalized dR/R per sec');
axis([-0.5 1.5 0 0.2]);

%% two-way ANOVA
y = [];
g1 = cell(0,0);
g2 = cell(0,0);
for i = 1:length(noturn)
    if length(noturn{i}) >= 2 & length(turn{i}) >= 2
        for j = 1:length(noturn{i})
            y = [y,noturn{i}(j)];
            g1{length(y)} = ['w',mat2str(i)];
            g2{length(y)} = ['noturn'];
        end
        for j = 1:length(turn{i})
            y = [y,turn{i}(j)];
            g1{length(y)} = ['w',mat2str(i)];
            g2{length(y)} = ['turn'];
        end
    end
end
[p,tbl,stats] = anovan(y,{g1,g2},'varnames',{'worm','turn'});

%% plot fitted curve 
%{
set(0,'DefaultFigureVisible', 'off');
for i = trial
    tt = 1:totaltime(i);
    if i<=11
        frame = 20;
    else
        frame = 50;
    end
    tt = tt/frame;
    figure
    subplot(2,1,1);
    plot(tt,ratio_nor{i},':b',tt,smo{i},'b');
    legend('raw','smoothed');
    title(['AIB activity of worm',num2str(i)]);
    hold on
    for j = 1:size(time{i},2)
        timetemp = time{i}(1:2,j)';
        backtimemax = max( backtimemax,( timetemp(2)-timetemp(1) ) );
        if isnan(time{i}(3,j)) == 0
            fill([timetemp/frame fliplr(timetemp/frame)],[ [0,0] [1 1] ],'y','facealpha',0.2,'edgealpha',1);
        else
            fill([timetemp/frame fliplr(timetemp/frame)],[ [0,0] [1 1] ],'r','facealpha',0.2,'edgealpha',1);
        end
    end
    hold on
    for j = 1:size(time{i},2)
        if isnan(time{i}(1,j)) == 0
            if isnan(time{i}(3,j)) == 1
                Y = smo{i}( (time{i}(1,j)+1) : (time{i}(2,j))  );
                %Y = dRR0{i}( (time{i}(1,j)+1) : (time{i}(2,j))  );
                testlength = length(Y);
                X = 1:length(Y);
                X = [ones(testlength,1),X'/frame];
                [b1, bint1,r1,rint1,stats1] = regress(Y,X,0.05);
                plot( ((time{i}(1,j)+1) : (time{i}(2,j)))/frame,X*b1,'r');
            else
                Y = smo{i}( (time{i}(1,j)+1) : (time{i}(2,j))  );
                %Y = dRR0{i}( (time{i}(1,j)+1) : (time{i}(2,j))  );
                testlength = length(Y);
                X = 1:length(Y);
                X = [ones(testlength,1),X'/frame];
                [b2, bint2,r2,rint2,stats2] = regress(Y,X,0.05);
                plot( ((time{i}(1,j)+1) : (time{i}(2,j)))/frame,X*b2,'r');
            end
        end
    end
    axis([0 totaltime(i)/frame 0 1]);
    
    subplot(2,1,2);
    hold on
    plot(tt,gcamp_ori{i},'g');
    plot(tt,gcamp_ref{i},'r');
    gcamp_ori_max = max([gcamp_ori{i}]);
	for j = 1:size(time{i},2)
        timetemp = time{i}(1:2,j)';
        back = [];
        if isnan(time{i}(3,j)) == 0
            fill([timetemp/frame fliplr(timetemp/frame)],[ [0,0] [gcamp_ori_max,gcamp_ori_max] ],'y','facealpha',0.2,'edgealpha',1);
        else
            fill([timetemp/frame fliplr(timetemp/frame)],[ [0,0] [gcamp_ori_max,gcamp_ori_max] ],'r','facealpha',0.2,'edgealpha',1);
        end
    end
    axis([0 totaltime(i)/frame 0 gcamp_ori_max]);
    legend('GFP','Ref');
    set(gcf,'unit','centimeters','position',[0 0 70 20]);
    saveas(gcf,[num2str(i),'.jpg']);

end
set(0,'DefaultFigureVisible', 'on');
%}
%% illustrating
i = 6;
j = 3;
tt = (time{i}(1,j)+1) : (time{i}(2,j)) ;
Y = smo{i}( (time{i}(1,j)+1) : (time{i}(2,j))  );
%Y = dRR0{i}( (time{i}(1,j)+1) : (time{i}(2,j))  );
testlength = length(Y);
X = 1:length(Y);
X = X/50;
figure
%subplot(2,1,1);
hold on
plot(X,ratio_nor{i}(tt)',':b',X,smo{i}(tt)','b');
X = [ones(testlength,1),X'];
[b1, bint1,r1,rint1,stats1] = regress(Y,X,0.05);
plot( (1:length(Y))/50,X*b1,'r');
legend('raw','smoothed','linear regression');
xlabel('t/s');
ylabel('normalized dR/R');
%{
subplot(2,1,2);
hold on
plot(X,gcamp_ref{i}(tt),'r');
plot(X,gcamp_ori{i}(tt),'g');
%}
