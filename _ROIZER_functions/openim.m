function [ih,HAx,HIm] = openim(IMG)


I=IMG(:,:,1);
max(I(:))
min(I(:))

ih = imtool(IMG(:,:,1));                pause(.05)
ih.Position = [10 50 750 700];          pause(.05)

HAx = findobj(ih,'Type','Axes');        pause(.05)

HAx.Units = 'normalized';               pause(.05)
HAx.Position = [.05 .05 .90 .90];       pause(.1)
HAx.Colormap = parula;                  pause(.1)
HAx.Position = [.05 .05 .90 .90];       pause(.1)


HIm = findobj(ih,'Type','Image');


% ih.Children(3).Visible = 'off';
% ih.Children(3).Children(end).Units = 'normalized'; pause(.1)
% ih.Children(3).Children(end).Position = [.05 .05 .90 .90];  pause(.1)
% ih.Children(3).Children(end).Colormap = parula;  pause(.1)
% ih.Children(3).Children(end).Position = [.05 .05 .90 .90];  pause(.1)
% ih.Children(3).Visible = 'on'; pause(.5)
% ih.Children(3).Children(end).Position = [.05 .05 .90 .90];  pause(.1)








end