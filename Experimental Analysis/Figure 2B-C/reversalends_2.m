%%% This code plot both single trial GCaMP and mean GCaMP

clearvars
%% load data from data.xlsx and time.xlsx
frame = 50;         % frames per second
smoothpara = 40;    % parameter for smoothing; larger -> more smooth
minnum = 3;         % if the number of availble data points is less than 3, 
                    % the code would not calculate the mean and SEM. 
backtimemax = 10000;% maximum frame, doesn't really matter
trial = 8;
gcamp_ref = cell(1,trial);
gcamp_ori = cell(1,trial);
ratio = cell(1,trial);
ratio_smo = cell(1,trial);
smo = cell(1,trial);
time = cell(1,trial);
time_full = cell(1,trial);
% get raw ratio
for i = 1:trial
    temp = xlsread('data.xlsx',i);
    gcamp_ref{i} = temp(:,2);
    gcamp_ori{i} = temp(:,1);
    ratio{i} = temp(:,1)./temp(:,2);
    time_full{i} = xlsread('time_2.xlsx',i);
    time{i} = time_full{i}(2:4,:);
end
% smooth data
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
% Key output of the section:
% 'smo': smoothed and normalized GCaMP ratio 
% 'ratio: normalized GCaMP ratio 
tt_rcd = cell(1,trial);
tt_rcd{1} = [[3245;5173],[8466;9936]];
tt_rcd{2} = [9535;10659];
tt_rcd{3} = [[1402;3056],[5891;7003],[10088;10724],[10989;12052]];
n = 0;
for i = 1:trial
    flag = 0;
    for j = 1:size(time{i},2)
        n = n+1;
        if i <= 3
            if all( tt_rcd{i}(1,:) - time_full{i}(1,j) )
                if flag == 1
                    flag = 0;
                else
                    tt = time_full{i}(1,j):time_full{i}(5,j);
                    temp = min(smo{i}(tt));
                    smo{i}(tt) = ( smo{i}(tt) - temp ) ./ temp;
                    ratio{i}(tt) = ( ratio{i}(tt) - temp ) ./ temp;
                end
            else
                flag = 1;
            end
        else
            tt = time_full{i}(1,j):time_full{i}(5,j);
            temp = min(smo{i}(tt));
            smo{i}(tt) = ( smo{i}(tt) - temp ) ./ temp;
            ratio{i}(tt) = ( ratio{i}(tt) - temp ) ./ temp;
        end
    end
end

for i = 1:3
    for j = 1:size(tt_rcd{i},2)
        tt = tt_rcd{i}(1,j):tt_rcd{i}(2,j);
        temp = min(smo{i}(tt));
        smo{i}(tt) = ( smo{i}(tt) - temp ) ./ temp;
        ratio{i}(tt) = ( ratio{i}(tt) - temp ) ./ temp;
    end
end

