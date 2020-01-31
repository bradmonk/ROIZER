function [] = cmappy(cm)
c = cm(1:30,:);
c = c .* (c./1.2);

c(:,3) = c(:,3)./4;
c(:,2) = c(:,2)./4;
c(:,1) = c(:,1)./4;

cm(1:30,:) = c;
colormap(cm)
end
