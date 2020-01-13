num=0;
for i=54:57
    for j= 1:1800
        num=num+1;
        extract(num)=BTotal{i,1}(1,j);
    end
end
extract_2=extract;
plot(extract);
for i=1:100
    extract_2(i)=NaN;
end
for i=1197:1320
    extract_2(i)=NaN;
end
for i=2567:2746
    extract_2(i)=NaN;
end
for i=3553:3807
    extract_2(i)=NaN;
end
for i=1:num
    if extract_2(i)>8000000 || isnan(extract_2(i))
        extract_filtered(i)=extract_2(i);
    elseif extract_2(i)<8000000
        f=i;
        l=i;

        while extract_2(f)<8000000
            f=f-1;
        end

        while extract_2(l)<8000000
            l=l+1;
        end
        extract_filtered(i)=(extract_2(f)+extract_2(l))/2;
    end
end

for i=1:num
    if isnan(extract_2(i))
        %extract_filtered(i)=extract(i);
    end
end
plot(extract_filtered);

%%
BTotal_max=max(extract_filtered,[],'omitnan');
for i=1:7200
    if isnan(extract_filtered(i))
        extract_normalized(i)=extract_filtered(i);
    else
        %extract_normalized(i)=(extract_NaN(i)-BTotal_min(1))/BTotal_min(1);
        extract_normalized(i)=extract_filtered(i)/BTotal_max-1;
    end
end

plot (extract_normalized);


ax=gca;
xticks=linspace(0,7200,25);
ax.XTick=xticks;
k=0;
XTickLabel{1}=[0];
for i=1:7200
    if mod(i,300)==0
        k=k+1;
        label=[num2str((i)/300)];
        XTickLabel{k+1}=label;
    end
end
ax.XTickLabel=XTickLabel;
xlabel('time(s)');
ylabel('F/Fmax-1');

set(gca,'YLim',[-1 0]);%set Y axis range


        