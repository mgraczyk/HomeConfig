shopt -s nocasematch
if [[ $OS == *Windows* ]] 
   then
      export IS_WINDOWS="TRUE"
fi
shopt -u nocasematch

if [ -f ~/.bashrc ]; then  
  . ~/.bashrc
fi

if [ "$(uname)" == "Darwin" ]; then
    if [ -f `brew --prefix`/etc/bash_completion ]; then
        . `brew --prefix`/etc/bash_completion
    fi
fi

# Don't do any of the rest on Windows
# SSH Stuff 
function checkssh() {
   if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        SESSION_TYPE=remote/ssh
   else
         case $(ps -o comm= -p $PPID) in sshd|*/sshd) SESSION_TYPE=remote/ssh;;
      esac
   fi


   if [ "$SESSION_TYPE" = "remote/ssh" ]; then
     if [ "$SSH_CLIENT_HOSTNAME" = "MGRACZYK" ]; then
        startterminator
     fi
   fi


   if [ "$HOSTNAME" = "MGDev" ]
   then
      [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
   fi
}


function startterminator () {
  (cd ~/dev && exec terminator --geometry=1521x878+0+0 &)
}

if [[ ! $OS == *Windows* ]]
   then
      checkssh
fi
