%This function calculate the mean intensity of the fluorescence


function mean_F = calculate_intensity(F,n)

if nargin==1
    n=50;
end

F_sorted=sort(F,'descend');
baseline_F=mean(F_sorted(end-10:end));
%baseline_F=0;
mean_F=mean(F_sorted(1:n))-baseline_F; % average over the first n brightest pixels

%mean_F=sum(F-baseline_F);                
%mean_F=sum(F);

end

