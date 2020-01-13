function registed_centers = identify_neuronal_position(imgStack,ROI, imgStack_pre,ROI_pre,centroids)

threshold = 150; % parameter to use in function find_centers_of_neurons_automatically
minArea = 150; % parameter to use in function find_centers_of_neurons_automatically

N=size(centroids,2);
registed_centers=zeros(2,N);
j=1;
    
if isempty(ROI{j})|| isempty(ROI_pre{j})

    disp('registration error: cannot identify the region of interest!');

    return;
end

idx_j=find((round(centroids(1,:))>=0)); 

if ~isempty(idx_j)



    moving=ROI_image(imgStack_pre(:,:),ROI_pre{j});

    fixed=ROI_image(imgStack(:,:),ROI{j});

    tformEstimate=imregcorr(moving,fixed);

    [optimizer, metric] = imregconfig('monomodal');
    optimizer.MaximumIterations=200;
    if isRigid(tformEstimate)
        tform = imregtform(moving,fixed,'rigid',optimizer,metric,'InitialTransformation',tformEstimate);
    else
        tform = imregtform(moving,fixed,'affine',optimizer,metric,'InitialTransformation',tformEstimate);
    end

    T1=maketform('affine',double(tform.T));

    shift=ROI_pre{j}(1:2); % Is the ROI different from two volume ? 
    shift_new=ROI{j}(1:2);
      
    % find candidate centers in the current image(2D)
    candidateCenters = find_centers_of_neurons_automatically(fixed,threshold,minArea);

    u=centroids(1,idx_j)-shift(1)+1;
    v=centroids(2,idx_j)-shift(2)+1;
    u=u'; v=v';
    [u_new,v_new]=tformfwd(T1,u,v);
    C_new = [u_new,v_new];
    centers=revise_image_registration_neural_position(C_new,candidateCenters);
    registed_centers(1,idx_j)=centers(:,1)'+shift_new(1)-1;
    registed_centers(2,idx_j)=centers(:,2)'+shift_new(2)-1;
    %{    
    %candidateCenters = find_centers_of_neurons_automatically(fixed,threshold,minArea);

    u=centroids(1,idx_j)-shift(1)+1;
    v=centroids(2,idx_j)-shift(2)+1;
    u=u'; v=v';
    [u_new,v_new]=tformfwd(T1,u,v);
    C_new = [u_new,v_new];
    %centers=revise_image_registration_neural_position(C_new,candidateCenters);
    registed_centers(1,idx_j)=C_new(:,1)'+shift_new(1)-1;
    registed_centers(2,idx_j)=C_new(:,2)'+shift_new(2)-1;
    %}
end








    


