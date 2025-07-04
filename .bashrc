# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi

# COLORS!!!!!!1111one
export TERM=xterm-256color

# don't put duplicate lines or lines starting with space in the history.
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTCONTROL=ignoreboth
export HISTSIZE=50000
export HISTFILESIZE=100000
export HISTTIMEFORMAT="[%F %T] "
HOSTNAME="$(hostname)"
HOSTNAME_SHORT="${HOSTNAME%%.*}"

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
if [ "$(uname)" != "Darwin" ]; then
    shopt -s globstar
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-*color|screen-*color) color_prompt=yes;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -al'
alias la='ls -A'
alias l='ls -C'

alias xclip="xclip -selection c"
alias amend="git commit --amend --no-edit"
alias gcm="git commit -m"

# dircolors on OS X
if [ "$(uname)" == "Darwin" ]; then
    export CLICOLOR=1
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export EDITOR=vim

# Use nvim if available
# TODO(mgraczyk): Enable once nvim is better.
#if $(type nvim &>/dev/null); then
#  alias vim='nvim'
#fi

# Use vim keybindings
set -o vi

# Only show 3 dirs in PS1
export PROMPT_DIRTRIM=3
PS1="\[\e[0;32m\]\w\[\e[0;31m\]> \[\e[0m\]"
PROMPT_COMMAND=__prompt_command    # Function to generate PS1 after CMDs

__prompt_command() {
    local EXIT="$?"                # This needs to be first
    if [ $EXIT != 0 ]; then
      PS1="\[\e[0;32m\]\w\[\e[0;31m\]> \[\e[0m\]"
    else
      PS1="\[\e[0;32m\]\w\[\e[0;37m\]> \[\e[0m\]"
    fi
}

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:~/scripts
export TMP=${TMP:-/tmp}
export TMPDIR=${TMPDIR:-/tmp}

# Disable ctrl-s because it's stupid
if [[ ! $OS == *Windows* ]]; then
  if [ -x /usr/bin/dircolors ]; then
    if [ -f ~/scripts/.dircolors/dircolors.ansi-dark ] ; then
      eval "$(dircolors ~/scripts/.dircolors/dircolors.ansi-dark)"
    fi
  fi
  stty ixany
  stty ixoff -ixon
fi


# Special cygwin settings
export GPG_TTY=$(tty)

# Various aliases
alias whereami="echo $HOSTNAME"
alias hop='cd "$(pwd -L)"'
if [ $(command -v rlwrap) ] ; then
  alias node='NODE_NO_READLINE=1 rlwrap node'
fi

if [ -n "$DISPLAY" ]; then
  if [ $(command -v setxkbmap) ] ; then
    setxkbmap -option caps:escape
  fi
fi


# Some cool directory navigation stuff from 
# http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
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
  local mark_print_cmd

  # OSX find lacks printf
  if [ "$(uname)" == "Darwin" ]; then
    mark_print_cmd="-exec basename {} ;"
  else
    mark_print_cmd="-printf %f\n"
  fi
  local curw=${COMP_WORDS[COMP_CWORD]}
  local wordlist=$(find $MARKPATH -type l $mark_print_cmd)
  COMPREPLY=($(compgen -W '${wordlist[@]}' -- "$curw"))
  return 0
}

complete -F _completemarks jump unmark


function flip() {
    python3 -c "import random; print('HEADS' if random.randint(0,1) else 'TAILS')"
}

function line_count_tree() {
    find . -type f  | parallel -n1 -L 1 "wc" | sort -rn
}

################################################################################
# TMUX
################################################################################

# For tmux: export 256color
[ -n "$TMUX" ] && export TERM=screen-256color

function rsc() {
  CLIENTID=$1$(date +%s)
  tmux new-session -d -t $1 -s $CLIENTID \; set-option destroy-unattached on \; attach-session -t $CLIENTID
}

function mksc () {
  tmux new-session -d -s $1
  rsc $1
}

function __tmux_sessions() {
    local cur sessions
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    sessions="$(cut -d ":" -f1 <(tmux list-sessions 2> /dev/null))"
    if [ -z "${sessions}" ]; then
      >&2 printf "\rNo sessions active."
      return 1
    else
      COMPREPLY=( $(compgen -W "${sessions}" -- ${cur}) )
      return 0
    fi
}
complete -o nospace -F __tmux_sessions rsc 2>/dev/null


################################################################################

alias j="vim ~/journal/daily/$(date +"%Y-%m-%d")_daily.txt"

function worktree {
  if [ "$1" == "list" ]; then
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

[[ -r ~/.bashrc_local ]] && . ~/.bashrc_local
