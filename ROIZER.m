function [] = ROIZER(varargin)
%% ROIZER.m - IMAGE SEGMENTATION TOOLBOX
clc; close all; clear all; clear java;
disp('WELCOME TO THE IMAGE SEGMENTATION ROI TOOLBOX')
global P; P.home = pwd; P.home = fileparts(which('ROIZER.m'));
if ~any(regexp(P.home,'ROIZER') > 0)
disp('Run this code from the ROIZER home directory,')
disp('or add latest ROIZER-master folder to your MATLAB path.')
disp('YOU CAN DOWNLOAD THE LATEST ROIZER SOFTWARE FROM')
web('https://github.com/subroutines/ROIZER.git','-browser')
return
end
cd(P.home); clc; rng('shuffle'); f = filesep;
P.fun  = [P.home f '_ROIZER_functions'];
P.dat  = [P.home f '_ROIZER_datasets'];
P.out  = [P.home f '_ROIZER_output'];
addpath(join(string(struct2cell(P)),pathsep,1))
cd(P.home); clearvars -except P; P.f = filesep;


P.egimg  = [P.dat  P.f '_ROIZER_example_data'];
P.egout  = [P.out  P.f '_ROIZER_example_output'];








%% MANUALLY SET PER-SESSION PATH PARAMETERS IF WANTED (OPTIONAL)

global IMG PIX SMIM PC ABIM PCI IMAX IMV NIM MAGE PIC
global IMBW BWMASK BWRAW IMFO ROIS ROITABLE ROIL 
global ThreshMin ThreshMax minmaxBins pixelsdBins total_frames
global MINMAXROIPIXELS AREA_FILTER 
global allhax PCASexp

ThreshMin = .01;
ThreshMax = .99;
minmaxBins = 20;
pixelsdBins = 20;
MINMAXROIPIXELS = [12 400];
AREA_FILTER = MINMAXROIPIXELS;


IMG     = [];
PIX     = [];
SMIM    = [];
PC      = [];
ABIM    = [];
PCI     = [];
IMAX    = [];
IMV     = [];
NIM     = [];
MAGE    = [];
PIC     = [];
BWMASK  = [];
BWRAW   = [];
IMBW    = [];







%% ESTABLISH GLOBALS AND SET STARTING VALUES

global mainguih imgLogo

global SEGstruct SEGtable XLSdata LICK IMGred IMGr

global IMGraw IMGSraw IM
global memes conboxH
global NormType


global total_trials framesPerTrial framesPerSec secondsPerTrial 
global IMhist tiledatX tiledatY RHposCheck

IMhist.smoothed   = 0;
IMhist.cropped    = 0;
IMhist.tiled      = 0;
IMhist.reshaped   = 0;
IMhist.aligned    = 0;
IMhist.normalized = 0;
IMhist.rawIM      = [];
IMhist.minIM      = [];
IMhist.maxIM      = [];
IMhist.aveIM      = [];

IMGred = [];
IMGr   = [];

NormType = 'dF';



global cropAmount IMGfactors blockSize previewNframes customFunOrder 
cropAmount = 18;
IMGfactors = 1;
blockSize = 22;
previewNframes = 25;
customFunOrder = 1;

global stimtype stimnum CSUSvals
% CSxUS:1  CS:2  US:3
stimnum = 1;
stimtype = 'CS'; 
CSUSvals = {'CS','US'};


global CSonset CSoffset USonset USoffset CSUSonoff
global CSonsetDelay baselineTime CSonsetFrame CSoffsetFrame
CSonsetDelay = 10;
baselineTime = 10;
CSonsetFrame = 25;
CSoffsetFrame = 35;


global smoothHeight smoothWidth smoothSD smoothRes
smoothHeight = .8;
smoothWidth = 9;
smoothSD = 1.2;
smoothRes = .1;


 
global muIMGS phSEG previewStacknum toggrid axGRID
muIMGS = [];
previewStacknum = 25;
toggrid = 0;

global confile confilefullpath
confile = 'gcconsole.txt';
% diary(confile)
disp('SEG CONSOLE LOGGING ON.')
% diary off
confilefullpath = which(confile,'-all');
% delete(confile)




%########################################################################
%%              MAIN SEG ANALYSIS GUI WINDOW SETUP 
%########################################################################

% mainguih.CurrentCharacter = '+';
mainguih = figure('Units', 'normalized','Position', [.05 .08 .90 .78], 'BusyAction',...
    'cancel', 'Name', 'SEG TOOLBOX', 'Tag', 'mainguih','Visible', 'Off'); 
     % 'KeyPressFcn', {@keypresszoom,1}, 'CloseRequestFcn',{@mainGUIclosereq}
     % intimagewhtb = uitoolbar(mainguih);


% -------- MAIN FIGURE WINDOW --------
haxSEG = axes('Parent', mainguih, 'NextPlot', 'replacechildren',...
    'Position', [0.01 0.01 0.40 0.85], 'PlotBoxAspectRatio', [1 1 1], ...
    'XColor','none','YColor','none','YDir','reverse'); 
    % ,'XDir','reverse',...
    
% -------- IMPORT IMAGE STACK & EXCEL DATA BUTTON --------
importimgstackH = uicontrol('Parent', mainguih, 'Units', 'normalized', ...
    'Position', [0.01 0.90 0.40 0.08], 'FontSize', 16, ...
    'String', 'Import Image Stack', ...
    'Callback', @importimgstack);



imgsliderH = uicontrol('Parent', mainguih, 'Units', 'normalized','Style','slider',...
	'Max',100,'Min',1,'Value',1,'SliderStep',[0.01 0.10],...
	'Position', [0.01 0.86 0.40 0.02], 'Callback', @imgslider);






%########################################################################
%%              MEMO CONSOLE GUI WINDOW
%########################################################################
memopanelH = uipanel('Parent', mainguih,'Title','Memo Log ','FontSize',10,...
    'BackgroundColor',[1 1 1],...
    'Position', [0.43 0.76 0.55 0.23]); % 'Visible', 'Off',


memes = {' ',' ',' ', ' ',' ',' ',' ', ...
         'Welcome to the SEG TOOLBOX', 'GUI is loading...'};

conboxH = uicontrol('Parent',memopanelH,'Style','listbox','Units','normalized',...
        'Max',9,'Min',0,'Value',9,'FontSize', 13,'FontName', 'FixedWidth',...
        'String',memes,'FontWeight', 'bold',...
        'Position',[.0 .0 1 1]);  
    

% memocon(['Factor set to: ' callbackdata.NewValue.String])







%########################################################################
%%           IMAGE STACK PRE-PROCESSING PANEL
%########################################################################
IPpanelH = uipanel('Title','Image Stack Preprocessing','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.43 0.23 0.35 0.52]); % 'Visible', 'Off',



runallIPH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.88 0.95 0.12], 'FontSize', 13, 'String', 'Run All Selected Processes',...
    'Callback', @runallIP, 'Enable','off'); 

HposCheck.A  = [.02  .76  .05  .05];
HposCheck.B  = [.02  .64  .05  .05];
HposCheck.C  = [.02  .52  .05  .05];
HposCheck.D  = [.02  .40  .05  .05];
HposCheck.E  = [.02  .28  .05  .05];
HposCheck.F  = [.02  .16  .05  .05];
HposCheck.G  = [.02  .04  .05  .05];

HposButton.A = [.08  .73  .60  .11];
HposButton.B = [.08  .61  .60  .11];
HposButton.C = [.08  .49  .60  .11];
HposButton.D = [.08  .37  .60  .11];
HposButton.E = [.08  .25  .60  .11];
HposButton.F = [.08  .13  .60  .11];
HposButton.G = [.08  .01  .60  .11];

HposTxt.A    = [.71  .77  .27  .045];
HposTxt.B    = [.71  .69  .27  .045];
HposTxt.C    = [.71  .53  .27  .045];
HposTxt.D1   = [.70  .46  .14  .045];
HposTxt.D2   = [.83  .46  .14  .045];
HposTxt.E    = [.71  .33  .27  .045];
HposTxt.F    = [.71  .20  .27  .045];
HposTxt.G    = [.71  .04  .27  .045];

HposEdit.A   = [.71  .76  .27  .06];
HposEdit.B   = [.70  .63  .28  .06];
HposEdit.C   = [.71  .50  .27  .06];
HposEdit.D1  = [.71  .40  .12  .06];
HposEdit.D2  = [.84  .40  .12  .06];
HposEdit.E   = [.71  .27  .27  .06];
HposEdit.F   = [.70  .14  .28  .06];
HposEdit.G   = [.70  .002 .27  .07];

checkbox1H = uicontrol('Parent', IPpanelH,'Style','checkbox','Units','normalized',...
    'Position', HposCheck.A ,'String','', 'Value',1);
checkbox2H = uicontrol('Parent', IPpanelH,'Style','checkbox','Units','normalized',...
    'Position', HposCheck.B ,'String','', 'Value',1);
checkbox3H = uicontrol('Parent', IPpanelH,'Style','checkbox','Units','normalized',...
    'Position', HposCheck.C ,'String','', 'Value',1);
checkbox4H = uicontrol('Parent', IPpanelH,'Style','checkbox','Units','normalized',...
    'Position', HposCheck.D ,'String','', 'Value',1);
checkbox5H = uicontrol('Parent', IPpanelH,'Style','checkbox','Units','normalized',...
    'Position', HposCheck.E ,'String','', 'Value',1);
checkbox6H = uicontrol('Parent', IPpanelH,'Style','checkbox','Units','normalized',...
    'Position', HposCheck.F ,'String','', 'Value',1);
checkbox7H = uicontrol('Parent', IPpanelH,'Style','checkbox','Units','normalized',...
    'Position', HposCheck.G ,'String','', 'Value',1);




cropimgH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.A, 'FontSize', 12, 'String', 'Crop Images',...
    'Callback', @cropimg, 'Enable','off'); 
cropimgtxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.A, 'FontSize', 10,'String', 'Crop: Click & Drag');
% cropimgnumH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
%     'Position', HposEdit.B, 'FontSize', 11); 



smoothimgH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.B, 'FontSize', 12, 'String', 'Smooth Images',...
    'Callback', @smoothimg, 'Enable','off'); 
smoothimgtxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.B, 'FontSize', 10,'String', 'Smooth Amount');
smoothimgnumH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', HposEdit.B, 'FontSize', 11); 





imgpcH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.C, 'FontSize', 12, 'String', 'Principal Components',...
    'Callback', @imgpc, 'Enable','off'); 
imgpctxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.C, 'FontSize', 10,'String', 'Clickable PCs');
% imgpcpopupH = uicontrol('Parent', IPpanelH,'Style', 'popup',...
%     'Units', 'normalized', 'String', {'20','2','1'},...
%     'Position', HposEdit.C,...
%     'Callback', @imgpcpopup);




remrescaleH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.D, 'FontSize', 12, 'String', 'Remove Outlier Pixels',...
    'Callback', @remrescale, 'Enable','off');
remrescaletxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.D1, 'FontSize', 10,'String', 'Min thresh');
remrescaletxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.D2, 'FontSize', 10,'String', 'Max thresh');
remrescaleminH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', HposEdit.D1, 'FontSize', 11); 
remrescalemaxH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', HposEdit.D2, 'FontSize', 11); 



iminimaxH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.E, 'FontSize', 12, 'String', 'Get min-max intensity',...
    'Callback', @iminimax, 'Enable','off'); 
iminimaxtxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.E, 'FontSize', 10,'String', 'N-bin frames');
iminimaxnumH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', HposEdit.E, 'FontSize', 11);



pixelsdH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.F, 'FontSize', 12, 'String', 'Get pixel intensity SD',...
    'Callback', @pixelsd, 'Enable','off'); 
pixelsdtxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.F, 'FontSize', 10,'String', 'N-bin frames');
pixelsdnumH = uicontrol('Parent', IPpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', HposEdit.F, 'FontSize', 11); 


compimgH = uicontrol('Parent', IPpanelH, 'Units', 'normalized', ...
    'Position', HposButton.G, 'FontSize', 12, 'String', 'Make final composite image',...
    'Callback', @compimg, 'Enable','off'); 
compimgtxtH = uicontrol('Parent', IPpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', HposTxt.G, 'FontSize', 10,'String', 'IMG to SEGMENT');




              






%########################################################################
%%               IMAGE SEGMENTATION PANEL
%########################################################################
imsegpanelH = uipanel('Title','Image Segmentation','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.80 0.23 0.18 0.52]); % 'Visible', 'Off',


roiposTxt.A   = [.05  .94  .90  .05];
roiposTxt.B1  = [.05  .90  .40  .045];
roiposTxt.B2  = [.55  .90  .40  .045];
roiposTxt.C1  = [.05  .84  .40  .06];
roiposTxt.C2  = [.55  .84  .40  .06];


% roiszH = uicontrol('Parent', imsegpanelH, 'Units', 'normalized', ...
%     'Position', HposButton.D, 'FontSize', 12, 'String', 'Remove Outlier Pixels',...
%     'Callback', @remrescale, 'Enable','off');

roisztxtH = uicontrol('Parent', imsegpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', roiposTxt.A, 'FontSize', 10,'String', 'ROI PIXEL COUNT THRESHOLD ');
roiszmintxtH = uicontrol('Parent', imsegpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', roiposTxt.B1, 'FontSize', 10,'String', 'Min');
roiszmaxtxtH = uicontrol('Parent', imsegpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', roiposTxt.B2, 'FontSize', 10,'String', 'Max');
roiszminH = uicontrol('Parent', imsegpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', roiposTxt.C1, 'FontSize', 11); 
roiszmaxH = uicontrol('Parent', imsegpanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', roiposTxt.C2, 'FontSize', 11); 


uicontrol('Parent', imsegpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [.05  .70  .90  .05], 'FontSize', 10,...
    'String', 'SEGMENTATION PROCESSES');

hBpos.A = [.05  .60  .90  .09];
hBpos.B = [.05  .50  .90  .09];
hBpos.C = [.05  .40  .90  .09];
hBpos.D = [.05  .30  .90  .09];
hBpos.E = [.05  .20  .90  .09];
hBpos.F = [.05  .10  .90  .09];
hBpos.G = [.05  .00  .90  .09];

imseg1H = uicontrol('Parent', imsegpanelH, 'Units', 'normalized', ...
    'Position', hBpos.A, 'FontSize', 12,...
    'String', 'Saturate ','Callback', @imsegSaturate, 'Enable','off');

imseg2H = uicontrol('Parent', imsegpanelH, 'Units', 'normalized', ...
    'Position', hBpos.B, 'FontSize', 12,...
    'String', 'Binarize ','Callback', @imsegBinarize, 'Enable','off');

imseg3H = uicontrol('Parent', imsegpanelH, 'Units', 'normalized', ...
    'Position', hBpos.C, 'FontSize', 12,...
    'String', 'Open Mask ','Callback', @imsegIMOPEN, 'Enable','off');

imseg4H = uicontrol('Parent', imsegpanelH, 'Units', 'normalized', ...
    'Position', hBpos.D, 'FontSize', 12,...
    'String', 'Active Contour ','Callback', @imsegACTIVECON, 'Enable','off');

imseg5H = uicontrol('Parent', imsegpanelH, 'Units', 'normalized', ...
    'Position', hBpos.E, 'FontSize', 12,...
    'String', 'Dilate ','Callback', @imsegDILATE, 'Enable','off');

imseg6H = uicontrol('Parent', imsegpanelH, 'Units', 'normalized', ...
    'Position', hBpos.F, 'FontSize', 12,...
    'String', 'Clear borders, fill holes ','Callback', @imsegCLEARFILL, 'Enable','off');

imseg7H = uicontrol('Parent', imsegpanelH, 'Units', 'normalized', ...
    'Position', hBpos.G, 'FontSize', 12,...
    'String', 'Get ROI activity ','Callback', @ROIACTIVITY, 'Enable','off');










%########################################################################
%%        POST-SEGMENTATION ROI SIGNALS PANEL
%########################################################################
roisigH = uipanel('Title','ROI Signals','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.43 0.01 0.35 0.20]); % 'Visible', 'Off',
              


plotTileStatsH = uicontrol('Parent', roisigH, 'Units', 'normalized', ...
    'Position', [0.03 0.66 0.31 0.28], 'FontSize', 12, 'String', 'Plot Tile Data',...
    'Callback', @plotTileStats, 'Enable','off'); 

plotGUIH = uicontrol('Parent', roisigH, 'Units', 'normalized', ...
    'Position', [0.03 0.34 0.31 0.28], 'FontSize', 12, 'String', 'Open Plot GUI',...
    'Callback', @plotGUI, 'Enable','off');

plotGroupMeansH = uicontrol('Parent', roisigH, 'Units', 'normalized', ...
    'Position', [0.03 0.03 0.31 0.28], 'FontSize', 12, 'String', 'Plot Group Means',...
    'Callback', @plotGroupMeans, 'Enable','off');

viewGridOverlayH = uicontrol('Parent', roisigH, 'Units', 'normalized', ...
    'Position', [0.35 0.66 0.31 0.28], 'FontSize', 12, 'String', 'View Grid Overlay',...
    'Callback', @viewGridOverlay, 'Enable','off');

viewTrialTimingsH = uicontrol('Parent', roisigH, 'Units', 'normalized', ...
    'Position', [0.35 0.34 0.31 0.28], 'FontSize', 12, 'String', 'View Trial Timings',...
    'Callback', @viewTrialTimings, 'Enable','off');

previewStackH = uicontrol('Parent', roisigH, 'Units', 'normalized', ...
    'Position', [0.35 0.03 0.38 0.28], 'FontSize', 12, 'String', 'Preview Image Stack',...
    'Callback', @previewStack, 'Enable','off');
previewStacktxtH = uicontrol('Parent', roisigH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.74 0.29 0.15 0.11], 'FontSize', 10,'String', 'Frames');
previewStacknumH = uicontrol('Parent', roisigH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.74 0.07 0.15 0.20], 'FontSize', 12);
% previewStackcbH = uicontrol('Parent', graphspanelH,'Style','checkbox','Units','normalized',...
%     'Position', [.62 0.12 .14 .14] ,'String','Postprocessing Previews', 'Value',1);


getROIstatsH = uicontrol('Parent', roisigH, 'Units', 'normalized', ...
    'Position', [0.67 0.45 0.31 0.50], 'FontSize', 12, 'String', 'ROI TOOLBOX',...
    'Callback', @openROITOOLBOX, 'Enable','off');











%########################################################################
%%              SAVE AND EXPORT DATA PANEL
%########################################################################
exportpanelH = uipanel('Title','I/O','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.80 0.01 0.18 0.20]); % 'Visible', 'Off',

exportvarsH = uicontrol('Parent', exportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.55 0.95 0.40], 'FontSize', 13,...
    'String', 'Export vars to workspace ',...
    'Callback', @exportROIACT2WS, 'Enable','off');

exportfileH = uicontrol('Parent', exportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.03 0.95 0.40], 'FontSize', 13,...
    'String', 'Export data to file',...
    'Callback', @exportROIACT2FILE, 'Enable','off');



% enableButtons
% memocon('Ready!')


pause(.1)
ROIZERtoolbox()




% -----------------------------------------------------------------------------
%%                     GUI TOOLBOX FUNCTIONS
% -----------------------------------------------------------------------------



%###############################################################
%%   INITIAL SEG TOOLBOX FUNCTION TO POPULATE GUI
%###############################################################
function ROIZERtoolbox(hObject, eventdata)

    % set(initmenuh, 'Visible', 'Off');
    % set(mainguih, 'Visible', 'On');
    
    %----------------------------------------------------
    %           SET USER-EDITABLE GUI VALUES
    %----------------------------------------------------
    imgLogo = imread('circlesBrightDark.png');
    set(haxSEG, 'XLim', [1 size(imgLogo,2)], 'YLim', [1 size(imgLogo,1)]);
    set(smoothimgnumH, 'String', num2str(smoothSD));
    set(remrescaleminH, 'String', num2str(ThreshMin));
    set(remrescalemaxH, 'String', num2str(ThreshMax));
    set(iminimaxnumH, 'String', num2str(minmaxBins));
    set(pixelsdnumH, 'String', num2str(pixelsdBins));
    set(previewStacknumH, 'String', num2str(previewStacknum));

    set(roiszminH, 'String', num2str(MINMAXROIPIXELS(1)));
    set(roiszmaxH, 'String', num2str(MINMAXROIPIXELS(2)));
    

    % Set radiobuttons
    % stimtypeh.SelectedObject = stimtypeh1; 
    % stimtype = stimtypeh.SelectedObject.String;
    %----------------------------------------------------
    
    
    
    
    %----------------------------------------------------
    %                   DRAW IMAGE
    %----------------------------------------------------

        axes(haxSEG)
        colormap(haxSEG,parula)
    phSEG = imagesc(imgLogo , 'Parent', haxSEG);
        pause(.1)

memocon('Ready to Import Image Stack!')
end






%###############################################################
%%        IMPORT IMAGE STACK MAIN FUNCTION
%###############################################################
function importimgstack(hObject, eventdata)
% diary on


    memocon('SELECT A TIFF STACK TO IMPORT')
    disp('Select a TIFF image stack.')

    [PIX] = getIMpath();

    IMG = IMPORTimages(PIX);


    memocon('Image stack sucessfully imported.') 
    

    % Adjust the contrast of the image so that 1% of the data
    % is saturated at low and high intensities, and display it.
    %IMJ = imadjust(mean(IMG,3));


    axes(haxSEG)
    colormap(haxSEG,parula)
    phSEG = imagesc(mean(IMG,3) , 'Parent', haxSEG);
              pause(1)
    
    IMGraw = IMG(:,:,1);
    
    
    if size(IMG,1) < 100
        %set(cropimgnumH, 'String', num2str(2));
        set(haxSEG, 'XLim', [1 size(IMG,2)+40], 'YLim', [1 size(IMG,1)+40]);
    elseif (size(IMG,1) < 140) && (size(IMG,1) >= 100)
        %set(cropimgnumH, 'String', num2str(4));
        set(haxSEG, 'XLim', [1 size(IMG,2)+30], 'YLim', [1 size(IMG,1)+30]);
    elseif size(IMG,1) < 180 && (size(IMG,1) >= 140)
        %set(cropimgnumH, 'String', num2str(8));
        set(haxSEG, 'XLim', [1 size(IMG,2)+20], 'YLim', [1 size(IMG,1)+20]);
    elseif size(IMG,1) < 220 && (size(IMG,1) >= 180)
        %set(cropimgnumH, 'String', num2str(12));
        set(haxSEG, 'XLim', [1 size(IMG,2)+10], 'YLim', [1 size(IMG,1)+10]);
    else
        %set(cropimgnumH, 'String', num2str(18));
        set(haxSEG, 'XLim', [1 size(IMG,2)], 'YLim', [1 size(IMG,1)]);
    end
    
    


     total_frames = size(IMG,3);
     
     
     % VISUALIZE AND ANNOTATE
     memocon(sprintf('Imported image stack size: % s ', num2str(size(IMG))));
     

     update_IMGfactors()
    
    
enableButtons
memocon('Image stack import completed!')
end









%###############################################################
%%        RUN ALL IMAGE PROCESSING FUNCTIONS
%###############################################################
function runallIP(hObject, eventdata)
disableButtons; pause(.02);
conon


    if checkbox1H.Value
        cropimg
    end
    
    if checkbox2H.Value
        smoothimg
    end
    
    if checkbox3H.Value
        imgpc
    end

    if checkbox4H.Value
        remrescale
    end

    if checkbox5H.Value
        iminimax
    end

    if checkbox6H.Value
        pixelsd
    end

    if checkbox7H.Value
        compimg
    end
    

memocon('ALL PROCESSING COMPLETED!')
conoff
enableButtons        
end








%###############################################################
%%        CROP IMAGES
%###############################################################
function cropimg(hObject, eventdata)
disableButtons; 
cropimgH.FontWeight = 'bold';
pause(.02);

    % TRIM EDGES FROM IMAGE
    memocon(' '); memocon(' '); memocon(' '); 
    memocon('1. Left-click-and-drag a cropping rectangle on image.')
    memocon('2. Right-click rectangle and then click "Crop Image".')
    memocon(' ');
    

    I = uint8(rescale(mean(double(IMG),3),0,1).*255);
    I = imadjust(I,stretchlim(I,[ThreshMin ThreshMax]));


    [~, rect] = imcrop(I);

% rect specifies the size and position of the crop rectangle 
% as [xmin ymin width height], in terms of spatial coordinates.


    CROPBOX = [ceil(rect(1:2)) floor(rect(3:4))];

    IMG = IMG(CROPBOX(2):(CROPBOX(2)+CROPBOX(4)),...
          CROPBOX(1):(CROPBOX(1)+CROPBOX(3)) , :);



    previewStack

        
IMhist.cropped = 1;
cropimgH.FontWeight = 'normal';
pause(.02);
enableButtons        
memocon('Crop Images completed!')
end









%###############################################################
%%        SMOOTH IMAGES
%###############################################################
function smoothimg(hObject, eventdata)
disableButtons; 
smoothimgH.FontWeight = 'bold';
pause(.02);




    % PERFORM IMAGE SMOOTHING
    memocon(' '); memocon('PERFORMING IMAGE SMOOTHING')

    
    smoothSD = str2num(smoothimgnumH.String);
    

    SMIM = imgaussfilt3(mean(IMG,3), smoothSD);
    
    
    axes(haxSEG)
    phSEG = imagesc(SMIM , 'Parent', haxSEG);


IMhist.smoothed = 1;        
smoothimgH.FontWeight = 'normal';
pause(.02);
enableButtons        
memocon('Image smoothing completed!')
end









%###############################################################
%%        COMPUTING PRINCIPAL COMPONENTS
%###############################################################
function imgpc(hObject, eventdata)
disableButtons; 
imgpcH.FontWeight = 'bold';
pause(.02);



    % CREATE IMAGES TILES PER ROBERT'S SPEC
    memocon('COMPUTING PRINCIPAL COMPONENTS (PCA running, please wait)...')

    
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



    
    % GET ABSOLUTE VALUE OF MEAN DEVIATION
    I = PC(1).imc;
    for j=1:size(I,3)
        k=I(:,:,j);
        ABIM(:,:,j) = abs(I(:,:,j) - mean(k(:)));
    end


    % PREVIEW ABIM IN MAIN WINDOW
    previewIMG(mean(ABIM,3))

   




    memocon('Finished computing PCs.');
    %--------------------------------------------
    memocon(' '); memocon(' ');
    memocon('CHOOSE FROM FIRST 16 PRINCIPAL COMPONENTS')
    memocon('1. Click desired principal component images in popup window')
    memocon('2. Close popup window')
    memocon(' '); pause(2);


    [AXE] = pickPC(PC(1).imc);
    AXE(1) = [];

    disp('CHOSEN PCs:'); disp(AXE)

    PCI = abs(PC(1).imc(:,:,AXE));

    previewStack(PCI)
    







imgpcH.FontWeight = 'normal';
pause(.02);
enableButtons
memocon('PCA GENERATION & SELECTION COMPLETED!')
end




%---------------------------------------------------------------
%%        SELECT PRINCIPAL COMPONENTS FIGURE FUNCTION
%---------------------------------------------------------------
function [AXE] = pickPC(IM)

    global AXI
    AXI = 0;

    % Make axes coordinates
    r = linspace(.02,.98,5);
    c = fliplr(linspace(.02,.98,5)); c(1)=[];
    w = .22; h = .22;


    fh1=figure('Units','normalized','OuterPosition',[.01 .05 .85 .90],'MenuBar','none',...
        'ButtonDownFcn',@(~,~)disp('pick an axis'),'HitTest','off');


    q = quantile(IM(:),[.001 .999]);

    k=1;
    for a=1:4
    for b=1:4

        ax{k} = axes('Position',[r(a) c(b) w h],'ButtonDownFcn',@(~,~)disp('axes'),...
       'HitTest','off','Tag',num2str(k));


        p{k} = imagesc(IM(:,:,k),'ButtonDownFcn',@pickaxe,...
       'PickableParts','all','Tag',num2str(k));  

        ax{k}.CLim=q;  %axis off;


        title(sprintf('PC-%s',num2str(k)))


        k=k+1;
    end
    end



    an1 = annotation(gcf,'textbox',[.1 .1 .8 .8],...
            'String','Click desired PCA images, then close this window',...
            'FitBoxToText','on','FontSize',24,'BackgroundColor','w');
    pause(2); delete(an1);

    uiwait
    AXE = AXI;
end
%---------------------------------------------------------------
function pickaxe(hObject, eventdata)
    global AXI

    T = str2num(hObject.Tag);

    InAXI = AXI == T;


    if ~any(InAXI)

        AXI = [AXI; T];

        %hObject.CData(1,1) = 1;
        hObject.Parent.Colormap = bone;

    else

        AXI(InAXI) = [];

        %hObject.CData(1,1) = 1;
        hObject.Parent.Colormap = parula;

    end

end
%###############################################################













%###############################################################
%%   REMOVE OUTLIER PIXELS AND RESCALE RAW & PCA STACKS
%###############################################################
function remrescale(hObject, eventdata)
disableButtons; 
remrescaleH.FontWeight = 'bold';
pause(.02);



    % Adjust the contrast of the image so that 1% of the data
    % is saturated at low and high intensities, and display it.
    %IMJ = imadjust(IMG);


    memocon('Removing outliers and rescaling image stacks...')

    IMG = rescale(double(IMG),0,1);
    PCI = rescale(double(PCI),0,1);


    IM1 = IMG; IMa = IM1;
    IM2 = PCI; IMb = IM2;


    IM1q = quantile(IM1(:),[ThreshMin ThreshMax]);
    IM2q = quantile(IM2(:),[ThreshMin ThreshMax]);


    IM1(IM1<IM1q(1)) = IM1q(1);
    IM1(IM1>IM1q(2)) = IM1q(2);

    IM2(IM2<IM2q(1)) = IM2q(1);
    IM2(IM2>IM2q(2)) = IM2q(2);


    IM1 = rescale(IM1,0,1);
    IM2 = rescale(IM2,0,1);



%     IM1 = imadjust(IMG,stretchlim(IMG,[ThreshMin ThreshMax]));
%     IM2 = imadjust(IMG,stretchlim(IMG,[ThreshMin ThreshMax]));
%     IM1 = rescale(IM1,0,1);
%     IM2 = rescale(IM2,0,1);



    %---------- DISPLAY PRE-OUTLIER REMOVAL DATA -------------------
    fh01 = figure('Units','normalized','OuterPosition',[.01 .05 .95 .90],...
                  'Color','w','MenuBar','none');
    ax01 = axes('Position',[.06 .56 .4 .4],'Color','none');
    ax02 = axes('Position',[.56 .56 .4 .4],'Color','none',...
            'YDir','reverse','PlotBoxAspectRatio',[1 1 1],...
            'XColor','none','YColor','none'); hold on
    ax03 = axes('Position',[.06 .06 .4 .4],'Color','none');
    ax04 = axes('Position',[.56 .06 .4 .4],'Color','none',...
            'YDir','reverse','PlotBoxAspectRatio',[1 1 1],...
            'XColor','none','YColor','none'); hold on

    
    axes(ax01); histogram(IMa(:)); hold on
    line([IM1q(1) IM1q(1)],[ax01.YLim(1) ax01.YLim(2)])
    line([IM1q(2) IM1q(2)],[ax01.YLim(1) ax01.YLim(2)])
    title('Raw stack pixel histogram BEFORE outlier removal')

    axes(ax02); imagesc(ax02,mean(IMa,3));
    axis tight off; colormap bone; 
    title('Raw stack mean BEFORE outlier removal')


    axes(ax03); histogram(IMb(:)); hold on
    line([IM2q(1) IM2q(1)],[ax03.YLim(1) ax03.YLim(2)])
    line([IM2q(2) IM2q(2)],[ax03.YLim(1) ax03.YLim(2)])
    title('PCA stack pixel histogram BEFORE outlier removal')

    axes(ax04); imagesc(ax04,mean(IMb,3));
    axis tight off; colormap bone; 
    title('PCA stack mean BEFORE outlier removal')

    pause(5); close(fh01)







    %---------- DISPLAY POST-OUTLIER REMOVAL DATA -------------------
    fh01 = figure('Units','normalized','OuterPosition',[.01 .05 .95 .90],...
                  'Color','w','MenuBar','none');
    ax01 = axes('Position',[.06 .56 .4 .4],'Color','none');
    ax02 = axes('Position',[.56 .56 .4 .4],'Color','none',...
            'YDir','reverse','PlotBoxAspectRatio',[1 1 1],...
            'XColor','none','YColor','none'); hold on
    ax03 = axes('Position',[.06 .06 .4 .4],'Color','none');
    ax04 = axes('Position',[.56 .06 .4 .4],'Color','none',...
            'YDir','reverse','PlotBoxAspectRatio',[1 1 1],...
            'XColor','none','YColor','none'); hold on

    
    axes(ax01); histogram(IM1(:));
    title('Raw stack pixel histogram AFTER outlier removal')

    axes(ax02); imagesc(ax02,mean(IM1,3));
    axis tight off; colormap bone; 
    title('Raw stack mean AFTER outlier removal')


    axes(ax03); histogram(IM2(:));
    title('PCA stack pixel histogram AFTER outlier removal')

    axes(ax04); imagesc(ax04,mean(IM2,3));
    axis tight off; colormap bone;
    title('PCA stack mean AFTER outlier removal')

    pause(5); close(fh01)




    IMG = IM1;
    PCI = IM2;


    previewStack




remrescaleH.FontWeight = 'normal';
pause(.02);
enableButtons
memocon('OUTLIER REMOVAL & RESCALE COMPLETED!')
end























%###############################################################
%%      GET MEAN MAX-MIN PROJECTION OF RAW IMAGE
%###############################################################
function iminimax(hObject, eventdata)
disableButtons; iminimaxH.FontWeight = 'bold';
pause(.02);



    memocon('COMPUTING MAX RANGE OF EACH STACK PIXEL...')


    nbins = str2double(iminimaxnumH.String);

    sz = size(IMG);
    t = round(linspace(1,sz(3),nbins));
    IM = double(IMG);

    IMAX = [];
    for i = 1:numel(t)-1
        IMmin = min(IM(:,:, t(i):t(i+1) ) ,[],3);
        IMmax = max(IM(:,:, t(i):t(i+1) ) ,[],3);
        IMAX(:,:,i) = IMmax - IMmin;
    end
    IMAX = mean(IMAX,3);


    axes(haxSEG)
    phSEG = imagesc(IMAX , 'Parent', haxSEG);
    pause(1)



iminimaxH.FontWeight = 'normal';
pause(.02); enableButtons
memocon('DONE!')
end







%###############################################################
%%   GET PIXEL SD OF RAW IMAGE STACK
%###############################################################
function pixelsd(hObject, eventdata)
disableButtons; pixelsdH.FontWeight = 'bold';
pause(.02);


    memocon('COMPUTING STANDARD DEVIATION OF EACH STACK PIXEL...')

	nbins = str2double(pixelsdnumH.String);

    sz = size(IMG);
    t = round(linspace(1,sz(3),nbins));
    IM = double(IMG);

    IMV = [];
    for i = 1:numel(t)-1
        IMV(:,:,i) = std(IM(:,:, t(i):t(i+1) ) ,[],3);
    end
    IMV = mean(IMV,3);


    axes(haxSEG)
    phSEG = imagesc(IMV , 'Parent', haxSEG);
    pause(1)


pixelsdH.FontWeight = 'normal';
pause(.02); enableButtons
memocon('DONE!')
end














%###############################################################
%%      CREATE COMPOSITE IMAGE USING COMBINATION OF ABOVE
%###############################################################
function compimg(hObject, eventdata)
disableButtons; compimgH.FontWeight = 'bold';
pause(.02);



memocon('Creating composite image for ROI segmentation...');



NIM.IMG  = rescale(IMG,0,1);
NIM.SMIM = rescale(SMIM,0,1);
NIM.IMAX = rescale(IMAX,0,1);
NIM.ABIM = rescale(ABIM,0,1);
NIM.PCI  = rescale(PCI,0,1);
NIM.IMV  = rescale(IMV,0,1);


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
pause(4); 
close (fh02)





MAGE = NIM.IMG(:,:,1);
MAGE(:,:,1) = rescale(mean(NIM.IMG,3),0,1);
MAGE(:,:,2) = rescale(mean(NIM.SMIM,3),0,1);
MAGE(:,:,3) = rescale(mean(NIM.IMAX,3),0,1);
MAGE(:,:,4) = rescale(mean(NIM.ABIM,3),0,1);
MAGE(:,:,5) = rescale(mean(NIM.PCI,3),0,1);
MAGE(:,:,6) = rescale(mean(NIM.IMV,3),0,1);



MAGE(:,:,1) = rescale(MAGE(:,:,1).^2,0,1)./20;
MAGE(:,:,2) = rescale(MAGE(:,:,2).^2,0,1)./20;
MAGE(:,:,3) = rescale(MAGE(:,:,3).^2,0,1)./20;
MAGE(:,:,4) = rescale(MAGE(:,:,4).^2,0,1);
MAGE(:,:,5) = rescale(MAGE(:,:,5).^2,0,1);
MAGE(:,:,6) = rescale(MAGE(:,:,6).^2,0,1);


PIC = rescale(mean(MAGE(:,:,[1 2 3 4 5 5 5 6]),3),0,1);




    axes(haxSEG)
    phSEG = imagesc(PIC , 'Parent', haxSEG);
    colormap hot

    IMBW = PIC;

    memocon('DISPLAYING COMPOSITE IMG FOR SEGENTATION');
    clc; disp('DONE')


compimgH.FontWeight = 'normal';
pause(.02); enableButtons
end












%###############################################################
%%      IMAGE_SEGMENTATION_PROCESS_1   imadjust
%###############################################################
function imsegSaturate(hObject, eventdata)
% disableButtons; imseg1H.FontWeight = 'bold';
% pause(.02);

    memocon('Saturating image...');


    
    % Adjust the contrast of the image so that 1% of the data
    % is saturated at low and high intensities, and display it.
    IMBW = imadjust(PIC);


    phSEG = imagesc(IMBW , 'Parent', haxSEG);
    phSEG.CData=IMBW; pause(.3)




% IMBW = imbinarize(PIC,.1);
% IM1 = PIC;
% IM2 = imgradient(IM1);
% % IM3 = imbinarize(IM1,'adaptive','Sensitivity',.1);
% IM3 = imbinarize(IM1,.1);
% IM4 = watershed(IM3);
% IM5 = imbinarize(IM1,graythresh(IM1));
% 
% IM = IM1;
% IM(:,:,2) = IM2;
% IM(:,:,3) = IM3;
% IM(:,:,4) = IM4;
% IM(:,:,5) = IM5;
% 
% close all;
% montage(IM, 'Size', [2 3]);
% 
% % Create masked image.
% maskedImage = PIX;
% maskedImage(~BW) = 0;



BWMASK = IMBW;
BWRAW = PIC;
BWRAW(~BWMASK) = 0;


memocon('done.');
% compimgH.FontWeight = 'normal';
% pause(.02); enableButtons
end


%###############################################################
function gaborFeatures = createGaborFeatures(im)

disp('CREATING GABOR FEATURES PLEASE WAIT...')

if size(im,3) == 3
    im = prepLab(im);
end

im = im2single(im);

imageSize = size(im);
numRows = imageSize(1);
numCols = imageSize(2);

wavelengthMin = 4/sqrt(2);
wavelengthMax = hypot(numRows,numCols);
n = floor(log2(wavelengthMax/wavelengthMin));
wavelength = 2.^(0:(n-2)) * wavelengthMin;

deltaTheta = 45;
orientation = 0:deltaTheta:(180-deltaTheta);

g = gabor(wavelength,orientation);
gabormag = imgaborfilt(im(:,:,1),g);

for i = 1:length(g)
    sigma = 0.5*g(i).Wavelength;
    K = 3;
    gabormag(:,:,i) = imgaussfilt(gabormag(:,:,i),K*sigma);
end

% Increases liklihood that neighboring pixels/subregions are segmented together
X = 1:numCols;
Y = 1:numRows;
[X,Y] = meshgrid(X,Y);
featureSet = cat(3,gabormag,X);
featureSet = cat(3,featureSet,Y);
featureSet = reshape(featureSet,numRows*numCols,[]);

% Normalize feature set
featureSet = featureSet - mean(featureSet);
featureSet = featureSet ./ std(featureSet);

gaborFeatures = reshape(featureSet,[numRows,numCols,size(featureSet,2)]);

% Add color/intensity into feature set
gaborFeatures = cat(3,gaborFeatures,im);


disp('FINISHED CREATING GABOR FEATURES!')

end
%###############################################################

%###############################################################
function out = prepLab(in)

% Convert L*a*b* image to range [0,1]
out = in;
out(:,:,1)   = in(:,:,1) / 100;  % L range is [0 100].
out(:,:,2:3) = (in(:,:,2:3) + 100) / 200;  % a* and b* range is [-100,100].

end
%###############################################################






%###############################################################
%%      IMAGE_SEGMENTATION_PROCESS_2   imbinarize
%###############################################################
function imsegBinarize(hObject, eventdata)
% disableButtons; imseg1H.FontWeight = 'bold';
% pause(.02);

    memocon('Creating binary image...');



    IMBW = imbinarize(IMBW,.1);


    axes(haxSEG)
    phSEG = imagesc(IMBW , 'Parent', haxSEG);
    phSEG.CData=IMBW; pause(.3)


    
    BW = IMBW;

    %---------------TOO LITTLE SIGNAL
    s = 0;
    mu = mean(BW(:)); 
    memocon(['Binary image mean: ' num2str(mu)]);
    if mu < .01
        memocon('Increasing ROI signal...');
        for s = 0:.001:1

            BW = imbinarize(PIC,.1-s);
            phSEG.CData=BW; pause(.005)

            mu = mean(BW(:));
            if mu > .01; break; end
        end
    end
    memocon(['Binary image mean: ' num2str(mu)]);

    IMBW = BW;
    phSEG = imagesc(IMBW , 'Parent', haxSEG);
    phSEG.CData=IMBW; pause(.3)

    t = .1-s;


    %---------------TOO MUCH BACKGROUND
    if mu > .01
        memocon('Decreasing ROI signal...');
        for s = .1:.001:1

            BW = imbinarize(PIC,t);
            phSEG.CData=BW; pause(.005)
            t = t+.0002;

            mu = mean(BW(:));
            if mu < .01; break; end
        end
    end
    memocon(['Binary image mean: ' num2str(mu)]);

    IMBW = BW;
    phSEG = imagesc(IMBW , 'Parent', haxSEG);
    phSEG.CData=IMBW; pause(.3)




BWMASK = IMBW;
BWRAW  = PIC;
BWRAW(~BWMASK) = 0;

memocon('DONE.');
% compimgH.FontWeight = 'normal';
% pause(.02); enableButtons
end






%###############################################################
%%      IMAGE_SEGMENTATION_PROCESS_3  imopen
%###############################################################
function imsegIMOPEN(hObject, eventdata)
% disableButtons; imseg1H.FontWeight = 'bold';
% pause(.02);


    memocon('Opening ROIs on disk mask...');


    IMBW = imopen(IMBW, strel('disk', 1, 4));

    axes(haxSEG)
    phSEG = imagesc(IMBW , 'Parent', haxSEG);
    phSEG.CData=IMBW; pause(.3)





BWMASK = IMBW;
BWRAW  = PIC;
BWRAW(~BWMASK) = 0;

% memocon('done.');
% compimgH.FontWeight = 'normal';
% pause(.02); enableButtons
end





%###############################################################
%%      IMAGE_SEGMENTATION_PROCESS_4   activecontour
%###############################################################
function imsegACTIVECON(hObject, eventdata)
% disableButtons; imseg1H.FontWeight = 'bold';
% pause(.02);

    memocon('Active contour on textures');


    % Active contour with texture
    IMBW = activecontour(PIC, IMBW, 10, 'Chan-Vese');


    axes(haxSEG)
    phSEG = imagesc(IMBW , 'Parent', haxSEG);
    phSEG.CData=IMBW; pause(.3)








BWMASK = IMBW;
BWRAW  = PIC;
BWRAW(~BWMASK) = 0;

% memocon('done.');
% compimgH.FontWeight = 'normal';
% pause(.02); enableButtons
end






%###############################################################
%%      IMAGE_SEGMENTATION_PROCESS_4   imdilate
%###############################################################
function imsegDILATE(hObject, eventdata)
% disableButtons; imseg1H.FontWeight = 'bold';
% pause(.02);


    memocon('Dilate ROI mask with disk...');


    % Dilate mask with disk
    IMBW = imdilate(IMBW, strel('disk', 1, 4));

    axes(haxSEG)
    phSEG = imagesc(IMBW , 'Parent', haxSEG);
    phSEG.CData=IMBW; pause(.3)








BWMASK = IMBW;
BWRAW  = PIC;
BWRAW(~BWMASK) = 0;

% memocon('done.');
% compimgH.FontWeight = 'normal';
% pause(.02); enableButtons
end





%###############################################################
%%      IMAGE_SEGMENTATION_PROCESS_4  clearfill
%###############################################################
function imsegCLEARFILL(hObject, eventdata)
% disableButtons; imseg1H.FontWeight = 'bold';
% pause(.02);


    memocon('Clearing borders, filling holes...');


    % Clear borders, fill holes
    IMBW = imclearborder(IMBW);
    IMBW = imfill(IMBW, 'holes');

    axes(haxSEG)
    phSEG = imagesc(IMBW , 'Parent', haxSEG);
    phSEG.CData=IMBW; pause(.3)





BWMASK = IMBW;
BWRAW  = PIC;
BWRAW(~BWMASK) = 0;

% memocon('done.');
% compimgH.FontWeight = 'normal';
% pause(.02); enableButtons
end




%###############################################################
%%      IMAGE_SEGMENTATION_PROCESS_4  imerode
%###############################################################
function imsegERODE(hObject, eventdata)
% disableButtons; imseg1H.FontWeight = 'bold';
% pause(.02);



    memocon('Eroding ROI...');

    

    SE = strel('disk',3,6);

    %SE = strel('diamond',2);

    % SE = strel('line',10,50);
    % SE = offsetstrel('ball',5,5);
    % SE = strel('diamond',r)
    % SE = strel('disk',r,n)
    % SE = strel('line',len,deg)
    % SE = strel('octagon',r)
    % SE = strel('rectangle',mn)
    % SE = strel('square',w)
    % SE = strel('cube',w)
    % SE = strel('cuboid',xyz)
    % SE = strel('sphere',r)
    % SE = strel('arbitrary',nhood)


    IMBW = imerode(IMBW, SE);

    axes(haxSEG)
    phSEG = imagesc(IMBW , 'Parent', haxSEG);
    phSEG.CData=IMBW; pause(.3)





BWMASK = IMBW;
BWRAW  = PIC;
BWRAW(~BWMASK) = 0;

% memocon('done.');
% compimgH.FontWeight = 'normal';
% pause(.02); enableButtons
end































%###############################################################
%%                GET ROI ACTIVITY
%###############################################################
function ROIACTIVITY(hObject, eventdata)
% disableButtons; imseg1H.FontWeight = 'bold'; pause(.02);


memocon('Getting ROI activity...');


BWMASK = IMBW;
BWRAW  = PIC;
BWRAW(~BWMASK) = 0;


% GET REGION PROPERTIES & STATISTICS
%--------------------------------------------------------

IMFO.stats = regionprops(BWMASK);

[IMFO.bi,IMFO.labs,IMFO.n,IMFO.a] = bwboundaries(BWMASK,'noholes');








% PLOT BOUNDING COORDINATES AROUND ROIs
%--------------------------------------------------------
    axes(haxSEG)
    phSEG = imagesc(BWMASK , 'Parent', haxSEG);
    phSEG.CData=BWMASK; colormap bone; hold on; pause(.3)

    for i = 1:numel(IMFO.stats)
        scatter(IMFO.bi{i}(:,2),IMFO.bi{i}(:,1),'.')
        hold on
    end

    pause(3)
    delete(findobj(haxSEG,'Type','Scatter'))






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




% DETERMINE IF MORPHOLOGY STATS MEET FILTER CRITERIA
%--------------------------------------------------------

    TOO.SMALL = AREA_FILTER(1) > Area;

    TOO.BIG   = AREA_FILTER(2) < Area;

    FAIL = TOO.SMALL | TOO.BIG;
    F = find(FAIL);


    nROIs = numel(Area);   
    memocon(['Total ROI count (first-pass): ' num2str(nROIs)])


    nSmall = sum(TOO.SMALL);
    memocon(['Number of ROIs below size threshold: ' num2str(nSmall)])

    nBig   = sum(TOO.BIG);
    memocon(['Number of ROIs above size threshold: ' num2str(nBig)])

    pause(1)




% REMOVE ROIS THAT DID NOT PASS ALL THRESH TESTS
%--------------------------------------------------------
memocon('Removing ROIs that did not pass thresholds')

    BW = IMFO.labs;
    for i = 1:numel(F)
        BW(BW == F(i)) = 0;
    end

    BWMASK = BW > 0;





% AGAIN GET REGION PROPERTIES & STATISTICS
%--------------------------------------------------------
memocon('Getting region properties & statistics')

IMFO.stats = regionprops(BWMASK);

[IMFO.bi,IMFO.labs,IMFO.n,IMFO.a] = bwboundaries(BWMASK,'noholes');





% AGAIN PLOT BOUNDING COORDINATES AROUND ROIs
%--------------------------------------------------------
memocon('Plotting boarders for ROIs that passed thresholds')

    axes(haxSEG)
    phSEG = imagesc(BWMASK , 'Parent', haxSEG);
    phSEG.CData=BWMASK; colormap bone; hold on; pause(.3)

    for i = 1:numel(IMFO.stats)
        scatter(IMFO.bi{i}(:,2),IMFO.bi{i}(:,1),'.')
        hold on
    end

    pause(3)
    delete(findobj(haxSEG,'Type','Scatter'))




%% SHOW ROI ACTIVITY AND GET MEAN ACTIVITY IN EACH ROI
%---------------------------------------------
memocon('Suppressing background; showing ROI activity')

    I = rescale(IMG,0,1) .* BWMASK;

    previewFullStack(I)




%% GET MEAN ACTIVITY IN EACH ROI
%--------------------------------------------------------
memocon('Computing mean activity in each ROI')


    IM = rescale(IMG,0,1);
    MUJ=[];
    for i = 1:IMFO.n

        msk = IMFO.labs==i;

        for j = 1:size(IM,3)

            IMJ = IM(:,:,j);

            MUJ(i,j) = mean(IMJ(msk));
        end
    end

    ROIS = MUJ';

    minROI = min(ROIS);

    ROIS = ROIS - minROI;

    ROIS = rescale(ROIS,0,1);





%% DETERMINE IF ACTIVITY IS SIMPLY RUNUP OR RUNDOWN
%--------------------------------------------------------
memocon('Determining if activity is due to linear trend')

    nbins = 9;

    t = round(linspace(1,size(ROIS,2),nbins));

    StartMu = mean(  ROIS( t(2):t(3)         ,:)  );
    EndMu   = mean(  ROIS( t(end-3):t(end-2) ,:)  );

    IRUN = StartMu - EndMu;
    IRUNmu = mean(IRUN);
    IRUNsd = std(IRUN);

    RAN = (IRUN > (IRUNsd*2 + IRUNmu)) | (IRUN < (IRUNsd*-2 + IRUNmu));




%% AGAIN REMOVE ROIS THAT DID NOT PASS ALL THRESH TESTS
%--------------------------------------------------------
memocon('Removing ROIs selected only based on linear trend')

    ROIS(:,RAN) = [];

    F = find(RAN);

    BW = IMFO.labs;
    for i = 1:numel(F)
        BW(BW == F(i)) = 0;
    end

    BWMASK = BW > 0;

    IMFO.stats = regionprops(BWMASK);
    [IMFO.bi,IMFO.labs,IMFO.n,IMFO.a] = bwboundaries(BWMASK,'noholes');



% AGAIN PLOT BOUNDING COORDINATES AROUND ROIs
%--------------------------------------------------------
    axes(haxSEG)
    phSEG = imagesc(BWMASK , 'Parent', haxSEG);
    phSEG.CData=BWMASK; colormap bone; hold on; pause(.3)

    for i = 1:numel(IMFO.stats)
        scatter(IMFO.bi{i}(:,2),IMFO.bi{i}(:,1),'.')
        hold on
    end

    pause(3)
    delete(findobj(haxSEG,'Type','Scatter'))




%% SHOW ROI ACTIVITY AND GET MEAN ACTIVITY IN EACH ROI
%---------------------------------------------

    I = rescale(IMG,0,1) .* BWMASK;

    previewFullStack(I)








%%  PLOT MEAN ACTIVITY IN EACH ROI
%--------------------------------------------------------
memocon('Plotting mean activity in each ROI')
memocon('  (showing only three-at-a-time)')

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
    pause(1)
    close(fh1)





%%  PLOT MEAN ACTIVITY FOR ALL ROIs
%--------------------------------------------------------
memocon('Plotting mean activity for all ROIs')

    fh1 = figure('Units','normalized','Position',[.05 .08 .88 .85],...
        'Color','w','MenuBar','none');
    ax1 = axes('Position',[.06 .06 .9 .9],'Color','none');

    n = size(ROIS,2);
    f = size(ROIS,1);

    R = ROIS + repmat(1:n,f,1);

    ph = plot(R,'LineWidth',3);
    pause(1)

    ROITABLE = table(ROIS);



    fh2 = figure('Units','pixels','Position',[10 35 1300 500],...
        'Color','w','MenuBar','none');
    ax2 = axes('Position',[.06 .06 .9 .9],'Color','none');
    ax2.YLim = [0 1]; hold on


    ph = plot(ROIS,'LineWidth',5);
    pause(1)

    



% memocon('done.');
% compimgH.FontWeight = 'normal';
% pause(.02); enableButtons
end

















%########################################################################
%%  EXPORT ROI ACTIVITY TRACES TO SPREADSHEET
%########################################################################
function exportROIACT2FILE(hObject, eventdata)
% disableButtons; imseg1H.FontWeight = 'bold'; pause(.02);


    memocon('SAVING ROI DATA TO MAT & CSV FILES...')

    NIM.IMG = uint8(rescale(NIM.IMG,0,1).*255);
    NIM.SMIM = uint8(rescale(NIM.SMIM,0,1).*255);
    NIM.ABIM = uint8(rescale(NIM.ABIM,0,1).*255);


    [path,name] = fileparts(PIX.info.Filename{1});


    save(['ROI_ANALYSIS_' name '.mat'],...
        'NIM','PIX','PC','MAGE','PIC','BWMASK',...
        'IMFO','ROIS','ROITABLE');

    writetable(ROITABLE,['ROI_ANALYSIS_' name '.csv'])


    memocon('Files saved to...')
    memocon(['    ROI_ANALYSIS_' name '.mat'])
    memocon(['    ROI_ANALYSIS_' name '.csv'])


% memocon('done.');
% compimgH.FontWeight = 'normal';
% pause(.02); enableButtons
end

















%########################################################################
%%  EXPORT ROI ACTIVITY TRACES TO SPREADSHEET
%########################################################################
function exportROIACT2WS(hObject, eventdata)
% disableButtons; imseg1H.FontWeight = 'bold'; pause(.02);



    memocon('Choose which variables to export to main workspace')


    labels = {...
    'Save PIX      to variable named:' ...
    'Save IMG      to variable named:' ...
    'Save SMIM     to variable named:' ...
    'Save PC       to variable named:' ...
    'Save ABIM     to variable named:' ...
    'Save PCI      to variable named:' ...
    'Save IMAX     to variable named:' ...
    'Save IMV      to variable named:' ...
    'Save NIM      to variable named:' ...
    'Save MAGE     to variable named:' ...
    'Save PIC      to variable named:' ...
    'Save BWMASK   to variable named:' ...
    'Save IMFO     to variable named:' ...
    'Save ROIS     to variable named:' ...
    'Save ROITABLE to variable named:' ...
    'Save ROIL     to variable named:' ...
    }; 


    vars = {'PIX','IMG','SMIM','PC','ABIM','PCI','IMAX','IMV','NIM','MAGE',...
            'PIC','BWMASK','IMFO','ROIS','ROITABLE','ROIL'};


    vals = {PIX , IMG , SMIM , PC , ABIM , PCI , IMAX , IMV , NIM , MAGE,...
            PIC , BWMASK , IMFO , ROIS , ROITABLE , ROIL};


    export2wsdlg(labels,vars,vals);



    memocon('Selected variables exported to main workspace.')


% memocon('done.');
% compimgH.FontWeight = 'normal';
% pause(.02); enableButtons
end
















%% NUMBER EACH ROI AND SHOW IMAGE
%{



xy = reshape(cell2mat({IMFO.stats.Centroid}),2,[])';


close all
imagesc(IMG(:,:,1) .* BWMASK); hold on;
scatter(xy(:,1),xy(:,2),'r')


for i = 1:size(xy,1)

    text(xy(i,1),xy(i,2),num2str(i)); hold on


end



%}





%% #####################################################################
%--------------------------------------------
%        IMGBLOCKS POPUP MENU CALLBACK
%--------------------------------------------
function imgpcpopup(hObject, eventdata)
        
    blockSize = str2num(imgpcpopupH.String(imgpcpopupH.Value,:));
    
    fprintf('\n\n New tile size: % s \n\n', num2str(blockSize));
    memocon(sprintf('New tile size: % s ', num2str(blockSize)));
    
    % imgpcpopupH.String
    % imgpcpopupH.Value

end



%--------------------------------------------
%  GET FACTORS DIVIDE EVENLY INTO size(IMG,1)
%--------------------------------------------
function update_IMGfactors()
    
    szIMG = size(IMG,1);
        
    s=1:szIMG;
    
    IMGfactors = s(rem(szIMG,s)==0);
    
% imgpcpopupH.String = IMGfactors;
%    
%     if ~mod(szIMG,10)        
%         
%         imgpcpopupH.Value = find(IMGfactors==(szIMG/10));
%         blockSize = str2num(imgpcpopupH.String(imgpcpopupH.Value,:));
%     
% %     if any(IMGfactors == 22)
% %         
% %         imgpcpopupH.Value = find(IMGfactors==22);
% %         blockSize = str2num(imgpcpopupH.String(imgpcpopupH.Value,:));
%         
%     elseif numel(IMGfactors) > 2
% 
%         imgpcpopupH.Value = round(numel(IMGfactors)/2)+1;
%         blockSize = str2num(imgpcpopupH.String(imgpcpopupH.Value,:));
%         
%     else
%         
%         imgpcpopupH.Value = ceil(numel(IMGfactors)/2);
%         blockSize = str2num(imgpcpopupH.String(imgpcpopupH.Value,:));
%     
%     end
    

    % fprintf('\n\n New tile size: % s \n\n', num2str(blockSize));

end






%% ------------------------- PLOTS FIGURES GRAPHS ------------------------------


%----------------------------------------------------
%        GET ROI STATISTICS
%----------------------------------------------------
function openROITOOLBOX(hObject, eventdata)
% disableButtons; pause(.02);


    if size(muIMGS,1) < 1
       
        msgbox('DATA HAS NOT BEEN PROCESSED'); 
        
        enableButtons
        
        return
        
    end
    
    memocon('Opening ROI TOOLBOX')
    
    % mainguih.HandleVisibility = 'off';
    % close all;
    % set(mainguih, 'Visible', 'Off');
    
    graphguih = ROITOOLBOXGUI(IMG, SEGstruct, SEGtable, XLSdata, IMGraw, IMGSraw, muIMGS, LICK);
    
    
    
%     waitfor(graphguih)
%     mainguih.HandleVisibility = 'off';
%     close all;
%     mainguih.HandleVisibility = 'on';
    
%     close all;
%     mainguih.HandleVisibility = 'on';
%     set(mainguih, 'Visible', 'On');
    
enableButtons
% memocon('Compute ROI statistics!')
end





%----------------------------------------------------
%        ENABLE AND DISABLE GUI BUTTONS
%----------------------------------------------------
function enableButtons()


    runallIPH.Enable = 'on';

    cropimgH.Enable    = 'on';
    smoothimgH.Enable  = 'on';
    imgpcH.Enable      = 'on';
    remrescaleH.Enable = 'on';
    iminimaxH.Enable   = 'on';
    pixelsdH.Enable    = 'on';
    compimgH.Enable    = 'on';



    imseg1H.Enable = 'on';
    imseg2H.Enable = 'on';
    imseg3H.Enable = 'on';
    imseg4H.Enable = 'on';
    imseg5H.Enable = 'on';
    imseg6H.Enable = 'on';
    imseg7H.Enable = 'on';

    exportvarsH.Enable = 'on';
    exportfileH.Enable = 'on';


%     getROIstatsH.Enable = 'on';
%     plotTileStatsH.Enable = 'on';
%     previewStackH.Enable = 'on';
%     viewGridOverlayH.Enable = 'on';
%     plotGroupMeansH.Enable = 'on';
%     viewTrialTimingsH.Enable = 'on';
%     plotGUIH.Enable = 'on';


end
function disableButtons()
    
    cropimgH.Enable    = 'off';
    smoothimgH.Enable  = 'off';
    imgpcH.Enable      = 'off';
    remrescaleH.Enable = 'off';
    iminimaxH.Enable   = 'off';
    pixelsdH.Enable    = 'off';
    compimgH.Enable    = 'off';


    imseg1H.Enable = 'off';
    imseg2H.Enable = 'off';
    imseg3H.Enable = 'off';
    imseg4H.Enable = 'off';
    imseg5H.Enable = 'off';
    imseg6H.Enable = 'off';
    imseg7H.Enable = 'off';

    exportvarsH.Enable = 'off';
    exportfileH.Enable = 'off';


    getROIstatsH.Enable = 'off';
    plotTileStatsH.Enable = 'off';
    runallIPH.Enable = 'off';
    previewStackH.Enable = 'off';
    viewGridOverlayH.Enable = 'off';
    plotGroupMeansH.Enable = 'off';
    viewTrialTimingsH.Enable = 'off';
    plotGUIH.Enable = 'off';


end




%----------------------------------------------------
%        MEMO LOG UPDATE
%----------------------------------------------------
function memocon(spf,varargin)
    
  
    if iscellstr(spf)
        spf = [spf{:}];
    end
    
    if iscell(spf)
        return
        keyboard
        spf = [spf{:}];
    end
    
    if ~ischar(spf)
        return
        keyboard
        spf = [spf{:}];
    end
    
    

    memes(1:end-1) = memes(2:end);
    memes{end} = spf;
    conboxH.String = memes;
    pause(.02)
    
    if nargin == 3
        
        vrs = deal(varargin);
                
        memi = memes;
                 
        memes(1:end) = {' '};
        memes{end-1} = vrs{1};
        memes{end} = spf;
        conboxH.String = memes;
        
        conboxH.FontAngle = 'italic';
        conboxH.ForegroundColor = [.9 .4 .01];
        pause(vrs{2})
        
        conboxH.FontAngle = 'normal';
        conboxH.ForegroundColor = [0 0 0];
        conboxH.String = memi;
        pause(.02)
        
    elseif nargin == 2
        vrs = deal(varargin);
        pause(vrs{1})
    end
    
    
    

end







%----------------------------------------------------
%        GET ROI STATISTICS
%----------------------------------------------------
function getROIstats(hObject, eventdata)
disableButtons; pause(.02);


    if size(muIMGS,1) < 1
       
        msgbox('DATA HAS NOT BEEN PROCESSED'); 
        
        enableButtons
        
        return
        
    end

    
    % PREVIEW AN ROI FOR A SINGLE CSUS AVERAGED OVER TRIALS
    memocon(' '); memocon('GETTING ROI STATISTICS'); 

    fh1=figure('Units','normalized','OuterPosition',[.40 .22 .59 .75],'Color','w');
    hax1 = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[]);

    ih1 = imagesc(muIMGS(:,:,1,1));

    memocon('Use mouse to trace around a region of interest on the figure.')
    hROI = imfreehand(hax1);   
    ROIpos = hROI.getPosition;
    ROIarea = polyarea(ROIpos(:,1),ROIpos(:,2));


    ROImask = hROI.createMask(ih1);
    
    ROI_INTENSITY = muIMGS(:,:,1,1) .* ROImask;
    figure; imagesc(ROI_INTENSITY); colorbar;




    % Here we are computing the average intensity for the selected ROI
    % N.B. here it is assumed that a pixel value (actually dF/F value)
    % has virtually a zero probability of equaling exactly zero; this
    % allows us to multiply the mask T/F matrix by the image matrix
    % and disclude from the average all pixels that equal exactly zero
    
    ROImu = zeros(size(muIMGS,4),size(muIMGS,3));
    for mm = 1:size(muIMGS,4)
        for nn = 1:size(muIMGS,3)
        
        ROI_INTENSITY = muIMGS(:,:,nn,mm) .* ROImask;
        ROImu(mm,nn) = mean(ROI_INTENSITY(ROI_INTENSITY ~= 0));

        end
    end

    CSUSplot(ROImu', SEGstruct);
    % CSUSplot(ROImu', SEGstruct, CSUSonoff);
    % previewstack(squeeze(muIMGS(:,:,:,1)), CSUSonoff, ROImu)
    
    
    
    
enableButtons
memocon('Compute ROI statistics completed!')
end





%----------------------------------------------------
%        PLOT TILE STATS DATA
%----------------------------------------------------
function plotTileStats(hObject, eventdata)
% disableButtons; pause(.02);


    if size(muIMGS,1) < 1
       
        msgbox('DATA HAS NOT BEEN PROCESSED'); 
        
        enableButtons
        
        return
        
    end

    memocon(' '); memocon('PLOTTING TILE STATS DATA (PLEASE WAIT)...'); 
    
    
    blockSize = str2num(imgpcpopupH.String(imgpcpopupH.Value,:));

    pxl = muIMGS(1:blockSize:end,1:blockSize:end,:,:);

    pixels = squeeze(reshape(pxl,numel(pxl(:,:,1)),[],size(pxl,3),size(pxl,4)));
    
    CSids = unique(SEGstruct.csus);
    
    
    %-------------------------- MULTI-TILE FIGURE --------------------------

    fh10=figure('Units','normalized','OuterPosition',[.02 .02 .90 .90],'Color','w');
    
    set(fh10,'ButtonDownFcn',@(~,~)memocon('figure'),...
   'HitTest','off')
    
    
    
    aXlocs =  (0:(size(pxl,1))) .* (1/(size(pxl,1)));
    aXlocs(end) = [];
    aYlocs =  (0:(size(pxl,2))) .* (1/(size(pxl,2)));
    aYlocs(end) = [];
    aXlocs = aXlocs+.005;
    aYlocs = aYlocs+.005;
    [aX,aY] = meshgrid(aXlocs,aYlocs);
    
    if strcmp(NormType,'dF')
        
        YL = [-.15 .15];

    elseif strcmp(NormType,'Zscore')
        
        YL = [-2 4];
        
    elseif strcmp(NormType,'Dprime')
        
        YL = [-.15 .15];
        
    else
        YL = 'auto';
    end
    

    % PLOT ALL THE TILES ON A SINGLE FIGURE WINDOW. THIS PLOTS THE FIRST
    % AXIS IN THE BOTTOM LEFT CORNER AND FIRST FILLS UPWARD THEN RIGHTWARD
    for ii = 1:size(pixels,1)

        axh{ii} = axes('Position',[aX(ii) aY(ii) (1/(size(pxl,1)+1)) (1/(size(pxl,2)+1))],...
        'Color','none','Tag',num2str(ii)); 
        % axis off;
        hold on;
    
        % h = squeeze(pixels(ii,:,:));
        tiledatX{ii} = 1:size(pixels,2);
        tiledatY{ii} = squeeze(pixels(ii,:,:));
        
        pha{ii} = plot( 1:size(pixels,2) , squeeze(pixels(ii,:,:)));
        % set(gca,'YLim',YL)
        ylim(YL)
        cYlim = get(gca,'YLim');
        line([CSUSonoff(1) CSUSonoff(1)],cYlim,'Color',[.8 .8 .8])
        line([CSUSonoff(2) CSUSonoff(2)],cYlim,'Color',[.8 .8 .8])
        
        
        set(axh{ii},'ButtonDownFcn',@(~,~)disp(gca),...
        'HitTest','on')
        
    end
        pause(.05)
    
    % INCREASE LINE WIDTH CHENYU
    for ii = 1:size(pha,2)
        for jj = 1:size(pha{ii},1)
            pha{ii}(jj).LineWidth = 3;
        end
    end
    
    
    %keyboard
    % REMOVE AXES CLUTTER
    %axh{ii}
    
    
    
    
    
    legpos = {  [0.01,0.95,0.15,0.033], ...
                [0.01,0.92,0.15,0.033], ...
                [0.01,0.89,0.15,0.033], ...
                [0.01,0.86,0.15,0.033], ...
                [0.01,0.83,0.15,0.033], ...
                [0.01,0.80,0.15,0.033], ...
                };
    
    pc = {pha{1}.Color};
    pt = CSids;
    
    for nn = 1:size(pixels,3)
        
    annotation(fh10,'textbox',...
    'Position',legpos{nn},...
    'Color',pc{nn},...
    'FontWeight','bold',...
    'String',pt(nn),...
    'FontSize',12,...
    'FitBoxToText','on',...
    'EdgeColor',pc{nn},...
    'FaceAlpha',.8,...
    'Margin',3,...
    'LineWidth',1,...
    'VerticalAlignment','bottom',...
    'BackgroundColor',[1 1 1]);
    
    end
    
    annotation(fh10,'textbox',...
    'Position',[.85 .975 .15 .04],...
    'Color',[0 0 0],...
    'FontWeight','bold',...
    'String','RIGHT-CLICK ANY GRAPH TO EXPAND',...
    'FontSize',10,...
    'FitBoxToText','on',...
    'EdgeColor','none',...
    'FaceAlpha',.7,...
    'Margin',3,...
    'LineWidth',2,...
    'VerticalAlignment','bottom',...
    'BackgroundColor',[1 1 1]);


    annotation(fh10,'textbox',...
    'Position',[.01 .975 .15 .04],...
    'Color',[0 0 0],...
    'FontWeight','bold',...
    'String',SEGstruct.file,...
    'FontSize',12,...
    'FitBoxToText','on',...
    'EdgeColor','none',...
    'FaceAlpha',.7,...
    'Margin',3,...
    'LineWidth',2,...
    'VerticalAlignment','bottom',...
    'Interpreter','none',...
    'BackgroundColor',[1 1 1]);
    
    
    % haxN = axes('Position',[.001 .001 .99 .99],'Color','none');
    % axis off; hold on;
    pause(.2)
    %-------------------------------------------------------------------------
    

    hcmenu = uicontextmenu;

    item1 = uimenu(hcmenu,'Label','OPEN IN ADVANCED PLOT GUI','Callback',@plottile);

    haxe = findall(fh10,'Type','axes');

         % Attach the context menu to each axes
    for aa = 1:length(haxe)
        set(haxe(aa),'uicontextmenu',hcmenu)
    end   
        

    
    
    
    
    
    gridbutton = uicontrol(fh10,'Units','normalized',...
                  'Position',[.01 .01 .1 .05],...
                  'String','Toggle Grid',...
                  'Tag','gridbutton',...
                  'Callback',@toggleGridOverlay);
    
    
    savetilesH = uicontrol(fh10,'Units','normalized',...
                  'Position',[.90 .01 .1 .05],...
                  'String','Save Tile Data',...
                  'Tag','gridbutton',...
                  'Callback',@savetilesfun);    
    
    
    
%     % Add 'doprint' checkbox before implementing this code
%     print(fh10,'-dpng','-r300','tilefig')
%     
%     hFig = figure('Toolbar','none',...
%               'Menubar','none');
%     hIm = imshow('tilefig.png');
%     hSP = imscrollpanel(hFig,hIm);
%     set(hSP,'Units','normalized',...
%         'Position',[0 .1 1 .9])        
        
        
enableButtons
memocon('PLOTTING TILE STATS DATA COMPLETED!')

end





%----------------------------------------------------
%        PLOT TILE CALLBACK - LAUNCH TILEplotGUI.m
%----------------------------------------------------
function plottile(hObject, eventdata)
% disableButtons; pause(.02);

    axdat = gca;
    
    axesdata = axdat.Children;
    
    TILEplotGUI(axesdata, SEGstruct, XLSdata, LICK)
 
end





%----------------------------------------------------
%        PLOT TILE CALLBACK - LAUNCH TILEplotGUI.m
%----------------------------------------------------
function savetilesfun(hObject, eventdata)
% disableButtons; pause(.02);


    % tiledatX
    
    for nn = 1:length(tiledatY)
        maxT(nn) = max(max(tiledatY{nn}));
    end
    
    TILE = tiledatY;
    
    uisave({'TILE','SEGstruct','XLSdata'},...
           ['TILE_' SEGstruct.file(1:end-4)]);
 
end





%----------------------------------------------------
%        RUN PCA
%----------------------------------------------------
function runPCA(hObject, eventdata)
% disableButtons; pause(.02);


t1=[];
t2=[];
t3=[];
t4=[];


hb = round(blockSize / 2);

PIM = IMG( hb:blockSize:end, hb:blockSize:end, : , : );

size(PIM)


CSp = squeeze(PIM(:,:,:,SEGstruct.tf(:,2)));

CSm = squeeze(PIM(:,:,:,SEGstruct.tf(:,1)));


size(CSp)
size(CSm)


CSp = CSp(3:7,3:7,:,:);
CSm = CSm(3:7,3:7,:,:);

szCSp = size(CSp)
szCSm = size(CSm)


CSP = squeeze(reshape(CSp,[],1,szCSp(3),szCSp(4)));
CSM = squeeze(reshape(CSm,[],1,szCSm(3),szCSm(4)));

size(CSP)
size(CSM)

CSplus  = CSP;
CSminus = CSM;

% save('SEGDATA.mat','CSplus','CSminus')

keyboard

size(CSP)
size(CSM)


figure
imagesc(CSM(:,:,1))

keyboard

%%
X = [];
Y = [];

Y = rand(10,100) .* .01;

figure
plot(Y')

X = X - mean(X);


covMX = 1/(n-1) * sum((X - mean(X)) * (X - mean(X))');






%%

SEGstruct.TreatmentGroups{1}
size(CSm)

SEGstruct.TreatmentGroups{2}
size(CSp)





% PCAdata = permute(CSM,[3 1 2]);
PCAdata = CSM;

size(PCAdata)


MaxComponents = 10;
opt = statset('pca');
opt.MaxIter = 5000;

[PCAScof,PCAval,PCAlat,PCAtsq,PCAexp,PCAmu] = pca( PCAdata ,...
    'Options',opt,'NumComponents',MaxComponents);



disp(PCAexp)


figure
plot(PCAScof(:,1:2))
hold on

figure
plot(PCAval)

x = repmat((1:size(PCAScof,1))',1,2);

scatter( x(:)  ,  PCAScof(:) )



clc
sum(PCASexp(:))

% format shortG
% PCASval(1:5 , :)












% [PCAScof,PCASval,PCAlat,PCAtsq,PCASexp,PCAmu] = pca(...
%     PCAdata,'Options',opt,'Algorithm','svd','NumComponents',Ncomps,'Centered',false);

% PCAStopcof = PCAScof(1,:);
% PCAScentered = PCASval*PCAScof';
% PCAStsredu = mahal(PCASval,PCASval);
% PCAStsqdiscard = PCASts - PCAStsredu;


% size(PIM)
% size(IMG)
% size(muIMGS)
% SEGstruct.tf
% XLSdata
% blockSize = str2num(imgpcpopupH.String(imgpcpopupH.Value,:));
% pxl = muIMGS(1:blockSize:end,1:blockSize:end,:,:);
% pixels = squeeze(reshape(pxl,numel(pxl(:,:,1)),[],size(pxl,3),size(pxl,4)));
% CSids = unique(SEGstruct.csus);
% for ii = 1:size(pixels,1)
%     tiledatX{ii} = 1:size(pixels,2);
%     tiledatY{ii} = squeeze(pixels(ii,:,:));
%     pha{ii} = squeeze(pixels(ii,:,:));
% end
% ii = 48;
% PCAdata = squeeze(pixels(ii,:,:))';





enableButtons        
memocon('Run custom function completed!')
end







%----------------------------------------------------
%    ADVANCED PLOTTING GUI - LAUNCH SEGplotGUI.m
%----------------------------------------------------
function plotGUI(hObject, eventdata)
% disableButtons; pause(.02);

    if size(muIMGS,1) < 1
       
        msgbox('DATA HAS NOT BEEN PROCESSED'); 
        
        enableButtons
        
        return
        
    end
    
    SEGplotGUI(IMG, SEGstruct, XLSdata, LICK, IMGSraw)
 
end




%----------------------------------------------------
%        VIEW GRID OVERLAY
%----------------------------------------------------
function viewGridOverlay(hObject, eventdata)
% disableButtons; pause(.02);



    
    %-------------------------- IMGraw FIGURE GRID --------------------------
    
    blockSize = str2num(imgpcpopupH.String(imgpcpopupH.Value,:));
    
    fprintf('\n\n Grid size is% d pixels \n\n', blockSize)

    if length(muIMGS) < 1
        
        pxl = zeros(size(IMG,1) / blockSize);
        
    else
    
        pxl = muIMGS(1:blockSize:end,1:blockSize:end,:,:);
        pixels = squeeze(reshape(pxl,numel(pxl(:,:,1)),[],size(pxl,3),size(pxl,4)));
    
    end
    
    
    aXlocs =  (0:(size(pxl,1))) .* (1/(size(pxl,1)));
    aXlocs(end) = [];
    aYlocs =  (0:(size(pxl,2))) .* (1/(size(pxl,2)));
    aYlocs(end) = [];
    aXlocs = aXlocs+.005;
    aYlocs = aYlocs+.005;
    [aX,aY] = meshgrid(aXlocs,aYlocs);
    YL=[-.15 .15];
    
    
    hFig = figure('Units','normalized','OuterPosition',[.1 .1 .5 .8],'Color','w','MenuBar','none','Name','SEGGRID');
    axR = axes;
    phR = imagesc(IMGraw);
    grid on
    axR.YTick = [0:blockSize:size(IMGraw,1)];
    axR.XTick = [0:blockSize:size(IMGraw,1)];
    % axR.YTickLabel = 1:30;
    
    axR.GridAlpha = .8;
    axR.GridColor = [0.99 0.1 0.1];
    
        tv1 = 1:size(IMGraw,1);
        
        pause(.2)
        
        
        % NUMBERING IS TECHNICALLY INCORRECT SINCE BELOW AXIS #1 STARTS IN THE
        % BOTTOM LEFT CORNER AND GOES UP, AND HERE IT STARTS IN THE TOP
        % LEFT CORNER AND GOES DOWN. NOT SURE THAT IT MATTERS...
        for ii = 1:size(pxl,1)^2
            
            tv2 = [  aX(ii)*size(IMGraw,1)   aY(ii)*size(IMGraw,1)+2 ...
                    (1/(size(pxl,1)+1))     (1/(size(pxl,2)+1))];

            text(tv2(1),tv2(2),num2str(tv1(ii)),'Color','r','Parent',axR);
    
        end
        
     pause(.1)
    %-------------------------------------------------------------------------


%{

mjf = get(hFig, 'JavaFrame');
jWindow = mjf.fHG2Client.getWindow;
mjc = jWindow.getContentPane;
mjr = jWindow.getRootPane;
figTitle = jWindow.getTitle;
jFrame = javaObjectEDT(javax.swing.JFrame(figTitle));
jFrame.setUndecorated(true);
jFrame.setLocation(mjc.getLocationOnScreen);
jFrame.setSize(mjc.getSize);
jFrame.setContentPane(mjc);
jFrame.setVisible(true);


MUtilities.setFigureFade(gcf, 0.2)
 
hFig.Visible = 'off';
    
    
% jFrame.setVisible(false)





%------------------------------------

% Create a simple Matlab figure (visible, but outside monitor area)
t = 0 : 0.01 : 10;
hFig = figure('Name','Plot example', 'ToolBar','none', 'MenuBar','none');
hLine = plot(t, cos(t));
hButton = uicontrol('String','Close', 'Position',[307,0,45,16]);
 
% Ensure that everything is rendered, otherwise the following will fail
drawnow;
 
% Get the underlying Java JFrame reference handle
mjf = get(handle(hFig), 'JavaFrame');
jWindow = mjf.fHG2Client.getWindow;  % or: mjf.getAxisComponent.getTopLevelAncestor
 
% Get the content pane's handle
mjc = jWindow.getContentPane;
mjr = jWindow.getRootPane;  % used for the offset below
 
% Create a new pure-Java undecorated JFrame
figTitle = jWindow.getTitle;
jFrame = javaObjectEDT(javax.swing.JFrame(figTitle));
jFrame.setUndecorated(true);
 
% Move the JFrame's on-screen location just on top of the original
jFrame.setLocation(mjc.getLocationOnScreen);
 
% Set the JFrame's size to the Matlab figure's content size
%jFrame.setSize(mjc.getSize);  % slightly incorrect by root-pane's offset
jFrame.setSize(mjc.getWidth+mjr.getX, mjc.getHeight+mjr.getY);
 
% Reparent (move) the contents from the Matlab JFrame to the new JFrame
jFrame.setContentPane(mjc);
 
% Make the new JFrame visible
jFrame.setVisible(true);


MUtilities.setFigureFade(gcf, 0.5)
 
hFig.Visible = 'off';

%}


enableButtons
memocon('GRID OVERLAY HAS BEEN GENERATED.')
end







%----------------------------------------------------
%        TOGGLE GRID OVERLAY
%----------------------------------------------------
function toggleGridOverlay(hObject, eventdata)
% disableButtons; pause(.02);


    if toggrid == 1
        if isvalid(axGRID)
            delete(axGRID.Children)
            delete(axGRID)
        end
            toggrid = 0;
        return
    end
    toggrid = 1;
    
    %-------------------------- IMGraw FIGURE GRID --------------------------
    
    blockSize = str2num(imgpcpopupH.String(imgpcpopupH.Value,:));
    
    fprintf('\n\n Grid size is% d pixels \n\n', blockSize)

    if length(muIMGS) < 1
        
        pxl = zeros(size(IMG,1) / blockSize);
        
    else
    
        pxl = muIMGS(1:blockSize:end,1:blockSize:end,:,:);
        pixels = squeeze(reshape(pxl,numel(pxl(:,:,1)),[],size(pxl,3),size(pxl,4)));
    
    end
    
    
    aXlocs =  (0:(size(pxl,1))) .* (1/(size(pxl,1)));
    aXlocs(end) = [];
    aYlocs =  (0:(size(pxl,2))) .* (1/(size(pxl,2)));
    aYlocs(end) = [];
    aXlocs = aXlocs+.005;
    aYlocs = aYlocs+.005;
    [aX,aY] = meshgrid(aXlocs,aYlocs);
    YL=[-.15 .15];
    
    
    
    %-------------------------------------------------------------------------

    axGRID = axes('Position',[.001 .001 .999 .999],'Color','none'); hold on;

    phR = imagesc(IMGraw,'Parent',axGRID,...
          'CDataMapping','scaled','AlphaData',0.6);
        axis image;  pause(.01)
        axis normal; pause(.01)
    
    
        axGRID.YTick = [0:blockSize:size(IMGraw,1)];
        axGRID.XTick = [0:blockSize:size(IMGraw,1)];
        
        axGRID.GridAlpha = .8;
        axGRID.GridColor = [0.99 0.1 0.1];
    

    
        tv1 = 1:size(IMGraw,1);
        
        pause(.2)
        
        
        % PLOT GRID IN A SINGLE FIGURE WINDOW TO OVERLAY ONTO TILE DATA
        % TO MATCH TILE AXES ORDERING, GRID NUMBERING STARTS IN THE BOTTOM LEFT 
        % CORNER OF THE FIGURE AND FIRST FILLS UPWARD THEN RIGHTWARD
        for ii = 1:size(pxl,1)^2
            
            tv2 = [  aX(ii)*size(IMGraw,1)   aY(ii)*size(IMGraw,1)+2 ...
                    (1/(size(pxl,1)+1))     (1/(size(pxl,2)+1))];

            text(tv2(1),tv2(2),num2str(tv1(ii)),'Color','r','Parent',axGRID);
    
        end
        
     pause(.1)
    %-------------------------------------------------------------------------

%     
%         keyboard
%     axGRID.YDir = 'reverse';
%     axis ij; axis xy;


enableButtons
memocon('GRID OVERLAY HAS BEEN GENERATED.')
end








%----------------------------------------------------
%        PLOT GROUP MEANS (CI ENVELOPE PLOT)
%----------------------------------------------------
function plotGroupMeans(hObject, eventdata)
% disableButtons; pause(.02);


%{
%     CSids = unique(SEGstruct.csus);
%     
%     size(IMG)
%     meanIMG = squeeze(mean(IMG(:,:,CSUSonoff(1),SEGstruct.tf(:,4)),4));
%     size(meanIMG)
%     
%         % Perform averaging for each (nCSUS) unique trial type
%     % This will create a matrix 'muIMGS' of size [h,w,f,nCSUS]
%     
%     muIMGS = zeros(szIMG(1), szIMG(2), szIMG(3), nCSUS);
%     for tt = 1:nCSUS
%         im = IMG(:,:,:,SEGstruct.tf(:,tt));
%         muIMGS(:,:,:,tt) = squeeze(mean(im,4));
%     end
    


fh33=figure('Units','normalized','OuterPosition',[.1 .1 .7 .9],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .55 .40 .40],'Color','none'); axis off; hold on;
hax2 = axes('Position',[.55 .55 .40 .40],'Color','none'); axis off; hold on;
hax3 = axes('Position',[.05 .05 .40 .40],'Color','none'); axis off; hold on;
hax4 = axes('Position',[.55 .05 .40 .40],'Color','none'); axis off; hold on;


meanIMG1 = squeeze(mean(IMG(:,:,CSUSonoff(1),SEGstruct.tf(:,4)),4));
meanIMG2 = squeeze(mean(IMG(:,:,CSUSonoff(2),SEGstruct.tf(:,4)),4));
meanIMG3 = squeeze(mean(IMG(:,:,CSUSonoff(3),SEGstruct.tf(:,4)),4));
meanIMG4 = squeeze(mean(IMG(:,:,CSUSonoff(4),SEGstruct.tf(:,4)),4));

axes(hax1)
imagesc(meanIMG1)
axes(hax2)
imagesc(meanIMG2)
axes(hax3)
imagesc(meanIMG3)
axes(hax4)
imagesc(meanIMG4)



fh34=figure('Units','normalized','OuterPosition',[.1 .1 .7 .9],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .55 .40 .40],'Color','none'); axis off; hold on;
hax2 = axes('Position',[.55 .55 .40 .40],'Color','none'); axis off; hold on;
hax3 = axes('Position',[.05 .05 .40 .40],'Color','none'); axis off; hold on;
hax4 = axes('Position',[.55 .05 .40 .40],'Color','none'); axis off; hold on;

meanIMG1 = squeeze(mean(IMG(:,:,CSUSonoff(3),SEGstruct.tf(:,1)),4));
meanIMG2 = squeeze(mean(IMG(:,:,CSUSonoff(3),SEGstruct.tf(:,2)),4));
meanIMG3 = squeeze(mean(IMG(:,:,CSUSonoff(3),SEGstruct.tf(:,3)),4));
meanIMG4 = squeeze(mean(IMG(:,:,CSUSonoff(3),SEGstruct.tf(:,4)),4));

axes(hax1)
imagesc(meanIMG1)
axes(hax2)
imagesc(meanIMG2)
axes(hax3)
imagesc(meanIMG3)
axes(hax4)
imagesc(meanIMG4)

%}


    if size(muIMGS,1) < 1
       
        msgbox('Group means have not yet been calculated'); 
        
        return
        
    end

    memocon(' '); memocon('PLOTTING GROUP MEANS (PLEASE WAIT)...'); 
        
    fh1=figure('Units','normalized','OuterPosition',[.08 .08 .8 .8],'Color','w');
    hax1 = axes('Position',[.05 .05 .9 .9],'Color','none');
    hax1.YLim = [-.15 .15];
    hax2 = axes('Position',[.05 .05 .9 .9],'Color','none');
    hax2.YLim = [-.15 .15];
    axis off; hold on;
    hax3 = axes('Position',[.05 .05 .9 .9],'Color','none');
    hax3.YLim = [-.15 .15];
    axis off; hold on;
    hax4 = axes('Position',[.05 .05 .9 .9],'Color','none');
    hax4.YLim = [-.15 .15];
    axis off; hold on;
    hax5 = axes('Position',[.05 .05 .9 .9],'Color','none');
    hax5.YLim = [-.15 .15];
    axis off; hold on;
    hax6 = axes('Position',[.05 .05 .9 .9],'Color','none');
    hax6.YLim = [-.15 .15];
    axis off; hold on;
    hax0 = axes('Position',[.05 .05 .9 .9],'Color','none');
    hax0.YLim = [-.15 .15];
    axis off; hold on;
    allhax = {hax1, hax2, hax3, hax4, hax5, hax6};
    colorz = {  [.99 .01 .01], ...
                [.01 .99 .01], ...
                [.01 .01 .99], ...
                [.99 .01 .99], ...
                [.99 .99 .01], ...
                [.01 .99 .99], ...
                };
    legpos = {  [0.75,0.85,0.15,0.06], ...
                [0.75,0.80,0.15,0.06], ...
                [0.75,0.75,0.15,0.06], ...
                [0.75,0.70,0.15,0.06], ...
                [0.75,0.65,0.15,0.06], ...
                [0.75,0.60,0.15,0.06], ...
                };

    
            

    blockSize = str2num(imgpcpopupH.String(imgpcpopupH.Value,:));

    pxl = muIMGS(1:blockSize:end,1:blockSize:end,:,:);

    pixels = squeeze(reshape(pxl,numel(pxl(:,:,1)),[],size(pxl,3),size(pxl,4)));
    
    CSids = unique(SEGstruct.csus);
    
    
    
    
    %-------------------------- CI ENVELOPE FIGURE --------------------------
    for nn = 1:size(pixels,3)
    
    pixCS = pixels(:,:,nn);
	
	Mu = mean(pixCS,1);
    Sd = std(pixCS,0,1);
    Se = Sd./sqrt(numel(Mu));
	y_Mu = Mu';
    x_Mu = (1:numel(Mu))';
    % e_Mu = Se';
    e_Mu = Sd';
	xx_Mu = 1:0.1:max(x_Mu);
	yy_Mu = spline(x_Mu,y_Mu,xx_Mu);
    ee_Mu = spline(x_Mu,e_Mu,xx_Mu);
    
    axes(allhax{nn})
    [ph1, po1] = envlineplot(xx_Mu',yy_Mu', ee_Mu','cmap',colorz{nn},...
                            'alpha','transparency', 0.6);
    hp1{nn} = plot(xx_Mu,yy_Mu,'Color',colorz{nn});
    pause(.2)
    
    % lh1{nn} = legend(allhax{nn},CSids(nn),'Position',legpos{nn},'Box','off');
    
    end
    
    text(1, -.12, ['CS ON/OFF US ON/OFF:  ', num2str(CSUSonoff)])
    
    leg1 = legend([hp1{:}],CSids);
	set(leg1, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
    set(leg1, 'Position', leg1.Position .* [1 .94 1 1.4])
    
        
    for mm = 1:4
    text(CSUSonoff(mm),allhax{nn}.YLim(1),{'\downarrow'},...
        'HorizontalAlignment','center','VerticalAlignment','bottom',...
        'FontSize',20,'FontWeight','bold')
    end
    line([CSUSonoff(1) CSUSonoff(1)],[allhax{nn}.YLim(1) allhax{nn}.YLim(2)])
    line([CSUSonoff(2) CSUSonoff(2)],[allhax{nn}.YLim(1) allhax{nn}.YLim(2)])
    pause(.1)
    %-------------------------------------------------------------------------
    
    
    
    
    
    
    
    
        
enableButtons
memocon('PLOTTING GROUP MEANS COMPLETED!')
end





%----------------------------------------------------
% VISUALIZE TRIAL BLOCKS AND CS / US ONSET / OFFSET
%----------------------------------------------------
function viewTrialTimings(hObject, eventdata)
    
    
    if length(delaytoCS) < 2
       
        msgbox('DATA HAS NOT BEEN IMPORTED'); 
        
        return
        
    end
    
trials = zeros(total_trials,round(secondsPerTrial));


for nn = 1:total_trials
    
    trials(nn,delaytoCS(nn):delaytoCS(nn)+10) = SEGstruct.id(nn);
    
end

cm = [ 1  1  1
      .95 .05 .05
      .90 .75 .15
      .95 .05 .95
      .05 .95 .05
      .05 .75 .95
      .05 .05 .95
      .45 .45 .25
      ];

fh1=figure('Units','normalized','OuterPosition',[.1 .08 .8 .85],'Color','w');
hax1 = axes('Position',[.15 .05 .82 .92],'Color','none');
hax2 = axes('Position',[.15 .05 .82 .92],'Color','none','NextPlot','add');
axis off; hold on;

axes(hax1)
ih = imagesc(trials);
colormap(cm)
grid on
hax1.YTick = [.5:1:total_trials-.5];
hax1.YTickLabel = 1:total_trials;
hax1.XLabel.String = 'Time (seconds)';

hax1.YTickLabel = SEGstruct.csus;
% hax1.YTickLabelRotation = 30;


% tv1 = [];
% tv2 = [];
% tv3 = [];
% tv4 = [];
% 
% tv1 = {'\color[rgb]{.95,.05,.05}'};
% tv1 = {'\color[rgb]{.90 .75 .15}'};
% tv1 = {'\color[rgb]{.95 .05 .95}'};
% tv1 = {'\color[rgb]{.9,.1,.1}'};
% tv1 = {'\color[rgb]{.9,.1,.1}'};
% tv1 = {'\color[rgb]{.9,.1,.1}'};
% 
% keyboard
% 
% tv2 = repmat(tv1,total_trials,1);
% 
% for nn=1:total_trials
% tv3{nn} = strcat(tv2{nn}, SEGstruct.csus{nn});
% end
% 
% 
% hax1.YTickLabel = tv3{nn};
% 
% 
% % annotation(fh1,'textbox',...
% %     'Position',[.1 .1 .3 .3],...
% %     'String',tv3{nn},...
% %     'BackgroundColor',[1 1 1]);


end





%----------------------------------------------------
%        PLOT GROUP MEANS (CI ENVELOPE PLOT)
%----------------------------------------------------
function viewSameFrames(hObject, eventdata)
% disableButtons; pause(.02);


%     CSids = unique(SEGstruct.csus);
%     
%     size(IMG)
%     meanIMG = squeeze(mean(IMG(:,:,CSUSonoff(1),SEGstruct.tf(:,4)),4));
%     size(meanIMG)
%     
%         % Perform averaging for each (nCSUS) unique trial type
%     % This will create a matrix 'muIMGS' of size [h,w,f,nCSUS]
%     
%     muIMGS = zeros(szIMG(1), szIMG(2), szIMG(3), nCSUS);
%     for tt = 1:nCSUS
%         im = IMG(:,:,:,SEGstruct.tf(:,tt));
%         muIMGS(:,:,:,tt) = squeeze(mean(im,4));
%     end
    


fh33=figure('Units','normalized','OuterPosition',[.1 .1 .7 .9],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .55 .40 .40],'Color','none'); axis off; hold on;
hax2 = axes('Position',[.55 .55 .40 .40],'Color','none'); axis off; hold on;
hax3 = axes('Position',[.05 .05 .40 .40],'Color','none'); axis off; hold on;
hax4 = axes('Position',[.55 .05 .40 .40],'Color','none'); axis off; hold on;


meanIMG1 = squeeze(mean(IMG(:,:,CSUSonoff(1),SEGstruct.tf(:,4)),4));
meanIMG2 = squeeze(mean(IMG(:,:,CSUSonoff(2),SEGstruct.tf(:,4)),4));
meanIMG3 = squeeze(mean(IMG(:,:,CSUSonoff(3),SEGstruct.tf(:,4)),4));
meanIMG4 = squeeze(mean(IMG(:,:,CSUSonoff(4),SEGstruct.tf(:,4)),4));

axes(hax1)
imagesc(meanIMG1)
axes(hax2)
imagesc(meanIMG2)
axes(hax3)
imagesc(meanIMG3)
axes(hax4)
imagesc(meanIMG4)



fh34=figure('Units','normalized','OuterPosition',[.1 .1 .7 .9],'Color','w','MenuBar','none');
hax1 = axes('Position',[.05 .55 .40 .40],'Color','none'); axis off; hold on;
hax2 = axes('Position',[.55 .55 .40 .40],'Color','none'); axis off; hold on;
hax3 = axes('Position',[.05 .05 .40 .40],'Color','none'); axis off; hold on;
hax4 = axes('Position',[.55 .05 .40 .40],'Color','none'); axis off; hold on;

meanIMG1 = squeeze(mean(IMG(:,:,CSUSonoff(3),SEGstruct.tf(:,1)),4));
meanIMG2 = squeeze(mean(IMG(:,:,CSUSonoff(3),SEGstruct.tf(:,2)),4));
meanIMG3 = squeeze(mean(IMG(:,:,CSUSonoff(3),SEGstruct.tf(:,3)),4));
meanIMG4 = squeeze(mean(IMG(:,:,CSUSonoff(3),SEGstruct.tf(:,4)),4));

axes(hax1)
imagesc(meanIMG1)
axes(hax2)
imagesc(meanIMG2)
axes(hax3)
imagesc(meanIMG3)
axes(hax4)
imagesc(meanIMG4)




    line([CSUSonoff(1) CSUSonoff(1)],[allhax{nn}.YLim(1) allhax{nn}.YLim(2)])
    line([CSUSonoff(2) CSUSonoff(2)],[allhax{nn}.YLim(1) allhax{nn}.YLim(2)])
    pause(.1)
    %-------------------------------------------------------------------------
    

enableButtons
memocon('PLOTTING GROUP MEANS COMPLETED!')
end






%% ------------------------- CALLBACKS & HELPERS ------------------------------


%###############################################################
%        PREVIEW IMAGE STACK
%###############################################################
function previewStack(varargin)
disableButtons; pause(.02);

    if nargin > 0
        I = varargin{1};
    else
        I = IMG;
    end



    totframes = size(I,3);
    previewStacknum = str2num(previewStacknumH.String);

    
    if totframes >= previewStacknum
    
        IMGi = I(:,:,1:previewStacknum);  
        
        axes(haxSEG)
        phSEG = imagesc(IMGi(:,:,1),'Parent',haxSEG,'CDataMapping','scaled');
        haxSEG.CLim = [quantile(IMGi(:),.002) quantile(IMGi(:),.998)];


        for nn = 1:previewStacknum
            phSEG.CData = IMGi(:,:,nn);
            pause(.04)
        end
    
        
    else
        
        IMGi = I;
        axes(haxSEG)
        phSEG = imagesc(IMGi(:,:,1),'Parent',haxSEG,'CDataMapping','scaled');
        haxSEG.CLim = [quantile(IMGi(:),.002) quantile(IMGi(:),.998)];

        for nn = 1:size(IMGi,3)
            phSEG.CData = IMGi(:,:,nn);
            pause(10/size(IMGi,3))
        end
        
    end


enableButtons        
end





%###############################################################
%        PREVIEW FULL IMAGE STACK
%###############################################################
function previewFullStack(IMGi)
disableButtons; pause(.02);


    axes(haxSEG)
    phSEG = imagesc(IMGi(:,:,1),'Parent',haxSEG,'CDataMapping','scaled');
    haxSEG.CLim = [quantile(IMGi(:),.002) quantile(IMGi(:),.998)];

    for nn = 1:size(IMGi,3)
        phSEG.CData = IMGi(:,:,nn);
        pause(10/size(IMGi,3))
    end
        

enableButtons        
end






%###############################################################
function previewIMG(I)

    axes(haxSEG);

    phSEG.CData = I;
    [lo,hi] = bounds(I(:)); 
    lohi = double([lo hi]);
    haxSEG.CLim = lohi;

%     axes(haxSEG); hold off
%     phSEG = imagesc(IM , 'Parent', haxSEG);
%     axis equal
%     haxSEG.XColor='none';
%     haxSEG.YColor = 'none';
%     haxSEG.YDir='reverse';
end







%###############################################################
function [varargout] = plotIM(IM_A,varargin)


% ---------------------------------------
if nargin == 1


    fh1 = figure('Units','pixels','Position',[10 50 750 700],'Color','w');
    ax1 = axes('Position',[.06 .06 .9 .9],'Color','none','YDir','reverse',...
    'PlotBoxAspectRatio',[1 1 1],'XColor','none','YColor','none'); hold on
    hold on


    axes(ax1)

    ph1 = imagesc(ax1, IM_A(:,:,1) );

    axis tight; colormap bone; pause(.1)

    imstats(IM_A)

end


% ---------------------------------------
if nargin == 3 && string(varargin{2}) == "Cdata"

    p = varargin{3};
    p.CData=PIX;
    pause(.1)

end


% ---------------------------------------
if nargin == 3 && string(varargin{2}) == "DUAL"


    IM_B = varargin{1};

    qB = quantile(IM_B(:),[.001 .999]);


    clc; close all
    fh1 = figure('Units','pixels','OuterPosition',[5 45 1400 750],'Color','w');

    ax1 = axes('Units','pixels','Position',[5 5 650 700],'Color','none',...
            'YDir','reverse','PlotBoxAspectRatio',[1 1 1],...
            'XColor','none','YColor','none'); hold on

    ax2 = axes('Units','pixels','Position',[705 5 650 700],'Color','none',...
            'YDir','reverse','PlotBoxAspectRatio',[1 1 1],...
            'XColor','none','YColor','none'); hold on

    axes(ax1)
    ph1 = imagesc(ax1,IM_A(:,:,1));
    axis tight; colormap bone; pause(.1)

    axes(ax2)
    ph2 = imagesc(ax2,IM_B(:,:,1));
    axis tight; colormap bone; pause(.1)



end


% ---------------------------------------
if nargin == 3 && string(varargin{2}) == "PCA4"


    IM = varargin{1};

    qC = quantile(IM(:),[.001 .999]);

    fh1 = figure('Position',[10 10 900 800]);

    ax1=subplot(2,2,1);  imagesc(IM(:,:,1));  ax1.CLim=qC; axis tight off;

    ax2=subplot(2,2,2);  imagesc(IM(:,:,2));  ax2.CLim=qC; axis tight off;

    ax3=subplot(2,2,3);  imagesc(IM(:,:,3));  ax3.CLim=qC; axis tight off;

    ax4=subplot(2,2,4);  imagesc(IM(:,:,4));  ax4.CLim=qC; axis tight off;

end
%---------------------------------------




% ---------------------------------------
if nargin == 3 && string(varargin{2}) == "PCA16"


    IM = varargin{1};

    % Make axes coordinates
    r = linspace(.02,.98,5);
    c = fliplr(linspace(.02,.98,5)); c(1)=[];
    w = .22; h = .22;


    fh1=figure('Position',[20 35 950 800],'MenuBar','none');

    q = quantile(IM(:),[.001 .999]);

    k=1;
    for a=1:4
    for b=1:4

        ax = axes('Position',[r(a) c(b) w h]);


        p = imagesc(IM(:,:,k));  ax.CLim=q;  axis off;


        title(sprintf('PC-%s',num2str(k)))


        k=k+1;
    end
    end


end
% ---------------------------------------


varargout = {fh1};
end





















%----------------------------------------------------
%        RUN CUSTOM FUNCTION
%----------------------------------------------------
function runCustomA(hObject, eventdata)
% disableButtons; pause(.02);

    memocon('RUNNING CUSTOM FUNCTION A!')
    
    [IMG] = stevesRedNormFun(IMG);

    [varargin] = grincustomA(IMG, SEGstruct, SEGtable, XLSdata, IMGraw, muIMGS, LICK);

enableButtons        
memocon('Run custom function completed!')
end

function runCustomB(hObject, eventdata)
% disableButtons; pause(.02);

    memocon('RUNNING CUSTOM FUNCTION B!')

    [varargin] = grincustomB(IMG, SEGstruct, SEGtable, XLSdata, IMGraw, muIMGS, LICK);

    
enableButtons        
memocon('Run custom function completed!')
end

function runCustomC(hObject, eventdata)
% disableButtons; pause(.02);

    memocon('RUNNING CUSTOM FUNCTION C!')

    [varargin] = grincustomC(IMG, SEGstruct, SEGtable, XLSdata, IMGraw, muIMGS, LICK);

    
enableButtons        
memocon('Run custom function completed!')
end

function runCustomD(hObject, eventdata)
% disableButtons; pause(.02);
    
    mainguih.HandleVisibility = 'off';
    close all;
    mainguih.HandleVisibility = 'on';
        
    memocon('RUNNING CUSTOM FUNCTION D!')

    % grincustomD(IMG, SEGstruct, SEGtable, XLSdata, IMGraw, IMGSraw, muIMGS, LICK);
    
    [Boundaries] = reverseSelectROI(IMG, SEGstruct, SEGtable, XLSdata, IMGraw, IMGSraw, muIMGS, LICK);
    
    
    
enableButtons        
memocon('Run custom function completed!')
end











%----------------------------------------------------
%        GET ALIGN
%----------------------------------------------------
function getAlign(hObject, eventdata)
% disableButtons; 
getAlignH.FontWeight = 'bold';
pause(.02);

%{
xlsA = [];
AlignSheetExists = 0;
try
    
   xlsA = xlsread([xlspathname , xlsfilename],'ALIGN');
   
   AlignSheetExists = 1;
   
   memocon('Imported pre-existing aligment values fomr ALIGN excel sheet');
   
catch ME
    
    memocon(ME.message)
    
end 





if isempty(xlsA)

    if AlignSheetExists && isempty(xlsA)
        memocon('ALIGN excel sheet exists, but is empty');
    end
    if ~AlignSheetExists
        memocon('ALIGN excel sheet does not exist');
    end


%     memocon(' ');
%     memocon('SMOOTHING AND CROPPING IMAGES...');
%     if checkbox1H.Value
%         smoothimg
%     end
%     if checkbox2H.Value
%         cropimg
%     end

    memocon('OPENING IMG ALIGNMENT POPOUT...');
    memocon('SELECT TWO (2) ALIGNMENT POINTS');


    % CREATE IMG WINDOW POPOUT

    IMGi = IMG(:,:,1:previewStacknum);

    fhIMA=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
    haxIMA = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[],'YTick',[]);
    % hold on;

    axes(haxIMA)
    phG = imagesc(IMGi(:,:,1),'Parent',haxIMA,'CDataMapping','scaled');
    [cmax, cmaxi] = max(IMGi(:));
    [cmin, cmini] = min(IMGi(:));
    cmax = cmax - abs(cmax/4);
    cmin = cmin + abs(cmin/4);
    haxIMA.CLim = [cmin cmax];
    axes(haxIMA)
    pause(.01)



    % SELECT TWO ROI POINTS
    hAP1 = impoint;
    hAP2 = impoint;

    AP1pos = hAP1.getPosition;
    AP2pos = hAP2.getPosition;

    imellipse(haxIMA, [AP1pos-5 10 10]); pause(.1);
    imellipse(haxIMA, [AP2pos-5 10 10]); pause(.1);

    pause(.5);
    close(fhIMA)

    memocon('  ');
    memocon('ALIGNMENT POINTS');
    memocon(sprintf('P1(X,Y): \t    %.2f \t    %.2f',AP1pos));
    memocon(sprintf('P2(X,Y): \t    %.2f \t    %.2f',AP2pos));

end
%}




    memocon('OPENING IMG ALIGNMENT POPOUT...');
    memocon('SELECT TWO (2) ALIGNMENT POINTS');


    % CREATE IMG WINDOW POPOUT

    IMGi = IMG(:,:,1:previewStacknum);

    fhIMA=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],'Color','w','MenuBar','none');
    haxIMA = axes('Position',[.05 .05 .9 .9],'Color','none','XTick',[],'YTick',[]);
    % hold on;

    axes(haxIMA)
    phG = imagesc(IMGi(:,:,1),'Parent',haxIMA,'CDataMapping','scaled');
    [cmax, cmaxi] = max(IMGi(:));
    [cmin, cmini] = min(IMGi(:));
    cmax = cmax - abs(cmax/4);
    cmin = cmin + abs(cmin/4);
    haxIMA.CLim = [cmin cmax];
    axes(haxIMA)
    pause(.01)



    % SELECT TWO ROI POINTS
    hAP1 = impoint;
    hAP2 = impoint;

    AP1pos = hAP1.getPosition;
    AP2pos = hAP2.getPosition;

    imellipse(haxIMA, [AP1pos-5 10 10]); pause(.1);
    imellipse(haxIMA, [AP2pos-5 10 10]); pause(.1);

    pause(.5);
    close(fhIMA)

    memocon('  ');
    memocon('ALIGNMENT POINTS');
    memocon(sprintf('P1(X,Y): \t    %.2f \t    %.2f',AP1pos));
    memocon(sprintf('P2(X,Y): \t    %.2f \t    %.2f',AP2pos));




AlignVals.P1x = AP1pos(1);
AlignVals.P1y = AP1pos(2);
AlignVals.P2x = AP2pos(1);
AlignVals.P2y = AP2pos(2);

imgAlignP1Xh.String = num2str(AlignVals.P1x);
imgAlignP1Yh.String = num2str(AlignVals.P1y);
imgAlignP2Xh.String = num2str(AlignVals.P2x);
imgAlignP2Yh.String = num2str(AlignVals.P2y);        
% imgAlignP3Xh.String = num2str(AlignVals.P3x);
% imgAlignP3Yh.String = num2str(AlignVals.P3y);
% imgAlignP4Xh.String = num2str(AlignVals.P4x);
% imgAlignP4Yh.String = num2str(AlignVals.P4y);



getAlignH.FontWeight = 'normal';
pause(.02);
enableButtons; pause(.02);
memocon('GET alignment completed.')
end





%----------------------------------------------------
%        SET ALIGN
%----------------------------------------------------
function setAlign(hObject, eventdata)
% disableButtons; 
setAlignH.FontWeight = 'bold';
pause(.02);



AlignVals.P1x = str2num(imgAlignP1Xh.String);
AlignVals.P1y = str2num(imgAlignP1Yh.String);
AlignVals.P2x = str2num(imgAlignP2Xh.String);
AlignVals.P2y = str2num(imgAlignP2Yh.String);
AlignVals.P3x = str2num(imgAlignP3Xh.String);
AlignVals.P3y = str2num(imgAlignP3Yh.String);
AlignVals.P4x = str2num(imgAlignP4Xh.String);
AlignVals.P4y = str2num(imgAlignP4Yh.String);



P1x = AlignVals.P1x;
P1y = AlignVals.P1y;
P2x = AlignVals.P2x;
P2y = AlignVals.P2y;
P3x = AlignVals.P3x;
P3y = AlignVals.P3y;
P4x = AlignVals.P4x;
P4y = AlignVals.P4y;


tX = P3x - P1x;
tY = P3y - P1y;

[IM,~] = imtranslate(IMG,[tX, tY],'FillValues',mean(IMG(:)),'OutputView','same');

IMG = IM;
previewStack



% P1x = P1x + tX;    % after translation P1x moves to P3x
% P1y = P1y + tY;    % after translation P1y moves to P3y
% P2x = P2x + tX;    % after translation P2x does not move to P4x
% P2y = P2y + tY;    % after translation P2y does not move to P4y
% 
% 
% % Make X and Y origins equal zero
% 
% Xa = P2x - P1x; 
% Ya = P2y - P1y; 
% 
% RotA = rad2deg(atan2(Ya,Xa));
% 
% 
% Xb = P4x - P3x;
% Yb = P4y - P3y;
% 
% RotB = rad2deg(atan2(Yb,Xb));
% 
% RotAng = RotB - RotA;
% 
% IM = imrotate(IMG,RotAng,'bilinear','crop'); % Make output image B the same size as the input image A, cropping the rotated image to fit
% 
% IMG = IM;
% previewStack




% fixed = IMG(:,:,1);
% moving = IMG(:,:,500);
% imshowpair(fixed, moving,'Scaling','joint')
% [optimizer, metric] = imregconfig('multimodal');
% optimizer.InitialRadius = 0.009;
% optimizer.Epsilon = 1.5e-4;
% optimizer.GrowthFactor = 1.01;
% optimizer.MaximumIterations = 300;
% movingRegistered = imregister(moving, fixed, 'affine', optimizer, metric);
% imshowpair(fixed, movingRegistered,'Scaling','joint')




setAlignH.FontWeight = 'normal';
pause(.02);
enableButtons; pause(.02);
memocon('SET alignment completed.')
end






%----------------------------------------------------
%        red Channel IMPORT
%----------------------------------------------------
function redChImport(hObject, eventdata)
pause(.02);

    pathfull = [SEGstruct.path(1:end-5) 'r.tif'];
    [VpPath,VpFile,VpExt] = fileparts(pathfull);
    rcFile = dir(pathfull);

    if numel(rcFile.name) > 1
        
        memocon(' ');
        memocon('Red channel stack found; attempting to import...');
                
    else
        
        memocon(' ');
        memocon('No red channel stack found named:');
        memocon(['  ' VpFile VpExt]);
        memocon(' '); memocon('Select a red channel tif stack...')

        [pathfile, pathdir, ~] = uigetfile({'*.tif*; *.TIF*'}, 'Select file.');
        pathfull = [pathdir pathfile];

    end



    % IMPORT RED CHANNEL IMAGE 
    InfoImage=imfinfo(pathfull);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);
        
    IMGred = zeros(nImage,mImage,NumberImages,'double');

    TifLink = Tiff(pathfull, 'r');
    for i=1:NumberImages
       TifLink.setDirectory(i);
       IMGred(:,:,i)=TifLink.read();
    end
    TifLink.close();
    

    if (size(IMG,3) * size(IMG,4)) == size(IMGred,3)
        memocon('GOOD: size(greenStack) == size(redStack)')
    else
        memocon(' ');memocon(' ');memocon(' ');memocon(' ');
        memocon('******  WARNING: size(greenStack) ~= size(redStack)  *****')
        warning('WARNING: size(greenStack) ~= size(redStack)')
        memocon('******    ABORTING RED CHANNEL STACK IMPORT    ******')
        memocon(' ');memocon(' ');memocon(' ');
        return
    end

      
        % VISUALIZE AND ANNOTATE

        SPF1 = sprintf('Green Channel dims: % s ', num2str(size(IMG))  );
        SPF2 = sprintf('Red   Channel dims: % s ', num2str(size(IMGred)) );
       
        memocon(' '); memocon(SPF1); memocon(SPF2);
        
        % SEGcompare(IMG, IMGf, previewNframes, [.98 1.05], [8 2])
        mainguih.HandleVisibility = 'off';
        close all;
        mainguih.HandleVisibility = 'on';
    
        
        memocon(' ');
        pause(.5)
        memocon('red Stack Preview'); previewIMGSTACK(IMGred)
        pause(.5)
        memocon('green Stack Preview'); previewStack
        pause(.5)
        memocon('red Stack Preview'); previewIMGSTACK(IMGred)
        pause(.5)
        memocon('green Stack Preview'); previewStack
        pause(.5)
        axes(haxSEG)
        phSEG = imagesc(IMG(:,:,1) , 'Parent', haxSEG);


pause(.02);
redChanNormalizeH.Enable = 'on';
enableButtons
memocon('Red channel import completed!')
end





%----------------------------------------------------
%        red Channel NORMALIZATION
%----------------------------------------------------
function redChanNormalize(hObject, eventdata)
% disableButtons;
pause(.02);




RHposCheck.A  = [.02  .76  .05  .05];
RHposCheck.B  = [.02  .64  .05  .05];
RHposCheck.C  = [.02  .52  .05  .05];
RHposCheck.D  = [.02  .40  .05  .05];
RHposCheck.E  = [.02  .28  .05  .05];
RHposCheck.F  = [.02  .16  .05  .05];
RHposCheck.G  = [.02  .04  .05  .05];
RHposTexts.A  = [.12  .72  .45  .08];
RHposTexts.B  = [.12  .60  .45  .08];
RHposTexts.C  = [.12  .48  .45  .08];
RHposTexts.D  = [.12  .36  .45  .08];
RHposTexts.E  = [.12  .24  .45  .08];
RHposTexts.F  = [.12  .12  .45  .08];
RHposTexts.G  = [.22  .85  .65  .08];



REDpopupH = figure('Units', 'normalized','Position', [.25 .12 .30 .80], 'BusyAction',...
    'cancel', 'Name', 'SEG TOOLBOX', 'Tag', 'REDpopupH','Visible', 'On'); 

REDpanelH = uipanel('Title','Process Red Channel Stack','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],'Position', [0.08 0.20 0.90 0.77]);

Rcheckbox1H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.A ,'String','', 'Value',1);
Rcheckbox2H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.B ,'String','', 'Value',1);
Rcheckbox3H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.C ,'String','', 'Value',1);
Rcheckbox4H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.D ,'String','', 'Value',1);
Rcheckbox5H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.E ,'String','', 'Value',1);
Rcheckbox6H = uicontrol('Parent', REDpanelH,'Style','checkbox','Units','normalized',...
    'Position', RHposCheck.F ,'String','', 'Value',1);

uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.A, 'FontSize', 14,'String', 'Smooth');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.B, 'FontSize', 14,'String', 'Crop');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.C, 'FontSize', 14,'String', 'Tile');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.D, 'FontSize', 14,'String', 'Reshape');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.E, 'FontSize', 14,'String', 'Align to CS');
uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', RHposTexts.F, 'FontSize', 14,'String', 'Normalize');
% uicontrol('Parent', REDpanelH, 'Style', 'Text', 'Units', 'normalized',...
%     'Position', RHposTexts.G, 'FontSize', 14,'String', 'CLOSE THIS WINDOW TO CONTINUE');


REDcontinueH = uicontrol('Parent', REDpopupH, 'Units', 'normalized', ...
    'Position', [.1 .05 .8 .12], 'FontSize', 12, 'String', 'Continue',...
    'Callback', @REDcontinue, 'Enable','on');

uiwait
REDpopupH.Visible = 'Off';

    
    %----------------------------------------------------
    %        SMOOTH RED CHAN IMAGES
    %----------------------------------------------------  
    if Rcheckbox1H.Value
        memocon(' '); memocon('PERFORMING RED CH IMAGE SMOOTHING')
        IMGr = [];

        smoothSD = str2num(smoothimgnumH.String);
        Mask = SEGkernel(smoothHeight, smoothWidth, smoothSD, smoothRes, 1);
        pause(.2)
        mbh = waitbar(.5,'Performing convolution smoothing, please wait...');

        IMGr = convn( IMGred, Mask,'same');

        waitbar(.8); close(mbh);

        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Image smoothing completed!')    
    end
    
    
    %----------------------------------------------------
    %        CROP RED CHANNEL IMAGES
    %----------------------------------------------------
    if Rcheckbox2H.Value
        memocon(' '); memocon('TRIMMING EDGES FROM IMAGE')
        IMGr = [];

        cropAmount = str2num(cropimgnumH.String);

        IMGr = IMGred((cropAmount+1):(end-cropAmount) , (cropAmount+1):(end-cropAmount) , :);

        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Crop Images completed!')
    end

    
    %----------------------------------------------------
    %        CREATE IMAGE TILES BLOCKS
    %----------------------------------------------------
    if Rcheckbox3H.Value
        memocon('SEGMENTING IMGAGES INTO TILES')
        IMGr = [];

        blockSize = str2num(imgpcpopupH.String(imgpcpopupH.Value,:));

        IMGr = zeros(size(IMGred));
        sz = size(IMGred,3);

        %-------------------------
        tv1 = 1:blockSize:size(IMGred,1);
        tv2 = 0:blockSize:size(IMGred,1);
        tv2(1) = [];

        progresstimer('Segmenting images into blocks...')
        for nn = 1:sz
          for cc = 1:numel(tv1)
            for rr = 1:numel(tv1)

              mbloc = IMGred( tv1(rr):tv2(rr), tv1(cc):tv2(cc) , nn );
              mu = mean(mbloc(:));

              IMGr( tv1(rr):tv2(rr), tv1(cc):tv2(cc) , nn ) = mu;

            end
          end
        if ~mod(nn,100); progresstimer(nn/sz); end    
        end
        %-------------------------


        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Block-Segment Images completed!')        
    end

    
    
    %----------------------------------------------------
    %        RESHAPE DATA BY TRIALS
    %----------------------------------------------------
    if Rcheckbox4H.Value
        memocon(' '); memocon('Reshaping dataset to 4D');
        IMGr = [];

        IMGr = reshape(IMGred,size(IMGred,1),size(IMGred,2),framesPerTrial,[]);

        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Reshape stack by trial completed!')
    end

    
    
    %----------------------------------------------------
    %        ALIGN CS FRAMES BY CS ONSET
    %----------------------------------------------------
    if Rcheckbox5H.Value
        memocon(sprintf('Setting CS delay to %s seconds for all trials',alignCSFramesnumH.String));
        IMGr = [];

        % Make all CS onsets this many seconds from trial start
        CSonsetDelay = str2num(alignCSFramesnumH.String);
        CSonsetFrame = round(CSonsetDelay .* framesPerSec);
        CSoffsetFrame = round((CSonsetDelay+CS_length) .* framesPerSec);


        EqualizeCSdelay  = round((delaytoCS-CSonsetDelay) .* framesPerSec);

        IMGr = IMGred;
        for nn = 1:size(IMGr,4)

            IMGr(:,:,:,nn) = circshift( IMGr(:,:,:,nn) , -EqualizeCSdelay(nn) ,3);

        end

        IMGred = IMGr;

        previewIMGSTACK(IMGred)
        memocon('Align frames by CS onset completed!')
    end
    
    
    %----------------------------------------------------
    %        deltaF OVER F
    %----------------------------------------------------
    if Rcheckbox6H.Value
        memocon(' '); memocon('Computing dF/F for all frames...')
        IMGr = [];

        IMGr = mean(IMGred(:,:,1:round(baselineTime*framesPerSec),:),3);

        im = repmat(IMGr,1,1,size(IMGred,3),1);

        IMGf = (IMGred - im) ./ im;

        IMGred = IMGf;

        previewIMGSTACK(IMGred)
        memocon('dF/F computation completed!')
    end
    
    
    %----------------------------------------------------
    %        RED CHANNEL SUBTRACTION NORMALIZATION
    %----------------------------------------------------
    
    szGimg = size(IMG);
    szRimg = size(IMGred);
    
    disp('Green Stack Dims:')
    disp(szGimg)
    disp('Red Stack Dims:')
    disp(szRimg)
    
    
    if all(szGimg == szRimg)
    
        prompt = {'Enter normalization equation:'};
        dlgout = inputdlg(prompt,'Equation Input',1,{'IMG = IMG - IMGred;'});    

        eval(char(dlgout));

        previewIMGSTACK(IMG)

    else
       
        warning('Green and Red IMG stacks are not the same size.')
        warning('Cannot perform normalization.')
        
    end





        
