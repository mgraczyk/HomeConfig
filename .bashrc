# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

if [ -f /etc/bashrc ]; then
    source /etc/bashrc
fi

if [ -f /usr/facebook/ops/rc/master.bashrc ]; then
    source /usr/facebook/ops/rc/master.bashrc
    saved_path=$PATH
fi

# COLORS!!!!!!1111one
export TERM=xterm-256color

# don't put duplicate lines or lines starting with space in the history.
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export HISTFILESIZE=10000
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
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
  # We have color support; assume it's compliant with Ecma-48
  # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
  # a case would tend to support setf rather than setaf.)
  color_prompt=yes
    else
  color_prompt=
    fi
fi

#if [ "$color_prompt" = yes ]; then
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#else
    #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi
#unset color_prompt force_color_prompt

## If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
    #PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    #;;
#*)
    #;;
#esac

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

# dircolors on OS X
if [ "$(uname)" == "Darwin" ]; then
    export CLICOLOR=1
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

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
export PS1="\[\e[0;32m\]\w\[\e[0;37m\]> \[\e[0m\]"

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:~/scripts
export TMP=${TMP:-/tmp}
export TMPDIR=${TMPDIR:-/tmp}

if [ -f ~/.android_dev.sh ] ; then
   source ~/.android_dev.sh
fi

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
#if [[ $(uname) == *"CYGWIN"* ]]; then
#fi
export GPG_TTY=$(tty)

# Various aliases
alias whereami="echo $HOSTNAME"
alias hop='cd "$(pwd -L)"'
if [ $(command -v rlwrap) ] ; then
  alias node='NODE_NO_READLINE=1 rlwrap node'
fi

if [ $(command -v setxkbmap) ] ; then
  setxkbmap -option caps:escape
fi


################################################################################
# PYTHON
################################################################################

export PYTHONSTARTUP=~/scripts/.pystartup.py

################################################################################

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



# SSH tab completion

# Add bash completion for ssh: it tries to complete the host to which you
# want to connect from the list of the ones contained in ~/.ssh/known_hosts
__ssh_known_hosts() {
    if [[ -f ~/.ssh/known_hosts ]]; then
        cut -d " " -f1 ~/.ssh/known_hosts | cut -d "," -f1
    fi
}
_ssh() {
    local cur known_hosts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    known_hosts="$(__ssh_known_hosts)"
    if [[ ! ${cur} == -* ]] ; then
        if [[ ${cur} == *@* ]] ; then
            COMPREPLY=( $(compgen -W "${known_hosts}" -P ${cur/@*/}@ -- ${cur/*@/}) )
        else
            COMPREPLY=( $(compgen -W "${known_hosts}" -- ${cur}) )
        fi
    fi
    return 0
}
complete -o bashdefault -o default -o nospace -F _ssh ssh 2>/dev/null \
    || complete -o default -o nospace -F _ssh ssh
complete -o bashdefault -o default -o nospace -F _ssh mosh 2>/dev/null \
    || complete -o default -o nospace -F _ssh mosh

function flip() {
    python -c "import random; print('HEADS' if random.randint(0,1) else 'TAILS')"
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

# Runs the specified command (provided by the first argument) in all tmux panes
# for every window regardless if applications are running in the terminal or not.
function execute_in_all_panes {
 
  # Notate which window/pane we were originally at
  ORIG_WINDOW_INDEX=`tmux display-message -p '#I'`
  ORIG_PANE_INDEX=`tmux display-message -p '#P'`
 
  # Assign the argument to something readable
  command=$1
 
  # Count how many windows we have
  windows=$((`tmux list-windows | wc -l` - 1))
 
  # Loop through the windows
  for (( window=0; window <= $windows; window++ )); do
    tmux select-window -t $window #select the window
 
    # Count how many panes there are in the window
    panes=$((`tmux list-panes| wc -l` - 1))
    # debugging
    #echo "window:$window pane:$pane";
    #sleep 1
 
    # Loop through the panes that are in the window
    for (( pane=0; pane <= $panes; pane++ )); do
      # Skip the window that the command was ran in, run it in that window last
      # since we don't want to suspend the script that we are currently running
      # and also we want to end back where we started..
      if [ $ORIG_WINDOW_INDEX -eq $window -a $ORIG_PANE_INDEX -eq $pane ]; then
          continue
      fi
      tmux select-pane -t $pane #select the pane
      # Send the escape key, in the case we are in a vim like program. This is
      # repeated because the send-key command is not waiting for vim to complete
      # its action... also sending a sleep 1 command seems to fuck up the loop.
      for i in {1..25}; do tmux send-keys C-[; done
      # temp suspend any gui thats running
      tmux send-keys C-z
      # if no gui was running, remove the escape sequence we just sent ^Z
      tmux send-keys C-H
      # run the command & switch back to the gui if there was any
      tmux send-keys "$command && fg 2>/dev/null" C-m
    done
  done
 
  tmux select-window -t $ORIG_WINDOW_INDEX #select the original window
  tmux select-pane -t $ORIG_PANE_INDEX #select the original pane
  # Send the escape key, in the case we are in a vim like program. This is
  # repeated because the send-key command is not waiting for vim to complete
  # its action... also sending a sleep 1 command seems to fuck up the loop.
  for i in {1..25}; do tmux send-keys C-[; done
  # temp suspend any gui thats running
  # run the command & switch back to the gui if there was any
  tmux send-keys C-c "$command && fg 2>/dev/null" C-m
  tmux send-keys "clear" C-m
 
}

################################################################################

alias j="vim ~/journal/daily/$(date +"%Y-%m-%d")_daily.txt"

[[ -r ~/.bashrc_local ]] && . ~/.bashrc_local

if [ -f /usr/facebook/ops/rc/master.bashrc ]; then
  # my bashrc overwrites the path, so save it
  PATH=$PATH:$saved_path
fi
