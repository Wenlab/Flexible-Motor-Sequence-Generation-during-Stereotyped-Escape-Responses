% This code plot mean calcium signal before and after type-1 transition
%% load data from data.xlsx and time.xlsx
clearvars
minnum = 3;         % if the number of availble data points is less than 3, 
                    % the code would not calculate the mean and SEM. 
frame = 100;        % frames per second
backtimemax = 10000;% maximum frame, doesn't really matter
smoothpara = 40;    % parameter for smoothing; larger -> more smooth
trial = 9;
gcamp_ref = cell(1,trial);
gcamp_ori = cell(1,trial);
ratio = cell(1,trial);
ratio_smo = cell(1,trial);
smo = cell(1,trial);
time = cell(1,trial);
for i = 1:trial
    temp = xlsread('datacb.xlsx',i);
    gcamp_ref{i} = temp(:,1);
    gcamp_ori{i} = temp(:,2);
    ratio{i} = temp(:,2)./temp(:,1);
    time{i} = xlsread('timecb.xlsx',i);
    ratio_smo{i} = smooth(ratio{i},smoothpara);
	NotANum = isnan(ratio{i});
    NaNPos = find( NotANum ==1 );
    for j = 1:length( NaNPos )
        ratio_smo{i}( NaNPos(j) ) = NaN;
    end
    smo{i} = ratio_smo{i};
end
totaltime = length(gcamp_ref{1});

%% Smooth and normalization
n = 0;
n_1 = 0;
n_2 = 0;
for i = 1:trial
    for j = 1:size(time{i},2)
        n = n+1;
        if isnan(time{i}(3,j))
            if j ~= size(time{i},2)
                tt = time{i}(1,j):(time{i}(1,j+1)-1);
            else
                tt = time{i}(1,j):(time{i}(2,j)+4*frame);
            end
            n_1 = n_1 + 1;
        else
            tt = time{i}(1,j):time{i}(3,j);
            n_2 = n_2 + 1;
        end
        temp = min(smo{i}(tt));
        smo{i}(tt) = ( smo{i}(tt) - temp ) ./ temp;
        ratio{i}(tt) = ( ratio{i}(tt) - temp ) ./ temp;
    end
end

individual_trial = n;

%%  Get mean and SEM from 'smo'
% Key outputs of this section: 
% 'forward': a cell array in which each cell contains all the availble values
%           for calculating the average at a time point during forward
%           after reversal (cause it's type-1) 
% 'back': a cell array in which each cell contains all the availble values
%           for calculating the average at a time point during reversal
forward = cell(1,backtimemax);
back = cell(1,backtimemax);
for i = 1:trial
    for j = 1:size(time{i},2)
        if isnan(time{i}(1,j)) == 0
            if isnan(time{i}(3,j)) == 1
                if isnan( smo{i}(time{i}(2,j)) ) == 0
                    % after reversal ends, during forward
                    if j == size(time{i},2)
                        endtime = length(ratio{i});
                    else
                        if isnan(time{i}(1,j+1)) == 0
                            endtime = time{i}(1,j+1);
                        else
                            endtime = time{i}(2,j+1);
                        end
                    end
                    endtime = min(endtime,time{i}(2,j)+4*frame);
                    for t = (time{i}(2,j)+1):endtime
                        backtime = t-time{i}(2,j);
                        if isnan(smo{i}(t)) == 0
                            forward{backtime} = [forward{backtime},smo{i}(t)-smo{i}(time{i}(2,j))];
                            %turn{backtime} = [turn{backtime},smo{i}(t)];
                        end
                    end
                    
                    % before reversal ends, during reversal
                    for t = (time{i}(2,j)-1):(-1):time{i}(1,j)
                        backtime = time{i}(2,j)-t;
                        if isnan(smo{i}(t)) == 0
                            back{backtime} = [back{backtime},smo{i}(t)-smo{i}(time{i}(2,j))];
                            %back{backtime} = [back{backtime},smo{i}(t)];
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
% 'smoback': mean of smoothed and normalized signal during forward
% 'smobackstd': STD of smoothed and normalized signal during forward
smoback = zeros(1,backtimemax);
smobackstd = zeros(1,backtimemax);
for t = 1:backtimemax
    smoback(t) = mean(forward{t});
    smobackstd(t) = std(forward{t})/sqrt(length(forward{t}));
    if length(forward{t}) >= minnum
        backtimevis = t;
    end
end
smoback_up = smoback + smobackstd;
smoback_low = smoback - smobackstd;
plot([0,(1:backtimevis)/frame],[0,smoback(1:backtimevis)],'b');
fill([((1:backtimevis))/frame fliplr(((1:backtimevis)-1)/frame)],[smoback_low(1:backtimevis) fliplr(smoback_up(1:backtimevis))],'b','facealpha',0.2,'edgealpha',0);

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
smoback_up = smoback + smobackstd;
smoback_low = smoback - smobackstd;
plot(fliplr(((1:backtimevis)-backtimevis-1)/frame),smoback(1:backtimevis),'b');
fill([fliplr(((1:backtimevis)-backtimevis-1)/frame) ((1:backtimevis)-backtimevis)/frame],[smoback_low(1:backtimevis) fliplr(smoback_up(1:backtimevis))],'b','facealpha',0.2,'edgealpha',0);

title('RIB GCaMP before and after type-1 transition ( t=0 aligned to forward starts)');
xlabel('t/s');
ylabel('dR/R');