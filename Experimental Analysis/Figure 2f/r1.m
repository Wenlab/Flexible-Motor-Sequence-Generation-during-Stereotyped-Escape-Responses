function [ output ] = r1( k,xdata )
output = zeros(1,length(xdata));
for i = 1:length(xdata)
    output(i) = k(1) * integral(@(theta)1./erfi( ( k(2)+k(3).*exp(-xdata(i)./k(4)) ) ./ cos(theta) ),0,pi/4);
end

