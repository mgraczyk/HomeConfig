export EDITOR=vim

# Disable ctrl-s because it's stupid
stty ixany
stty ixoff -ixon

# Use vim keybindings
set -o vi

# COLORS!!!!!!1111one
export TERM=xterm-256color
export PS1="\[\e[0;32m\]\w\[\e[0;37m\]> \[\e[0m\]"
eval `dircolors ./scripts/.dircolors/dircolors.ansi-dark`

# Source hexagon development variables
if [ -f ~/dev/.hexdevvars.bash ] ; then
	source ~/dev/.hexdevvars.bash
fi

# Special cygwin settings
if [[ $(uname) == *"CYGWIN"* ]]; then
	alias ls="ls --color"
fi

# Various aliases
alias whereami="echo $HOSTNAME"
alias ll="ls -l"

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
