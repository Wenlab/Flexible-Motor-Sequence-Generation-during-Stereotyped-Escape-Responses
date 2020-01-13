% annotation is in 'single trial.m'
clearvars
global m
tic

tot_trial = 500;
mode = 2;
m = 4;
dt = 0.2e-3;
block = 1;
total_time = 10;
tot = total_time/dt;
Ec = -35;
C = [1,1,1,1];                %pF
Gc = 100*[1,1,1,1];           %pS
SingleSyn = 100;
SingleGap = 100;
AMPAr = 1/1e-2;
AMPAd = 1/0.2e-2;
GABAr = 1/1e-2;
GABAd = 1/0.2e-2;
S_max = 1/6;

STDfinal_gen = 0.8;%25/26;
STDfinal_BtT = 0.535;
STDd_gen = 1/(1.5);
STDd_BtT = 1/(2);
[STDr_sen,STDd_sen] = deal(1/(1e0),1/(5e-2));
STDr_gen = STDfinal_gen/(1-STDfinal_gen)*STDd_gen;
STDr_BtT = STDfinal_BtT/(1-STDfinal_BtT)*STDd_BtT;
betaE = [0.25,0.25,0.25,20];
betaI = [1,1,0.125,1];
VthE = [-15,-15,-15,-24];
VthI = [-15,-15,-15,-15];
VH = 0;
VL = -45;
Noise_Single = 8/sqrt(dt);
SingleGapOther = 30;  %this term includes the different possibilities of excited and relaxed
OtherSyn = [10,48,63,6];            %[8,131,782,389,84]

STDr = [STDr_sen*ones(1,m);ones(3,m)*STDr_gen];
STDd = [STDd_sen*ones(1,m);ones(3,m)*STDd_gen];
STDr(2,4) = STDr_BtT;
STDd(2,4) = STDd_BtT;

%load('GapSynNum.mat','Gap','Syn')

Syn=xlsread('Syn.xlsx');
Gap=xlsread('Gap.xlsx');
Syn=5*Syn;
%save('GapSynNum.mat','Gap','Syn')


Gs = SingleSyn*abs(Syn);
Gs_pos = (SingleSyn*Syn+Gs)/2;
Gs_GABA = (Gs-SingleSyn*Syn)/2;
Gs_AMPA = Gs_pos;
Ee = VH;
Ei = VL;
Gg = SingleGap*(Gap+Gap');
totleak = Gc;

totact = 1.5/dt;
n = ones(1,m);
tlen1= [];
tlen2 = [];

for trial = 1:tot_trial
    state = 0;      %0 for forward, 1 for reversal
    V = -ones(1,m)*35;
    S_AMPA = zeros(1,m);
    S_GABA = zeros(1,m);
    P = ones(m,m);
    rcdV = zeros(tot/(0.01/dt),m);
    rcdtime = 1;
    if mode == 1
        V(3) = VH;
        S_AMPA(3) = S_max;
        S_GABA(3) = S_max;
    else
        if mode == 2
            V(2) = VH;
            S_AMPA(2) = S_max;
            S_GABA(2) = S_max;
        else
            if mode == 3
                V(3) = VH;
                S_AMPA(3) = S_max;
                S_GABA(3) = S_max;
            end
        end
    end

    rcdV(rcdtime,:) = V;
    for t = 1:tot
        if mode == 1
            if t <= totact
                V(1) = VH;
            end
        end
        dS_AMPA = (AMPAr*(1-S_AMPA)./(1+exp(betaE.*(VthE-V)))-AMPAd*S_AMPA)*dt;
        S_AMPA = S_AMPA+dS_AMPA;
        dS_GABA = (GABAr*(1-S_GABA)./(1+exp(betaI.*(VthI-V)))-GABAd*S_GABA)*dt;
        S_GABA = S_GABA+dS_GABA;
        dP = ( (1-P).*STDr - P.*([S_GABA'/S_max,S_GABA'/S_max,S_GABA'/S_max,S_GABA'/S_max]).*STDd )*dt;
        P = P+dP;
        Il = -totleak.*(V-Ec);
        Ig = -V.*(n*Gg)+V*Gg;
        Is = -[S_AMPA(1)*P(1,3),S_AMPA(2:end)]*(Gs_AMPA.*(n'*V-Ee))-S_GABA*(P.*(Gs_GABA.*(n'*V-Ei)));
        Ie = normrnd(0,Noise_Single,1,m).*OtherSyn;
        dV = (Il+Is+Ig+Ie)*dt./C;
        V = V+dV;
        rcdornot = mod(t,0.01/dt);
        if rcdornot == 0
            rcdtime = rcdtime+1;
            rcdV(rcdtime,:) = V;

            if V(4)>=VthE(4)
                tlen2 = [tlen2,t];
                break;
            end
            if t>=0.05/dt & V(3)>=VH
                tlen1 = [tlen1,t];
                break;
            end
           
        end
    end
    
end

tlen1 = tlen1*dt;
tlen2 = tlen2*dt;

%% load final experimental data and compare with simulation
dataExp = xlsread('QW373(combin)(halfnotcount).xlsx');
datafExp = dataExp(:,1);
databExp = dataExp(:,2);
datafTheo = tlen1';
databTheo = tlen2';

