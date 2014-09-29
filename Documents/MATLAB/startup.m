home = getenv('HOME');
matlabLibDir = fullfile(home, 'software/matlab');

addpath(matlabLibDir)

%devDir = fullfile(home, 'dev');
%if exist(devDir, 'dir')
    %cd(devDir)
%end
clear *
