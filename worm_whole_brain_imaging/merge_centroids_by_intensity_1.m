function finalCentroids=merge_centroids_by_intensity(centroidsInOneVolume,imageOfOneVolume)
    
    radius = 5; % the radius of characteristic element in function "find_centers_of_neurons_automatically"
    numSlice = size(imageOfOneVolume,3);
    
    for z=1:numSlice-1
        referenceImage = imageOfOneVolume(:,:,z);
        compareImage = imageOfOneVolume(:,:,z+1);
        
        referenceCentroids = centroidsInOneVolume{z,1}; % abbreviation RC
        compareCentroids = centroidsInOneVolume{z+1,1}; % abbreviation CC
        
        indicesInRCtoCancel = [];
        indicesInCCtoCancel = [];
        for i=1:size(referenceCentroids,1) % the number of rows
            for j=1:size(compareCentroids,1)
                if(norm(referenceCentroids(i,:)-compareCentroids(j,:))<radius)
                    doesReferenceWin = compareIntensity(referenceImage,compareImage,referenceCentroids(i,:),compareCentroids(j,:));
                    if(doesReferenceWin)
                        indicesInCCtoCancel = [indicesInCCtoCancel,j];
                    else
                        indicesInRCtoCancel = [indicesInRCtoCancel,i];
                    end
                end
                
            end
        end
        
        centroidsInOneVolume{z,1}(indicesInRCtoCancel,:)=[];
        centroidsInOneVolume{z+1,1}(indicesInCCtoCancel,:)=[];
    end
    finalCentroids = centroidsInOneVolume;
end

function doesReferenceWin = compareIntensity(referenceImage,compareImage,pointInReference,pointInCompare)
    localRange = 3; % quantify the local range of centroids. And 3 is an empirical number
    
    xMin = max(1,floor(pointInReference(1)-localRange)); xMax = min(size(referenceImage,2),floor(pointInReference(1)+localRange)); % check if out of dimension
    yMin = max(1,floor(pointInReference(2)-localRange)); yMax = min(size(referenceImage,1),floor(pointInReference(2)+localRange)); % check if out of dimension
    referenceLocalMatrix = referenceImage(yMin:yMax,xMin:xMax);
    referenceLocalMean = mean(referenceLocalMatrix(:));
    
    xMin = max(1,floor(pointInCompare(1)-localRange)); xMax = min(size(compareImage,2),floor(pointInCompare(1)+localRange)); % check if out of dimension
    yMin = max(1,floor(pointInCompare(2)-localRange)); yMax = min(size(compareImage,1),floor(pointInCompare(2)+localRange)); % check if out of dimension
    compareLocalMatrix = compareImage(yMin:yMax,xMin:xMax);
    compareLocalMean = mean(compareLocalMatrix(:));
    
    if(referenceLocalMean > compareLocalMean)
        doesReferenceWin = 1;
    else
        doesReferenceWin = 0;
    end
    
    
end