ddt = 1;
FracBin = 1;    %1.5 or 2.5 is good
datafExp = FracBin*datafExp;
databExp = FracBin*databExp;
datafTheo = FracBin*datafTheo;
databTheo = FracBin*databTheo;

max1 = ceil(max([max(datafExp),max(databExp),max(datafTheo),max(databTheo)]));
distfExp = zeros(1,ceil(max1/ddt));
for j = 1:(length(datafExp))
    if datafExp(j) > -0.1
        distfExp(ceil(datafExp(j)/ddt)) = distfExp(ceil(datafExp(j)/ddt))+1;
    end
end
distbExp = zeros(1,ceil(max1/ddt));
for j=1:(length(databExp))
    if databExp(j) > -0.1
        distbExp(ceil(databExp(j)/ddt)) = distbExp(ceil(databExp(j)/ddt)) +1;
    end
end
distfTheo = zeros(1,ceil(max1/ddt));
for j = 1:(length(datafTheo))
    if datafTheo(j) > -0.1
        distfTheo(ceil(datafTheo(j)/ddt)) = distfTheo(ceil(datafTheo(j)/ddt)) +1;
    end
end
distbTheo = zeros(1,ceil(max1/ddt));
for j = 1:(length(databTheo))
    if databTheo(j) > -0.1
        distbTheo(ceil(databTheo(j)/ddt)) = distbTheo(ceil(databTheo(j)/ddt))+1;
    end
end

disttotalExp = distfExp + distbExp;
disttotalTheo = distfTheo + distbTheo;

totalExp=sum(disttotalExp);
deadExp = 0;
svvExp(1) = totalExp;
for i = 1:max1
    deadExp = deadExp + disttotalExp(i);
    svvExp(i+1) = totalExp - deadExp;
end
svvExp = svvExp(1:length(svvExp)-1);
[deadfExp,errfExp] = binofit(distfExp,svvExp);
[deadbExp,errbExp] = binofit(distbExp,svvExp);
[deadtotalExp,errtotalExp] = binofit(disttotalExp,svvExp);

totalTheo=sum(disttotalTheo);
deadTheo = 0;
svvTheo(1) = totalTheo;
for i = 1:max1
    deadTheo = deadTheo + disttotalTheo(i);
    svvTheo(i+1) = totalTheo - deadTheo;
end
svvTheo = svvTheo(1:length(svvTheo)-1);
[deadfTheo,errfTheo] = binofit(distfTheo,svvTheo);
[deadbTheo,errbTheo] = binofit(distbTheo,svvTheo);
[deadtotalTheo,errtotalTheo] = binofit(disttotalTheo,svvTheo);

%%
figure
subplot(2,1,2)
xx1=1:max1;
X=(xx1-1/2)*ddt/FracBin;

hold on
errorbar(X,deadbExp,errbExp(:,1)'-deadbExp,-errbExp(:,2)'+deadbExp,'g');
errorbar(X,deadfExp,errfExp(:,1)'-deadfExp,-errfExp(:,2)'+deadfExp,'r');
errorbar(X,deadbTheo,errbTheo(:,1)'-deadbTheo,-errbTheo(:,2)'+deadbTheo,'g--');
errorbar(X,deadfTheo,errfTheo(:,1)'-deadfTheo,-errfTheo(:,2)'+deadfTheo,'r--');

End=max1/FracBin;  %max1/FracBin
%End = 5;

title('Transition Rate');
legend('r2','r1');
xlabel('t/s');
ylabel('rate');
axis([0 End 0 1]);

%{
subplot(6,1,1);
%bar(X,disttotal/total);
bar(X,distf/total,'r');
alpha(0.5);
hold on
bar(X,distb/total,'g');
alpha(0.5);
title({'QW373' ; '(N=390) Reversal Length Distribution '});
legend('Without turn','With turn');
xlabel('t/s');
ylabel('probability');
axis([0 End 0 0.25]);
%}
%End = 5;

subplot(6,1,1);hold on
pExp = disttotalExp/totalExp;
epExp = sqrt(pExp.*(1-pExp)/totalExp);
errorbar(X,pExp,epExp,'g');
pTheo = disttotalTheo/totalTheo;
epTheo = sqrt(pTheo.*(1-pTheo)/totalTheo);
errorbar(X,pTheo,epTheo,'g--');
title({'QW373' ; 'Reversal Length Distribution '});
legend('Exp','Theo');
xlabel('t/s');
ylabel('probability');
axis([0 End 0 0.3]);

subplot(6,1,2);hold on
pExp = distfExp/totalExp;
epExp = sqrt(pExp.*(1-pExp)/totalExp);
errorbar(X,pExp,epExp,'r');
pTheo = distfTheo/totalTheo;
epTheo = sqrt(pTheo.*(1-pTheo)/totalTheo);
errorbar(X,pTheo,epTheo,'r--');
legend('Exp','Theo');
xlabel('t/s');
ylabel('probability');
axis([0 End 0 0.3]);

subplot(6,1,3);hold on
pExp = distbExp/totalExp;
epExp = sqrt(pExp.*(1-pExp)/totalExp);
errorbar(X,pExp,epExp,'b');
pTheo = distbTheo/totalTheo;
epTheo = sqrt(pTheo.*(1-pTheo)/totalTheo);
errorbar(X,pTheo,epTheo,'b--');
legend('Exp','Theo');
xlabel('t/s');
ylabel('probability');
axis([0 End 0 0.3]);

simtime = toc