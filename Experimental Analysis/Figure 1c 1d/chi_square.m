% This code calculates how well r1 and r2 are fitted, using chi square
% test. 
%% Get raw data from the figure

open('fitted_r1r2_qw373_transfer_to1s_final.fig');
lh = findall(gca, 'type', 'line');
xc = get(lh, 'xdata');

yc = get(lh, 'ydata');

% 5 12 19 26 33 40 47 54 61 68 75 82 89 96 

%%
chi = 0;
for i = 1:10 
    chi = chi + ( yc{1}(i*7-2) - deadf(i) )^2 / (( errf(i,2)-errf(i,1) )/2)^2;
end
p_r1 = chi2cdf(chi,6);

chi = 0;
for i = 1:10 
    chi = chi + ( yc{2}(i*7-2) - deadb(i) )^2 / (( errb(i,2)-errb(i,1) )/2)^2;
end
p_r2 = chi2cdf(chi,6);

%% QW373
% p_r1 = 0.0432 0.9568
% p_r2 = 0.0833 0.9167
%% Thermal
% p_r1 = 0.3844 0.6156
% p_r2 = 0.1810 0.8190