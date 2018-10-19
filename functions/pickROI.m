function [AXE,STATUS] = pickROI(ROIZ,tf)
%%

if ~tf; disp('LESS THAN 16 ROIS LEFT TO PICK FROM'); return; end

global AXI
AXI = 0;


clear p ax fh1
close all

% Make axes coordinates
r = linspace(.02,.98,5);
c = fliplr(linspace(.02,.98,5)); c(1)=[];
w = .22; h = .22;


% fh1=figure('Position',[20 35 950 800],'MenuBar','none',...
%     'ButtonDownFcn',@(~,~)disp('pick an axis'),'HitTest','off');
fh1=figure('Position',[20 35 950 800],'MenuBar','none');





%%

% keyboard

%%

k=0;
for a=1:4
for b=1:4
k=k+1;

    ax{k} = axes('Position',[r(a) c(b) w h],'ButtonDownFcn',@pickaxis,...
    'PickableParts','all','Tag',['A' num2str(k)],'Color','none',...
    'XColor','none','YColor','none',...
    'HitTest','on');
    


    hG{k} = hggroup('ButtonDownFcn',@pickaxis,'Parent',ax{k},'Tag',['H' num2str(k)]);

    p{k} = plot( ROIZ(:,k),'LineWidth',3,'Parent',hG{k},'HitTest','off','Tag',['P' num2str(k)]); 

    title(sprintf('ROI-%s',num2str(k)))


end
end
%%



uiwait
STATUS = 1;
AXE = AXI;
end



function pickaxis(hObject, eventdata)
global AXI
% disableButtons; pause(.02);
disp('############## CLICK DETECTED ##################')


disp('Previous Set:'); disp(AXI)
fprintf('\nClicked Object: %s\n\n',hObject.Tag);


S = char(hObject.Tag);
T = str2num(S(2:end));
InAXI = AXI == T;



if S(1)=='P'
    OBJ = hObject.Parent.Parent;
elseif S(1)=='H'
    OBJ = hObject.Parent;
elseif  S(1)=='A'
    OBJ = hObject;
else
disp('error')
end    




if ~any(InAXI)
    AXI = [AXI; T];
    OBJ.Color = [.5 .5 .5];
    disp('Added!')
else
    AXI(InAXI) = [];
    OBJ.Color = 'none';
    disp('Removed!')
end







disp('Updated set:'); disp(AXI)
disp('######## ROI SET UPDATED (CLOSE WINDOW WHEN FINISHED) #############')
end


%{
function pickax(hObject, eventdata)
global AXI
% disableButtons; pause(.02);

disp('Picked')


T = str2num(hObject.Tag);

InAXI = AXI == T;



if ~any(InAXI)

    AXI = [AXI; T];

    %hObject.CData(1,1) = 1;
    hObject.Parent.Color = [.5 .5 .5];

else

    AXI(InAXI) = [];

    %hObject.CData(1,1) = 1;
    hObject.Parent.Colormap = parula;

end






%     axdat = gca;
%     disp(axdat)
%     axesdata = axdat.Children;
%     axis off;

end
%}





