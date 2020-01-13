function centroids = find_candidate_neuron_center_in_one_volume(img_stack,threshold,minArea,shift)

centroids=zeros(3,1000);
numSlice = size(img_stack,3);
candidate_centroids=cell(numSlice,1);
for j=1:numSlice
    candidate_centroids{j,1}=find_centers_of_neurons_automatically(img_stack(:,:,j),threshold,minArea);
end

final_Centroids=merge_centroids_by_intensity(candidate_centroids,img_stack);
k=1;
for j=1:numSlice
    
       
    for i=1:size(final_Centroids{j,1},1)
        
        centroids(1,k)=final_Centroids{j,1}(i,1)+shift(1)-1;
        centroids(2,k)=final_Centroids{j,1}(i,2)+shift(2)-1;
        centroids(3,k)=j;
        k=k+1;
    end
end

if k<1000
    
    centroids(:,k:end)=[];
    
end


 
 

