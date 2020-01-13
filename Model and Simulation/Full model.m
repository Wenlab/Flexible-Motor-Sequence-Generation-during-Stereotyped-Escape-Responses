clearvars
load('Exp_data.mat');

tot_trial = 300;
m = 11;
dt = 1e-4;
Vth = -15;
OtherSyn = [35*ones(1,6),35*ones(1,3),15*ones(1,2)];
Noise_Single = 5/sqrt(dt);
ext_AIZ = 200;
ext_AIY = 200;

STDfinal_gen = 0.809;
STDfinal_BtT = 0.51;
STDd_gen = 1/(1);
STDd_BtT = 1/(3);

x = zeros(1,50);
BB = 8.5;
FF = 30;
TT = 10;
BF = -9.95;
FB = -10;
BT = -30;
FT = -30;
x(15:47) = [BB*ones(1,12),FF*ones(1,2),TT*ones(1,2),BF*ones(1,5),FB*ones(1,9),BT*ones(1,2),FT];

Syn = [ ...
    0   0   x(15) x(16) x(17) 0       x(32) x(31) x(33)   x(45) 0 ; ...
    0   0   0   x(18) 0   0           0   0   0           0	0 ; ...
    0   0   0   x(19) 0   0           0   0   0           0	0 ; ...
    0   x(20) x(21) 0   0   0         0   0   0           0	0 ; ...
    x(22) 0   0   x(23) 0   0         0   x(34) x(35)     x(46)	0 ; ...
    x(24) 0   x(25) 0   x(26) 0       0   0   0           0	0 ; ...
    ...
    0   0   0   0   0   x(39)           0   0   x(27)       0	0 ; ...
    0   x(36) x(37) x(38) 0   0         0   0   0           0	0 ; ...
    x(40) x(41) x(42) x(43) 0 x(44)     0   x(28) 0         x(47) 0 ; ...
    ...
    0   0   0   0   0   0           0   0   0           0 x(29) ; ...
    0   0   0   0   0   0           0   0   0           x(30) 0 ; ...
    ];

Gap = [ ...
    0   0   0   0   20   0        0   0   0           0	20 ; ...
    0   0   0   0   0   0           0   0   0           0	0 ; ...
    0   0   0   0   20   0        0   0   0           0	0 ; ...
    0   0   0   0   20	0       0   0   0           0	0 ; ...
    0   0   0   0   0   0           0   0   0       0	0 ; ...
    0   0   0   0   0   0           0   0   0           0	0 ; ...
    ...
    0   0   0   0   0   0           0   0   0           0	0 ; ...
    0   0   0   0   0   0           0   0   20        0	0 ; ...
    0   0   0   0   0   0           0   0   0           0	0 ; ...
    ...
    0   0   0   0   0   0           0   0   0           0	50 ; ...
    0   0   0   0   0   0           0   0   0           0	0 ; ...
    ];

S_max = 1/6;
betaE = [0.25*ones(1,m-2),20,20];
betaI = ones(1,m);
VthE = [-15*ones(1,m-2),Vth,Vth];
VthI = [-15*ones(1,m)];
VH = 0;
VL = -45;
VjudL = -17;
VjudH = -13;
SingleGapOther = 30;  %this term includes the different possibilities of excited and relaxed
block = 1;
total_time = 10;
tot = total_time/dt;
Ec = -35;
C = ones(1,m);                %pF
Gc = 100*ones(1,m);           %pS
SingleSyn = 100;
SingleGap = 100;
AMPAr = 1/1e-2;
AMPAd = 1/5e-2;
GABAr = 1/1e-2;
GABAd = 1/5e-2;
STDr_gen = STDfinal_gen/(1-STDfinal_gen)*STDd_gen;
STDr_BtT = STDfinal_BtT/(1-STDfinal_BtT)*STDd_BtT;

