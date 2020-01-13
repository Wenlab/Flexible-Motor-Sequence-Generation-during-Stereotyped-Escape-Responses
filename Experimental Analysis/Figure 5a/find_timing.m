clearvars
minnum = 3;
backtimemax = 10000;
frame = 50;
smoothpara = 40;
trial = 8;
gcamp_ref = cell(1,trial);
gcamp_ori = cell(1,trial);
ratio = cell(1,trial);
ratio_smo = cell(1,trial);
smo = cell(1,trial);
time = cell(1,trial);
time_full = cell(1,trial);
rcd = cell(1,trial);
n = 0;
for i = 1:3
    temp = xlsread('data.xlsx',i);
    gcamp_ref{i} = temp(:,2);
    gcamp_ori{i} = temp(:,1);
    ratio{i} = temp(:,1)./temp(:,2);
end
for i = 1:3
    flag = 0;
    n = 0;
    for t = 1:length(ratio{i})
        if flag == 0
            if isnan(ratio{i}(t)) == 0
                flag = 1;
                n = n+1;
                rcd{i}(1,n) = t;
            end
        end
        if flag == 1
            if isnan(ratio{i}(t)) == 1
                flag = 0;
                rcd{i}(2,n) = t-1;
            end
        end
    end
end
