function img_roi = ROI_image(img,rect)
%choose an image with region of interest
xmin=round(rect(1));
ymin=round(rect(2));
xmax=round(rect(1)+rect(3)-1);
ymax=round(rect(2)+rect(4)-1);

img_roi=img(ymin:ymax,xmin:xmax);

h=fspecial('gaussian',[3,3]);
img_roi=imfilter(img_roi,h);


end

