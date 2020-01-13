function c_mask=circle_mask_2D(ix,iy,cx,cy,r) 
[x,y]=meshgrid(-(cx-1):(ix-cx),-(cy-1):(iy-cy)); 
c_mask=((x.^2+y.^2)<=r^2);
