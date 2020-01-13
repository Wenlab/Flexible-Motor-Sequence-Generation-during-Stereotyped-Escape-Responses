clearvars
global m
tic

tot_trial = 1;
mode = 2;
m = 4;
dt = 0.2e-3;
block = 1;
total_time = 10;
turn_duration = 2;
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
betaE = [0.25,0.25,0.25,1e3];
betaI = [1,1,0.125,1e3];
VthE = [-15,-15,-15,-24];
VthI = [-15,-15,-15,-24];
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
tlen1 = [];
tlen2 = [];

for trial = 1:tot_trial
    state = 0;      %0 for forward, 1 for reversal
    V = -ones(1,m)*35;
    S_AMPA = zeros(1,m);
    S_GABA = zeros(1,m);
    P = ones(m,m);
    rcdV = NaN*zeros(tot/(0.01/dt),m);
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
        if length(tlen2) ~= 0
            if (t - tlen2)*dt <= turn_duration
                V(4) = VH;
                S_GABA(4) = S_max;
                S_AMPA(4) = S_max;
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

            if V(4)>=VthE(4) & length([tlen1,tlen2]) == 0
                tlen2 = [tlen2,t];
                V(4) = VH;
                %break;
            end
            if t>=0.05/dt & V(3)>=VH & length([tlen1,tlen2]) == 0
                tlen1 = [tlen1,t];
                %break;
            end
            
        end
    end
    
end

figure
xx = 1:(tot/(0.01/dt)+1);
xx = (xx-1)/100;

plot(xx,rcdV(:,2),xx,rcdV(:,3),xx,rcdV(:,4));
axis([0 total_time -60 10]); 
legend('Backward','Forward','Turn');

simtime=toc