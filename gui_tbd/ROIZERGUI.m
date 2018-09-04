function [] = ROIZERGUI()
% function [] = ROIzerGUI(ROIS,IMZ,PC)
% clc; close all;
% 
% clearvars -except ROIS IMZ PC
% 
% RR = ROIS;
% IMG = IMZ;
% PP = PC;
% 
% 
% ACT = [];
% GRPS = [];

% P.home='/Users/bradleymonk/Documents/MATLAB/GIT/ROIZER';


% CLEAR ENV, ADD FOLDER TO PATH
%----------------------------------------------------
close all; clear; clc; rng('shuffle');
mfi = mfilename('fullpath');
[p,n] = fileparts(mfi);
n(end+1:end+2) = '.m';
P.mfilename = p;
cd(P.mfilename)
P.home  = pwd;
P.funs  = [P.home filesep 'datasets'];
P.data  = [P.home filesep 'functions'];
addpath(join(string(struct2cell(P)),':',1))
clearvars -except P











%----------------------------------------------------
global IMG Sframe Eframe BSframe IMsz IMraw IMGSraw ACT

Sframe = [];
IMG = [];
IMsz = [];
IMraw = [];
IMGSraw = [];
ACT = [];


%----------------------------------------------------
global BlurVal quantMin quantMax minROIsz doCustomBaseline

BlurVal = .1;
quantMin = .001;
quantMax = .999;
minROIsz = 20;
doCustomBaseline = 0;
% ACT = [];








%########################################################################
%%     CREATE ROIZER FIGURE WINDOW
%----------------------------------------------------
ROIZERAPP = figure('Units','pixels','Position',[10 35 1100 750],...
'BusyAction','cancel','Name','ROIMODULE','Tag','ROIMODULE','MenuBar','none'); 


%----------------------------------------------------
%%     LEFT PANE MAIN PLOT WINDOW
%----------------------------------------------------
AXMAIN = axes('Parent',ROIZERAPP,'Units','normalized',...
    'Position', [0.05 0.08 0.54 0.65],'NextPlot','replacechildren',...
    'XLimMode', 'manual','YLimMode', 'manual','Color','none','YDir','reverse');
pause(2); AXMAIN.YDir = 'normal';


    I = imread('ROIZERLOGO.png');
    %I = imread('ROIZERLOGO.jpg');
	%I = imresize(I,.5);
    imagesc(I,'Parent',AXMAIN)
    axis tight
    AXMAIN.XLim = [1 size(I,2)];

    IMG = I;
    IMsz = size(IMG);
    IMraw = mean(IMG,3);
    IMGSraw = IMraw;


GimgsliderYAH = uicontrol('Parent', ROIZERAPP, ...
    'Units', 'normalized','Style','slider',...
	'Max',1,'Min',0,'Value',.15,'SliderStep',[0.01 0.10],...
	'Position', [-.01 0.42 0.03 0.25], 'Callback', @GimgsliderYA);

GimgsliderYBH = uicontrol('Parent', ROIZERAPP, ...
    'Units', 'normalized','Style','slider',...
	'Max',0,'Min',-1,'Value',-.15,'SliderStep',[0.01 0.10],...
	'Position', [-.01 0.04 0.03 0.25], 'Callback', @GimgsliderYB);

GimgsliderXAH = uicontrol('Parent', ROIZERAPP, ...
    'Units', 'normalized','Style','slider',...
	'Max',200,'Min',0,'Value',100,'SliderStep',[0.01 0.10],...
	'Position', [0.40 0.01 0.20 0.03], 'Callback', @GimgsliderXA);

GimgsliderXBH = uicontrol('Parent', ROIZERAPP, ...
    'Units', 'normalized','Style','slider',...
	'Max',200,'Min',0,'Value',1,'SliderStep',[0.01 0.10],...
	'Position', [0.05 0.01 0.20 0.03], 'Callback', @GimgsliderXB);



%----------------------------------------------------
%     CHECK-BOX PANEL
%----------------------------------------------------



