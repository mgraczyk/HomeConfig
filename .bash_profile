if [ -f ~/.bashrc ]; then  
  . ~/.bashrc
fi


if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	  SESSION_TYPE=remote/ssh
	  (cd ~/dev && exec terminator -l SSH --geometry=1521x878+0+0 &)
	  unalias git
else
		case $(ps -o comm= -p $PPID) in sshd|*/sshd) SESSION_TYPE=remote/ssh;;
	esac
fi