STDr = [ones(m,m)*STDr_gen];
STDd = [ones(m,m)*STDd_gen];
STDr(1,10) = STDr_BtT;
STDd(1,10) = STDd_BtT;
STDr(6,10) = STDr_BtT;
STDd(6,10) = STDd_BtT;
STDr(5,10) = STDr_BtT;
STDd(5,10) = STDd_BtT;


Gs = SingleSyn*abs(Syn);
Gg = SingleGap*(Gap+Gap');
Gs_AMPA = (SingleSyn*Syn + Gs)/2;
Gs_GABA = (Gs - SingleSyn*Syn)/2;

Ee = VH;
Ei = VL;
totleak = Gc;
Iext = zeros(1,m);
n = ones(1,m);
tlen1 = [];
tlen2 = [];
tlen3 = [];
rcdV = zeros(tot/100,m);

for trial = 1:tot_trial
    if mod(trial,10) == 0
        [trial,tot_trial]
    end
    flag = 0;
    V = -ones(1,m)*35;
    V(1:6) = VH;
    S_AMPA = zeros(1,m);
    S_GABA = zeros(1,m);
    S_AMPA(1:6) = S_max;
    S_GABA(1:6) = S_max;
    P = ones(m,m);

    for t = 1:tot
        dS_AMPA = (AMPAr*(1-S_AMPA)./(1+exp(betaE.*(VthE-V)))-AMPAd*S_AMPA)*dt;
        S_AMPA = S_AMPA+dS_AMPA;
        dS_GABA = (GABAr*(1-S_GABA)./(1+exp(betaI.*(VthI-V)))-GABAd*S_GABA)*dt;
        S_GABA = S_GABA+dS_GABA;
        %dP = ( (1-P)*STDr - P.*(S_GABA/S_max)*STDd )*dt;
        dP = ( (1-P).*STDr - P.*(repmat(S_GABA',1,m)/S_max).*STDd )*dt;
        P = P+dP;
        Il = -totleak.*(V-Ec);
        Ig = -V.*(n*Gg)+V*Gg;
        Is = -S_AMPA*(Gs_AMPA.*(n'*V-Ee))-(S_GABA)*((Gs_GABA.*P.*(n'*V-Ei)));
        %Is = -S_AMPA*(Gs_AMPA.*(n'*V-Ee))-S_GABA*(P.*(Gs_GABA.*(n'*V-Ei)));
        Ie = normrnd(0,Noise_Single,1,m).*OtherSyn;
        Iext(6:7) = [-ext_AIZ*(V(6)-Ee),-ext_AIY*(V(7)-Ee)];
        dV = (Il+Is+Ig+Ie+Iext).*dt./C;
        V = V+dV;
        if mod(t,100) == 0 & tot_trial == 1
            rcdV(t/100,:) = V;
        end
        if V(11)>=VthE(end)
            tlen2 = [tlen2,t*dt];
            endt = t;
            flag = 2;
            break;
        end
        if all([V(1:6)<=VjudL,V(7:9)>=VjudH])
            tlen1 = [tlen1,t*dt];
            endt = t;
            flag = 1;
            break;
        end
    end
    if flag == 0
        tlen3 = [tlen3,t*dt];
        endt = t;
    end
end

%



if tot_trial == 1
    if floor(endt/100) ~= 0
        tt = 1:floor(endt/100);
        figure
        hold on
        simbol = {'-','--',':'};
        for i = 1:3
            plot(tt*100*dt,rcdV(1:floor(endt/100),i),['r',simbol{i}]);
        end
        for i = 4:6
            plot(tt*100*dt,rcdV(1:floor(endt/100),i),['m',simbol{i-3}]);
        end
        for i = 7:9
            plot(tt*100*dt,rcdV(1:floor(endt/100),i),['b',simbol{i-6}]);
        end
        for i = 10:11
            plot(tt*100*dt,rcdV(1:floor(endt/100),i),['y',simbol{i-9}]);
        end
        axis([0 10 -45 0]);
        legend('AIB','AVD','AVE','AVA','RIM','AIZ','AIY','AVB','RIB','SMD','RIV');
        title('backward');
    end
else
    
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
    
end