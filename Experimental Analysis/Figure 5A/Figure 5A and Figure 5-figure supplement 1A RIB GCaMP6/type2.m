clearvars
minnum = 3;
frame = 100;
backtimemax = 10000;
smoothpara = 40;
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
%% 
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
                tt = time{i}(1,j):(time{i}(2,j)+3*frame);
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

%%
%{
for i = 1:trial
    mintemp = min(ratio_smo{i});
    maxtemp = max(ratio_smo{i});
    smo{i} = ( ratio_smo{i} - mintemp ) ./ mintemp ;
end
%}

%%

turn = cell(1,backtimemax);
back = cell(1,backtimemax);
for i = 1:trial
    for j = 1:size(time{i},2)
        if isnan(time{i}(1,j)) == 0
            if isnan(time{i}(3,j)) == 0
                if isnan( smo{i}(time{i}(2,j)) ) == 0
                    % turn开始之后，turn中
                    %plot(1:( time{i}(3,j) - time{i}(2,j) ),smo{i}((time{i}(2,j)+1):time{i}(3,j))-smo{i}(time{i}(2,j)));
                    %hold on
                    for t = (time{i}(2,j)+1):time{i}(3,j)
                        backtime = t-time{i}(2,j);
                        if isnan(smo{i}(t)) == 0
                            turn{backtime} = [turn{backtime},smo{i}(t)-smo{i}(time{i}(2,j))];
                            %turn{backtime} = [turn{backtime},smo{i}(t)];
                        end
                    end
                    % turn开始之前，后退中
                    
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
smoback_up = smoback + smobackstd;
smoback_low = smoback - smobackstd;
plot([0,(1:backtimevis)/frame],[0,smoback(1:backtimevis)],'b');
fill([((1:backtimevis)-1)/frame fliplr(((1:backtimevis)-1)/frame)],[smoback_low(1:backtimevis) fliplr(smoback_up(1:backtimevis))],'b','facealpha',0.2,'edgealpha',0);

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

axis([-3 3 -0.1 1]);
title('RIB GCaMP before and after type-2 transition ( t=0 aligned to turn starts)');
xlabel('t/s');
ylabel('dR/R');