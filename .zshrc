# Determine if shell is interactive
IS_INTERACTIVE=false
case $- in
    *i*) IS_INTERACTIVE=true ;;
esac

# If not running interactively, don't do anything, unless claude code.
if [[ ! $CLAUDECODE ]] && [[ $IS_INTERACTIVE == false ]]; then
    return
fi

if [ -f /etc/zshrc ]; then
    source /etc/zshrc
fi

# History configuration
export HISTSIZE=50000
export SAVEHIST=100000
export HISTFILE=~/.zsh_history
#setopt SHARE_HISTORY          # Share history between sessions (this is annoying)
setopt EXTENDED_HISTORY       # Save timestamp
setopt APPEND_HISTORY         # Append to history file
export SHELL=/bin/zsh

autoload -Uz compinit
compinit

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# some more ls aliases
alias ll='ls -al'
alias la='ls -A'
alias l='ls -C'
alias xclip="xclip -selection c"
alias amend="git commit --amend --no-edit"
alias gcm="git commit -m"

alias whereami="echo $(hostname)"
alias hop='cd "$(pwd -L)"'
alias vim-fast='vim -u NONE'

function gb() {
  git checkout --track -b mgraczyk/$1
}

function gb-test() {
  echo git checkout --track -b mgraczyk/$1
}


export EDITOR=vim

# Use vim keybindings
bindkey -v

# Set prompt to match old bashrc
truncate_hostname() {
  local h=$(hostname)
  if [[ ${#h} -le 17 ]]; then
      echo $h
  else
      echo "${h:0:7}...${h: -7}"
  fi
}

precmd() {
  local EXIT="$?"                # This needs to be first
  if [ $EXIT != 0 ]; then
    PROMPT="%F{yellow}$(truncate_hostname)%f %F{2}%(5~|%-1~/…/%3~|%4~)%f%F{1}> %f"
  else
    PROMPT="%F{yellow}$(truncate_hostname)%f %F{2}%(5~|%-1~/…/%3~|%4~)%f%F{7}> %f"
  fi
}

# Reduce key timeout for faster mode switching
export KEYTIMEOUT=1

# Better vi mode search
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

export PATH=$PATH:~/scripts
export TMP=${TMP:-/tmp}
export TMPDIR=${TMPDIR:-/tmp}

# Disable ctrl-s
if [[ ! $OS == *Windows* ]] && [[ $IS_INTERACTIVE == true ]]; then
  stty ixany
  stty ixoff -ixon
fi

# Fix readline
if [ $(command -v rlwrap) ] ; then
  alias node='NODE_NO_READLINE=1 rlwrap node'
fi

if [ -n "$DISPLAY" ]; then
  if [ $(command -v setxkbmap) ] ; then
    setxkbmap -option caps:escape
  fi
fi


# Directory navigation with marks
export MARKPATH=$HOME/.marks
function jump { 
  jump_path=$(readlink "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1")
  if [ ! -z "$jump_path" ];
  then
    cd -P "$jump_path" 2>/dev/null || \
        printf "Mark target missing:\n   $1 -/-> $jump_path\n"
  fi
}
function mark { 
  mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}
function unmark { 
  if [ -z "$1" ]; then
    echo "Error: Specify which mark to remove with \"unmark <mark>\""
    return 1
  fi
  rm -i "$MARKPATH/$1"
}
function marks {
  ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/  -/g' && echo
}

_completemarks() {
  local marks
  marks=($(find $MARKPATH -type l -exec basename {} \; 2>/dev/null))
  
  if [[ ${#marks[@]} -eq 0 ]]; then
     _message "No marks found"
  else
     compadd -S ' ' -a marks
  fi
}

function flip() {
    python3 -c "import random; print('HEADS' if random.randint(0,1) else 'TAILS')"
}

function line_count_tree() {
    find . -type f  | parallel -n1 -L 1 "wc" | sort -rn
}

################################################################################
# TMUX
################################################################################

function rsc() {
  tmux new-session -d -s $1
  CLIENTID=$1$(date +%s)
  tmux new-session -d -t $1 -s $CLIENTID \; set-option destroy-unattached on \; attach-session -t $CLIENTID
}

_tmux_session_groups() {
   local groups
   groups=($(tmux list-sessions 2>/dev/null | sed -n 's/.*[(]group \([^)]*\)[)].*/\1/p' | sort -u))
   
   if [[ ${#groups[@]} -eq 0 ]]; then
      _message "No tmux session groups found"
   else
      compadd -S '' -a groups
   fi
}

################################################################################

function llm_small() {
  cllm -m haiku "$1"
}
function llm() {
  cllm -m sonnet "$1"
}
function llm_big() {
  cllm -m opus "$1"
}

function worktree-nobranch {
  tempdir=$(mktemp -d)
  workdir="$tempdir"
  git worktree add $workdir
  (cd $workdir && $SHELL)
  git worktree remove $workdir
  rm -r $tempdir
}

function worktree {
  if [[ "$1" == "list" ]]; then
    git worktree list
    return
  fi
  branchname=$1
  tempdir=$(mktemp -d)
  workdir="$tempdir"/$branchname
  git worktree add --checkout -b $branchname $workdir
  (cd $workdir && $SHELL)
  git worktree remove $workdir
  rm -r $tempdir
  git branch -d $branchname
}

function git-cleanup() {
  # https://stackoverflow.com/a/6127884
  git branch --merged | grep -Ev "(^\*|^\+|master|main|staging|dev)" | xargs --no-run-if-empty git branch -d
  git remote prune origin
}

[[ -r ~/.zshrc_local ]] && . ~/.zshrc_local

# Register completions at the end in case something overwrites us.
compdef _tmux_session_groups rsc
compdef _completemarks jump
compdef _completemarks unmark
compdef _completemarks marks
