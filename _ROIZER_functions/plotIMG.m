function [varargout] = plotIMG(IM_A,varargin)


% keyboard



close all

%% ---------------------------------------
if nargin == 1


clc; close all
fh1 = figure('Units','pixels','Position',[10 50 750 700],'Color','w');
ax1 = axes('Position',[.06 .06 .9 .9],'Color','none','YDir','reverse',...
'PlotBoxAspectRatio',[1 1 1],'XColor','none','YColor','none'); hold on
hold on


axes(ax1)

ph1 = imagesc(ax1, IM_A(:,:,1) );

axis tight; colormap bone; pause(.1)

imstats(IM_A)



end


% keyboard
%% ---------------------------------------
if nargin == 3 && string(varargin{2}) == "Cdata"


% keyboard

p = varargin{3};

p.CData=PIX;
pause(.1)

end


%% ---------------------------------------
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


%% ---------------------------------------
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




%% ---------------------------------------
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
%% ---------------------------------------



















% close all; fh1=figure('Position',[20 35 950 800],'MenuBar','none');
% montage(IMG(:,:,1:16));
% q = quantile(I(:),[.001 .999]);
% fh1.Children.CLim=q;
% title('Gaussian filtered image volume')




varargout = {fh1};
end