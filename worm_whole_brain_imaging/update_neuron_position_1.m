function post_position = update_neuron_position(img,pre_position,radius,threshold)
%track neuronal position
[height,width]=size(img);
            
ymin=max(round(pre_position(2)-radius),1);
ymax=min(round(pre_position(2)+radius),height);
xmin=max(round(pre_position(1)-radius),1);
xmax=min(round(pre_position(1)+radius),width);
h = fspecial('gaussian',[3,3],3);  
c_filtered=imfilter(img(ymin:ymax,xmin:xmax),h);
%threshold and find the local maxima
bw = imextendedmax(c_filtered,threshold); 
L=logical(bw);
s=regionprops(L,'Centroid');
%putative neuronal positions
Centroids=cat(1,s.Centroid);
[~,idx]=min(sum((Centroids-repmat(pre_position-[xmin,ymin],size(Centroids,1),1)).^2,2));
post_position=Centroids(idx,:)+[xmin,ymin]; %update neuron positions


end

