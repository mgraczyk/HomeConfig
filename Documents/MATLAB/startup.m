home = getenv('HOME');
matlab_lib_dir = fullfile(home, 'software/matlab');

if isdir(matlab_lib_dir)
  addpath(matlab_lib_dir);
end

set(0, 'DefaultFigureRenderer', 'OpenGL');

%devDir = fullfile(home, 'dev');
%if exist(devDir, 'dir')
    %cd(devDir)
%end
clear *
