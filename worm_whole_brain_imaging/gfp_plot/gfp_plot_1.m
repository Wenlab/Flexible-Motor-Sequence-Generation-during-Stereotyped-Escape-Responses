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
    N1_normalized(i)=(N1(i)-N1_min)/N1_min;
    N2_normalized(i)=(N2(i)-N2_min)/N2_min;
end

plot(N1_normalized);
xlabel('frame');
ylabel('¦ÄF/F');
%%
%{
%for sample 1
ax=gca;
xticks=linspace(0,600,7);
ax.XTick=xticks;
k=0;
XTickLabel{1}=[0];
for i=1:601
    if mod(i,100)==0
        k=k+1;
        label=[num2str((i)/100)];
        XTickLabel{k+1}=label;
    end
end
ax.XTickLabel=XTickLabel;
xlabel('time(s)');
ylabel('¦ÄF/F');
%}

%{
%needed to change manually
ax=gca;
xticks=linspace(0,500,6);
ax.XTick=xticks;
k=0;
XTickLabel{1}=[0];
for i=1:501
    if mod(i,100)==0
        k=k+1;
        label=[num2str((i)/100)];
        XTickLabel{k+1}=label;
    end
end
ax.XTickLabel=XTickLabel;
xlabel('time(s)');
ylabel('¦ÄF/F');
%}

