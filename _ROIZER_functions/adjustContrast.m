function [IMG] = adjustContrast(IMG)


clc; close all
fh1 = figure('Units','pixels','Position',[10 50 750 700],'Color','w');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none','YDir','reverse',...
'PlotBoxAspectRatio',[1 1 1],'XColor','none','YColor','none'); hold on
hold on



I = IMG(:,:,1);
idisp(I)
J = stretchlim(I,[.01 .99]);
I = imadjust(I,J);
idisp(I)

ph1 = imagesc(ax1,I);
axis tight; colormap bone

% htool = imcontrast(gcf,'CloseRequestFcn',@contrastclosereq);
% htool.Position = [690 40 700 250];
% uiwait(htool)
% % [ih,HAx,HIm] = openim(IMG);



end