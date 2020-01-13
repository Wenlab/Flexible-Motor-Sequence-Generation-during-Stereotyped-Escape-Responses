function centroids = compare_centroids(transformed_centroids, candidate_centroids)
%Compare the transformed neuronal center with the candidate centered
%determined by local intensity maximum calculation

N=size(transformed_centroids,2);
M=size(candidate_centroids,2);
centroids=transformed_centroids;

w=12;
%return;

for j=1:N
    
    ps=transformed_centroids(:,j);
    
    square_difference=(candidate_centroids-repmat(ps,1,M)).^2;
    
    square_difference(3,:)=w^2*square_difference(3,:);
    
    
    
    
    [minvalue,id]=min(sqrt(sum(square_difference,1)));
    
    if minvalue<20
        centroids(:,j)=candidate_centroids(:,id);
        candidate_centroids(:,id)=[];
        M=M-1;
    end
        

end

