function Mask = getkernel(varargin)
%----------------------------------------------------
%        MASK KERNEL FUNCTION FOR FIND ROI
%----------------------------------------------------

    if nargin < 1
    
        GNpk  = 2.5;	% HIGHT OF PEAK
        GNnum = 11;     % SIZE OF MASK
        GNsd = 0.18;	% STDEV OF SLOPE
        GNres = 0.1;    % RESOLUTION
        doMASKfig = 0;

    elseif nargin == 1
        v1 = varargin{1};
        
        GNpk  = v1;     % HIGHT OF PEAK
        GNnum = 11;     % SIZE OF MASK
        GNsd = 0.18;	% STDEV OF SLOPE
        GNres = 0.1;    % RESOLUTION
        doMASKfig = 0;

    elseif nargin == 2
        [v1, v2] = deal(varargin{:});

        GNpk  = v1; 	% HIGHT OF PEAK
        GNnum = v2;     % SIZE OF MASK
        GNsd = 0.18;	% STDEV OF SLOPE
        GNres = 0.1;    % RESOLUTION
        doMASKfig = 0;

    elseif nargin == 3
        [v1, v2, v3] = deal(varargin{:});

        GNpk  = v1; 	% HIGHT OF PEAK
        GNnum = v2;     % SIZE OF MASK
        GNsd = v3;      % STDEV OF SLOPE
        GNres = 0.1;    % RESOLUTION
        doMASKfig = 0;

    elseif nargin == 4
        [v1, v2, v3, v4] = deal(varargin{:});

        GNpk  = v1; 	% HIGHT OF PEAK
        GNnum = v2;     % SIZE OF MASK
        GNsd = v3;      % STDEV OF SLOPE
        GNres = v4;     % RESOLUTION
        doMASKfig = 0;
        
    elseif nargin == 5
        [v1, v2, v3, v4, v5] = deal(varargin{:});

        GNpk  = v1; 	% HIGHT OF PEAK
        GNnum = v2;     % SIZE OF MASK
        GNsd = v3;      % STDEV OF SLOPE
        GNres = v4;     % RESOLUTION
        doMASKfig = v5;

    else
        warning('Too many inputs')
    end

%% -- MASK SETUP
GNx0 = 0;       % x-axis peak locations
GNy0 = 0;   	% y-axis peak locations
GNspr = ((GNnum-1)*GNres)/2;

a = .5/GNsd^2;
c = .5/GNsd^2;

[X, Y] = meshgrid((-GNspr):(GNres):(GNspr), (-GNspr):(GNres):(GNspr));
Z = GNpk*exp( - (a*(X-GNx0).^2 + c*(Y-GNy0).^2)) ;

Mask=Z;

spf1=sprintf('  SIZE OF MASK:   % s x % s', num2str(GNnum), num2str(GNnum));
spf2=sprintf('  STDEV OF SLOPE: % s', num2str(GNsd));
spf3=sprintf('  HIGHT OF PEAK:  % s', num2str(GNpk));
spf4=sprintf('  RESOLUTION:     % s', num2str(GNres));


disp('SMOOTHING KERNEL PARAMETERS:')
disp(spf1)
disp(spf2)
disp(spf3)
disp(spf4)



end

