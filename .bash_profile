if [ -f ~/.bashrc ]; then  
  . ~/.bashrc
fi


if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	  SESSION_TYPE=remote/ssh
	  if [ X"" != X"$DISPLAY" ]; then
		  (cd ~/dev && exec terminator --geometry=1521x878+0+0 &)
		  unalias git
	  fi
else
		case $(ps -o comm= -p $PPID) in sshd|*/sshd) SESSION_TYPE=remote/ssh;;
	esac
fi

if [ "$HOSTNAME" = "MGDev" ]
then
	[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
fi
