% Please go to 'Figure 3E-F\turnstart.m' for
% annotation. The two code are exactly the same.
clearvars
minnum = 3;
backtimemax = 10000;

smoothpara = 40;
trial = 10;
individual_trial = 20;
gcamp_ref = cell(1,trial);
gcamp_ori = cell(1,trial);
ratio = cell(1,trial);
ratio_smo = cell(1,trial);
smo = cell(1,trial);
time = cell(1,trial);
for i = 1:trial
    temp = xlsread('data.xlsx',i);
    gcamp_ref{i} = temp(:,2);
    gcamp_ori{i} = temp(:,1);
    ratio{i} = temp(:,1)./temp(:,2);
    time{i} = xlsread('time_turn_starts.xlsx',i);
end
totaltime = length(gcamp_ref{1});
for i = 1:trial
    ratio_smo{i} = smooth(ratio{i},smoothpara);
	NotANum = isnan(ratio{i});
    NaNPos = find( NotANum ==1 );
    for j = 1:length( NaNPos )
        ratio_smo{i}( NaNPos(j) ) = NaN;
    end
    mintemp = min(ratio_smo{i});
    maxtemp = max(ratio_smo{i});
    smo{i} = ( ratio_smo{i} - mintemp ) ./ mintemp ;
end

turn = cell(1,backtimemax);
back = cell(1,backtimemax);
heatmap = NaN*zeros(individual_trial,2*backtimemax-1);
n = 0;
for i = 1:trial
    for j = 1:size(time{i},2)
        if isnan(time{i}(1,j)) == 0
            if isnan(time{i}(3,j)) == 0
                if isnan( smo{i}(time{i}(2,j)) ) == 0
                    n = n+1;

                    for t = (time{i}(2,j)+1):time{i}(3,j)
                        backtime = t-time{i}(2,j);
                        if isnan(smo{i}(t)) == 0
                            turn{backtime} = [turn{backtime},smo{i}(t)-smo{i}(time{i}(2,j))];
                            heatmap(n,backtime+backtimemax) = smo{i}(t)-smo{i}(time{i}(2,j));
                            %turn{backtime} = [turn{backtime},smo{i}(t)];
                        end
                    end

                    for t = (time{i}(2,j)-1):(-1):time{i}(1,j)
                        backtime = time{i}(2,j)-t;
                        if isnan(smo{i}(t)) == 0
                            back{backtime} = [back{backtime},smo{i}(t)-smo{i}(time{i}(2,j))];
                            heatmap(n,backtimemax+1-backtime) = smo{i}(t)-smo{i}(time{i}(2,j));
                            %back{backtime} = [back{backtime},smo{i}(t)];
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
backtimevis = min(200,backtimevis);
smoback_up = smoback + smobackstd;
smoback_low = smoback - smobackstd;
plot([0,(1:backtimevis)/50],[0,smoback(1:backtimevis)],'b');
fill([((1:backtimevis)-1)/50 fliplr(((1:backtimevis)-1)/50)],[smoback_low(1:backtimevis) fliplr(smoback_up(1:backtimevis))],'b','facealpha',0.2,'edgealpha',0);

smoback = zeros(1,backtimemax);
smobackstd = zeros(1,backtimemax);
for t = 1:backtimemax
    smoback(t) = mean(back{t});
    smobackstd(t) = std(back{t})/sqrt(length(back{t}));
    if length(back{t}) >= minnum
        backtimevis = t;
    end
end
backtimevis = min(200,backtimevis);
smoback_up = smoback + smobackstd;
smoback_low = smoback - smobackstd;
plot(fliplr(((1:backtimevis)-backtimevis-1)/50),smoback(1:backtimevis),'b');
fill([fliplr(((1:backtimevis)-backtimevis-1)/50) ((1:backtimevis)-backtimevis)/50],[smoback_low(1:backtimevis) fliplr(smoback_up(1:backtimevis))],'b','facealpha',0.2,'edgealpha',0);

title('RIV GCaMP before and after turn starts');
xlabel('t/s');
ylabel('Normalized dR/R');

%% heat map
figure
gca = pcolor(heatmap(:,(backtimemax-4*50):(backtimemax+4*50)));
%caxis([-0.02 1]);
set(gca,'LineStyle','none');
colorbar;
title('RIV GCaMP before and after turn starts');
xlabel('t/s');
ylabel('trial');
%set(gca,'xtick',[1 50 100 150 200 250 300 350 400])
%set(gca,'xticklabel',{'-4','-3','-2','-1','0','1','2','3','4'})
xticks([1 50 100 150 200 250 300 350 400]);
xticklabels({'-4','-3','-2','-1','0','1','2','3','4'});
colormap('jet');

%{
heatmap_shuffle = heatmap(randperm(size(heatmap,1)),:);
figure
gca = pcolor(heatmap_shuffle(:,(backtimemax-4*50):(backtimemax+4*50)));
caxis([-0.2 0.4]);
set(gca,'LineStyle','none');
colorbar;
title('RIV GCaMP before and after turn starts');
xlabel('t/s');
ylabel('trial');
%set(gca,'xtick',[1 50 100 150 200 250 300 350 400])
%set(gca,'xticklabel',{'-4','-3','-2','-1','0','1','2','3','4'})
xticks([1 50 100 150 200 250 300 350 400]);
xticklabels({'-4','-3','-2','-1','0','1','2','3','4'});
colormap('jet');
%}