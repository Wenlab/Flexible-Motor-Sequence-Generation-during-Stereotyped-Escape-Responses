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

%% transfer time matrix
% before transfer: [ reversal starts ; turn starts ; turn ends ] 
% after transfer: [ sometime during forward (not necessarily the start) ; reversal starts ; turn ends ] 
for i = 1:trial
    temp = time{i};
    temp(2,:) = time{i}(1,:);
    temp(3,:) = time{i}(3,:);   % time{i}(3,:) includes turn behavior. time{i}(2,:) only contains reversal
    temp(1,1) = max([1,time{i}(1,1) - plotlength*frame]);
    for j = 2:size(time{i},2)
        temp(1,j) = max([time{i}(3,j-1)+1,time{i}(1,j) - plotlength*frame]);
    end
    time{i} = temp;
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
                    smo{i}(tt) = ( smo{i}(tt) - min(smo{i}(tt)) ) ./ min(smo{i}(tt)); 
                end
            end
        end
    end
end
individual_trial = n;

%%  Get mean and SEM from 'smo'
% Key outputs of this section: 
% Please note that all the variable names do not represent what they
% actually means, which may cause confusion. I am sorry. 
% 'turn': a cell array in which each cell contains all the availble values
%           for calculating the average at a time point during *reversal*,
%           instead of turn
% 'back': a cell array in which each cell contains all the availble values
%           for calculating the average at a time point during *forward*,
%           instead of backward. 
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
                    % after reversal starts, during reversal
                    for t = (time{i}(2,j)):(time{i}(3,j))
                        backtime = t-time{i}(2,j)+1;
                        if isnan(smo{i}(t)) == 0
                            turn{backtime} = [turn{backtime},smo{i}(t)];
                            %turn{backtime} = [turn{backtime},smo{i}(t)-smo{i}(time{i}(2,j))];
                            heatmap(n,backtime+backtimemax) = smo{i}(t);
                            %heatmap(n,backtime+backtimemax) = smo{i}(t)-smo{i}(time{i}(2,j));
                        end
                    end
                    
                    % before reversal starts, during forward
                    for t = (time{i}(2,j)):(-1):time{i}(1,j)
                        backtime = time{i}(2,j)-t+1;
                        if isnan(smo{i}(t)) == 0
                            back{backtime} = [back{backtime},smo{i}(t)];
                            %back{backtime} = [back{backtime},smo{i}(t)-smo{i}(time{i}(2,j))];
                            heatmap(n,backtimemax+1-backtime) = smo{i}(t);
                            %heatmap(n,backtime+backtimemax) = smo{i}(t)-smo{i}(time{i}(2,j));
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
% 'smoback': mean of smoothed and normalized signal during reversal or turn
% 'smobackstd': STD of smoothed and normalized signal during reversal or
% turn
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

% plot mean and SEM during reversal
% 'smoback': mean of smoothed and normalized signal during forward
% 'smobackstd': STD of smoothed and normalized signal during forward
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

title('RIV GCaMP after reversal starts');
xlabel('t/s');
ylabel('dR/R0');

%% heat map
figure
gca = pcolor(heatmap(:,(backtimemax-3*frame):(backtimemax+3*frame)));
%caxis([-0.02 1]);
set(gca,'LineStyle','none');
colorbar;
title('RIV GCaMP after reversal starts');
xlabel('t/s');
ylabel('trial');
%xticks([1 50 100 150 200 250 300 350 400]);
%xticklabels({'-4','-3','-2','-1','0','1','2','3','4'});
%colormap('jet');
