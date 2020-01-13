function centroids=find_centers_of_neurons_automatically(I,threshold,minArea)
% this function can automatically find all bright enough neural centers in 2D
% grayscale image.
% The recommand value for W1 worm(whole brain imaging) is "threshold = 200, minArea = 200"

% The main drawback of this function is that the darker neurons cannot be
% labeled if they are very near to some brighter ones. ( related function:
% imregionalmax) 
% Solution I guess: 1. Maybe we can remove bright neurons and then find
% local maximum again and again. (maybe you should use characteristic element to enhance image after remove the maximum in the first time)
%% Threshold filter
indices = I<threshold;
I(indices)=0;

%% convert to gradient image
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);

% figure
% imshow(gradmag,[]), title('Gradient magnitude (gradmag)');

%% remove small spots in image
BW = gradmag>0;
BW2 = bwareaopen(BW,minArea); % use 200 to remove small spot.
indices = (BW2 == 0);
gradmag(indices) = 0;
indices = (gradmag==0);
I(indices)=0;
%% use characteristic element enhance the foreground
se = strel('disk', 5); % the radius 5 is an empirical parameters.
Io = imopen(I, se);

% figure
% imshow(Io,[]), title('Opening (Io)');

%% find local maxima
fgm = imregionalmax(Io); % this function can be GPU accelerated
% figure;
% imshow(fgm,[]), title('Regional maxima of opening-closing by reconstruction (fgm)');

%% find centroids
if(~isempty(find(Io,1)))
s = regionprops(fgm,'centroid');
centroids = cat(1, s.Centroid);
else
    centroids = [];
end
%% find remain centroids iteratively
while(~isempty(find(Io,1)))
    indices = (fgm == 1);
    Io(indices) = 0; % remove the local maxima regions in the first time.
    Io = imopen(Io, se); % remove ugly boundrys in the image and leave disk-like regions in the image
    if(Io==0)
        break;
    end
    fgm = imregionalmax(Io); 
    s = regionprops(fgm,'centroid');
    centroids = cat(1,centroids, s.Centroid);
end
%% plot centroids on the binary image.
% figure;
% imshow(fgm,[]);
% hold on
% plot(centroids(:,1),centroids(:,2), 'b*')
% hold off
