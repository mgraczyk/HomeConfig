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

# Goma setup
function setup_goma() {
  #export GOMA_DIR=~/tools/goma
  #export CHROME_SRC=${HOME}/dev/chromium/src

  #${GOMA_DIR}/goma_ctl.py ensure_start
  #unset CC CXX

  #cd ${CHROME_SRC}
  #GYP_GENERATORS=ninja ./build/gyp_chromium -D use_goma=0 -D gomadir=${GOMA_DIR}
  #export GYP_DEFINES="use_goma=0"
  :;
}

function setup_chrome() {
  setup_goma;
  export CHROME_DEVEL_SANDBOX=/usr/local/sbin/chrome-devel-sandbox
}
