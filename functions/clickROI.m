function [ROX] = clickROI(IMG,varargin)


if nargin > 1
    ROI = varargin{1};
else
    ROI = [];
    clc; close all;
    fh1 = figure('Units','pixels','Position',[200 50 800 700],'Color','w');
    HAX = axes('Position',[.06 .06 .9 .9],'Color','none','YDir','reverse',...
    'PlotBoxAspectRatio',[1 1 1],'XColor','none','YColor','none'); hold on
    ph1 = imagesc(HAX,IMG(:,:,1));
    axis tight; colormap bone;
end

HAX = gca;


% fh1 = figure('Units','pixels','Position',[200 50 800 700],'Color','w');
% HAX = axes('Position',[.06 .06 .9 .9],'Color','none','YDir','reverse',...
% 'PlotBoxAspectRatio',[1 1 1],'XColor','none','YColor','none'); hold on
% ph1 = imagesc(HAX,IMG(:,:,1));
% axis tight; colormap bone;


stampSize = 14;

ROI_IDh.num = numel(ROI) + 1;
ROI_IDh.str = num2str(ROI_IDh.num);


hROI = impoint;
ROIpos = hROI.getPosition;
delete(hROI)
hROI = imellipse(HAX, [ROIpos-round(stampSize/2) stampSize stampSize]);
ROIpos = hROI.getPosition;
ROIarea = pi * (stampSize/2)^2;
setColor(hROI,[.7 1 .7]);

% uiwait
idisp(IMG)


%{
if ~strcmp(boxtypeh.SelectedObject.String,'freehand')

hROI = impoint;
ROIpos = hROI.getPosition;
Spos = ROIpos;
delete(hROI)

end




if strcmp(boxtypeh.SelectedObject.String,'rectangle')

    hROI = imrect(HAX);
    ROIpos = hROI.getPosition;
    ROIarea = ROIpos(3) * ROIpos(4);
    setColor(hROI,[.7 1 .7]);

elseif strcmp(boxtypeh.SelectedObject.String,'elipse')

    hROI = imellipse(HAX,[ROIpos-round(stampSize/2) stampSize stampSize]);
    ROIpos = hROI.getPosition;
    ROIarea = pi * (.5*ROIpos(3)) * (.5*ROIpos(4));
    setColor(hROI,[.7 1 .7]);

elseif strcmp(boxtypeh.SelectedObject.String,'stamp')

    % [x,y] = FLIMginput(2,'custom');
    hROI = impoint;
    ROIpos = hROI.getPosition;
    delete(hROI)
    hROI = imellipse(HAX, [ROIpos-round(stampSize/2) stampSize stampSize]);
    ROIpos = hROI.getPosition;
    ROIarea = pi * (stampSize/2)^2;
    setColor(hROI,[.7 1 .7]);

else strcmp(boxtypeh.SelectedObject.String,'freehand')
    hROI = imfreehand(HAX);
    ROIpos = hROI.getPosition;
    ROIarea = polyarea(ROIpos(:,1),ROIpos(:,2));
    setColor(hROI,[.7 1 .7]);
end
%}


HAX.Children(1).DisplayName = ['S' ROI_IDh.str];

nROI = numel(ROI)+1;
ROI(nROI).POS   = ROIpos;
ROI(nROI).PH    = hROI;
ROI(nROI).TYPE  = 'stamp';


%---------------------------
% GET ANOTHER ROI
%---------------------------
doagainROI = questdlg('Select next ROI?', 'Select next ROI?', 'Yes', 'No', 'No');
switch doagainROI
   case 'Yes'
        clickROI(IMG,ROI)
   case 'No'
        %return
end
set(gcf,'Pointer','arrow')





