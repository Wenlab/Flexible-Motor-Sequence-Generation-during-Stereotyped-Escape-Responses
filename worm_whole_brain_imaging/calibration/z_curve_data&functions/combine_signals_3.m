%{
for i=1:320
    BTotal(7,i)=B(1,i);
end

BTotal=BTotal';
%}


for i=1:7
    BTotal_min=min(BTotal');
end



for i=1:7
    for j=1:320
        BTotal_normalized(i,j)=(BTotal(i,j)-BTotal_min(1,i))/BTotal_min(1,i);
    end
end


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

