% This code plot both mean calcium signal and heat map for single trial
%% load data from data.xlsx and time.xlsx
clearvars
minnum = 3;         % if the number of availble data points is less than 3, 
                    % the code would not calculate the mean and SEM. 
plotlength = 3;     % time length for plotting signal (seconds)
backtimemax = 10000;% maximum frame, doesn't really matter
frame = 50;         % frames per second
smoothpara = 40;    % parameter for smoothing; larger -> more smooth
trial = 11;
gcamp_ref = cell(1,trial);
gcamp_ori = cell(1,trial);
ratio = cell(1,trial);
ratio_smo = cell(1,trial);
smo = cell(1,trial);
time = cell(1,trial);
for i = 1:trial
    temp = xlsread('dataRIV.xlsx',i);
    gcamp_ref{i} = temp(:,1);
    gcamp_ori{i} = temp(:,2);
    ratio{i} = temp(:,2)./temp(:,1);
    time{i} = xlsread('time.xlsx',i);
end

%% Smooth 
totaltime = length(gcamp_ref{1});
for i = 1:trial
    ratio_smo{i} = smooth(ratio{i},smoothpara);
	NotANum = isnan(ratio{i});
    NaNPos = find( NotANum ==1 );
    for j = 1:length( NaNPos )
        ratio_smo{i}( NaNPos(j) ) = NaN;
    end
    smo{i} = ratio_smo{i};
end

%% single trial normalization
n = 0;
for i = 1:trial
    for j = 1:size(time{i},2)
        if isnan(time{i}(1,j)) == 0
            if isnan(time{i}(3,j)) == 0
                if isnan( smo{i}(time{i}(2,j)) ) == 0
                    n = n+1;
                    tt = time{i}(1,j):time{i}(3,j);
                    temp = min(smo{i}(tt));
                    smo{i}(tt) = ( smo{i}(tt) - temp ) ./ temp;
                    ratio{i}(tt) = ( ratio{i}(tt) - temp ) ./ temp;
                end
            end
        end
    end
end
individual_trial = n;

%%  Get mean and SEM from 'smo'
% Key outputs of this section: 
% 'turn': a cell array in which each cell contains all the availble values
%           for calculating the average at a time point during turn
% 'back': a cell array in which each cell contains all the availble values
%           for calculating the average at a time point during reversal
turn = cell(1,backtimemax);
back = cell(1,backtimemax);
heatmap = NaN*zeros(individual_trial+1,2*backtimemax-1);
n = 0;
for i = 1:trial
    for j = 1:size(time{i},2)
        if isnan(time{i}(1,j)) == 0
            if isnan(time{i}(3,j)) == 0
                if isnan( smo{i}(time{i}(2,j)) ) == 0
                    n = n+1;
                    % after turn starts, during turn
                    for t = (time{i}(2,j)):(time{i}(3,j))
                        backtime = t-time{i}(2,j)+1;
                        if isnan(smo{i}(t)) == 0
                            %turn{backtime} = [turn{backtime},smo{i}(t)];
                            turn{backtime} = [turn{backtime},smo{i}(t)-smo{i}(time{i}(2,j))];
                            %heatmap(n,backtime+backtimemax) = smo{i}(t);
                            heatmap(n,backtime+backtimemax) = smo{i}(t)-smo{i}(time{i}(2,j));
                        end
                    end
                    
                    % before turn starts, during reversal
                    for t = (time{i}(2,j)):(-1):time{i}(1,j)
                        backtime = time{i}(2,j)-t+1;
                        if isnan(smo{i}(t)) == 0
                            %back{backtime} = [back{backtime},smo{i}(t)];
                            back{backtime} = [back{backtime},smo{i}(t)-smo{i}(time{i}(2,j))];
                            %heatmap(n,backtimemax+1-backtime) = smo{i}(t);
                            heatmap(n,backtimemax+1-backtime) = smo{i}(t)-smo{i}(time{i}(2,j));
                        end
                    end
                    
                end
            end
        end
    end
