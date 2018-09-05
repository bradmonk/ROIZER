%###############################################################
%###############################################################
%                                                              |
%--                      ROIZER                               --
%                                                              |
%###############################################################
%###############################################################

P.home = pwd;
if ~any(regexp(P.home,'ROIZER') > 0)
disp(['Run this code from the ROIfinder directory; '...
'your current working directory is instead:'])
disp(P.home);
P.home='/Users/bradleymonk/Documents/MATLAB/GIT/ROIZER';
cd(P.home)
end
P.funs  = [P.home filesep 'datasets'];
P.data  = [P.home filesep 'functions'];
addpath(join(string(struct2cell(P)),':',1))





%###############################################################
%% SELECT A TIFF STACK AND GET INFO
%###############################################################

[PIX] = getIMpath();

clearvars -except PIX





%###############################################################
%% IMPORT TIFF STACK
%###############################################################


IMG = IMPORTimages(PIX);

clearvars -except PIX IMG




%###############################################################
%% PREPROCESS TIFF STACK
%###############################################################



[IMG, BND] = PREPROCESSimages(IMG);


% IMG = uint8(rescale(IMG).*255);

IMG = rescale(IMG);

viewstack(IMG,.05)


clearvars -except PIX IMG BND




%###############################################################
%%               ADJUST IMAGE CONTRAST
%###############################################################



% IMG = adjustContrast(IMG);
% 
% clearvars -except PIX IMG
% 
% imstats(IM_A)






%###############################################################
%%              SMOOTH IMAGE
%###############################################################


% IM = smoothIMG(IMG);

SMIM = imgaussfilt3(IMG, 2);

close all
imagesc(SMIM(:,:,1))
colormap hot
title('FIRST FRAME OF GAUSSIAN SMOOTHED IMAGE STACK')
pause(2)



clearvars -except PIX IMG SMIM





%###############################################################
%%                        RUN PCA
%###############################################################
clc;

SZ.r = size(IMG,1);
SZ.c = size(IMG,2);
SZ.z = size(IMG,3);

% FIRST RESHAPE IMAGE STACK INTO A SINGLE MATRIX
IM = reshape(IMG,  SZ.r*SZ.c,[]  );


% RUN PRINCIPAL COMPONENTS ANALYSIS
IM = single(IM);

