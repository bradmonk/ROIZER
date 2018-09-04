%###############################################################
%--                      ROIzer                               --
%###############################################################

close all; clear; clc; rng('shuffle');
P.home  = pwd;
P = ROIZERstartup(P);
clearvars -except P




%% SELECT A TIFF STACK AND GET INFO
%###############################################################

[PIX] = ROIZERgetimages();

clearvars -except PIX






%% IMPORT TIFF STACK
%###############################################################


IMG = IMPORTimages(PIX);

clearvars -except PIX IMG





%% PREPROCESS TIFF STACK
%###############################################################



[IMG, BND] = PREPROCESSimages(IMG);

viewstack(IMG,.05)


clearvars -except PIX IMG BND





%%               ADJUST IMAGE CONTRAST
%###############################################################



% IMG = adjustContrast(IMG);
% 
% clearvars -except PIX IMG
% 
% imstats(IM_A)







%%              SMOOTH IMAGE
%###############################################################


% IM = smoothIMG(IMG);

% IM = imgaussfilt3(IMG, 2);

clearvars -except PIX IMG







%%          HAND-SELECT SOME ROIs AND BACKGROUND
%###############################################################




ROX = clickROI(IMG);

clearvars -except PIX IMG BND




% ###############################################################
%%                        RUN PCA
% ###############################################################
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

clearvars -except ROX PIX IMG BND PC





%% VIEW FIRST 4 COMPONENTS AFTER GETTING ABSOLUTE VALUE OF MEAN DEVIATION

I = PC(1).imc;

clear IM
for j=1:size(I,3)

    k=I(:,:,j);
    IM(:,:,j) = abs(I(:,:,j) - mean(k(:)));

end


plotIMG(IMG, IM ,'PCA4');
cmappy(colormap('winter'));



pause(3);
clearvars -except ROX PIX IMG PC





%% PREVIEW THE FIRST 16 PRINCIPAL COMPONENTS (COEFFICIENT MATRIX)



plotIMG(IMG, PC(1).imc ,'PCA16');
% cmappy(colormap('winter'));



pause(3);
clc;clearvars -except ROX PIX IMG PC




% ###############################################################
%%      DISPLAY HISTOGRAM AND CHOOSE BG VALUE
% ###############################################################


[THRESH] = imhist(IMG, PC);

clc;clearvars -except ROX PIX IMG PC





% ###############################################################
%%      GET MEAN MAX PROJECTION IMAGE
% ###############################################################


maxI = zeros(size(IMG,1),size(IMG,2),2);

j=1;
for i = 1:10:(size(IMG,3)-10)

    maxI(:,:,j) = (max(IMG(:,:,i:(i+9)),[],3));

j=j+1;
end


IMS.IMAX = mean(maxI,3);


close all
imagesc(IMS.IMAX)


clc;clearvars -except ROX PIX IMG PC IMS












%########################################################################
%% imageSegmenter(X) & imageRegionAnalyzer(I)
%########################################################################



% imageSegmenter(X)
% imageRegionAnalyzer(X)


%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
for jj=1:16
% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%%


% GET ABSOLUTE VALUE OF PCA DATA AND NORMALIZE TO RANGE [0,1].
%--------------------------------------------------------

% PIX = abs(PC(1).imc(:,:,jj));
PIX = PC(1).imc(:,:,jj);

% PIX = rescale(PIX);





close all
imagesc(PIX)

% clc;clearvars -except ROX jj PIX IMG PC IMS PIX



% VARIABLE CONVENTIONS
%--------------------------------------------------------
% PIX    : ORIGINAL IMAGE (PRINCIPAL COMPONENT RAW VALUES)
% BW     : BLACK-AND-WHITE IMAGE MASK
% XBW    : PIX .* BW
% BWMASK : PERSISTENT FORM OF BW
% IMFO   : IMAGE INFO STATS & PROPERTIES
%--------------------------------------------------------









% DISPLAY RAW PCA IMAGE
%--------------------------------------------------------
close all; figure; a=axes;
p = imagesc(PIX);
p.CData=PIX;
pause(.1)


