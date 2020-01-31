function [THRESH] = imhisto(IMG, PC)



IM = PC;

I = IM;
I = mean(I,3);
% I = IM(:,:,1);

q = quantile(I(:),[.05 .95]);

THRESH = q(2);



clc; close all
fh1 = figure('Units','pixels','OuterPosition',[5 45 1400 750],'Color','w');

ax1 = axes('Units','pixels','Position',[49 49 650 600],'Color','none'); hold on

ax2 = axes('Units','pixels','Position',[705 49 650 600],'Color','none',...
        'YDir','reverse','PlotBoxAspectRatio',[1 1 1],...
        'XColor','none','YColor','none'); hold on



axes(ax1)
ph1 = histogram(I(:)); hold on
line([q(2) q(2)],[ax1.YLim(1) ax1.YLim(2)])
pause(1)


IM(IM<q(2)) = 0;
IM = rescale(IM,-.02,1);
IM(IM<q(2)) = 0;

I = IM;
I = mean(I,3);
q = quantile(I(:),[.001 .999]);

axes(ax2)
ph2 = imagesc(ax2,I);
ax2.CLim=q; axis tight off;
colormap bone; pause(.1)



end