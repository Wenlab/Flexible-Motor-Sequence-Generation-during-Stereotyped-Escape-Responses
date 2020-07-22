% Please go to 'Figure 1C 1D/fit_r1r2_new_timebin1s_final_r1sig.m' for
% annotation. The two code are exactly the same. 
clearvars;
data=xlsread('Forward.xlsx');
dataf=data(:,1);
datab=data(:,2);

ddt=1;

max1=ceil(max(max(dataf),max(datab)));
distf=zeros(1,ceil(max1/ddt));
for j=1:(length(dataf))
    if dataf(j)~=-1
        distf(ceil(dataf(j)/ddt))=distf(ceil(dataf(j)/ddt))+1;
    end    
end

distb=zeros(1,ceil(max1/ddt));
for j=1:(length(datab))
    if datab(j)~=-1
        distb(ceil(datab(j)/ddt))=distb(ceil(datab(j)/ddt))+1;
    end
end

disttotal=distf+distb;
total=sum(disttotal);
dead=0;
svv(1)=total;
for i=1:max1
    dead=dead+disttotal(i);
    svv(i+1)=total-dead;
end
svv=svv(1:length(svv)-1);
[deadf,errf]=binofit(distf,svv);
[deadb,errb]=binofit(distb,svv);
[deadtotal,errtotal]=binofit(disttotal,svv);


figure
subplot(2,1,2);
xx1=1:max1;
X=(xx1-1/2)*ddt;
errorbar(X,deadf,errf(:,1)'-deadf,-errf(:,2)'+deadf,'r');
max2=40;
title('transition rate');
xlabel('t/s');
ylabel('rate');
axis([0 max2 0 0.3]);

subplot(2,1,1);
bar((xx1-1/2)*ddt,disttotal/total);
title({'(N=1284) Forward length distribution of N2 '});
legend('total');
xlabel('t/s');
ylabel('possibility');
axis([0 max2 0 1]);