plotIMG(PIX,'CData',p)




% PERFORM IMAGE SEGMENTATION USING A BAG OF TRICKS
%--------------------------------------------------------
%{.


% Threshold image - adaptive threshold
BW = imbinarize(PIX, 'adaptive', 'Sensitivity', 0.5,...
                'ForegroundPolarity', 'bright');
p.CData=BW; pause(.1)

mu = mean(BW(:)); disp(mu);

%---------------TOO MUCH BACKGROUND
if mu > .03
%     f = fliplr(linspace(.5,0,10000));
    f = 0:.001:.5;
    for s = 1:numel(f)

        fs = .5 - f(s);

        BW = imbinarize(PIX, 'adaptive', 'Sensitivity',fs,...
        'ForegroundPolarity', 'bright');

        p.CData=BW; pause(.02)

        mu = mean(BW(:));
        if mu < .03; break; end
    end
end
disp(mu);
disp('done')



%---------------NOT ENOUGH SIGNAL
if mu < .001
%     f = fliplr(linspace(.5,0,10000));
    f = 0:.001:.5;
    for s = 1:numel(f)

        fs = .5 + f(s);

        BW = imbinarize(PIX, 'adaptive', 'Sensitivity',fs,...
        'ForegroundPolarity', 'bright');

        p.CData=BW; pause(.02)

        mu = mean(BW(:));
        if mu > .02; break; end
    end
end
disp(mu);
disp('done')








%
% Close mask with disk
BW = imclearborder(BW);
radius = 2;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imclose(BW, se);
p.CData=BW;
pause(.1)



% Erode mask with line
BW = imclearborder(BW);
length = 2;
angle = 0;
se = strel('line', length, angle);
BW = imerode(BW, se);
p.CData=BW;
pause(.1)



% Dilate mask with disk
BW = imclearborder(BW);
radius = 2;
decomposition = 6;
se = strel('disk', radius, decomposition);
BW = imdilate(BW, se);
p.CData=BW;
pause(.1)



% Active contour
BW = imclearborder(BW);
iterations = 3;
BW = activecontour(PIX, BW, iterations, 'Chan-Vese');
p.CData=BW;
pause(.1)


% % Fill holes
% BW = imclearborder(BW);
% BW = imfill(BW, 'holes');
% BW = imclearborder(BW);
% p.CData=BW;
% pause(.1)



% Open mask with disk
BW = imclearborder(BW);
radius = 2;
decomposition = 6;
se = strel('disk', radius, decomposition);
BW = imopen(BW, se);
p.CData=BW;
pause(.1)



% Dilate mask with disk
BW = imclearborder(BW);
radius = 1;
decomposition = 6;
se = strel('disk', radius, decomposition);
BW = imdilate(BW, se);
p.CData=BW;
pause(.1)




% CREATE MASK FOR IMAGE
%--------------------------------------------------------

XBW = PIX;
XBW(~BW) = 0;

BWMASK = BW;


p.CData=XBW;
pause(.1)


%}


% GET REGION PROPERTIES & STATISTICS
%--------------------------------------------------------

IMFO.stats = regionprops(BWMASK);

% [IMFO.bi,IMFO.labs,IMFO.n,IMFO.a] = bwboundaries(BWMASK,'noholes');


clc;clearvars -except ROX jj PIX IMG PC IMS PIX ROIS SIM IMS XBW IMFO BWMASK




% PULL OUT SOME STATS SO WE CAN DETERMINE IF ANYTHING
% NEEDS TO BE REMOVED OR RESHAPED
%--------------------------------------------------------
Area = [IMFO.stats.Area]';

c=[IMFO.stats.Centroid]; 
cx = c(1:2:end);
cy = c(2:2:end);
Centroid = [cx',cy'];

b = [IMFO.stats.BoundingBox];
br = b(1:4:end);
bc = b(2:4:end);
bw = b(3:4:end);
bh = b(4:4:end);
BBox = [bw',bh' (bw./bh)' (bh./bw)'];
%--------------





% ESTABLISH FILTERING PARAMETERS
%--------------------------------------------------------
AREA_FILTER = [20 , 400];      % MIN AND MAX ROI AREA