pause(.02);
enableButtons        
memocon('RED CHANNEL NORMALIZATION COMPLETED')
end






%----------------------------------------------------
%        RED CHANNEL CONTINUE BUTTON CALLBACK
%----------------------------------------------------
function REDcontinue(hObject, eventdata)    

    uiresume
    
end















%----------------------------------------------------
%        EXPORT DATA TO BASE WORKSPACE
%----------------------------------------------------
function exportvars(hObject, eventdata)
% disableButtons; pause(.02);

    if size(SEGtable,1) > 1
        checkLabels = {'Save IMG to variable named:' ...
                   'Save SEGstruct to variable named:' ...
                   'Save SEGtable to variable named:' ...
                   'Save XLSdata to variable named:' ...
                   'Save IMGraw to variable named:'...
                   'Save IMGSraw to variable named:'...
                   'Save muIMGS to variable named:'...
                   'Save LICK to variable named:'}; 
        varNames = {'IMG','SEGstruct','SEGtable','XLSdata','IMGraw','IMGSraw','muIMGS','LICK'}; 
        items = {IMG,SEGstruct,SEGtable,XLSdata,IMGraw,IMGSraw,muIMGS,LICK};
        export2wsdlg(checkLabels,varNames,items,...
                     'Save Variables to Workspace');

        memocon('Main VARS exported to base workspace')
    else
        memocon('no variables available to export')
    end
    
