for i=1:1800
    extract(i)=BTotal{7,1}(1,i);
end

for i=1:1100
    extract(i+1800)=BTotal{8,1}(1,i);
end

extract_NaN=extract;
for i=1:200
    extract_NaN(i)=NaN;
end

for i=290:346
    extract_NaN(i)=NaN;
end

for i=594:940
    extract_NaN(i)=NaN;
end

for i=1570:1598
    extract_NaN(i)=NaN;
end

for i=1658:1795
    extract_NaN(i)=NaN;
end

for i=2436:2900
    extract_NaN(i)=NaN;
end


plot(extract_NaN);
ylim([0 6.5*10^6]);


for i=1:2900
    %BTotal_min=min(extract_NaN,[],'omitnan');
    %BTotal_min=mean(extract_NaN,'omitnan');
    BTotal_min=max(extract_NaN,[],'omitnan');
end



for i=1:2900
    if isnan(extract_NaN(i))
        extract_normalized(i)=extract_NaN(i);
    else
        %extract_normalized(i)=(extract_NaN(i)-BTotal_min(1))/BTotal_min(1);
        extract_normalized(i)=(extract_NaN(i)-BTotal_min(1))/BTotal_min(1)+1;
    end
end

plot (extract_normalized);


ax=gca;
xticks=linspace(0,3000,11);
ax.XTick=xticks;
k=0;
XTickLabel{1}=[0];
for i=1:3000
    if mod(i,300)==0
        k=k+1;
        label=[num2str((i)/300)];
        XTickLabel{k+1}=label;
    end
end
ax.XTickLabel=XTickLabel;
xlabel('time(s)');
ylabel('¦Ägradient/gradient');

set(gca,'YLim',[0 1]);%set Y axis range
%{
for i=1:2900
    if isnan(extract_NaN(i))
        extract_to_one(i)=extract_NaN(i);
    else
        extract_to_one(i)=(1-0)*(extract_NaN(i)-min(1))/(max-min)+0;
    end
end
y = (ymax-ymin)*(x-xmin)/(xmax-xmin) + ymin;
%extract_to_one=mapminmax('apply',extract_normalized,PS);
%plot(extract_to_one);
%}