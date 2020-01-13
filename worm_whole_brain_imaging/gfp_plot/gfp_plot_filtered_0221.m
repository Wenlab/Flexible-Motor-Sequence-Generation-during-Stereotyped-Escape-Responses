[ImgLength,~]=size(calcium_signal);
for i=1:ImgLength
    if ~isempty(calcium_signal{i,1})
        N1(i)=calcium_signal{i,1}(1,1);
        N2(i)=calcium_signal{i,1}(2,1);
        fprintf('%d\n',i);
    else
        N1(i)=NaN;
        N2(i)=NaN;
    end
end


N1_min=min(N1,[],'omitnan');
N2_min=min(N2,[],'omitnan');

fprintf('%d\n',N1_min);

for i=1:ImgLength
    if N1(i)<N1_min*1.1 || N2(i)<N2_min*1.1648
        N1_filtered(i)=NaN;
        N2_filtered(i)=NaN;
    else
        N1_filtered(i)=N1(i);
        N2_filtered(i)=N2(i);
    end
end

N1_filtered_min=min(N1_filtered,[],'omitnan');
N2_filtered_min=min(N2_filtered,[],'omitnan');

for i=1:ImgLength    
    N1_filtered_normalized(i)=(N1_filtered(i)-N1_filtered_min)/N1_filtered_min;
    N2_filtered_normalized(i)=(N2_filtered(i)-N2_filtered_min)/N2_filtered_min;
end

%% calculate f/fmax

N1_filtered_normalized_max=max(N1_filtered_normalized,[],'omitnan');
N2_filtered_normalized_max=max(N2_filtered_normalized,[],'omitnan');
for i=1:ImgLength
    N1_filtered_normalized(i)=(N1_filtered_normalized(i)+1)/(N1_filtered_normalized_max+1)-1;
    N2_filtered_normalized(i)=(N2_filtered_normalized(i)+1)/(N2_filtered_normalized_max+1)-1;
end

%%
for i=1:ImgLength-350
    N1_filtered_normalized_shifted(i)=N1_filtered_normalized(i+350);
    N2_filtered_normalized_shifted(i)=N2_filtered_normalized(i+350);
end
plot(N2_filtered_normalized_shifted);%N1 or N2?


%%
ax=gca;
xticks=linspace(0,1400,15);
ax.XTick=xticks;

k=0;
XTickLabel{1}=[0];
for i=1:1400
    if mod(i,100)==0
        k=k+1;
        label=[num2str((i)/100)];
        XTickLabel{k+1}=label;
    end
end
ax.XTickLabel=XTickLabel;
xlabel('time(s)');
ylabel('F/Fmax-1');