%------
    sROI = findobj(HAX,'Type','patch');
    
    % haxROIS.Children(1).Children(1).Color
    % haxROIS.Children(1).DisplayName
    % sROI(1).Parent.DisplayName
    
    for nn = 1:length(sROI)
        
        %ROInameID = sROI(nn).Parent.DisplayName;
        
        sROIpos = sROI(nn).Vertices;
        sROIarea = polyarea(sROIpos(:,1),sROIpos(:,2));
        sROImask = poly2mask(sROIpos(:,1),sROIpos(:,2), ...
                             size(IMG,1), size(IMG,2));


        ROI_INTENSITY = double(IMG) .* sROImask;
        
        ROI_INTENSITY_MEAN = mean(ROI_INTENSITY(ROI_INTENSITY > 0));


        ROX.area(nn)        = sROIarea;
        ROX.intensity(nn)   = ROI_INTENSITY_MEAN;
        ROX.center{nn}      = ROI.POS;
        ROX.trace{nn}       = sROIpos;
        ROX.mask{nn}        = sROImask;


%         ROILIST{nn} = {ROI_INTENSITY_MEAN, ...
%                        ROI,sROIpos,sROIarea,sROImask};
    
    
    end
    % ------
    













end



%{
axes(HAX)
ROI_IDh.String = int2str(str2num(ROI_IDh.String) + 1);



%---------------------------
% GET SPINE ROI
%---------------------------       
% [x,y] = FLIMginput(2,'custom');

if ~strcmp(boxtypeh.SelectedObject.String,'freehand')

hROI = impoint;
ROIpos = hROI.getPosition;
Spos = ROIpos;
delete(hROI)

end




if strcmp(boxtypeh.SelectedObject.String,'rectangle')

    hROI = imrect(HAX);
    ROIpos = hROI.getPosition;
    ROIarea = ROIpos(3) * ROIpos(4);
    setColor(hROI,[.7 1 .7]);

elseif strcmp(boxtypeh.SelectedObject.String,'elipse')

    hROI = imellipse(HAX,[ROIpos-round(stampSize/2) stampSize stampSize]);
    ROIpos = hROI.getPosition;
    ROIarea = pi * (.5*ROIpos(3)) * (.5*ROIpos(4));
    setColor(hROI,[.7 1 .7]);

elseif strcmp(boxtypeh.SelectedObject.String,'stamp')

    % [x,y] = FLIMginput(2,'custom');
    hROI = impoint;
    ROIpos = hROI.getPosition;
    delete(hROI)
    hROI = imellipse(HAX, [ROIpos-round(stampSize/2) stampSize stampSize]);
    ROIpos = hROI.getPosition;
    ROIarea = pi * (stampSize/2)^2;
    setColor(hROI,[.7 1 .7]);

else strcmp(boxtypeh.SelectedObject.String,'freehand')
    hROI = imfreehand(HAX);
    ROIpos = hROI.getPosition;
    ROIarea = polyarea(ROIpos(:,1),ROIpos(:,2));
    setColor(hROI,[.7 1 .7]);
end

HAX.Children(1).DisplayName = ['S' ROI_IDh.String];

nROI = numel(ROI)+1;
ROI(nROI).POS   = ROIpos;
ROI(nROI).PH    = hROI;
ROI(nROI).TYPE  = boxtypeh.SelectedObject.String;



%---------------------------
% GET DENDRITE ROI
%---------------------------
%Q_getd = questdlg('Select dendrite ROI?', 'Select dendrite ROI?', 'Yes', 'No', 'Yes');
Q_getdnum = 0;

if Q_getdnum == 1

    hROI = impoint;
    ROIpos = hROI.getPosition;
    Dpos = ROIpos;
    delete(hROI)


    axes(HAX)

    if strcmp(boxtypeh.SelectedObject.String,'rectangle')

        hROI = imrect(HAX);
        ROIpos = hROI.getPosition;
        ROIarea = ROIpos(3) * ROIpos(4);
        setColor(hROI,[.7 1 .7]);

    elseif strcmp(boxtypeh.SelectedObject.String,'elipse')

        hROI = imellipse(HAX,[ROIpos-round(stampSize/2) stampSize stampSize]);
        ROIpos = hROI.getPosition;
        ROIarea = pi * (.5*ROIpos(3)) * (.5*ROIpos(4));
        setColor(hROI,[.7 1 .7]);

    elseif strcmp(boxtypeh.SelectedObject.String,'stamp')

        % [x,y] = FLIMginput(2,'custom');
        hROI = impoint;
        ROIpos = hROI.getPosition;
        delete(hROI)
        hROI = imellipse(HAX, [ROIpos-round(stampSize/2) stampSize stampSize]);
        ROIpos = hROI.getPosition;
        ROIarea = pi * (stampSize/2)^2;
        setColor(hROI,[.7 1 .7]);

    else % strcmp(boxtypeh.SelectedObject.String,'freehand')
        hROI = imfreehand(HAX);
        ROIpos = hROI.getPosition;
        ROIarea = polyarea(ROIpos(:,1),ROIpos(:,2));
        setColor(hROI,[.7 1 .7]);
    end

    HAX.Children(1).DisplayName = ['D' ROI_IDh.String];

end


%---------------------------
% GET LINE-TRACE ROI
%---------------------------
if Q_getdnum == 1
    axes(HAX)

    linepos = [Spos(1:2); Dpos(1:2)];

    hROI = imline(HAX,linepos);
    setColor(hROI,[.7 1 .7]);

    dpos = [Spos(1:2); Dpos(1:2)];
    %dpos = hROI.getPosition;
    HAX.Children(1).DisplayName = ['L' ROI_IDh.String];

    spineextent = sqrt((dpos(1,1)-dpos(2,1))^2 + (dpos(1,2)-dpos(2,2))^2);

    [SPIx,SPIy,SPIf] = improfile(imgF, dpos(:,1), dpos(:,2), round(spineextent));
    [SPIx,SPIy,SPIg] = improfile(imgG, dpos(:,1), dpos(:,2), round(spineextent));
    [SPIx,SPIy,SPIr] = improfile(imgR, dpos(:,1), dpos(:,2), round(spineextent));

    % scatter(haxTABH, cx,cy, dotsz,'MarkerFaceColor', [1 0 0])
    axes(haxTABH); hold off;
    plot(haxTABH, SPIf); hold on;
    plot(haxTABH, SPIg); hold on;
    plot(haxTABH, SPIr)
    axes(HAX)
end


%{
% Q_getline = questdlg('Draw ROI Line?', 'Draw ROI Line?', 'Yes', 'No', 'Yes');
Q_getlinenum = 0;
if Q_getlinenum == 1
    axes(HAX)

    hROI = imline(HAX);
    dpos = hROI.getPosition;
    setColor(hROI,[0 1 0]);
    HAX.Children(1).DisplayName = ['L' ROI_IDh.String];

    spineextent = sqrt((dpos(1,1)-dpos(2,1))^2 + (dpos(1,2)-dpos(2,2))^2);

    [SPIx,SPIy,SPIf] = improfile(imgF, dpos(:,1), dpos(:,2), round(spineextent));
    [SPIx,SPIy,SPIg] = improfile(imgG, dpos(:,1), dpos(:,2), round(spineextent));
    [SPIx,SPIy,SPIr] = improfile(imgR, dpos(:,1), dpos(:,2), round(spineextent));

    % scatter(haxTABH, cx,cy, dotsz,'MarkerFaceColor', [1 0 0])
    axes(haxTABH); hold off;
    plot(haxTABH, SPIf); hold on;
    plot(haxTABH, SPIg); hold on;
    plot(haxTABH, SPIr)
    axes(HAX)

end
%}



%---------------------------
% GET ANOTHER ROI
%---------------------------
doagainROI = questdlg('Select next ROI?', 'Select next ROI?', 'Yes', 'No', 'No');
switch doagainROI
   case 'Yes'
        clickROI
   case 'No'

end

set(gcf,'Pointer','arrow')
%}