BOX_FILTER  = [5 5 1/4 1/4];   % MIN BOX WIDTH, MAX RATIO OF W/H & H/W





% DETERMINE IF MORPHOLOGY STATS MEET FILTER CRITERIA
%--------------------------------------------------------

TOO.SMALL = AREA_FILTER(1) > Area;

TOO.BIG   = AREA_FILTER(2) < Area;

TOO.BOXY  = sum((BBox < BOX_FILTER),2);


FAIL = TOO.SMALL | TOO.BIG | TOO.BOXY;
F = find(FAIL);


% FAIL(2) = 1;
% FAIL(5) = 1;



% UPDATE STATS FOR THINGS THAT DON'T MEET CRITERIA (REMOVE THEM)
%--------------------------------------------------------
%{
BIM.bi(FAIL) = [];
BIM.n = BIM.n - numel(F);
BIM.a = [];

for ff = 1:numel(F)
    z = BIM.labs == F(ff);

    BIM.labs(z) = 0;

%     r=BIM.Lrgb(:,:,1); r(z) = 128;
%     g=BIM.Lrgb(:,:,2); g(z) = 128;
%     b=BIM.Lrgb(:,:,3); b(z) = 128;
%     BIM.Lrgb(:,:,1) = r;
%     BIM.Lrgb(:,:,2) = g;
%     BIM.Lrgb(:,:,2) = b;
end

BIM.stats(FAIL) = [];
%}



% UPDATE ROI MORPHOLOGIES
%--------------------------------------------------------
%{
% needsToGrow   = 1;
% needsToShrink = 1;
% 
% if needsToGrow == 1
%     [BW,maskedImage] = ROIgrow(IMG,BW);
% end
% 
% if needsToShrink == 1
%     [BW,maskedImage] = ROIshrink(IMG,BW);
% end
%}



% ASCERTAIN THAT EXPECTAIONS MATCH REALITY
%--------------------------------------------------------


nMinExpectedROIs = 5;  % <<<<<<<<<<<< USER SHOULD ENTER THIS <<<<<<<<<<<<

nMaxExpectedROIs = 20; % <<<<<<<<<<<< USER SHOULD ENTER THIS <<<<<<<<<<<<


nROIs = numel(Area);   
fprintf('Total ROI count (first-pass): %0.f \n\n',nROIs)


nSmall = sum(TOO.SMALL);
fprintf('Number of ROIs below threshold (first-pass): %0.f \n\n',nSmall)


nBig   = sum(TOO.BIG);
fprintf('Number of ROIs above threshold (first-pass): %0.f \n\n',nBig)






% IF FEW ROIS PASS EXAMINATION, BUT THERE ARE MANY 'TOO-SMALL' ROIs
% WE CAN TRY TO FIX THAT USING ROI DILATION
%--------------------------------------------------------
% imageSegmenter
if (nROIs < nMinExpectedROIs) && (nSmall > 1)
disp('MAKING FIXES!')

    BW = activecontour(PIX, BWMASK, 20, 'Chan-Vese');  % ACTIVE CONTOUR
    BW = imfill(BW, 'holes');                        % FILL HOLES

    se = strel('disk', 4, 0);                        % DIALATE WITH DISK
    BW = imdilate(BW, se);

    BW = activecontour(PIX, BW, 8, 'Chan-Vese');       % ACTIVE CONTOUR

    % Create masked image.
    XBW = PIX;
    XBW(~BW) = 0;


p.CData = BW;  pause(.5)
p.CData = XBW; pause(2)
disp('done with fixes...')
end







