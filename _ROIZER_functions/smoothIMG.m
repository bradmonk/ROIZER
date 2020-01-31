function [IM] = smoothIMG(IMG)


idisp(IMG)

IM = imgaussfilt3(IMG, 2);

clc; close all
fh1 = figure('Units','pixels','OuterPosition',[5 45 1400 750],'Color','w');

ax1 = axes('Units','pixels','Position',[5 5 650 700],'Color','none',...
        'YDir','reverse','PlotBoxAspectRatio',[1 1 1],...
        'XColor','none','YColor','none'); hold on

ax2 = axes('Units','pixels','Position',[705 5 650 700],'Color','none',...
        'YDir','reverse','PlotBoxAspectRatio',[1 1 1],...
        'XColor','none','YColor','none'); hold on

axes(ax1)
ph1 = imagesc(ax1,IMG(:,:,1));
axis tight; colormap bone; pause(.1)

axes(ax2)
ph2 = imagesc(ax2,IM(:,:,1));
axis tight; colormap bone; pause(.1)

idisp(IMG)
idisp(IM)




end



% ###############################################################
%%           SMOOTHING IMAGES THE HARD WAY
% ###############################################################
%{

I = PC(1).imc;

clear IM
for j=1:size(I,3)

    k=I(:,:,j);
    IM(:,:,j) = abs(I(:,:,j) - mean(k(:)));

end


%getkernel(peakHight (.5), maskSize (9), slopeSD (.2), res (.1), doPlot (1))

Mask = getkernel(.1, 5, .11, .1, 1);
close all; surf(Mask); 

SIM = convn( IM, Mask,'same');

close all; figure
subplot(1,2,1); imagesc(IM(:,:,1))
subplot(1,2,2); imagesc(SIM(:,:,1))



SIM = convn( IM, Mask,'same');

mean(SIM(:))
mean(IM(:))

close all; imagesc(SIM(:,:,1))



I = SIM(:,:,1:8);
I = mean(I,3);


close all; figure('Position',[10 10 900 800]); ax=axes;
q = quantile(I(:),[.001 .999]);
imagesc(I);  cmappy(colormap(winter)); ax.CLim=q; axis tight off;
pause(1)

% clc; close all;
clearvars -except ROX PIX IMG BND SZ PC SIM

%}

