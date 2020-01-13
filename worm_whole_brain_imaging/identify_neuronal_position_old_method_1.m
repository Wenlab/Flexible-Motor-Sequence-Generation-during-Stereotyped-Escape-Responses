function registed_centers = identify_neuronal_position_old_method(imgStack,ROIposition,centroids_pre,threshold)

N=size(centroids_pre,2);
registed_centers=zeros(2,N);

[height,width]=size(imgStack);
idx_num=size(centroids_pre,2);
for i=1:height
    for j=1:width
        if ~(i>=ROIposition(2)&&i<=(ROIposition(2)+ROIposition(4))&&j>=ROIposition(1)&&j<=(ROIposition(1)+ROIposition(3)))
            imgStack(i,j) = 0;
        end
    end
end

if ~isempty(idx_num)
    
    h = fspecial('gaussian',[3,3],3);
    c_filtered=imfilter(imgStack,h);
    %threshold and find the local maxima
    bw = imextendedmax(c_filtered,threshold);
    L=logical(bw);
    s=regionprops(L,'Centroid');
    %putative neuronal positions
    centroids=cat(1,s.Centroid);
    centroids=centroids';
    for k=1:idx_num
        if centroids_pre(1,k)
            [~,idx]=min(sum((centroids-repmat(centroids_pre(:,k),1,size(centroids,2))).^2,1));
            registed_centers(:,k)=centroids(:,idx); %update neuron positions
            
        else
            registed_centers(:,k)=0;
        end
    end
end

