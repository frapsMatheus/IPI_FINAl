function [newpos, nits] = mspos(initimg, newimg, sig, h, initpos, oldpos, epsilon, maxits)
% Copyright 2003 by author.
% $Revision: 1.2$ $Date: Tue Nov 18 17:47:38 EST 2003$
[ix1,ix2] = inddisk(initimg,initpos,sig);
sig2 = 2*sig*sig; h2 = 2*h*h;
y = oldpos;
for k = 1:maxits,
    [jy1,jy2] = inddisk(newimg,y,sig);
    y0 = y; sumxyuv = 0.0; sumyxyuv = zeros(size(y));
    for i = 1:length(ix1),
        dx = initpos - [ix1(i) ix2(i)]; dx2 = dx*dx.';
        ui = initimg(ix2(i),ix1(i),:); ui = ui(:);
        for j = 1:length(jy1),
            jy = [jy1(j) jy2(j)];
            dy = y - jy; dy2 = dy*dy.';
            vj = newimg(jy2(j),jy1(j),:); vj = vj(:);
            duv = ui - vj; duv2 = duv.'*duv;
            wt = exp(-((dx2+dy2)/sig2 + duv2/h2));
            sumxyuv = sumxyuv + wt;
sumyxyuv = sumyxyuv + jy*wt;
end
end
y = sumyxyuv / sumxyuv;
if norm(y - y0) < epsilon, break; end
end
newpos = y;
nits = min(k,maxits);
return;
function [ix,iy] = inddisk(img,pos,h)
siz = size(img);
[XX,YY] = meshgrid(1:siz(1),1:siz(2));
[ix,iy] = find((XX-pos(2)).^2 + (YY-pos(1)).^2 < h^2);
return;