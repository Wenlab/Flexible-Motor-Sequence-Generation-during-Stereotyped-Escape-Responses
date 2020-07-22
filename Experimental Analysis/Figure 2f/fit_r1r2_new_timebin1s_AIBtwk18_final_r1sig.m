% Please go to 'Figure 1C 1D/fit_r1r2_new_timebin1s_final_r1sig.m' for
% annotation. The two code are exactly the same. 

clearvars
data=xlsread('QW373(combin)(halfnotcount).xlsx');
dataf=data(:,1);
datab=data(:,2);

ddt=1;

FracBin=1;    %1.5 or 2.5 is good
dataf=FracBin*dataf;
datab=FracBin*datab;

max1=ceil(max(max(dataf),max(datab)));
distf=zeros(1,ceil(max1/ddt));
for j=1:(length(dataf))
    if dataf(j)>-0.1
        distf(ceil(dataf(j)/ddt))=distf(ceil(dataf(j)/ddt))+1;
    end
end

distb=zeros(1,ceil(max1/ddt));
for j=1:(length(datab))
    if datab(j)>-0.1
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

xx1 = 1:max1;
xdata = (xx1-1/2)*ddt/FracBin;
ydata = deadf;
xdata = xdata(1:7);
ydata = ydata(1:7);
r1 = @(k,xdata) k(1)./(1+exp(-(xdata-k(2))./k(3)));
k0 = [0.3,3,1];
kfit1 = lsqcurvefit(r1,k0,xdata,ydata);

ydata = deadb;
xdata = xdata(1:6);
ydata = ydata(1:6);
r2 = @(k,xdata) k(1)./erfi(k(2)+k(3).*exp(-xdata./k(4)));
k0 = [0.0233,0.1746,0.7092,0.2889];
kfit2 = lsqcurvefit(r2,k0,xdata,ydata);

%% 
figure
xx1=1:max1;
X=(xx1-1/2)*ddt/FracBin;

errorbar(X,deadb,errb(:,1)'-deadb,-errb(:,2)'+deadb,'gs');
hold on
errorbar(X,deadf,errf(:,1)'-deadf,-errf(:,2)'+deadf,'rs');
XX = linspace(0,7);
plot(XX,r2(kfit2,XX),'g');
plot(XX,r1(kfit1,XX),'r');

%End=max1/FracBin;  %max1/FracBin
End = 7;

title('Transition Rate (N=300)');
legend('r2','r1','fitted r2','fitted r1');
xlabel('t/s');
ylabel('rate');
axis([0 End 0 1]);

%% fitted distribution
%{
dt = 2/3;
svv = 1;
for t = 1:11
    fitdistf(t) = svv*r1(kfit1,(t-1/2)*dt);
    fitdistb(t) = svv*r2(kfit2,(t-1/2)*dt);
    svv = svv - fitdistf(t) - fitdistb(t);
end
figure
plot((xx1-1/2)*ddt/FracBin,distf/total,(xx1-1/2)*ddt/FracBin,distb/total);
hold on;
plot((xx1-1/2)*ddt/FracBin,fitdistf,(xx1-1/2)*ddt/FracBin,fitdistb);
figure
plot((xx1-1/2)*ddt/FracBin,fitdistf+fitdistb,(xx1-1/2)*ddt/FracBin,(distf+distb)/total);
%}

%legend('r2','r1','fitted r2','fitted r1','(Control n=593 ) r2','(Control n=593 ) r1','(Control n=593 ) fitted r2','(Control n=593 ) fitted r1');

