%% load data from data.xlsx and time.xlsx
backtimemax = 2000; % maximum frame, doesn't really matter
smoothpara = 40;    % parameter for smoothing; larger -> more smooth
trial = 1:6;
trialnum = length(trial);
gcamp_ref = cell(1,trialnum);
gcamp_ori = cell(1,trialnum);
ratio = cell(1,trialnum);
smo = cell(1,trialnum);
smo = cell(1,trialnum);
time = cell(1,trialnum);
% get raw ratio
for i = trial
    temp = xlsread('data.xlsx',i);
    gcamp_ref{i} = temp(:,1);
    gcamp_ori{i} = temp(:,2);
    ratio{i} = temp(:,2)./temp(:,1);
    time{i} = xlsread('time.xlsx',i);
    time{i} = [time{i};NaN*zeros(1,size(time{i},2))];
end
% smooth data
for i = trial
    smo{i} = smooth(ratio{i},smoothpara);
    %ratio_smo{i} = ratio{i};
	NotANum = isnan(ratio{i});
    NaNPos = find( NotANum ==1 );
    for j = 1:length( NaNPos )
        smo{i}( NaNPos(j) ) = NaN;
    end
end
%% single trial normalization
% Key output of the section:
% 'smo': smoothed and normalized GCaMP ratio 
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

%% Get mean and SEM from 'smo'
% 'back': a cell array in which each cell contains all the availble values
%           for calculating the average at a time point during reversal
% 'smoback': mean of smoothed and normalized signal
% 'smobackstd': STD of smoothed and normalized signal
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
%% Plot mean
frame2 = 50;
figure
hold on
plot(((1:backtimevis2)-1)/frame2,smoback2(1:backtimevis2),'r');
fill([((1:backtimevis2)-1)/frame2 fliplr(((1:backtimevis2)-1)/frame2)],[smoback_low2(1:backtimevis2) fliplr(smoback_up2(1:backtimevis2))],'r','facealpha',0.2,'edgealpha',0);
title('AIB GCaMP & RIB glutamate sensor signal (AIB activated)');
legend('Control');
xlabel('t/s');
ylabel('dR/R0');
%axis([0 6.5 -0.1 0.5]);

%% Plot single trial with sub figures
figure
n = 0;
for i = trial
    for j = 1:size(time{i},2)
        if isnan(time{i}(1,j)) == 0
                if isnan( smo{i}(time{i}(2,j)) ) == 0
                    n = n+1;
                    tt = time{i}(1,j):time{i}(2,j);
                    subplot(10,5,n);
                    hold on
                    plot((1:length(tt))/frame2,smo{i}(tt),'b');
                    plot((1:length(tt))/frame2,ratio{i}(tt),'b:');
                    axis([1 7 0 0.3]);
                end
        end
    end
end