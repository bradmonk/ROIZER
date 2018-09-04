function [] = viewstack(IMG,varargin)

if nargin == 2
    dt = varargin{1};
    qt = [.0001 .9999];
elseif nargin == 3
    dt = varargin{1};
    qt = varargin{2};
    if isempty(dt)
        dt = .02;
    end
else
    dt = .02;
    qt = [.0001 .9999];
end

I = IMG;
q = quantile(I(:),qt);

close all; figure; a=axes;

p = imagesc(I(:,:,1));   a.CLim=q;

for i = 1:size(I,3)
    p.CData = I(:,:,i);  pause(dt)
end