% IF FEW ROIS PASS EXAMINATION, BUT THERE ARE MANY 'TOO-BIG' ROIs
% WE CAN TRY TO FIX THAT USING ROI EROSION
%--------------------------------------------------------
% imageSegmenter
if (nROIs > nMaxExpectedROIs) && (nBig > 1)
disp('MAKING FIXES!')


    BW = activecontour(PIX, BWMASK, 20, 'Chan-Vese');  % ACTIVE CONTOUR
    BW = imfill(BW, 'holes');                        % FILL HOLES
    pause(.02)

    % Erode mask with line
    BW = imclearborder(BW);
    se = strel('line', 2, 0);
    BW = imerode(BW, se);
    p.CData=BW;
    pause(.02)

   
    BW = activecontour(PIX, BW, 8, 'Chan-Vese');       % ACTIVE CONTOUR


    % smooth image
    B = imgaussfilt3(double(BW), 2);

%     imstats(B)



    % Close mask with disk
    BW = imclearborder(BW);
    radius = 3;
    decomposition = 0;
    se = strel('disk', radius, decomposition);
    BW = imclose(BW, se);
    p = imagesc(BW);
    pause(.05)

    % Create masked image.
    XBW = PIX;
    XBW(~BW) = 0;


p.CData = BW;   pause(.5)
p.CData = XBW;  pause(.5)

imagesc(XBW); pause(2)

disp('done with fixes...')
end




%--------------------------------------------------------










% AGAIN GET THE REGION INFO STATS & PROPERTIES
%--------------------------------------------------------

IMFO.stats = regionprops(BWMASK);

[IMFO.bi,IMFO.labs,IMFO.n,IMFO.a] = bwboundaries(BWMASK,'noholes');


clc;clearvars -except ROX jj PIX IMG PC IMS PIX ROIS SIM IMS XBW IMFO BWMASK


IMFO.Lrgb = label2rgb(IMFO.labs, @jet, [.5 .5 .5]);

ph4 = imagesc(IMFO.Lrgb);  disp('Labeled data')



% AGAIN GET REGION PROPERTIES & STATISTICS
%--------------------------------------------------------
% clc;clearvars -except ROX jj PIX IMG BND SZ PC ROIS SIM IMS IMFO XBW BWMASK
% IMFO.stats = regionprops(BWMASK);
% [IMFO.bi,IMFO.labs,IMFO.n,IMFO.a] = bwboundaries(BW,'noholes');
% IMFO.stats = regionprops(BW);
% IMFO.Lrgb = label2rgb(IMFO.labs, @jet, [.5 .5 .5]);
% ph4 = imagesc(IMFO.Lrgb);  disp('Labeled data')





%---------------------------------------------
showIMGS = 0;
if showIMGS == 1
% PREVIEW 3D IMAGE STACK (NO RGB COLORMAP)
%---------------------------------------------

    I = rescale(IMG) .* XBW;

    q = quantile(I(:),[.0001 .9999]);

    close all; figure; a=axes; colormap(bone)

    p = imagesc(I(:,:,1));   a.CLim=q;

    for i = 1:size(I,3)
        p.CData = I(:,:,i);  pause(.04)
    end

    pause(1)
    clc;clc;
    clearvars -except ROX jj X PIX IMG BND SZ PC ROIS...
            SIM IMS IMFO BWMASK XBW MI BI BIM XBW



    % GET THE ROI DATA FOR A LINE GRAPH OF ACTIVITY
    %--------------------------------------------------------
    m=zeros(size(IMG,3),1);
    for i = 1:IMFO.n
        I = rescale(IMG) .* IMFO.labs==i;
        m(:,i) = squeeze(mean(mean(I)));
    end
    plot(m)
    pause(4)
end
%---------------------------------------------






ROIS(jj).MI  = XBW;
ROIS(jj).BI  = XBW;
ROIS(jj).BIM = IMFO;

clc;clearvars -except ROX jj X PIX IMG BND SZ PC ROIS...
SIM IMS IMFO BWMASK XBW MI BI BIM XBW


%########################################################################
end
%########################################################################
%%


return



