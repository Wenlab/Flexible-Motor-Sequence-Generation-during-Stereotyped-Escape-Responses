%{
for i=1:320
    BTotal(7,i)=B(1,i);
end

BTotal=BTotal';
%}


for i=1:7
    BTotal_max=max(BTotal');
end


for i=1:7
    for j=1:320
        BTotal_normalized(i,j)=BTotal(i,j)/BTotal_max(1,i);
    end
end

for i=1:7
    for j=1:320
        if BTotal_normalized(i,j)==1
            BTotal_max_index(i)=j;
        end
    end
end

for i=1:7
    shift=BTotal_max_index(i)-160;
    if shift<0
        for j=(-shift+1):(320-shift)
            BTotal_normalized_shift(i,j)=BTotal_normalized(i,j+shift);
        end
    else
        for j=1:(320-shift)
            BTotal_normalized_shift(i,j)=BTotal_normalized(i,j+shift);
        end
    end
end

for i=1:7
    find_index=find((BTotal_normalized_shift(i,:))~=0);
    left(i)=find_index(1);
    right(i)=find_index(end);
end
left_plot=max(left);
right_plot=min(right);
for i=1:7
    for j=1:(left_plot-1)
        BTotal_normalized_shift_2(i,j)=NaN;
    end
    for j=(right_plot+1):(length(BTotal_normalized_shift(i,:)))
        BTotal_normalized_shift_2(i,j)=NaN;
    end
    for j=left_plot:right_plot
        BTotal_normalized_shift_2(i,j)=BTotal_normalized_shift(i,j);
    end
end

%%
for i=1:7
    plot(BTotal_normalized_shift_2(i,:));
    hold on
end
ax=gca;
xticks=linspace(0,(floor(length(BTotal_normalized_shift_2)/10)+1)*10,floor(length(BTotal_normalized_shift_2)/10)+2);
ax.XTick=xticks;
for i=1:(floor(length(BTotal_normalized_shift_2)/10)+2)
    label10=[num2str(((i-17))*10)];
    XTickLabel{i}=label10;
end
ax.XTickLabel=XTickLabel;
xlabel('z position(micron)');
ylabel('B/Bmax')
set(gca,'ylim',[0 1]);
set(gca,'xlim',[40 270]);
hold off
%%

X=BTotal_normalized_shift_2;
S=std(X,[],'omitnan')/sqrt(7);
M=mean(X,'omitnan');

k=0;
for i=1:length(X)
    if mod(i,10)==0 || i==1
        k=k+1;
        M_s(k)=M(i);
        S_s(k)=S(i);

    end
end


errorbar(M_s,S_s);
ax=gca;
xticks=linspace(0,length(X),length(X)+1);
ax.XTick=xticks;
for i=1:length(X)
    label10=[num2str((i-18)*10)];
    XTickLabel{i}=label10;
end
ax.XTickLabel=XTickLabel;
xlabel('z position(micron)');
ylabel('B/Bmax')
set(gca,'ylim',[0 1]);
set(gca,'xlim',[5 28]);
%%


X=BTotal_normalized_shift_2-1;
S=std(X,[],'omitnan')/sqrt(7);
M=mean(X,'omitnan');

k=0;
for i=1:length(X)
    if mod(i,10)==0 || i==1
        k=k+1;
        M_s(k)=M(i);
        S_s(k)=S(i);

    end
end


errorbar(M_s,S_s);
ax=gca;
xticks=linspace(0,length(X),length(X)+1);
ax.XTick=xticks;
for i=1:length(X)
    label10=[num2str((i-18)*10)];
    XTickLabel{i}=label10;
end
ax.XTickLabel=XTickLabel;
xlabel('z position(micron)');
ylabel('B/Bmax')
set(gca,'ylim',[-1 0]);
set(gca,'xlim',[5 28]);






%{
for i=1:7
    plot(BTotal_normalized(i,:));
    hold on
end


ax=gca;
xticks=linspace(0,321,33);
ax.XTick=xticks;
k=0;
for i=1:321
    if mod(i,10)==0
        k=k+1;
        label10=[num2str(i)];
        XTickLabel{k+1}=label10;
    end
end
XTickLabel{1}=[0];
ax.XTickLabel=XTickLabel;
xlabel('z position(micron)');
ylabel('normalized gradient');
%}





%{
X=BTotal_normalized;

%X=BTotal;
[Y,PS]=mapminmax(X,0,1);
BTotal_map=Y';

S=(std(Y))/sqrt(7);
M=mean(Y);

k=0;
for i=1:320
    if mod(i,10)==0 || i==1
        k=k+1;
        M_s(k)=M(i);
        S_s(k)=S(i);

    end
end

errorbar(M_s,S_s);
ax=gca;
xticks=linspace(0,33,34);
ax.XTick=xticks;
for i=1:34
    label10=[num2str((i-19)*10)];
    XTickLabel{i}=label10;
end
XTickLabel{1}=[];
ax.XTickLabel=XTickLabel;
xlabel('z position(micron)');
ylabel('normalized gradient');
%}
