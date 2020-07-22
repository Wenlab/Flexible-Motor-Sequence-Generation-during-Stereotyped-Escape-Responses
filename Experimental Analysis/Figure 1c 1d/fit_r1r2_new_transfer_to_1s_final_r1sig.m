% Please go to 'Figure 1C 1D/fit_r1r2_new_timebin1s_final_r1sig.m' for annotation
% This code use time bin = 0.5s, but the results has been converted to 1s.
% See line 68-71 for conversion

clearvars

data=xlsread('QW373(combin)(halfnotcount).xlsx');
dataf=data(:,1);
datab=data(:,2);

ddt=1;

FracBin=2;    % time bin = 0.5s
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
xdata = xdata(1:11);
ydata = ydata(1:11);
%r1 = @(k,xdata) k(1).*( k(2)+k(3).*exp(-xdata./k(4)) )./exp( k(2)+k(3).*exp(-xdata./k(4)) );
%r1 = @(k,xdata) k(1) * integral(@(theta)1./erfi( ( k(2)+k(3).*exp(-xdata./k(4)) ) ./ cos(theta) ),0,pi/4);

r1 = @(k,xdata) k(1)./(1+exp(-(xdata-k(2))./k(3)));
k0 = [0.3,3,1];
kfit1 = lsqcurvefit(r1,k0,xdata,ydata);

ydata = deadb;
xdata = xdata(1:10);
ydata = ydata(1:10);
r2 = @(k,xdata) k(1)./erfi(k(2)+k(3).*exp(-xdata./k(4)));
k0 = [0.0233,0.1746,0.7092,0.2889];
kfit2 = lsqcurvefit(r2,k0,xdata,ydata);

%% 
figure
xx1=1:max1;
X=(xx1-1/2)*ddt/FracBin;

deadb = -deadb.^2+2*deadb;
errb = -errb.^2+2*errb;
deadf = -deadf.^2+2*deadf;
errf = -errf.^2+2*errf;
XX = linspace(0,7);
r2_line = -r2(kfit2,XX).^2+2*r2(kfit2,XX);
r1_line = -r1(kfit1,XX).^2+2*r1(kfit1,XX);

errorbar(X,deadb,errb(:,1)'-deadb,-errb(:,2)'+deadb,'gs');
hold on
errorbar(X,deadf,errf(:,1)'-deadf,-errf(:,2)'+deadf,'rs');
plot(XX,r2_line,'g');
plot(XX,r1_line,'r');

%End=max1/FracBin;  %max1/FracBin
End = 5;

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


