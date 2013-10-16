if [ -f ~/.bashrc ]; then  
  . ~/.bashrc
fi


if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	  SESSION_TYPE=remote/ssh
else
		case $(ps -o comm= -p $PPID) in sshd|*/sshd) SESSION_TYPE=remote/ssh;;
	esac
fi

if [ "$SESSION_TYPE" = "remote/ssh" ]; then
  if [ "$SSH_CLIENT_HOSTNAME" = "MGRACZYK" ]; then
	  (cd ~/dev && exec terminator --geometry=1521x878+0+0 &)
  fi

  unalias git
fi

if [ "$HOSTNAME" = "MGDev" ]
then
	[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
fi