enableButtons        
end




%----------------------------------------------------
%        SAVE DATA TO .MAT FILE
%----------------------------------------------------
function savedataset(hObject, eventdata)
% disableButtons; pause(.02);

    if size(IMG,3) > 1
        
        

        
        
        
        [filen,pathn] = uiputfile([SEGstruct.file(1:end-4),'.mat'],'Save Vars to Workspace');
            
        if isequal(filen,0) || isequal(pathn,0)
           memocon('User selected Cancel')
        else
           memocon(['User selected ',fullfile(pathn,filen)])
        end
        
        % IMGint16 = uint16(IMG);
        % IMG = single(IMG);
                
        memocon('Saving data to .mat file, please wait...')
        save(fullfile(pathn,filen),'IMG','SEGstruct','SEGtable','XLSdata',...
            'LICK','IMGraw','muIMGS','IMGSraw','-v7.3')
        % save(fullfile(pathn,filen),'IMGint16','SEGstruct','SEGtable','-v7.3')
        memocon('Dataset saved!')
        
        % whos('-file','newstruct.mat')
        % m = matfile(filename,'Writable',isWritable)
        % save(filename,variables,'-append')
        
%         switch comchoice
%             case 'Yes'
%                 memocon('YOU ARE NOW USING COMPRESSED IMG DATA')
%                 memocon('IF YOU WANT TO WORK WITH UNCOMPRESSED DATA, RELAUNCH TOOLBOX')
%                 IMG = int16(IMG./10000);
%             case 'No'
%                 memocon('CONTINUE USING UNCOMPRESSED IMG DATA')
%         end        

    else
        memocon('No data to save')
    end
    
