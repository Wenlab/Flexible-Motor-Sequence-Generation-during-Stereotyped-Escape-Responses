% Please go to 'Figure 3E-F\turnstart.m' for
% annotation. The two code are exactly the same.
clearvars
minnum = 3;
plotlength = 3;
backtimemax = 10000;
frame = 50;
smoothpara = 40;
trial = 11;
gcamp_ref = cell(1,trial);
gcamp_ori = cell(1,trial);
ratio = cell(1,trial);
ratio_smo = cell(1,trial);
smo = cell(1,trial);
time = cell(1,trial);
for i = 1:trial
    temp = xlsread('data.xlsx',i);
    gcamp_ref{i} = temp(:,1);
    gcamp_ori{i} = temp(:,2);
    ratio{i} = temp(:,2)./temp(:,1);
    time{i} = xlsread('time.xlsx',i);
end

%%
totaltime = length(gcamp_ref{1});
for i = 1:trial
    ratio_smo{i} = smooth(ratio{i},smoothpara);
	NotANum = isnan(ratio{i});
    NaNPos = find( NotANum ==1 );
    for j = 1:length( NaNPos )
        ratio_smo{i}( NaNPos(j) ) = NaN;
    end
    %mintemp = min(ratio_smo{i});
    %maxtemp = max(ratio_smo{i});
    %smo{i} = ( ratio_smo{i} - mintemp ) ./ mintemp ;
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

%%
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
                    % turn开始之后，turn中
                    %plot(1:( time{i}(3,j) - time{i}(2,j) ),smo{i}((time{i}(2,j)+1):time{i}(3,j))-smo{i}(time{i}(2,j)));
                    %hold on
                    for t = (time{i}(2,j)):(time{i}(3,j))
                        backtime = t-time{i}(2,j)+1;
                        if isnan(smo{i}(t)) == 0
                            %turn{backtime} = [turn{backtime},smo{i}(t)];
                            turn{backtime} = [turn{backtime},smo{i}(t)-smo{i}(time{i}(2,j))];
                            %heatmap(n,backtime+backtimemax) = smo{i}(t);
                            heatmap(n,backtime+backtimemax) = smo{i}(t)-smo{i}(time{i}(2,j));
                        end
                    end
                    % turn开始之前，reversal中
                    
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

figure
hold on

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

%% single trial
figure
n = 0;
for i = 1:trial
    for j = 1:size(time{i},2)
        if isnan(time{i}(1,j)) == 0
            if isnan(time{i}(3,j)) == 0
                if isnan( smo{i}(time{i}(2,j)) ) == 0
                    n = n + 1;
                    subplot(7,6,n);
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