[PC.coef,PC.score,~] = pca(IM');

[PC(2).coef,PC(2).score,~] = pca(IM);


% RESHAPE COEF BACK INTO A STACK
PC(1).imc = reshape( PC(1).coef , SZ.r , SZ.c , [] );
PC(1).imc = PC(1).imc(:,:,1:25); % GET THE FIRST 25 COMPONENTS

PC(2).ims = reshape( PC(2).score , SZ.r , SZ.c , [] );
PC(2).ims = PC(2).ims(:,1:25); % GET THE FIRST 25 COMPONENTS



plotIMG(IMG, PC(1).imc ,'PCA4')

clearvars -except PIX IMG SMIM PC




%###############################################################
%% VIEW FIRST 4 COMPONENTS AFTER GETTING ABSOLUTE VALUE OF MEAN DEVIATION
%###############################################################

I = PC(1).imc;

clear ABIM
for j=1:size(I,3)

    k=I(:,:,j);
    ABIM(:,:,j) = abs(I(:,:,j) - mean(k(:)));

end


plotIMG(IMG, ABIM ,'PCA4');
title('ABSOLUTE VALUE OF PCA MEAN DEVIATION')
cmappy(colormap('winter'));



pause(3);
clearvars -except PIX IMG SMIM PC ABIM




%###############################################################
%% PREVIEW THE FIRST 16 PRINCIPAL COMPONENTS (COEFFICIENT MATRIX)
%###############################################################



% plotIMG(IMG, PC(1).imc ,'PCA16');
% % cmappy(colormap('winter'));
% 
% pause(3);
% clearvars -except PIX IMG SMIM ROX PC ABIM




%###############################################################
%%      CHOOSE FROM FIRST 16 PRINCIPAL COMPONENTS
%###############################################################



close all

% pickPCs(PC(1).imc)

[AXE] = pickPCs(PC(1).imc);
AXE(1) = [];

disp('CHOSEN PCs:'); disp(AXE)

PCI = abs(PC(1).imc(:,:,AXE));

viewstack(rescale(PCI),1)


clearvars -except PIX IMG SMIM PC ABIM PCI




%###############################################################
%%      DISPLAY HISTOGRAM AND BG CUTOFF
%###############################################################


[THRESH] = imhist(IMG, PCI);

clearvars -except PIX IMG SMIM PC ABIM PCI





%###############################################################
%%      GET MEAN MAX PROJECTION OF RAW IMAGE
%###############################################################


maxI = zeros(size(IMG,1),size(IMG,2),2);

j=1;
for i = 1:10:(size(IMG,3)-10)

    maxI(:,:,j) = (max(IMG(:,:,i:(i+9)),[],3));

j=j+1;
end


IMAX = rescale(mean(maxI,3));



close all; imagesc(IMAX); colormap hot; 
title('AVERAGE MAX PIXEL INTENSITY OF RAW IMAGE STACK')
pause(2)



clearvars -except PIX IMG SMIM PC ABIM PCI IMAX




%###############################################################
%%      GET PIXEL VARIANCE OF RAW IMAGE STACK
%###############################################################


IMV = std(double(IMG),[],3);

close all; imagesc(IMV); colormap hot
title('AVERAGE PIXEL VARIANCE OF RAW IMAGE STACK')
pause(2)


clearvars -except PIX IMG SMIM PC ABIM PCI IMAX IMV





%###############################################################
%%      CREATE COMPOSITE IMAGE USING COMBINATION OF ABOVE
%###############################################################


disp('IMG');  imstats(IMG);     % RAW IMAGE STACK
disp('SMIM'); imstats(SMIM);    % GAUSSIAN SMOOTHED VERSION OF IMG
disp('IMAX'); imstats(IMAX);    % MEAN MAX PIXEL INTENSITY OF IMG
disp('ABIM'); imstats(ABIM);    % ABSOLUTE MEAN DEVIATION OF ALL PCs
disp('PCI');  imstats(PCI);     % CHOSEN PRINCIPAL COMPONENTS
disp('IMV');  imstats(IMV);     % STDEV OF EACH IMG PIXEL ALONG 3RD DIM


%############   PLOT ALL 6 COMPOSITE OPTIONS   ################
close all
fh01 = figure('Units','normalized','OuterPosition',[.01 .05 .95 .90],...
              'Color','w','MenuBar','none');
ax01 = axes('Position',[.02 .56 .3 .4],'Color','none'); axis off; hold on;
ax02 = axes('Position',[.35 .56 .3 .4],'Color','none'); axis off; hold on;
ax03 = axes('Position',[.67 .56 .3 .4],'Color','none'); axis off; hold on;
ax04 = axes('Position',[.02 .06 .3 .4],'Color','none'); axis off; hold on;
ax05 = axes('Position',[.35 .06 .3 .4],'Color','none'); axis off; hold on;
ax06 = axes('Position',[.67 .06 .3 .4],'Color','none'); axis off; hold on;

axes(ax01); imagesc(mean(IMG,3));  title('RAW IMAGE STACK');
axes(ax02); imagesc(mean(SMIM,3)); title('GAUSSIAN SMOOTHED VERSION OF IMG');
axes(ax03); imagesc(mean(IMAX,3)); title('MEAN MAX PIXEL INTENSITY OF IMG');
axes(ax04); imagesc(mean(ABIM,3)); title('ABSOLUTE MEAN DEVIATION OF ALL PCs');
axes(ax05); imagesc(mean(PCI,3));  title('CHOSEN PRINCIPAL COMPONENTS');
axes(ax06); imagesc(mean(IMV,3));  title('STDEV OF EACH IMG PIXEL ALONG 3RD DIM');

colormap hot
pause(2)





NIM.IMG  = rescale(IMG);
NIM.SMIM = rescale(SMIM);
NIM.IMAX = rescale(IMAX);
NIM.ABIM = rescale(ABIM);
NIM.PCI  = rescale(PCI);
NIM.IMV  = rescale(IMV);


disp('IMG');  imstats(NIM.IMG);     % RAW IMAGE STACK
disp('SMIM'); imstats(NIM.SMIM);    % GAUSSIAN SMOOTHED VERSION OF IMG
disp('IMAX'); imstats(NIM.IMAX);    % MEAN MAX PIXEL INTENSITY OF IMG
disp('ABIM'); imstats(NIM.ABIM);    % ABSOLUTE MEAN DEVIATION OF ALL PCs
disp('PCI');  imstats(NIM.PCI);     % CHOSEN PRINCIPAL COMPONENTS
disp('IMV');  imstats(NIM.IMV);     % STDEV OF EACH IMG PIXEL ALONG 3RD DIM


%############   PLOT ALL 6 COMPOSITE OPTIONS   ################
fh02 = figure('Units','normalized','OuterPosition',[.03 .07 .95 .90],...
              'Color','w','MenuBar','none');
ax11 = axes('Position',[.02 .56 .3 .4],'Color','none'); axis off; hold on;
ax12 = axes('Position',[.35 .56 .3 .4],'Color','none'); axis off; hold on;
ax13 = axes('Position',[.67 .56 .3 .4],'Color','none'); axis off; hold on;
ax14 = axes('Position',[.02 .06 .3 .4],'Color','none'); axis off; hold on;
ax15 = axes('Position',[.35 .06 .3 .4],'Color','none'); axis off; hold on;
ax16 = axes('Position',[.67 .06 .3 .4],'Color','none'); axis off; hold on;

axes(ax11); imagesc(mean(NIM.IMG,3));  title('RAW IMAGE STACK');
axes(ax12); imagesc(mean(NIM.SMIM,3)); title('GAUSSIAN SMOOTHED VERSION OF IMG');
axes(ax13); imagesc(mean(NIM.IMAX,3)); title('MEAN MAX PIXEL INTENSITY OF IMG');
axes(ax14); imagesc(mean(NIM.ABIM,3)); title('ABSOLUTE MEAN DEVIATION OF ALL PCs');
axes(ax15); imagesc(mean(NIM.PCI,3));  title('CHOSEN PRINCIPAL COMPONENTS');
axes(ax16); imagesc(mean(NIM.IMV,3));  title('STDEV OF EACH IMG PIXEL ALONG 3RD DIM');

colormap hot
pause(2)





MAGE = NIM.IMG(:,:,1);
MAGE(:,:,1) = rescale(mean(NIM.IMG,3));
MAGE(:,:,2) = rescale(mean(NIM.SMIM,3));
MAGE(:,:,3) = rescale(mean(NIM.IMAX,3));
MAGE(:,:,4) = rescale(mean(NIM.ABIM,3));
MAGE(:,:,5) = rescale(mean(NIM.PCI,3));
MAGE(:,:,6) = rescale(mean(NIM.IMV,3));



MAGE(:,:,1) = rescale(MAGE(:,:,1).^2)./20;
MAGE(:,:,2) = rescale(MAGE(:,:,2).^2)./20;
MAGE(:,:,3) = rescale(MAGE(:,:,3).^2)./20;

MAGE(:,:,4) = rescale(MAGE(:,:,4).^2);
MAGE(:,:,5) = rescale(MAGE(:,:,5).^2);
MAGE(:,:,6) = rescale(MAGE(:,:,6).^2);


PIC = rescale(mean(MAGE(:,:,[1 2 3 4 5 6]),3));


% ################   SINGLE AXIS ABSOLUTE LOCATION   ################
close all
fh03 = figure('Units','pixels','Position',[100 35 800 750],...
    'Color','w','MenuBar','none');
ax31 = axes('Position',[.06 .06 .9 .9],'Color','none');


imagesc(PIC);
colormap hot
title('COMPOSITE IMAGE FOR AUTOMATED IMAGE SEGENTATION');



clearvars -except PIX IMG SMIM PC ABIM PCI IMAX IMV NIM MAGE PIC






%########################################################################
%%          HAND-SELECT SOME ROIs AND BACKGROUND
%########################################################################


ROX = clickROI(PIC);

clearvars -except PIX IMG SMIM PC ABIM PCI IMAX IMV NIM MAGE PIC ROX



nROI = size(ROX.mask,2);
IM = {};

for i = 1:nROI

    msk = ROX.mask{i};

    IM{i} = IMG .* msk;

end


ROIM = zeros(size(IM{1}));
for i = 1:nROI

    ROIM = ROIM + IM{i};

end

viewstack(ROIM,.05)


% GET MEAN ACTIVITY IN EACH ROI
%--------------------------------------------------------

MUJ=[];
for i = 1:nROI

    msk = ROX.mask{i};

    for j = 1:size(IMG,3)

        IMJ = IMG(:,:,j);

        MUJ(i,j) = mean(IMJ(msk));
    end
end

ROIS = MUJ';

minROI = min(ROIS);

ROIS = ROIS - minROI;

ROIS = rescale(ROIS);



%  PLOT MEAN ACTIVITY IN EACH ROI
%--------------------------------------------------------
clc; close all;
fh1 = figure('Units','pixels','Position',[10 35 1300 500],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none');
ax1.YLim = [0 1]; hold on

ph = plot(ROIS(:,1:3),'k','LineWidth',3);
pause(1)

for i = 4:size(ROIS,2)

    ph(1).YData = ph(2).YData;
    ph(2).YData = ph(3).YData;
    ph(3).YData = ROIS(:,i);
    ax1.YLim = [0 1];
    pause(.6)

end


ph = plot(ROIS,'LineWidth',3);