DisplaypanelH = uipanel('Parent', ROIZERAPP,'Units','normalized',...
    'Title','Display on Line Graph','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.01 0.75 0.13 0.24]); % 'Visible', 'Off',


GRPS = ["I","am","your","best","buddy"];


sp = linspace(.1,.9,3);

GcheckboxH1 = uicontrol('Parent', DisplaypanelH,...
    'Style','checkbox','Units','normalized',...
    'Position', [.05 0.02 sp(1) .10] ,'String',GRPS(1),...
    'Value',1,'Callback',{@plot_callback,7});

GcheckboxH2 = uicontrol('Parent', DisplaypanelH,...
    'Style','checkbox','Units','normalized',...
    'Position', [.05 0.02 sp(2) .10] ,'String',GRPS(1),...
    'Value',1,'Callback',{@plot_callback,7});

GcheckboxH3 = uicontrol('Parent', DisplaypanelH,...
    'Style','checkbox','Units','normalized',...
    'Position', [.05 0.02 sp(1) .1],'String',GRPS(1),...
    'Value',1,'Callback',{@plot_callback,7});




%----------------------------------------------------
%           MEMO CONSOLE GUI WINDOW
%----------------------------------------------------

memopanelH = uipanel('Parent', ROIZERAPP,'Title','Memo Log ','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.15 0.75 0.45 0.24]); % 'Visible', 'Off',


memos = {' ',' ',' ', ' ',' ',' ',' ',' ', ...
         'Welcome to ROI Finder', 'GUI is loading...'};

memoboxH = uicontrol('Parent',memopanelH,...
        'Style','listbox','Units','normalized','Max',10,'Min',0,...
        'Value',10,'FontSize', 13,'FontName', 'FixedWidth',...
        'String',memos,'FontWeight', 'bold',...
        'Position',[.02 .02 .96 .96]);  
    
% memolog('Ready!')





%----------------------------------------------------
%%     RIGHT PANE FIGURE PANELS
%----------------------------------------------------

tabgp = uitabgroup(ROIZERAPP,'Position',[0.61 0.02 0.38 0.95]);
btabs = uitab(tabgp,'Title','Options');
dtabs = uitab(tabgp,'Title','Data');
itabs = uitab(tabgp,'Title','ROI');
gtabs = uitab(tabgp,'Title','Image');







%----------------------------------------------------
%%     IMAGE TAB
%----------------------------------------------------

IMpanel = uipanel('Parent', gtabs,'Title','Image Previews','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],'Position', [0.01 0.01 0.98 0.98]);


haxROI = axes('Parent', IMpanel, ...
    'Position', [0.01 0.21 0.98 0.65], 'Color','none',...
    'XLimMode', 'manual','YLimMode', 'manual',...
    'YDir','reverse','XColor','none','YColor','none','XTick',[],'YTick',[]); 
    haxROI.YLim = [0 IMsz(1)];
    haxROI.XLim = [0 IMsz(2)];
    hold on
    % 'NextPlot', 'replacechildren',
    
    
phIM = imagesc(IMGSraw(:,:,1,1) , 'Parent',haxROI);

haxROI.Title = text(0.5,0.5,'IMG Stack');


haxMINI = axes('Parent', IMpanel, 'NextPlot', 'replacechildren',...
    'Position', [0.01 0.02 0.98 0.18],...
    'XLimMode', 'manual','YLimMode', 'manual','Color','none');
    haxMINI.YLim = [-.10 .15];
    haxMINI.XLim = [1 size(IMG,3)];


%----------------------------------------------------
%%     OPTIONS TAB
%----------------------------------------------------


%-----------------------------------
%    FIND ROI PANEL
%-----------------------------------
GIPpanelH = uipanel('Parent', btabs,'Title','Image Processing','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.02 0.01 0.45 0.98]); % 'Visible', 'Off',

findROIcallbackH = uicontrol('Parent', GIPpanelH, 'Units', 'normalized', ...
    'Position', [.05 0.94 .90 .05], 'FontSize', 13, 'String', 'FIND ROI',...
    'Callback', @findROIcallback, 'Enable','on');


BulkFindROIsH = uicontrol('Parent', GIPpanelH, 'Units', 'normalized', ...
    'Position', [.05 0.88 .90 .05], 'FontSize', 12, 'String', 'BULK FIND ROIs',...
    'Callback', @BulkFindROIs); % , 'Enable','on' 'BackgroundColor',[.95 .95 .95],...

if size(ACT,2) > 2
togLickDataH = uicontrol('Parent', GIPpanelH, 'Units', 'normalized', ...
    'Position', [.05 0.82 .90 .05], 'FontSize', 12, 'String', 'Toggle ACT Data',...
    'Callback', @togLickData, 'Enable','on');
else
togLickDataH = uicontrol('Parent', GIPpanelH, 'Units', 'normalized', ...
    'Position', [.05 0.82 .90 .05], 'FontSize', 12, 'String', 'Toggle ACT Data',...
    'Callback', @togLickData, 'Enable','off');
end

buttongroup1 = uibuttongroup('Parent', GIPpanelH,'Title','ROI FACTOR',...
                  'Units', 'normalized','Position',[.01 0.40 .98 .37],...
                  'SelectionChangedFcn',@buttongroup1selection);
              
bva = 1;

if size(GRPS,1) > 0
    fac1 = uicontrol(buttongroup1,'Style','radiobutton',...
    'Units', 'normalized','Position',[.05 0.86 .90 .10],...
        'String',GRPS(1),'HandleVisibility','off');
end
if size(GRPS,1) > 1
    fac2 = uicontrol(buttongroup1,'Style','radiobutton',...
    'Units', 'normalized','Position',[.05 0.72 .90 .10],...
        'String',GRPS(2),'HandleVisibility','off');
end
if size(GRPS,1) > 2
    fac3 = uicontrol(buttongroup1,'Style','radiobutton',...
    'Units', 'normalized','Position',[.05 0.58 .90 .10],...
        'String',GRPS(3),'HandleVisibility','off');
end
if size(GRPS,1) > 3
    fac4 = uicontrol(buttongroup1,'Style','radiobutton',...
    'Units', 'normalized','Position',[.05 0.44 .90 .10],...
        'String',GRPS(4),'HandleVisibility','off');
end
if size(GRPS,1) > 4 
    fac5 = uicontrol(buttongroup1,'Style','radiobutton',...
    'Units', 'normalized','Position',[.05 0.30 .90 .10],...
        'String',GRPS(5),'HandleVisibility','off');
end
if size(GRPS,1) > 5
    fac6 = uicontrol(buttongroup1,'Style','radiobutton',...
    'Units', 'normalized','Position',[.05 0.16 .90 .10],...
        'String',GRPS(6),'HandleVisibility','off');
end
if size(GRPS,1) > 6
    fac7 = uicontrol(buttongroup1,'Style','radiobutton',...
    'Units', 'normalized','Position',[.05 0.02 .90 .10],...
        'String',GRPS(7),'HandleVisibility','off');
end





buttongroup2 = uibuttongroup('Parent', GIPpanelH,'Title','ROI COFACTOR',...
                  'Units', 'normalized','Position',[.01 0.01 .98 .37],...
                  'SelectionChangedFcn',@buttongroup2selection);
              
bva = 1;

if size(GRPS,1) > 0
    cofac1 = uicontrol(buttongroup2,'Style','radiobutton',...
    'Units', 'normalized','Position',[.05 0.86 .90 .10],...
        'String',GRPS(1),'HandleVisibility','off');
end
if size(GRPS,1) > 1
    cofac2 = uicontrol(buttongroup2,'Style','radiobutton',...
    'Units', 'normalized','Position',[.05 0.72 .90 .10],...
        'String',GRPS(2),'HandleVisibility','off');
end
if size(GRPS,1) > 2
    cofac3 = uicontrol(buttongroup2,'Style','radiobutton',...
    'Units', 'normalized','Position',[.05 0.58 .90 .10],...
        'String',GRPS(3),'HandleVisibility','off');
end
if size(GRPS,1) > 3
    cofac4 = uicontrol(buttongroup2,'Style','radiobutton',...
    'Units', 'normalized','Position',[.05 0.44 .90 .10],...
        'String',GRPS(4),'HandleVisibility','off');
end
if size(GRPS,1) > 4 
    cofac5 = uicontrol(buttongroup2,'Style','radiobutton',...
    'Units', 'normalized','Position',[.05 0.30 .90 .10],...
        'String',GRPS(5),'HandleVisibility','off');
end
if size(GRPS,1) > 5
    cofac6 = uicontrol(buttongroup2,'Style','radiobutton',...
    'Units', 'normalized','Position',[.05 0.16 .90 .10],...
        'String',GRPS(6),'HandleVisibility','off');
end
if size(GRPS,1) > 6
    cofac7 = uicontrol(buttongroup2,'Style','radiobutton',...
    'Units', 'normalized','Position',[.05 0.02 .90 .10],...
        'String',GRPS(7),'HandleVisibility','off');
end


function buttongroup1selection(source,callbackdata)
    
    % memolog(['Previous ROI factor: ' callbackdata.OldValue.String])
    % memolog(['Current ROI factor: ' callbackdata.NewValue.String])
    memolog(['Factor set to: ' callbackdata.NewValue.String])
    ROIfac = callbackdata.NewValue.String;
end


function buttongroup2selection(source,callbackdata)
    memolog(['Cofactor set to: ' callbackdata.NewValue.String])
    ROIcof = callbackdata.NewValue.String;
end


%-----------------------------------
%    ROI PARAMETERS PANEL
%-----------------------------------
ParamPanelH = uipanel('Parent', btabs,'Title','ROI Processing Parameters','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.50 0.85 0.45 0.14]); % 'Visible', 'Off',


smoothimgtxtH = uicontrol('Parent', ParamPanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.01 0.69 0.46 0.22], 'FontSize', 10,'String', 'Smooth amount: ');
smoothimgnumH = uicontrol('Parent', ParamPanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.51 0.69 0.42 0.27], 'FontSize', 10,'Callback',@smoothimgnumHCallback);

quantMinT = uicontrol('Parent', ParamPanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.01 0.35 0.46 0.22], 'FontSize', 10,'String', 'Min Quantile: ');
quantMinH = uicontrol('Parent', ParamPanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.51 0.36 0.42 0.27], 'FontSize', 10,'Callback',@quanMinFun);

minROIszT = uicontrol('Parent', ParamPanelH, 'Style', 'Text', 'Units', 'normalized',...
    'Position', [0.01 0.02 0.46 0.22], 'FontSize', 10,'String', 'Min ROI pixels: ');
minROIszH = uicontrol('Parent', ParamPanelH, 'Style', 'Edit', 'Units', 'normalized', ...
    'Position', [0.51 0.04 0.42 0.27], 'FontSize', 10,'Callback',@minROIszFun);



% BulkFindROIsH = uicontrol('Parent', ParamPanelH,...
%     'Style','checkbox','Units','normalized',...
%     'Position', [0.01 0.35 0.46 0.10] ,...
%     'String','Bulk Find ROIs', 'Value',0,...
%     'Callback',{@BulkFindROIsCall,1});




smoothimgnumH.String    = num2str(BlurVal);
% zcritnumH.String      = num2str(zcrit);
% zoutnumH.String       = num2str(zout);
quantMinH.String        = num2str(quantMin);
minROIszH.String        = num2str(minROIsz);






%%
%-----------------------------------
%    TIMING PARAMETERS PANEL
%-----------------------------------
TimePanelH = uipanel('Parent', btabs,'Title','Timing Parameters','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.50 0.25 0.45 0.57]); % 'Visible', 'Off',

frameinfoH = uicontrol('Parent', TimePanelH, 'Units', 'normalized', ...
    'Position', [.01 0.88 .98 .11], 'FontSize', 13, 'String', 'Frame Timing Info',...
    'Callback', @frameinfocallback, 'Enable','on');



customTimingH = uicontrol('Parent', TimePanelH,...
    'Style', 'Text', 'Units', 'normalized',...
    'Position', [.01 0.38 .98 .05], 'FontSize', 11,...
    'String', 'Custom Comparison');
custFrameTimingH = uicontrol('Parent', TimePanelH,...
    'Style', 'Text', 'Units', 'normalized',...
    'Position', [.01 0.33 .98 .05], 'FontSize', 11,...
    'String', 'Start Frame     -     End Frame');
SframeH = uicontrol('Parent', TimePanelH, 'Style', 'Edit',...
    'Units', 'normalized','Enable', 'Off',...
    'Position', [.02 0.26 .45 .07], 'FontSize', 10,...
    'Callback',@custSFrameTiming);
EframeH = uicontrol('Parent', TimePanelH, 'Style', 'Edit', ...
    'Units', 'normalized','Enable', 'Off', ...
    'Position', [.52 0.26 .45 .07], 'FontSize', 10,...
    'Callback',@custEFrameTiming);

SframeH.String = num2str(Sframe);
EframeH.String = num2str(Eframe);




customBaselineH = uicontrol('Parent', TimePanelH,...
    'Style', 'Text', 'Units', 'normalized',...
    'Position', [.10 0.13 .78 .05], 'FontSize', 11,...
    'String', 'Custom Baseline');
customBaseCheckH = uicontrol('Parent', TimePanelH,...
    'Style','checkbox','Units','normalized',...
    'Position', [.03 0.01 .45 .07] ,'String','Use Custom',...
    'Value',doCustomBaseline,'Callback',@customBaseCheck);
custBaseTimingH = uicontrol('Parent', TimePanelH, 'Style', 'Text',...
    'Units', 'normalized','Position', [.55 0.08 .40 .05],...
    'FontSize', 11,'String', 'Frame Number');
BSframeH = uicontrol('Parent', TimePanelH, 'Style', 'Edit',...
    'Units', 'normalized','Enable', 'Off','Position', [.52 0.01 .45 .07],...
    'FontSize', 10,'Callback',@custBSFrameTiming);
% BEframeH = uicontrol('Parent', TimePanelH, 'Style', 'Edit',...
%   'Units', 'normalized','Enable', 'Off', ...
%   'Position', [.51 0.01 .48 .07], 'FontSize', 10,'Callback',@custBEFrameTiming);

BSframeH.String = num2str(BSframe);
% BEframeH.String = num2str(BEframe);


%%
function custSFrameTiming(hObject, eventdata, handles)

    Sframe = str2double(get(hObject,'String'));
    % SframeH.String = SframeH.String;
    memolog(['Start frame updated to: ' SframeH.String])
    memolog(['Frame range now: ' SframeH.String ' - ' EframeH.String])

end

function custEFrameTiming(hObject, eventdata, handles)

    Eframe = str2double(get(hObject,'String'));
    memolog(['End frame updated to: ' EframeH.String])
    memolog(['Frame range now: ' SframeH.String ' - ' EframeH.String])

end



function custBSFrameTiming(hObject, eventdata, handles)

    BSframe = str2double(get(hObject,'String'));
    % BSframeH.String = BSframeH.String;
    memolog(['Rolling Baseline frames: ' BSframeH.String])
    %memolog(['Frame range is: ' BSframeH.String ' - ' BEframeH.String])

end

function customBaseCheck(hObject, eventdata, handles)

    % BEframe = str2double(get(hObject,'String'));
    
    doCustomBaseline = customBaseCheckH.Value;
    
    if doCustomBaseline == 1
        BSframe = str2num(BSframeH.String);
        BSframeH.Enable = 'on';
        memolog('Rolling Baseline ON')
    end
    if doCustomBaseline == 0
        BSframe = 0;
        BSframeH.String = num2str(BSframe);
        BSframeH.Enable = 'off';
        memolog('Rolling Baseline OFF')
    end
    
end

%%

frameBG = uibuttongroup('Parent', TimePanelH,'Title','Comparison Frame Range',...
                  'Units', 'normalized','Position',[.01 0.45 .98 .40],...
                  'SelectionChangedFcn',@frameBGfun);
              
    framerange1 = uicontrol(frameBG,'Style','radiobutton','Units', 'normalized',...
        'Position',[.01 0.75 .48 .20],'String','Baseline','HandleVisibility','off');

    framerange2 = uicontrol(frameBG,'Style','radiobutton','Units', 'normalized',...
        'Position',[.51 0.75 .48 .20],'String','Custom','HandleVisibility','off');
    
    
    
    framerange3 = uicontrol(frameBG,'Style','radiobutton','Units', 'normalized',...
        'Position',[.01 0.50 .48 .20],'String','CS All','HandleVisibility','off');

    framerange4 = uicontrol(frameBG,'Style','radiobutton','Units', 'normalized',...
        'Position',[.51 0.50 .48 .20],'String','US All','HandleVisibility','off');
    
    
    
    framerange5 = uicontrol(frameBG,'Style','radiobutton','Units', 'normalized',...
        'Position',[.01 0.25 .48 .20],'String','CS 1st Half','HandleVisibility','off');

    framerange6 = uicontrol(frameBG,'Style','radiobutton','Units', 'normalized',...
        'Position',[.51 0.25 .48 .20],'String','US 1st Half','HandleVisibility','off');
    
    
    
    framerange7 = uicontrol(frameBG,'Style','radiobutton','Units', 'normalized',...
        'Position',[.01 0.01 .48 .20],'String','CS 2nd Half','HandleVisibility','off');

    framerange8 = uicontrol(frameBG,'Style','radiobutton','Units', 'normalized',...
        'Position',[.51 0.01 .48 .20],'String','US 2nd Half','HandleVisibility','off');
    
    
%%    
    

function frameBGfun(source,callbackdata)
    
    frameSE = callbackdata.NewValue.String;
    
    
    memolog(['ROI period updated to: ' callbackdata.NewValue.String])
    
    
    if strcmp(frameSE,'Baseline')
        SframeH.String = Fbson;
        EframeH.String = Fbsoff;
        SframeH.Enable = 'off';
        EframeH.Enable = 'off';
    end
    if strcmp(frameSE,'Custom')
        SframeH.String = SframeH.String;
        EframeH.String = EframeH.String;
        SframeH.Enable = 'on';
        EframeH.Enable = 'on';
    end
    
    if strcmp(frameSE,'CS All')
        SframeH.String = Fcson;
        EframeH.String = Fcsoff;
        SframeH.Enable = 'off';
        EframeH.Enable = 'off';
    end
    if strcmp(frameSE,'US All')
        SframeH.String = Fuson;
        EframeH.String = Fusend;
        SframeH.Enable = 'off';
        EframeH.Enable = 'off';
    end

    if strcmp(frameSE,'CS 1st Half')
        SframeH.String = Fcson;
        EframeH.String = Fcsmid;
        SframeH.Enable = 'off';
        EframeH.Enable = 'off';
    end
    if strcmp(frameSE,'US 1st Half')
        SframeH.String = Fuson;
        EframeH.String = Fusmid;
        SframeH.Enable = 'off';
        EframeH.Enable = 'off';
    end
    
    if strcmp(frameSE,'CS 2nd Half')
        SframeH.String = Fcsmid;
        EframeH.String = Fcsoff;
        SframeH.Enable = 'off';
        EframeH.Enable = 'off';
    end
    if strcmp(frameSE,'US 2nd Half')
        SframeH.String = Fusmid;
        EframeH.String = Fusend;
        SframeH.Enable = 'off';
        EframeH.Enable = 'off';
    end
    
    Sframe = str2num(SframeH.String);
    Eframe = str2num(EframeH.String);
    
    memolog(['Frame range: ' SframeH.String ' - ' EframeH.String])
    
end

frameBG.SelectedObject = framerange4;









%-----------------------------------
%    SAVE AND EXPORT PANEL
%-----------------------------------
GexportpanelH = uipanel('Parent', btabs,'Title','I/O','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.50 0.02 0.45 0.20]); % 'Visible', 'Off',

GexportvarsH = uicontrol('Parent', GexportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.65 0.95 0.28], 'FontSize', 13,...
    'String', 'Export ROIs to Workspace ',...
    'Callback', @exportROIs);


GsavedatasetH = uicontrol('Parent', GexportpanelH, 'Units', 'normalized', ...
    'Position', [0.03 0.34 0.95 0.28], 'FontSize', 13, ...
    'String', 'Save ROIs to .mat',...
    'Callback', @saveROIs);

% GloadmatdataH = uicontrol('Parent', GexportpanelH, 'Units', 'normalized', ...
%     'Position', [0.03 0.03 0.95 0.28], 'FontSize', 13, ...
%     'String', 'Load ROIs from .mat',...
%     'Callback', {@loadROIs,ROIDATA});



%----------------------------------------------------
%%    IMAGE VIEW PANEL
%----------------------------------------------------

IMGpanelH = uipanel('Parent', itabs,'Title','GRIN Image','FontSize',10,...
    'BackgroundColor',[.95 .95 .95],...
    'Position', [0.01 0.01 0.98 0.97]); % 'Visible', 'Off',

haxIMG = axes('Parent', IMGpanelH, 'NextPlot', 'replacechildren',...
    'Position', [0.01 0.01 0.90 0.80], 'PlotBoxAspectRatio', [1 1 1], ...
    'XColor','none','YColor','none','YDir','reverse');

    slideValIM = size(IMG,1);
    haxIMG.XLim = [.5 slideValIM+.5];
    haxIMG.YLim = [.5 slideValIM+.5];

% if all(IMG(1) == IMG(1:XLSdata.blockSize))
% 
%     IMG = IMG(1:XLSdata.blockSize:end,1:XLSdata.blockSize:end,:,:);
%     IMGt = squeeze(reshape(IMG,numel(IMG(:,:,1)),[],size(IMG,3),size(IMG,4)));
%     hIMG = imagesc(IMG(:,:,1,1) , 'Parent',haxIMG);
%     slideValIM = size(IMG,1);
%     XLSdata.blockSize = 1;
%     
% else

    hIMG = imagesc(IMGSraw(:,:,1,1) , 'Parent',haxIMG);
    
% end



updateROIH = uicontrol('Parent', IMGpanelH, 'Units', 'normalized', ...
    'Position', [0.05 0.92 0.25 0.07], 'FontSize', 13, 'String', 'Update ROI',...
    'Callback', @updateROI);


RObg = uibuttongroup('Parent', IMGpanelH,'Visible','off','Units', 'normalized',...
                  'Position',[0.31 0.86 0.60 0.13],...
                  'SelectionChangedFcn',@bselection);
              


colorord = rand(6,3);
% Create three radio buttons in the button group.
if size(GRPS,1) > 0
CSUSr1 = uicontrol(RObg,'Style','radiobutton','Units', 'normalized',...
                  'String',GRPS(1),...
                  'Position',[.01 .52 .32 .45],...
                  'BackgroundColor',colorord(1,:),...
                  'HandleVisibility','off');
end
if size(GRPS,1) > 1
CSUSr2 = uicontrol(RObg,'Style','radiobutton','Units', 'normalized',...
                  'String',GRPS(2),...
                  'Position',[.34 .52 .32 .45],...
                  'BackgroundColor',colorord(2,:),...
                  'HandleVisibility','off');
end
if size(GRPS,1) > 2
CSUSr3 = uicontrol(RObg,'Style','radiobutton','Units', 'normalized',...
                  'String',GRPS(3),...
                  'Position',[.67 .52 .32 .45],...
                  'BackgroundColor',colorord(3,:),...
                  'HandleVisibility','off');
end
if size(GRPS,1) > 3
CSUSr4 = uicontrol(RObg,'Style','radiobutton','Units', 'normalized',...
                  'String',GRPS(4),...
                  'Position',[.01 .01 .32 .45],...
                  'BackgroundColor',colorord(4,:),...
                  'HandleVisibility','off');
end
if size(GRPS,1) > 4              
CSUSr5 = uicontrol(RObg,'Style','radiobutton','Units', 'normalized',...
                  'String',GRPS(5),...
                  'Position',[.34 .01 .32 .45],...
                  'BackgroundColor',colorord(5,:),...
                  'HandleVisibility','off');
end
if size(GRPS,1) > 5
CSUSr6 = uicontrol(RObg,'Style','radiobutton','Units', 'normalized',...
                  'String',GRPS(6),...
                  'Position',[.67 .01 .32 .45],...
                  'BackgroundColor',colorord(6,:),...
                  'HandleVisibility','off');
end              
 
% Make the uibuttongroup visible after creating child objects. 
RObg.Visible = 'on';



% haxIMG.XLim = [0 slideValIM];
% haxIMG.YLim = [0 slideValIM];

axis(haxIMG,[.5 slideValIM+.5 .5 slideValIM+.5]);
    
    

IMGsliderH = uicontrol('Parent', IMGpanelH, 'Units','normalized','Style','slider',...
	'Max',size(IMG,3),'Min',1,'Value',1,'SliderStep',[1 1]./size(IMG,3),...
	'Position', [0.01 0.801 0.94 0.05], 'Callback', @IMGslider);


AXsliderH = uicontrol('Parent', IMGpanelH, 'Units','normalized','Style','slider',...
	'Max',size(IMG,1)*2,'Min',size(IMG,1)/2,'Value',size(IMG,1),...
    'SliderStep',[1 1]./(size(IMG,1)),...
	'Position', [0.93 0.02 0.05 0.80], 'Callback', @AXslider);






%----------------------------------------------------
%%        CREATE DATA TABLE
%----------------------------------------------------


impx = size(IMG,1)/2;


hROI = imrect(haxIMG, [impx/2 impx/2 ...
                       impx impx]);

ROIpos = hROI.getPosition;


tv1 = round(ROIpos(1):ROIpos(3));
tv2 = round(ROIpos(2):ROIpos(3));




tv3 = squeeze(mean(mean(IMG(tv1,tv2,:,:))));





GRPS = rand(6,10);

for nn = 1:size(GRPS,1)

% ROIs(:,nn) = mean(tv3(:,GRINstruct.tf(:,nn)),2);
ROIs(:,nn) = mean(GRPS,2);
    
end



tablesize = size(ROIs);
colnames = GRPS;
colfmt = repmat({'numeric'},1,length(colnames));
coledit = zeros(1,length(colnames))>1;
colwdt = repmat({100},1,length(colnames));


htable = uitable('Parent', dtabs,'Units', 'normalized',...
                 'Position', [0.02 0.02 0.95 0.95],...
                 'Data',  ROIs,... 
                 'ColumnFormat', colfmt,...
                 'ColumnWidth', colwdt,...
                 'ColumnEditable', coledit,...
                 'ToolTipString',...
                 'Select cells to highlight them on the plot',...
                 'CellSelectionCallback', {@select_callback});
                 %'ColumnName', colnames,...






%----------------------------------------------------
%    PLOT DOT MARKERS AND MAKE THEM INVISIBLE
%----------------------------------------------------
% AXMAIN.YDir = 'normal';

Xn = AXMAIN.XLim(2);
ROIs = 1:Xn;
ROIs = repmat(ROIs,6,1);
ROIs = ROIs .* rand(size(ROIs));
ROIs = ROIs';

htable.Data = ROIs;


AXMAIN.ColorOrderIndex = 1; 
hmkrs = plot(AXMAIN, ROIs, 'LineStyle', 'none',...
                    'Marker', '.',...
                    'MarkerSize',45);
pause(.2)

                

csus = ["A","B","C","D","E","F","G","H"];

leg1 = legend(hmkrs,csus(1:numel(hmkrs)));
	set(leg1, 'Location','NorthWest', 'Color', [1 1 1],...
        'FontSize',12,'Box','off');
    set(leg1, 'Position', leg1.Position .* [1 .94 1 1.4])
                
set(hmkrs,'Visible','off','HandleVisibility', 'off')
pause(.2)

                
%----------------------------------------------------
%    PLOT CS ON / OFF POINTS
%----------------------------------------------------                

% CSonsetFrame = round(XLSdata.CSonsetDelay .* XLSdata.framesPerSec);
% CSoffsetFrame = round((XLSdata.CSonsetDelay+XLSdata.CS_length) .*...
%     XLSdata.framesPerSec);
% 
% 
% line([CSonsetFrame CSonsetFrame],AXMAIN.YLim,...
%     'Color',[.7 .7 .7],'HandleVisibility', 'off','Parent',AXMAIN)
% line([CSoffsetFrame CSoffsetFrame],AXMAIN.YLim,...
%     'Color',[.7 .7 .7],'HandleVisibility', 'off','Parent',AXMAIN)
                



%----------------------------------------------------
%    PLOT DATA ON MINI AXES
%---------------------------------------------------- 
phMINI = plot(haxMINI, ROIs);
% line([CSonsetFrame CSonsetFrame],haxMINI.YLim,...
%     'Color',[.8 .8 .8],'HandleVisibility', 'off','Parent',haxMINI)
% line([CSoffsetFrame CSoffsetFrame],haxMINI.YLim,...
%     'Color',[.8 .8 .8],'HandleVisibility', 'off','Parent',haxMINI)
racerline = line([0 0],haxMINI.YLim,'Color',[.2 .8 .2],'Parent',haxMINI);
axes(AXMAIN)
pause(.2)


%--------------------------------------------------------------------------
%        MAIN FUNCTION PROCESSES
%--------------------------------------------------------------------------
        
    %GRPS = unique(GRINstruct.csus);
    GRPS = csus(1:numel(hmkrs));

    
    AXMAIN.ColorOrderIndex = 1; 
    hp = plot(AXMAIN, ROIs , 'LineWidth',2);
    
    pause(1)
    
                            
%----------------------------------------------------
%        MAKE LINE PLOT OF DATA FROM COLUMN 1
%----------------------------------------------------

axdata = hp;
for cc = 1:size(axdata,1)

    colorz{cc} = axdata(cc).Color;
    % colors = {'b','m','r','y','c','k'}; % Use consistent color for lines
end

    set(hp,'Visible','off','HandleVisibility', 'off')
    


AXMAIN.NextPlot = 'Add';

AXMAIN.ColorOrderIndex = 1; 

if strcmp(htable.ColumnName,'numbered')
    for nn = 1:size(htable.Data,2)
        plot(AXMAIN, htable.Data(:,nn),...
            'DisplayName', num2str(nn), 'Color', colorz{nn}, 'LineWidth',2);
    end
else
    for nn = 1:size(htable.Data,2)
        plot(AXMAIN, htable.Data(:,nn),...
            'DisplayName', htable.ColumnName{nn}, 'Color', colorz{nn}, 'LineWidth',2);
    end
end























% tabgp.SelectedTab = tabgp.Children(1);

tabgp.SelectedTab = tabgp.Children(2);
pause(.2)

tabgp.SelectedTab = tabgp.Children(3);
pause(.2)

tabgp.SelectedTab = tabgp.Children(4);
pause(.2)

tabgp.SelectedTab = tabgp.Children(1);
pause(.2)

% memolog('Ready!')

















end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%        GUI HELPER FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%% SELECT A TIFF STACK AND GET INFO
function [] = getStack()


% Open image selection dialogue box
[fname,fpath] = uigetfile({'*.tif*';'*.TIF*'});
imgfullpath = [fpath,fname];

% Select image to import
PIX.path = imgfullpath;


% Use iminfo() to gather information about image file
Info = imfinfo(PIX.path);


% Turn the struct into a table
PIX.info = struct2table(Info);


% Count the number of images in the stack
PIX.count  = height(PIX.info);




% IMPORT TIFF STACK
%---------------------------------------------------------------
clear IMG

warning('off')
TifLink = Tiff(PIX.info.Filename{1}); 

for i=1:height(PIX.info)

    TifLink.setDirectory(i);
    IMG(:,:,i)=TifLink.read();

end
TifLink.close();

clearvars -except PIX IMG





% PREPROCESS TIFF STACK
%---------------------------------------------------------------

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



% PREVIEW 3D IMAGE STACK (NO RGB COLORMAP)
viewstack(IMG)


clearvars -except PIX IMG BND SZ

end












