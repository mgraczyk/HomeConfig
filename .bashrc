export EDITOR=vim


# Use vim keybindings
set -o vi

# COLORS!!!!!!1111one
export TERM=xterm-256color
export PS1="\[\e[0;32m\]\w\[\e[0;37m\]> \[\e[0m\]"
alias ls="ls --color"
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

# For tmux: export 256color
[ -n "$TMUX" ] && export TERM=screen-256color

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
