%% load data from data.xlsx and time.xlsx
clearvars
backtimemax = 2000; % maximum frame, doesn't really matter
smoothpara = 100;   % parameter for smoothing; larger -> more smooth
trial = 1:6;
trialnum = length(trial);
gcamp_ref = cell(1,trialnum);
gcamp_ori = cell(1,trialnum);
ratio = cell(1,trialnum);
ratio_smo = cell(1,trialnum);
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
    ratio_smo{i} = smooth(ratio{i},smoothpara);
    %ratio_smo{i} = ratio{i};
	NotANum = isnan(ratio{i});
    NaNPos = find( NotANum ==1 );
    for j = 1:length( NaNPos )
        ratio_smo{i}( NaNPos(j) ) = NaN;
    end
end
%% single trial normalization
% Key output of the section:
% 'smo': smoothed and normalized GCaMP ratio 
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
%% Plot single trial with sub figures
figure
hold on
for i = 1:43
    subplot(9,5,i);
    hold on
    tt = (1:length(smo{i}))/length(smo{i})*12;
    plot(tt,raw{i},':c',tt,smo{i},'b');
    xlim([0 12])
end