%{

%########################################################################
% xcorr()
%########################################################################


% Next, we use the xcorr() function to compute the cross-correlations 
% between the three pairs of signals; then normalize them so their 
% maximum value is one.

[C21,lag21] = xcorr(s2,s1);
C21 = C21/max(C21);

[C31,lag31] = xcorr(s3,s1);
C31 = C31/max(C31);

[C32,lag32] = xcorr(s3,s2);
C32 = C32/max(C32);




% The locations of the maximum values of the cross-correlations 
% indicate time leads or lags.


[M21,I21] = max(C21);
t21 = lag21(I21);

[M31,I31] = max(C31);
t31 = lag31(I31);

[M32,I32] = max(C32);
t32 = lag31(I32);



% Plot the cross-correlations. In each plot display the 
% location of the maximum.

figure

subplot(3,1,1)
plot(lag21,C21,[t21 t21],[-0.5 1],'r:')
text(t21+100,0.5,['Lag: ' int2str(t21)])
ylabel('C_{21}')
axis tight
title('Cross-Correlations')

subplot(3,1,2)
plot(lag31,C31,[t31 t31],[-0.5 1],'r:')
text(t31+100,0.5,['Lag: ' int2str(t31)])
ylabel('C_{31}')
axis tight

subplot(3,1,3)
plot(lag32,C32,[t32 t32],[-0.5 1],'r:')
text(t32+100,0.5,['Lag: ' int2str(t32)])
ylabel('C_{32}')
axis tight
xlabel('Samples')



% We can see that s2 leads s1 by 350 samples; s3 lags s1 by 150 samples.
% Thus s2 leads s3 by 500 samples. Line up the signals by clipping the
% vectors with longer delays.

s1 = s1(-t21:end);
s3 = s3(t32:end);



ax(1) = subplot(3,1,1);
plot(s1)
ylabel('s_1')
axis tight

ax(2) = subplot(3,1,2);
plot(s2)
ylabel('s_2')
axis tight

ax(3) = subplot(3,1,3);
plot(s3)
ylabel('s_3')
axis tight
xlabel('Samples')

linkaxes(ax,'x')

%}




%########################################################################
%%                   DISPLAY ROI ANIMATIONS
%########################################################################
showIMGS = 1;
if showIMGS == 1


% DISPLAY FOUND ROIS
%---------------------------------------------

close all
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.05 .05 .9 .9],'Color','none');
ph1 = imagesc(mean(IMG,3));
qmax = quantile(IMG(:),.999);
qmin = quantile(IMG(:),.001);
ax1.CLim=[qmin qmax];
axis tight; pause(.1)
colormap bone


for nn = 1:size(ROIS,2)

    ph1 = imagesc(ROIS(nn).MI);
    colormap jet
    pause(.5)

    ph1 = imagesc(ROIS(nn).BI);
    colormap bone
    pause(.5)

    ph1 = imagesc(ROIS(nn).BIM.labs);
    colormap jet
    pause(.5)

    C = {ROIS(nn).BIM.stats.Centroid}';
    C = cell2mat(C);
    hold on
    scatter(C(:,1),C(:,2),'filled')
    pause(.5)

    B = {ROIS(nn).BIM.stats.BoundingBox}';
    B = cell2mat(B);
    for i=1:size(B,1)
    rectangle('Position',B(i,:),'Curvature',0.8,'EdgeColor',[.95,.4,.9],...
    'LineWidth',3)
    end
    pause(1)
    hold off

end



% STACK UP BOUNDING BOXES
%---------------------------------------------

close all
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.05 .05 .9 .9],'Color','none');
ph1 = imagesc(mean(IMG,3));
qmax = quantile(IMG(:),.999);
qmin = quantile(IMG(:),.001);
ax1.CLim=[qmin qmax];
axis tight; pause(.1)
colormap bone
hold on


for nn = 1:size(ROIS,2)

    B = {ROIS(nn).BIM.stats.BoundingBox}';
    B = cell2mat(B);
    for i=1:size(B,1)
    rectangle('Position',B(i,:),'Curvature',0.8,'EdgeColor',[.95,.4,.9],...
    'LineWidth',3)
    end
    pause(1)
    
end




% DISPLAY ALL ROI CENTROIDS
%---------------------------------------------

close all
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.05 .05 .9 .9],'Color','none');
ph1 = imagesc(mean(IMG,3));
qmax = quantile(IMG(:),.999);
qmin = quantile(IMG(:),.001);
ax1.CLim=[qmin qmax];
axis tight; pause(.1)
colormap bone
hold on


