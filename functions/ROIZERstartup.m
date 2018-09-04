function [P] = ROIZERstartup(P)


if ~any(regexp(P.home,'ROIZER') > 0)
disp(['Run this code from the ROIfinder directory; '...
'your current working directory is instead:'])
disp(P.home);
P.home='/Users/bradleymonk/Documents/MATLAB/GIT/ROIZER';
cd(P.home)
end
P.funs  = [P.home filesep 'datasets'];
P.data  = [P.home filesep 'functions'];
addpath(join(string(struct2cell(P)),':',1))


end