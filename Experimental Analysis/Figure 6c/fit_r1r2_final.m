clearvars
data=xlsread('QW373(combin)(halfnotcount).xlsx');
dataf=data(:,1);
datab=data(:,2);

ddt=1;

FracBin=2;    %1.5 or 2.5 is good
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

%k0 = [1.7611,1.5422,8.8953,1.3090];
%k0 = [280.5991    2.8732    4.0564    0.1844];
k0 = [370.5991    2.9225    0.5376    0.2884];
options = optimset('MaxFunEvals',1000);
kfit1 = lsqcurvefit(@r1,k0,xdata,ydata,[],[],options);
%kfit1 = lsqcurvefit(@r1,k0,xdata,ydata);

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

errorbar(X,deadb,errb(:,1)'-deadb,-errb(:,2)'+deadb,'gs');
hold on
errorbar(X,deadf,errf(:,1)'-deadf,-errf(:,2)'+deadf,'rs');
XX = linspace(0,7);
plot(XX,r2(kfit2,XX),'g');
plot(XX,r1(kfit1,XX),'r');

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