for nn = 1:size(ROIS,2)

    C = {ROIS(nn).BIM.stats.Centroid}';
    C = cell2mat(C);
    hold on
    scatter(C(:,1),C(:,2),'filled')
    pause(.5)
    pause(1)
    
end






% ACCUMULATE RAW PIXEL VALUES INSIDE (OVERLAPPING) ROIS
%---------------------------------------------

IM = zeros(size(IMG,1),size(IMG,2));

close all
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],...
    'Color','w','MenuBar','none');
ax1=axes('Position',[.05 .05 .9 .9],'Color','none');
ph1=imagesc(IM);
axis tight; pause(.1)
colormap hot
hold on


for nn = 1:size(ROIS,2)

    I = ROIS(nn).MI;

    IM = IM + I;

    imagesc(IM);
    pause(.5)
    
end






% ACCUMULATE BW PIXEL VALUES INSIDE (OVERLAPPING) ROIS
%---------------------------------------------

IM = zeros(size(IMG,1),size(IMG,2));

close all
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],...
    'Color','w','MenuBar','none');
ax1=axes('Position',[.05 .05 .9 .9],'Color','none');
ph1=imagesc(IM);
axis tight; pause(.1)
colormap jet
hold on


for nn = 1:size(ROIS,2)

    I = ROIS(nn).BI;

    IM = IM + I;

    imagesc(IM);
    pause(.5)
    
end




% ACCUMULATE PIXEL LABELS INSIDE (OVERLAPPING) ROIS
%---------------------------------------------

IM = zeros(size(IMG,1),size(IMG,2));

close all
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],...
    'Color','w','MenuBar','none');
ax1=axes('Position',[.05 .05 .9 .9],'Color','none');
ph1=imagesc(IM);
axis tight; pause(.1)
colormap jet
hold on


for nn = 1:size(ROIS,2)

    I = ROIS(nn).BIM.labs;

    IM = IM + I;

    imagesc(IM);
    pause(.5)
    
end






%########################################################################
end
%########################################################################




%% GET ACTIVITY FOR EACH ROI

clear Blabs ROItraces

IMDUB = rescale(IMG);

for j = 1:size(ROIS,2)

    Blabs = ROIS(j).BIM.labs;



    m=zeros(size(IMG,3),1);
    for i = 1:max(Blabs(:))

        I = IMDUB .* (Blabs==i);

        for k = 1:size(I,3)
            IM = I(:,:,k);
            m(k,i) = mean(IM(Blabs==i));
        end

    end

    ROItraces{j} = m;
end


for j = 1:size(ROItraces,2)
    t = ROItraces{j};
    m = min(t,[],1);
    ROItraces{j} = t-m;
end

clc

r = ROItraces{1};
sd = std(r,1);
q = quantile(sd,[.1 .8]);
m = sd<q(2);

r(m,:) = [];

close all;
plot(r)




%% Make axes coordinates
r = linspace(.02,.98,5);
c = fliplr(linspace(.02,.98,5)); c(1)=[];
w = .22; h = .22;
close all; 
figure('Position',[20 35 950 800],'MenuBar','none');


k=1;
for a=1:4
for b=1:4

    ax = axes('Position',[r(a) c(b) w h]);


    %p = imagesc(I(:,:,k));  ax.CLim=q;  axis off;

    plot(ROItraces{k})


    title(sprintf('PC-%s',num2str(k)))
    ax=gca;
    ax.XTickLabel=[];
    %axis off


    k=k+1;
end
end






clearvars -except ROX PIX IMG PC ROIS SIM IMS ROItraces



%% COMBINE ALL ROI ACTIVITY INTO VARIABLE 'ACT'; FOR PLOTTING 'ACTSTACK'

ACT = [];
for i = 1:size(ROItraces,2)
    ACT = [ACT ROItraces{i}];
end

x = repmat((1:size(ACT,2)),size(ACT,1),1);
ACTSTACK = ACT + x;




% -------------- PLOT ACTIVITY STACK --------------
close all
fh1 = figure('Units','pixels','Position',[10 35 900 800],...
    'Color','w','MenuBar','none');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none');


