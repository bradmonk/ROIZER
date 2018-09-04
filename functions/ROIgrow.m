function [BW,maskedImage] = ROIgrow(X,BW_MASK)

% Load Mask
BW = BW_MASK;

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

% Active contour
iterations = 8;
BW = activecontour(X, BW, iterations, 'Chan-Vese');

% Create masked image.
maskedImage = X;
maskedImage(~BW) = 0;
end

