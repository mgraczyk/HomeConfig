export PATH=${PATH}:~/tools/depot_tools

################################################################################
## Beamer
################################################################################

# Put matlab in path on OSX
if [ "$(uname)" == "Darwin" ]; then
    export PATH=${PATH}:/Applications/MATLAB_R2014a.app/bin
fi

export P4DIFF=vimdiff

if [ -f ~/.google_dev.sh ] ; then
   source ~/.google_dev.sh
fi
