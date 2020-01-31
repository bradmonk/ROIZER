function [AXE] = pickPCs(IM)

global AXI
AXI = 0;

clear p ax fh1
close all

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


    p{k} = imagesc(IM(:,:,k),'ButtonDownFcn',@pickax,...
   'PickableParts','all','Tag',num2str(k));  

    ax{k}.CLim=q;  %axis off;


    title(sprintf('PC-%s',num2str(k)))


    k=k+1;
end
end
%%



% for aa = 1:length(ax)
%     set(ax{aa},'ButtonDownFcn',@(~,~)disp('patch'),...
%         'PickableParts','all')
% end 
  

% Attach a context menu to each axes
% haxe = findall(fh1,'Type','axes');
% for aa = 1:length(ax)
%     set(haxe(aa),'uicontextmenu',hcmenu)
% end 




uiwait
AXE = AXI;
end




function pickax(hObject, eventdata)
global AXI
% disableButtons; pause(.02);

% keyboard

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






%     axdat = gca;
%     disp(axdat)
%     axesdata = axdat.Children;
%     axis off;

end



