function [IMG, BND] = PREPROCESSimages(IMG)


% Get Dims (rows, cols, frames)
[SZ.r, SZ.c, SZ.f]= size(IMG);


% Check high-low bounds of pixel data
[BND.prehi,BND.prelo] = bounds(IMG(:));


% Attenuate outliers
q = quantile(IMG(:),[.001 .999]);
IMG(IMG < q(1)) = q(1);
IMG(IMG > q(2)) = q(2);


% Recheck high-low bounds of pixel data
[BND.qhi,BND.qlo] = bounds(IMG(:));


% Make sure the image data is scaled from 0:255 (legend one-liner!)
IMG = uint8(rescale(IMG).*255);


% Recheck high-low bounds of pixel data
[BND.posthi,BND.postlo] = bounds(IMG(:));



% Display pixel value updates and stack size
s1=sprintf('Pixel value range of original image:    %.f  -  %.f \n' ,...
    [BND.prehi,BND.prelo]); 
s2=sprintf('Pixel range after quantile mitigation:  %.f  -  %.f \n' ,...
    [BND.qhi,BND.qlo]); 
s3=sprintf('Pixel range after rescale to 255 uint8: %.f  -  %.f '   ,...
    [BND.posthi,BND.postlo]); 
disp(s1); disp(s2); disp(s3); 
bytesize(IMG)





end