plot(ACTSTACK(:,1:30))
axis tight


clearvars -except ROX PIX IMG PC ROIS SIM IMS ROItraces ACT ACTSTACK








return
%% EXPORT ROI DATA

% ROIzerGUI(ROIS,IMG,PC)









%########################################################################
%                           MISC JUNK
%########################################################################
%% ################   PREVIEW IMAGE STACK   ################
%{
fh1=figure('Units','normalized','OuterPosition',[.1 .1 .4 .6],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');
ph1 = imagesc(mean(IMG,3));
 
qmax = quantile(IMG(:),.99);
qmin = quantile(IMG(:),.01);
ax1.CLim=[qmin qmax];
axis tight; pause(.5)
 
for nn = 1:size(IMG,3)
    ph1.CData = IMG(:,:,nn,1);
    pause(.05)
end
%}
%########################################################################
%{
f2=figure(2); histogram(X(:))

% Threshold image - manual threshold
BW = X > .44;

p.CData=BW;

% Open mask with disk
radius = 2;
decomposition = 4;
se = strel('disk', radius, decomposition);
BW = imopen(BW, se);

p.CData=BW;


% Clear borders
BW = imclearborder(BW);

p.CData=BW;


% Fill holes
BW = imfill(BW, 'holes');
p.CData=BW;


% Active contour
iterations = 30;
BW = activecontour(X, BW, iterations, 'Chan-Vese');
p.CData=BW;


% Fill holes
BW = imfill(BW, 'holes');
p.CData=BW;


% Dilate mask with disk
radius = 2;
decomposition = 6;
se = strel('disk', radius, decomposition);
BW = imdilate(BW, se);
p.CData=BW;


% Open mask with disk
radius = 3;
decomposition = 6;
se = strel('disk', radius, decomposition);
BW = imopen(BW, se);
p.CData=BW;


% Create masked image.
maskedImage = X;
maskedImage(~BW) = 0;
p.CData=maskedImage;
%}
%{
% Threshold image - adaptive threshold
BW = imbinarize(X, 'adaptive', 'Sensitivity', 0.580000, 'ForegroundPolarity', 'bright');
p.CData=BW;


% Active contour
iterations = 3;
BW = activecontour(X, BW, iterations, 'edge');
p.CData=BW;


% Close mask with disk
radius = 5;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imclose(BW, se);
p.CData=BW;


% Dilate mask with disk
radius = 2;
decomposition = 6;
se = strel('disk', radius, decomposition);
BW = imdilate(BW, se);
p.CData=BW;


% Open mask with disk
radius = 3;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imopen(BW, se);
p.CData=BW;


% Dilate mask with disk
radius = 1;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imdilate(BW, se);
p.CData=BW;


% Clear borders
BW = imclearborder(BW);
p.CData=BW;


% Fill holes
BW = imfill(BW, 'holes');
p.CData=BW;


% Create masked image.
MI = X;
MI(~BW) = 0;
p.CData=MI;
BI = BW;
p.CData=BW;
%}
%{
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

p.CData=BW;



% Clear borders
BW = imclearborder(BW);
p.CData=BW;


% Fill holes
BW = imfill(BW, 'holes');
p.CData=BW;


% Close mask with disk
radius = 6;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imclose(BW, se);
p.CData=BW;


% Open mask with disk
radius = 1;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imopen(BW, se);
p.CData=BW;


% Dilate mask with disk
radius = 3;
decomposition = 0;
se = strel('disk', radius, decomposition);
BW = imdilate(BW, se);
p.CData=BW;


% Active contour
iterations = 10;
BW = activecontour(X, BW, iterations, 'Chan-Vese');
p.CData=BW;


% Close mask with disk
radius = 4;
decomposition = 8;
se = strel('disk', radius, decomposition);
BW = imclose(BW, se);
p.CData=BW;


% Dilate mask with disk
radius = 2;
decomposition = 8;
se = strel('disk', radius, decomposition);
BW = imdilate(BW, se);
p.CData=BW;
%}





