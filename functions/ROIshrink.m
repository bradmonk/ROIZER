function [BW,maskedImage] = ROIshrink(X,BW_MASK)

% % Create empty mask.
% BW = false(size(X,1),size(X,2));



% Auto clustering
sz = size(X);
im = single(reshape(X,sz(1)*sz(2),[]));
im = im - mean(im);
im = im ./ std(im);
s = rng;
rng('default');
L = kmeans(im,2,'Replicates',2);
rng(s);
BW = L == 2;
BW = reshape(BW,[sz(1) sz(2)]);

% Erode mask with disk
radius = 2;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imerode(BW, se);

% % Create masked image.
% maskedImage = X;
% maskedImage(~BW) = 0;



% Fill holes
BW = imfill(BW, 'holes');

% % Load Mask
% BW = BW_MASK;

% % Erode mask with disk
% radius = 3;
% decomposition = 0;
% se = strel('disk', radius, decomposition);
% BW = imerode(BW, se);

% Active contour
iterations = 20;
BW = activecontour(X, BW, iterations, 'Chan-Vese');

% Fill holes
BW = imfill(BW, 'holes');

% Dilate mask with disk
radius = 4;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imdilate(BW, se);

% Erode mask with disk
radius = 3;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imerode(BW, se);

% Active contour
iterations = 8;
BW = activecontour(X, BW, iterations, 'Chan-Vese');

% Create masked image.
maskedImage = X;
maskedImage(~BW) = 0;
end

