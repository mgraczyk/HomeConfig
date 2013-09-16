alias whereami="echo $HOSTNAME"
export PS1="\[\e[0;32m\]\w\[\e[0;37m\]> \[\e[0m\]"
export EDITOR=vim

export TERM=xterm-256color

# Source hexagon development variables
if [ -f ~/dev/.hexdevvars.bash ] ; then
	source ~/dev/.hexdevvars.bash
fi

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