enableButtons        
end




%----------------------------------------------------
%        COMPRESS AND SAVE
%----------------------------------------------------
function compnsave(hObject, eventdata)

    if size(IMG,3) < 1
        memocon('No data to save')
        return
    end

    comchoice = questdlg('Save compressed dataset?', ...
        'Compress IMG Stack', ...
        'Single','uint16','Nevermind','Single');

    switch comchoice
        case 'Single'
            memocon('DETERMING OPTIMAL DATA COMPRESSION METHOD...')
            doCompress = 1;
        case 'uint16'
            memocon('DETERMING OPTIMAL DATA COMPRESSION METHOD...')
            doCompress = 2;            
        case 'Nevermind'
            memocon('RETURNING TO GUI')
            doCompress = 0;
            return
    end 

    
    
    
    
    
    if doCompress == 1
    
        IM = IMG;
        IMhist.rawIM = IMG(:,:,1,1);
        IMhist.minIM = min(min(min(min(IMG))));
        IMhist.maxIM = max(max(max(max(IMG))));
        IMhist.aveIM = mean(mean(mean(mean(IMG))));

        
        IMG = im2single( IMG  );
        IMGSraw = im2single( IMGSraw  );
        muIMGS  = im2single( muIMGS  );

        [filen,pathn] = uiputfile([SEGstruct.file(1:end-4),'.mat'],'Save Vars to Workspace');
        if isequal(filen,0) || isequal(pathn,0)
           memocon('Data Save Cancelled'); return
        end; memocon('Saving data to .mat file, please wait...')

        disableButtons; pause(.02);

        save(fullfile(pathn,filen),'IMG','SEGstruct','SEGtable','XLSdata',...
                                   'muIMGS','IMGSraw','LICK','IMhist','-v7.3')

        memocon('Dataset saved!')

        IMG = IM;
        IM = [];

        IMGSraw = double(IMGSraw);
        muIMGS  = double(muIMGS);

    
    end
    
    
    
    
    
    
    
    
    
    
    if doCompress == 2
        IM = IMG;
        IMhist.rawIM = IMG(:,:,1,1);
        IMhist.minIM = min(min(min(min(IMG))));
        IMhist.maxIM = max(max(max(max(IMG))));
        IMhist.aveIM = mean(mean(mean(mean(IMG))));


        if IMhist.minIM < 0
            IMG = im2uint16(  IMG +  abs(IMhist.minIM)   );
            % IM = im2single( IMG  );
        else
            IMG = im2uint16(  IMG -  abs(IMhist.minIM)   );
        end


        IMGSraw = im2single( IMGSraw  );
        muIMGS  = im2single( muIMGS  );


        [filen,pathn] = uiputfile([SEGstruct.file(1:end-4),'.mat'],'Save Vars to Workspace');
        if isequal(filen,0) || isequal(pathn,0)
           memocon('Data Save Cancelled'); return
        end; memocon('Saving data to .mat file, please wait...')

        disableButtons; pause(.02);

        save(fullfile(pathn,filen),'IMG','SEGstruct','SEGtable','XLSdata',...
                                   'muIMGS','IMGSraw','LICK','IMhist','-v7.3')

        memocon('Dataset saved!')

        IMG = IM;
        IM = [];

        IMGSraw = double(IMGSraw);
        muIMGS  = double(muIMGS);
    end
            