end
%% Plot mean GCaMP ratio
figure
hold on
% plot mean and SEM during turn
% 'smoback': mean of smoothed and normalized signal during turn
% 'smobackstd': STD of smoothed and normalized signal during turn
smoback = zeros(1,backtimemax);
smobackstd = zeros(1,backtimemax);
for t = 1:backtimemax
    smoback(t) = mean(turn{t});
    smobackstd(t) = std(turn{t})/sqrt(length(turn{t}));
    if length(turn{t}) >= minnum
        backtimevis = t;
    end
end
backtimevis = min(plotlength*frame,backtimevis);
smoback_up = smoback + smobackstd;
smoback_low = smoback - smobackstd;
plot([((1:backtimevis)-1)/frame],[smoback(1:backtimevis)],'b');
fill([((1:backtimevis)-1)/frame fliplr(((1:backtimevis)-1)/frame)],[smoback_low(1:backtimevis) fliplr(smoback_up(1:backtimevis))],'b','facealpha',0.2,'edgealpha',0,'handlevisibility','off');

% 'smoback': mean of smoothed and normalized signal during reversal
% 'smobackstd': STD of smoothed and normalized signal during reversal
smoback = zeros(1,backtimemax);
smobackstd = zeros(1,backtimemax);
for t = 1:backtimemax
    smoback(t) = mean(back{t});
    smobackstd(t) = std(back{t})/sqrt(length(back{t}));
    if length(back{t}) >= minnum
        backtimevis = t;
    end
end
backtimevis = min(plotlength*frame,backtimevis);
smoback_up = smoback + smobackstd;
smoback_low = smoback - smobackstd;
plot(fliplr(((1:backtimevis)-backtimevis)/frame),smoback(1:backtimevis),'b','handlevisibility','off');
fill([fliplr(((1:backtimevis)-backtimevis)/frame) ((1:backtimevis)-backtimevis)/frame],[smoback_low(1:backtimevis) fliplr(smoback_up(1:backtimevis))],'b','facealpha',0.2,'edgealpha',0,'handlevisibility','off');

title('RIV GCaMP before and after turn starts');
xlabel('t/s');
ylabel('dR/R0');

%% heat map
figure
gca = pcolor(heatmap(:,(backtimemax-plotlength*frame):(backtimemax+plotlength*frame)));
%caxis([-0.02 1]);
set(gca,'LineStyle','none');
colorbar;
title('RIV GCaMP before and after turn starts');
xlabel('t/s');
ylabel('trial');
%xticks([1 50 100 150 200 250 300 350 400]);
%xticklabels({'-4','-3','-2','-1','0','1','2','3','4'});
%colormap('jet');

%% Plot single trial with sub figures
figure
n = 0;
for i = 1:trial
    for j = 1:size(time{i},2)
        if isnan(time{i}(1,j)) == 0
            if isnan(time{i}(3,j)) == 0
                if isnan( smo{i}(time{i}(2,j)) ) == 0
                    n = n + 1;
                    subplot(7,7,n);
                    hold on
                    tt = (1:( time{i}(3,j) - time{i}(1,j) +1 ))/frame;
                    plot( tt ,smo{i}((time{i}(1,j)):time{i}(3,j)),'b');
                    plot( tt ,ratio{i}((time{i}(1,j)):time{i}(3,j)),':b');
                    plot( [(time{i}(3,j) - time{i}(1,j))/frame,(time{i}(3,j) - time{i}(1,j))/frame],[-10,10],'r','handlevisibility','off');
                    plot( [(time{i}(2,j) - time{i}(1,j))/frame,(time{i}(2,j) - time{i}(1,j))/frame],[-10,10],'r','handlevisibility','off');
                    axis([0 7 0 1]);
                end
            end
        end
    end
end