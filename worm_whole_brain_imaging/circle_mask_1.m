function mask=circle_mask(ix,iy,iz,cx,cy,cz,r) 
[x,y]=meshgrid(-(cx-1):(ix-cx),-(cy-1):(iy-cy)); 
c_mask=((x.^2+y.^2)<=r^2);

mask=false(ix,iy,iz);

mask(:,:,max(1,cz-1))=c_mask;
mask(:,:,cz)=c_mask;
mask(:,:,min(iz,cz+1))=c_mask;