enableButtons        
end




%----------------------------------------------------
%        LOAD .mat DATA
%----------------------------------------------------
function loadmatdata(hObject, eventdata)
% disableButtons; pause(.02);


    [filename, pathname] = uigetfile( ...
    {'*.mat'}, ...
   'Select a .mat datafile');
    
    IMG = [];
    IMGSraw = [];
    muIMGS = [];

memocon('Loading data from .mat file, please wait...')
disableButtons; pause(.02);    

    LODIN = load([pathname, filename]);
    
    
    [IMG] = deal(LODIN.IMG);
    [SEGstruct] = deal(LODIN.SEGstruct);
    [SEGtable] = deal(LODIN.SEGtable);
    [XLSdata] = deal(LODIN.XLSdata);
    [muIMGS] = deal(LODIN.muIMGS);
    [IMGSraw] = deal(LODIN.IMGSraw);
    [LICK] = deal(LODIN.LICK);
    [IMhist] = deal(LODIN.IMhist);
    
    
    if isa(IMG, 'single')

        memocon('loading single precision dataset...')
        IM = IMG;
        IMG = double(IM);
        
    else
        
        memocon('loading uint16-compressed dataset...')
        IM = IMG;
        IMG = double(IM);
        lintrans = @(x,a,b,c,d) (c.*(1-(x-a)./(b-a)) + d.*((x-a)./(b-a)));
        IMG = lintrans(IMG,min(min(min(min(IMG)))),max(max(max(max(IMG)))),IMhist.minIM,IMhist.maxIM);
        
    end
    
    LODIN = [];
    IM = [];
    
    previewStack

    clc;
    memocon('Dataset loaded with the following history...')
    memocon(IMhist)
    memocon('Experimental parameters...')
    memocon(XLSdata.CSUSvals)
    memocon('Image stack sizes...')
    memocon(['size(IMG) :  ' num2str(size(IMG))])
    memocon(['size(muIMGS) :  ' num2str(size(muIMGS))])
    memocon(['size(IMGSraw) :  ' num2str(size(IMGSraw))])

