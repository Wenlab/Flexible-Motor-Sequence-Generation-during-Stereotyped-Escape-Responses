clearvars
%% load data from .xlsx
data = xlsread('QW373(combin)(halfnotcount).xlsx');
dataf = data(:,1);
datab = data(:,2);

%% Setting time bin width
FracBin = 1;    % for example, 1 and 2 represent time bin width = 1s and 0.5s, respectively
ddt = 1;  
dataf = FracBin*dataf;
datab = FracBin*datab;

%% get histogram
% distf: type-1 reversal length histogram
% distb: type-2 reversal length histogram
% disttotal: total reversal length histogram
% svv: total survival function
% deadf,errf: type-1 transition rate and corresponding confidence interval
% deadb,errb: type-2 transition rate and corresponding confidence interval
% deadtotal,errtotal: total transition rate and corresponding confidence interval
max1 = ceil(max(max(dataf),max(datab)));
distf = zeros(1,ceil(max1/ddt));
for j = 1:(length(dataf))
    if dataf(j)>-0.1
        distf(ceil(dataf(j)/ddt)) = distf(ceil(dataf(j)/ddt))+1;
    end
end

distb = zeros(1,ceil(max1/ddt));
for j = 1:(length(datab))
    if datab(j) >- 0.1
        distb(ceil(datab(j)/ddt)) = distb(ceil(datab(j)/ddt))+1;
    end
end

disttotal = distf+distb;
total = sum(disttotal);
dead = 0;
svv(1) = total;
for i = 1:max1
    dead = dead+disttotal(i);
    svv(i+1) = total-dead;
end
svv = svv(1:length(svv)-1);
[deadf,errf] = binofit(distf,svv);
[deadb,errb] = binofit(distb,svv);
[deadtotal,errtotal] = binofit(disttotal,svv);

%% fit r1 and r2
% r1 has been abondoned
% k0 is the initial vector of the four parameters, kfit2 is the fitted
% parameters
xx1 = 1:max1;
xdata = (xx1-1/2)*ddt/FracBin;
ydata = deadf;
xdata = xdata(1:7);
ydata = ydata(1:7);
r1 = @(k,xdata) k(1)./(1+exp(-(xdata-k(2))./k(3)));
k0 = [0.2,0.5,5];
kfit1 = lsqcurvefit(r1,k0,xdata,ydata);
kfit1(2) = 0.33;
kfit1(3) = 0.2;

ydata = deadb;
xdata = xdata(1:7);
ydata = ydata(1:7);
r2 = @(k,xdata) k(1)./erfi(k(2)+k(3).*exp(-xdata./k(4)));
k0 = [0.0233,0.1746,0.7092,0.2889];
kfit2 = lsqcurvefit(r2,k0,xdata,ydata);

%% plot figure
figure
xx1 = 1:max1;
X = (xx1-1/2)*ddt/FracBin;

errorbar(X,deadb,errb(:,1)'-deadb,-errb(:,2)'+deadb,'gs');
hold on
errorbar(X,deadf,errf(:,1)'-deadf,-errf(:,2)'+deadf,'rs');
XX = linspace(0,7);
plot(XX,r2(kfit2,XX),'g');
plot(XX,r1(kfit1,XX),'r');

%End=max1/FracBin;  %max1/FracBin
End = 7;

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


