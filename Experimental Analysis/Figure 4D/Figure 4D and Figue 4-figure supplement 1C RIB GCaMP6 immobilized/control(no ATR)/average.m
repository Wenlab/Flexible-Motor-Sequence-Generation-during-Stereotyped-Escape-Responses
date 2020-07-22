clearvars
backtimemax = 2000;
smoothpara = 40;
trial = 1:7;    % 7 for control, 9 for eat-4
trialnum = length(trial);
gcamp_ref = cell(1,trialnum);
gcamp_ori = cell(1,trialnum);
ratio = cell(1,trialnum);
smo = cell(1,trialnum);
smo = cell(1,trialnum);
time = cell(1,trialnum);
for i = trial
    temp = xlsread('data.xlsx',i);
    gcamp_ref{i} = temp(:,1);
    gcamp_ori{i} = temp(:,2);
    ratio{i} = temp(:,2)./temp(:,1);
    time{i} = xlsread('time.xlsx',i);
    time{i} = [time{i};NaN*zeros(1,size(time{i},2))];
end

for i = trial
    smo{i} = smooth(ratio{i},smoothpara);
    %ratio_smo{i} = ratio{i};
	NotANum = isnan(ratio{i});
    NaNPos = find( NotANum ==1 );
    for j = 1:length( NaNPos )
        smo{i}( NaNPos(j) ) = NaN;
    end
end

n = 0;
for i = trial
    for j = 1:size(time{i},2)
        if isnan(time{i}(1,j)) == 0
                if isnan( smo{i}(time{i}(1,j)) ) == 0
                    n = n+1;
                    tt = time{i}(1,j):time{i}(2,j);
                    ratio{i}(tt) = ( ratio{i}(tt) - min(smo{i}(tt)) ) ./ min(smo{i}(tt));
                    smo{i}(tt) = ( smo{i}(tt) - min(smo{i}(tt)) ) ./ min(smo{i}(tt));
                end
        end
    end
end
back = cell(1,backtimemax);

for i = trial
    for j = 1:size(time{i},2)
        if isnan(time{i}(1,j)) == 0
            if isnan( smo{i}(time{i}(1,j)) ) == 0
                for t = (time{i}(1,j)+1):time{i}(2,j)
                    backtime = t-time{i}(1,j);
                    if isnan(smo{i}(t)) == 0
                        %back{backtime} = [back{backtime},smo{i}(t)/smo{i}(time{i}(1,j))];
                        %back{backtime} = [back{backtime},smo{i}(t)-smo{i}(time{i}(1,j))];
                        back{backtime} = [back{backtime},smo{i}(t)];
                    end
                end
            end
        end
    end
end
smoback2 = zeros(1,backtimemax);
smobackstd2 = zeros(1,backtimemax);
for t = 1:backtimemax
    smoback2(t) = mean(back{t});
    smobackstd2(t) = std(back{t})/sqrt(length(back{t}));
    %smoback_up(t) = prctile(back{t},100-68.3);
    %smoback_low(t) = prctile(back{t},68.3);
	if length(back{t}) >= 5
        backtimevis2 = t;
    end
end
smoback_up2 = smoback2 + smobackstd2;
smoback_low2 = smoback2 - smobackstd2;




frame2 = 50;
figure
hold on
backtimevis2 = 480;
plot(((1:backtimevis2)-1)/frame2,smoback2(1:backtimevis2),'r');
fill([((1:backtimevis2)-1)/frame2 fliplr(((1:backtimevis2)-1)/frame2)],[smoback_low2(1:backtimevis2) fliplr(smoback_up2(1:backtimevis2))],'r','facealpha',0.2,'edgealpha',0);
title('RIB GCamp (AIB activated)');
legend('Control (N=52)');
xlabel('t/s');
ylabel('dR/R0');
axis([0 10 0 1]);

%% single trial
figure
n = 0;
for i = trial
    for j = 1:size(time{i},2)
        if isnan(time{i}(1,j)) == 0
                if isnan( smo{i}(time{i}(1,j)) ) == 0
                    n = n+1;
                    tt = time{i}(1,j):time{i}(2,j);
                    subplot(14,4,n);
                    hold on
                    plot((1:length(tt))/frame2,smo{i}(tt),'b');
                    plot((1:length(tt))/frame2,ratio{i}(tt),'b:');
                    axis([1 10 0 1]);
                end
        end
    end
end