memocon('Dataset fully loaded, SEG Toolbox is Ready!')
enableButtons        
end





%----------------------------------------------------
%        OPEN IMAGEJ API
%----------------------------------------------------
function openImageJ(hObject, eventdata)
% disableButtons; pause(.02);


    memocon('LAUNCHING ImageJ (FIJI) using MIJ!')
    
    matfiji(IMG(:,:,1:100), SEGstruct, XLSdata, LICK)
        

  
    
% SEGMENTIZER
return
enableButtons        
memocon('ImageJ (FIJI) processes completed!')
end




%----------------------------------------------------
%        3D DATA EXPLORATION
%----------------------------------------------------
function img3d(hObject, eventdata)
disableButtons; pause(.02);



    choice = questdlg({'Contour slicing could take a few minutes.',...
                       'Do you want to continue?'},' ','Yes','No','No');
                   
            switch choice
                case 'Yes'
                     memocon('CREATING CONTOUR SLICE (please wait)...')
                case 'No'
                    return
            end

    IM = IMG(:,:,1:50);

    
    fh10=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],...
        'Color','w','MenuBar','none','Pointer','circle');
    hax10 = axes('Position',[.05 .05 .9 .9],'Color','none');
    rotate3d(fh10);
    
    Sx = []; 
    Sy = [];
    Sz = [1 25 50];
    
    contourslice(IM,Sx,Sy,Sz)
        campos([0,-15,8])
        box on
    
    


    
enableButtons        
memocon('3D VIEW FUNCTION COMPLETED!')
end




%----------------------------------------------------
%        VISUAL EXPLORATION
%----------------------------------------------------
function visualexplorer(hObject, eventdata)
% disableButtons; pause(.02);




    if numel(size(IMG))==3

        IM = IMG(:,:,1:XLSdata.framesPerTrial);
        
        vol = [round(XLSdata.sizeIMG(1)*.25),round(XLSdata.sizeIMG(1)*.5),...
               round(XLSdata.sizeIMG(2)*.25),round(XLSdata.sizeIMG(2)*.5),...
               1,XLSdata.framesPerTrial];
        
        isoval = 5;
        
    else
        
        IM = IMG(:,:,1:XLSdata.framesPerTrial,1);
        
        vol = [round(XLSdata.sizeIMG(1)*.25),round(XLSdata.sizeIMG(1)*.5),...
               round(XLSdata.sizeIMG(2)*.25),round(XLSdata.sizeIMG(2)*.5),...
               1,XLSdata.framesPerTrial];
        
        isoval = -1;
    
    end
    
    
    memocon('CREATING SUBVOLUME FROM IMAGE STACK...')

    
    
    [x,y,z,D] = subvolume(IM,vol);

    
    
%     fh10=figure('Units','normalized','OuterPosition',[.1 .1 .6 .8],...
%         'Color','w','MenuBar','none');
%     hax10 = axes('Position',[.05 .05 .9 .9],'Color','none');


    p1 = patch(isosurface(x,y,z,D, isoval),...
         'FaceColor','red','EdgeColor','none');
    isonormals(x,y,z,D,p1);
    p2 = patch(isocaps(x,y,z,D, isoval),...
         'FaceColor','interp','EdgeColor','none');
    view(3); axis tight;
    camlight right; camlight left; lighting gouraud
    
    rotate3d(gca);

for i = 1:150;
   camorbit(3,0)
   pause(.05)
end


    
enableButtons        
memocon('SUBVOLUME CREATION COMPLETED (USE MOUSE TO ROTATE IMAGE)!')
end





%----------------------------------------------------
%        RESET WORKSPACE
%----------------------------------------------------
function resetws(hObject, eventdata)
% disableButtons; pause(.02);


    choice = questdlg({'This will close all windows and reset the ',...
                       'SEG Lens Toolbox workspace. Continue?'}, ...
	'Relaunch SEG Toolbox', ...
	'reset toolbox','abort reset','reset toolbox');
    % Handle response
    switch choice
        case 'reset toolbox'
            memocon(' Resetting SEG Lens Toolbox...')
            pause(1)
            SEGMENTIZER()
            return
        case 'abort reset'
            memocon(' Continuing without reset...')
    end
    
    
% enableButtons
end





%----------------------------------------------------
%        IMAGE SIDER CALLBACK
%----------------------------------------------------
function imgslider(hObject, eventdata)

    % Hints: hObject.Value returns position of slider
    %        hObject.Min and hObject.Max determine range of slider
    % sunel = get(handles.sunelslider,'value'); % Get current light elev.
    % sunaz = get(hObject,'value');   % Varies from -180 -> 0 deg

    slideVal = ceil(imgsliderH.Value);

    if size(IMG,3) > 99

        phSEG = imagesc(IMG(:,:,slideVal) , 'Parent', haxSEG);
                  pause(.05)

        memocon(['image' num2str(slideVal)])

    else

        memocon('There must be at least 100 images in the stack')
        memocon('(per trial) to use the slider; currently there are')
        memocon(size(IMG,3))

    end

end





%----------------------------------------------------
%        CONSOLE DIARY ON / OFF / OPEN
%----------------------------------------------------
function conon
    % diary on
end
function conoff
    % diary(confile)
    % diary off
    
    % UNCOMMENT TO OPEN DIARY WHEN DONE IMAGE PROCESSING
    % web(confilefullpath{1})
end



%----------------------------------------------------
%        CSUS DROPDOWN MENU CALLBACK
%----------------------------------------------------
function CSUSpopup(hObject, eventdata)

    if numel(SEGtable) > 0 
        memocon('reminder of CS/US combos...')
        SEGtable(1:7,1:2)
        % SEGstruct
    end
        
    stimnum = CSUSpopupH.Value;

    % CSUSvals = unique(SEGstruct.csus);
    % set(CSUSpopupH, 'String', CSUSvals);

end




% %----------------------------------------------------
% %        NormType DROPDOWN MENU CALLBACK
% %----------------------------------------------------
% function NormTypePopup(hObject, eventdata)
%     
%     
%     PopValue = NormTypePopupH.Value;
%     NormType = NormTypePopupH.String{PopValue};
%     
%     memocon(sprintf('Normalization set to: % s ',NormType));
% 
%     
%     % set(NormTypePopupH, 'String', {'dF','Zscore'});
%     % CSUSvals = unique(SEGstruct.csus);
%     % set(CSUSpopupH, 'String', CSUSvals);
% 
% end








%------------------------------------------------------------------------------
%        PLOT LICKING DATA
%------------------------------------------------------------------------------
function plotLick(hObject, eventdata)

    maxY = (max(max(LICK)));
    minY = (min(min(LICK)));
    rmaxY = ceil(round(maxY,2));
    rminY = floor(round(minY,2));
    

    %-----------------------------------
    %    CREATE FIGURE FOR LICKING PLOT
    %-----------------------------------
    lickfigh = figure('Units', 'normalized','Position', [.02 .05 .60 .42], 'BusyAction',...
    'cancel', 'Name', 'lickfigh', 'Tag', 'lickfigh','MenuBar', 'none'); 

    LhaxSEG = axes('Parent', lickfigh, 'NextPlot', 'replacechildren',...
    'Position', [0.05 0.05 0.9 0.9],'Color','none'); 
    LhaxSEG.YLim = [rminY rmaxY];
    LhaxSEG.XLim = [1 size(LICK,2)];

    GhaxLCK = axes('Parent', lickfigh, 'NextPlot', 'replacechildren',...
    'Position', [0.05 0.05 0.9 0.9],'Color','none'); hold on;
    GhaxLCK.YLim = LhaxSEG.YLim;
    GhaxLCK.XLim = LhaxSEG.XLim;
    hold on;

    %-----------------------------------
    %    PLOT LICKING DATA
    %-----------------------------------
    axes(LhaxSEG)
    LhaxSEG.ColorOrderIndex = 1;
hpLick = plot(LhaxSEG, LICK' , ':', 'LineWidth',2,'HandleVisibility', 'off');
    
    legLick = legend(hpLick,XLSdata.CSUSvals);
	set(legLick, 'Location','NorthWest', 'Color', [1 1 1],'FontSize',12,'Box','off');
    set(legLick, 'Position', legLick.Position .* [1 .94 1 1.4])      
    
    
    
    %-----------------------------------
    %    PLOT CS ON/OFF LINES
    %-----------------------------------
    axes(GhaxLCK)
    
    CSonsetFrame = round(XLSdata.CSonsetDelay .* XLSdata.framesPerSec);
    CSoffsetFrame = round((XLSdata.CSonsetDelay+XLSdata.CS_length) .* XLSdata.framesPerSec);
    line([CSonsetFrame CSonsetFrame],GhaxLCK.YLim,...
    'Color',[.52 .52 .52],'Parent',GhaxLCK,'LineWidth',2)
    line([CSoffsetFrame CSoffsetFrame],GhaxLCK.YLim,...
    'Color',[.5 .5 .5],'Parent',GhaxLCK,'LineWidth',2)




    axes(LhaxSEG)
    pause(.02)

   
end


%------------------------------------------------------------------------------
%        PLOT LICKING DATA
%------------------------------------------------------------------------------
function normLick(hObject, eventdata)
    
    
    if strcmp(normLickH.String,'Normalize Lick')
        memocon('Normalizing Lick Data...')
        
        LICKraw = LICK;
        LICKbase = mean(LICK(:,1:round(baselineTime*framesPerSec)),2);
        LICKbase = repmat(LICKbase,1,size(LICK,2));
        LICK = (LICK - LICKbase) ./ (LICKbase);
        
        
        normLickH.String = 'Undo Lick Norm';
        memocon('Normalization Completed.')
    elseif strcmp(normLickH.String,'Undo Lick Norm')
        memocon('Reverting lick data Normalization...')
        
        LICK = LICKraw;
        
        normLickH.String = 'Normalize Lick';
        memocon('Undid lick data Normalization.')
    end
    
    
    
    
end









end
%% EOF