individual_trial = n;
%% This section generate 'heatmap' from 'smo'
% Key output of the section:
% 'turn': a cell array in which each cell contains all the availble values
%           for calculating the average at a time point during turn
% 'back': a cell array in which each cell contains all the availble values
%           for calculating the average at a time point during reversal
% Let turn starts as t=0, back{1} contains all the values at t = -20ms
%                           turn{1} contains all the values at t = 20ms
%                           (say it's 50fps)
turn = cell(1,backtimemax);
back = cell(1,backtimemax);
heatmap = NaN*zeros(individual_trial+1,2*backtimemax-1);
noturnN = 0;
turnN = 23;
for i = 1:trial
    for j = 1:size(time{i},2)
        %if isnan(time{i}(3,j)) ~= 0
            
            if isnan(time_full{i}(4,j)) == 1
                noturnN = noturnN+1;
                n = noturnN;
            else
                turnN = turnN+1;
                n = turnN;
            end
            % after turn starts, during turn
            for t = (time{i}(2,j)):(time_full{i}(5,j))
                backtime = t-time{i}(2,j)+1;
                if isnan(smo{i}(t)) == 0
                    turn{backtime} = [turn{backtime},smo{i}(t)];
                    %turn{backtime} = [turn{backtime},smo{i}(t)-smo{i}(time{i}(2,j))];
                    heatmap(n,backtime+backtimemax) = smo{i}(t);
                    %heatmap(n,backtime+backtimemax) = smo{i}(t)-smo{i}(time{i}(2,j));
                end
            end
            % before turn starts, during reversal
            for t = (time{i}(2,j)):(-1):time{i}(1,j)
                backtime = time{i}(2,j)-t+1;
                if isnan(smo{i}(t)) == 0
                    back{backtime} = [back{backtime},smo{i}(t)];
                    %back{backtime} = [back{backtime},smo{i}(t)-smo{i}(time{i}(2,j))];
                    heatmap(n,backtimemax+1-backtime) = smo{i}(t);
                    %heatmap(n,backtimemax+1-backtime) = smo{i}(t)-smo{i}(time{i}(2,j));
                end
            end

        %end
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
backtimevis = min(4*frame,backtimevis);
smoback_up = smoback + smobackstd;
smoback_low = smoback - smobackstd;
plot([((1:backtimevis)-1)/frame],[smoback(1:backtimevis)],'r');
fill([((1:backtimevis)-1)/frame fliplr(((1:backtimevis)-1)/frame)],[smoback_low(1:backtimevis) fliplr(smoback_up(1:backtimevis))],'r','facealpha',0.2,'edgealpha',0,'handlevisibility','off');

% plot mean and SEM during reversal
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
backtimevis = min(4*frame,backtimevis);
smoback_up = smoback + smobackstd;
smoback_low = smoback - smobackstd;
plot(fliplr(((1:backtimevis)-backtimevis)/frame),smoback(1:backtimevis),'r','handlevisibility','off');
fill([fliplr(((1:backtimevis)-backtimevis)/frame) ((1:backtimevis)-backtimevis)/frame],[smoback_low(1:backtimevis) fliplr(smoback_up(1:backtimevis))],'r','facealpha',0.2,'edgealpha',0,'handlevisibility','off');

title('AIB GCaMP before and after reversal ends');
xlabel('t/s');
ylabel('dR/R0');

%% Plot heat map
figure
hold on
gca = pcolor(heatmap(:,(backtimemax-3*frame):(backtimemax+3*frame)));
%caxis([-0.02 1]);
set(gca,'LineStyle','none');
colorbar;
title('AIB GCaMP before and after reversal ends');
xlabel('t/s');
ylabel('trial');
plot([150,150],[1,60],'--w');
plot([1,300],[24,24],'r');
axis([0 300 1 60]);
%xticks([1 50 100 150 200 250 300 350 400]);
%xticklabels({'-4','-3','-2','-1','0','1','2','3','4'});
%colormap('jet');

%% Plot single trial with sub figures
figure

noturnN = 0;
turnN = 24;
for i = 1:trial
    for j = 1:size(time{i},2)
        if isnan(time_full{i}(4,j)) == 0
            turnN = turnN+1;
            n = turnN;
            subplot(8,8,n);
            hold on
            forward_time = time_full{i}(2,j) - time_full{i}(1,j);
            turnafter_time = time_full{i}(5,j) - time_full{i}(4,j);
            tt = ( -forward_time:( time{i}(3,j) - time{i}(1,j) +turnafter_time  ))/frame;
            plot( tt ,smo{i}((time{i}(1,j)-forward_time):(time{i}(3,j)+turnafter_time)),'b');
            plot( tt ,ratio{i}((time{i}(1,j)-forward_time):(time{i}(3,j)+turnafter_time)),'b:');
            plot( [0,0],[-10,10],'r');
            plot( [(time{i}(3,j) - time{i}(1,j))/frame,(time{i}(3,j) - time{i}(1,j))/frame],[-10,10],'k');
            plot( [(time{i}(2,j) - time{i}(1,j))/frame,(time{i}(2,j) - time{i}(1,j))/frame],[-10,10],'m');
            axis([-2 10 0 0.8]);
        else
            noturnN = noturnN+1;
            n = noturnN;
            subplot(8,8,n);
            hold on
            tt = ( (time_full{i}(1,j) - time_full{i}(2,j)):( time_full{i}(5,j) - time_full{i}(2,j)  ))/frame;
            plot( tt ,smo{i}((time_full{i}(1,j)):(time_full{i}(5,j))),'b');
            plot( tt ,ratio{i}((time_full{i}(1,j)):(time_full{i}(5,j))),'b:');
            plot( [0,0],[-10,10],'r');
            plot( [(time{i}(2,j) - time{i}(1,j))/frame,(time{i}(2,j) - time{i}(1,j))/frame],[-10,10],'g');
            axis([-2 10 0 0.8]);
        end
    end
end