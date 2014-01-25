export EDITOR=vim


# Use vim keybindings
set -o vi

# COLORS!!!!!!1111one
export TERM=xterm-256color
export PS1="\[\e[0;32m\]\w\[\e[0;37m\]> \[\e[0m\]"
alias ls="ls --color"
alias grep="grep --color"

export PATH=${PATH}:~/scripts

# Disable ctrl-s because it's stupid
if [[ ! $OS == *Windows* ]]; then
   eval `dircolors ~/scripts/.dircolors/dircolors.ansi-dark`
   stty ixany
   stty ixoff -ixon
fi

# Source hexagon development variables
if [ -f ~/dev/.hexdevvars.bash ] ; then
	source ~/dev/.hexdevvars.bash
fi

# Special cygwin settings
#if [[ $(uname) == *"CYGWIN"* ]]; then
#fi

# Various aliases
alias whereami="echo $HOSTNAME"
alias ll="ls -l"
alias la="ls -a"
alias hop="cd $(pwd)"

# For tmux: export 256color
[ -n "$TMUX" ] && export TERM=screen-256color

# tmux shouldn't see TMPDIR
export TMPDIR=

# Some cool directory navigation stuff from 
# http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
export MARKPATH=$HOME/.marks
function jump { 
	cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}
function mark { 
	mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}
function unmark { 
	rm -i "$MARKPATH/$1"
}
function marks {
	ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
}

_completemarks() {
	  local curw=${COMP_WORDS[COMP_CWORD]}
	    local wordlist=$(find $MARKPATH -type l -printf "%f\n")
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


function rsc() {
	CLIENTID=$1.`date +%S`
	tmux new-session -d -t $1 -s $CLIENTID \; set-option destroy-unattached \; attach-session -t $CLIENTID
}

function mksc () {
	tmux new-session -d -s $1
	rsc $1
}


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
