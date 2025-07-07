# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

if [ -f /etc/zshrc ]; then
    source /etc/zshrc
fi

# History configuration
export HISTSIZE=50000
export SAVEHIST=100000
export HISTFILE=~/.zsh_history
setopt SHARE_HISTORY          # Share history between sessions
setopt EXTENDED_HISTORY       # Save timestamp
setopt APPEND_HISTORY         # Append to history file

autoload -Uz compinit
compinit


# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# some more ls aliases
alias ll='ls -al'
alias la='ls -A'
alias l='ls -C'
alias xclip="xclip -selection c"
alias amend="git commit --amend --no-edit"
alias gcm="git commit -m"

alias whereami="echo $(hostname)"
alias hop='cd "$(pwd -L)"'

export EDITOR=vim

# Use vim keybindings
bindkey -v

# Set prompt to match old bashrc
truncate_hostname() {
  local h=$(hostname)
  if [[ ${#h} -le 17 ]]; then
      echo $h
  else
      echo "${h:0:7}...${h: -7}"
  fi
}

precmd() {
  local EXIT="$?"                # This needs to be first
  if [ $EXIT != 0 ]; then
    PROMPT="%F{yellow}$(truncate_hostname)%f %F{2}%(5~|%-1~/…/%3~|%4~)%f%F{1}> %f"
  else
    PROMPT="%F{yellow}$(truncate_hostname)%f %F{2}%(5~|%-1~/…/%3~|%4~)%f%F{7}> %f"
  fi
}

# Reduce key timeout for faster mode switching
export KEYTIMEOUT=1

# Better vi mode search
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

export PATH=$PATH:~/scripts
export TMP=${TMP:-/tmp}
export TMPDIR=${TMPDIR:-/tmp}

# Disable ctrl-s
if [[ ! $OS == *Windows* ]]; then
  stty ixany
  stty ixoff -ixon
fi

# Fix readline
if [ $(command -v rlwrap) ] ; then
  alias node='NODE_NO_READLINE=1 rlwrap node'
fi

if [ -n "$DISPLAY" ]; then
  if [ $(command -v setxkbmap) ] ; then
    setxkbmap -option caps:escape
  fi
fi

# Load complete compat for zsh
if [[ -n ${ZSH_VERSION-} ]]; then
  # First calling compinit (only if not called yet!)
  # and then bashcompinit as mentioned by zsh man page.
  if ! command -v compinit > /dev/null; then
    autoload -U +X compinit && if [[ ${ZSH_DISABLE_COMPFIX-} = true ]]; then
      compinit -u
    else
      compinit
    fi
  fi
  autoload -U +X bashcompinit && bashcompinit
fi


# Directory navigation with marks
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
  if [[ "$(uname)" == "Darwin" ]]; then
    mark_print_cmd="-exec basename {} ;"
  else
    mark_print_cmd="-printf %f\n"
  fi
  local curw=${COMP_WORDS[COMP_CWORD]}
  local wordlist=$(find $MARKPATH -type l $mark_print_cmd)
  COMPREPLY=($(compgen -W ${wordlist} -- "$curw"))
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

function llm_small() {
  claude --model claude-3-5-haiku-20241022 -p "$1"
}
function llm() {
  claude --model claude-sonnet-4-20250514 -p "$1"
}
function llm_big() {
  claude --model claude-opus-4-20250514	-p "$1"
}

function push() {
  # Get current branch name
  local current_branch=$(git branch --show-current)

  # Check if branch starts with "mgraczyk/"
  if [[ ! "$current_branch" =~ ^mgraczyk/ ]]; then
    # Create a temporary branch first
    local temp_branch="mgraczyk/temp-$(date +%s)"
    git checkout -b "$temp_branch"

    # Check if there are staged changes
    if ! git diff --cached --quiet; then
      # Get the staged diff
      local diff=$(git diff --cached)

      # Generate commit message using llm
      local commit_message=$(echo "$diff" | llm "Based on the following git diff, write a concise and descriptive git commit message. The message should follow conventional commit standards. Only output the commit message, nothing else.")

      # Print the generated commit message
      echo "Generated commit message: $commit_message"

      # Create a commit with the generated message
      git commit --no-verify -m "$commit_message"
    fi

    # Check if there's any difference between current commit and staging
    if git diff staging --quiet; then
      echo "Error: No changes between current commit and staging branch"
      # Clean up - go back to staging and delete temp branch
      git checkout staging
      git branch -D "$temp_branch"
      return 1
    fi

    # Get the commit diff for branch name generation
    local commit_diff=$(git diff staging)

    # Generate branch name using llm_small based on the commit diff
    local branch_name=$(echo "$commit_diff" | llm_small "Generate a very short branch name (max 30 chars) based on this git diff. Use only lowercase letters, numbers, and dashes. No spaces or other characters. Output only the branch name, nothing else.")

    # Validate and clean branch name with regex
    if [[ ! "$branch_name" =~ ^[a-z0-9-]+$ ]]; then
      # Remove any invalid characters if llm_small didn't follow instructions perfectly
      branch_name=$(echo "$branch_name" | tr -cd 'a-z0-9-' | sed 's/^-*//' | sed 's/-*$//')
    fi

    # Ensure branch name is not empty
    if [[ -z "$branch_name" ]]; then
      branch_name="auto-branch-$(date +%s)"
    fi

    # Rename the branch
    git branch -m "mgraczyk/$branch_name"
    current_branch="mgraczyk/$branch_name"

    # Print the branch name
    echo "Created branch: $current_branch"
  fi

  # Push the current branch to remote
  echo "Pushing branch to remote..."
  git push -u origin "$current_branch"

  # Get the most recent commit message
  local commit_title=$(git log -1 --pretty=format:"%s")

  # Create PR using gh CLI with staging as base
  local pr_url=$(gh pr create --base staging --title "$commit_title" --body "" | tail -1)

  echo "Pull request created: $pr_url"

  # Enable auto-merge if available
  gh pr merge "$pr_url" --auto --squash --delete-branch

  # Open the PR in Chrome
  sh -i -c 'chrome '"$pr_url"
}

[[ -r ~/.zshrc_local ]] && . ~/.zshrc_local

source /Users/mgraczyk/code/anthropic/config/local/zsh/zshrc  # added by conda.sh
