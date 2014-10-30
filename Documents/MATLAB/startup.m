home = getenv('HOME');
matlabLibDir = fullfile(home, 'software/matlab');

addpath(matlabLibDir)
set(0, 'DefaultFigureRenderer', 'OpenGL');

%devDir = fullfile(home, 'dev');
%if exist(devDir, 'dir')
    %cd(devDir)
%end
clear *
