clearvars
backtimemax = 500;
smoothpara = 40;
trial = 1:45;
trialnum = length(trial);
gcamp_ref = cell(1,trialnum);
gcamp_ori = cell(1,trialnum);
ratio = cell(1,trialnum);
ratio_smo = cell(1,trialnum);
smo = cell(1,trialnum);
time = cell(1,trialnum);
gcamp_ori_temp = xlsread('mutant.xlsx',1);
gcamp_ref_temp = xlsread('mutant.xlsx',2);
for i = trial
    gcamp_ref{i} = gcamp_ref_temp(:,i)';
    gcamp_ori{i} = gcamp_ori_temp(:,i)';
    ratio{i} = gcamp_ori{i}./gcamp_ref{i};
    %ratio{i} = gcamp_ori{i};
    time{i} = [1;349;NaN];
end
for i = trial
    ratio_smo{i} = smooth(ratio{i},smoothpara);
	NotANum = isnan(ratio{i});
    NaNPos = find( NotANum ==1 );
    for j = 1:length( NaNPos )
        ratio_smo{i}( NaNPos(j) ) = NaN;
    end
    mintemp = min(ratio_smo{i});
    maxtemp = max(ratio_smo{i});
    %smo{i} = ( ratio_smo{i} - mintemp ) ./ ( maxtemp - mintemp );
    smo{i} = ( ratio_smo{i} - mintemp ) ./ mintemp ;
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
                        back{backtime} = [back{backtime},smo{i}(t)-smo{i}(time{i}(1,j))];
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


backtimemax = 500;
smoothpara = 40;
trial = 1:71;
trialnum = length(trial);
gcamp_ref = cell(1,trialnum);
gcamp_ori = cell(1,trialnum);
ratio = cell(1,trialnum);
ratio_smo = cell(1,trialnum);
smo = cell(1,trialnum);
time = cell(1,trialnum);
gcamp_ori_temp = xlsread('control.xlsx',1);
%gcamp_ref_temp = xlsread('mutant.xlsx',2);
for i = trial
    %gcamp_ref{i} = gcamp_ref_temp(:,i)';
    gcamp_ori{i} = gcamp_ori_temp(:,i)';
    %ratio{i} = gcamp_ori{i}./gcamp_ref{i};
    ratio{i} = gcamp_ori{i};
    time{i} = [1;140;NaN];
end
for i = trial
    ratio_smo{i} = smooth(ratio{i},smoothpara);
	NotANum = isnan(ratio{i});
    NaNPos = find( NotANum ==1 );
    for j = 1:length( NaNPos )
        ratio_smo{i}( NaNPos(j) ) = NaN;
    end
    mintemp = min(ratio_smo{i});
    maxtemp = max(ratio_smo{i});
    %smo{i} = ( ratio_smo{i} - mintemp ) ./ ( maxtemp - mintemp );
    smo{i} = ( ratio_smo{i} - mintemp ) ./ mintemp ;
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
                        back{backtime} = [back{backtime},smo{i}(t)-smo{i}(time{i}(1,j))];
                    end
                end
            end
        end
    end
end
smoback = zeros(1,backtimemax);
smobackstd = zeros(1,backtimemax);
for t = 1:backtimemax
    smoback(t) = mean(back{t});
    smobackstd(t) = std(back{t})/sqrt(length(back{t}));
    %smoback_up(t) = prctile(back{t},100-68.3);
    %smoback_low(t) = prctile(back{t},68.3);
	if length(back{t}) >= 5
        backtimevis = t;
    end
end
smoback_up = smoback + smobackstd;
smoback_low = smoback - smobackstd;
figure
hold on
plot(((1:backtimevis2)-1)/50,smoback2(1:backtimevis2),'r');
plot(((1:backtimevis)-1)/20,smoback(1:backtimevis),'b');
fill([((1:backtimevis2)-1)/50 fliplr(((1:backtimevis2)-1)/50)],[smoback_low2(1:backtimevis2) fliplr(smoback_up2(1:backtimevis2))],'r','facealpha',0.2,'edgealpha',0);
fill([((1:backtimevis)-1)/20 fliplr(((1:backtimevis)-1)/20)],[smoback_low(1:backtimevis) fliplr(smoback_up(1:backtimevis))],'b','facealpha',0.2,'edgealpha',0);
title('(AIB:Chrimson) RIV GCaMP during reversal');
legend('Gap junction mutant','Control');
xlabel('t/s');
ylabel('dR/R');
