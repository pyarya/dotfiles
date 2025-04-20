#!/usr/bin/env bash
# ===================================================================
# Core bash aliases
# ===================================================================
# Might be necessary for vim
shopt -s expand_aliases

# Safety aliases
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'

# Legibility
alias df='df -h'
alias du='du -h'
alias tdu='du -h -d1 | sort -h'
alias free='free -h'
alias mkdir='mkdir -p'
alias bat='bat --paging=never'
alias tt='/usr/bin/time -f "%MKB, %es"'
alias colo='colo.sh'
alias rsync='rsync -h --info=progress2'

# Other
alias mem='top -l 1 -s 0 | grep PhysMem'
alias please='sudo -E '
alias cc="clang -Wall -Wextra -Werror -O2 -std=c99 -pedantic"
alias lsblkf="lsblk -o name,label,fstype,mountpoint,fsused,size,state"
alias lsblkfa="lsblk -o name,label,fstype,mountpoints,fsused,size,state"
alias mr='make run'
alias ed="ed -p '> :'"
alias ra='rg --no-ignore -.'
alias ee='exit'
alias ffprobe='ffprobe -hide_banner'
alias ip='ip -color'
alias ssgrim='grim - | wl-copy'
alias switchkeys='sudo systemctl stop xremap.service'

# ===================================================================
# Keybindings
# ===================================================================
if [[ "${-}" =~ i ]]; then
  # Vim-ish movement by word
  bind '"\C-w":"\ef"'  # Move forward one word \x1BF
  bind '"\C-b": backward-word'
  bind '"\C-j": backward-char' # Back one character
  bind '"\C-l": complete' # Tab-completion to match vim

  stty werase ^u

  stty -ixon  # i-search down with ^s

  # Figure that out:
  #https://superuser.com/questions/1601543/ctrl-x-e-without-executing-command-immediately
fi


# ===================================================================
# Navigation aliases
# ===================================================================
alias cd..='cd ..'
alias safe='cd ~/safe'
alias shm='cd /dev/shm'
alias dots='cd ~/dotfiles'

# Avoid symlink paths
alias cd='cd -P'
alias pwd='pwd -P'
alias cdb='cd $OLDPWD' # Go back a directory. Works with symlinks


# ===================================================================
# Listing aliases
# ===================================================================
# List Long - List files in acending order of size
alias ls='listlong --ll-ls'

# Additional listing options with eza
if command -v eza &> /dev/null; then
  alias ll='eza --all --long --icons=always -s=size'
    # Tree List Long - Recursively print a tree view
  alias tll='eza --all --long --icons=always -s=size -T -l=2'
    # Git List Long - Recursively print a tree view following .gitignore
  alias gll='listlong --ll-git-tree'
    # Directories List Long - List the directory hierarchy
  alias dll='listlong --ll-dir-tree'
    # All List Long - Detailed information for files in current working dir
  alias all='listlong --ll-all'
    # List symlinks
  alias llinks='listlong --ll-links'
fi


# ===================================================================
# Git
# ===================================================================
if command -v git &> /dev/null; then
  alias gitst='git status -s'
  alias gitlloga='git log --graph --all --oneline --decorate --color=always | less -R'
  alias gitllogw='git log --graph --all --date=relative --color=always --pretty="format:%C(auto,yellow)%h%C(auto,magenta) %C(auto,blue)%>(14,trunc)%ad %C(auto,green)%<(13,trunc) %aN%C(auto,red)%gD% D %C(auto,reset)%s" | less -R'
  alias gitcontrib='
  git ls-files |
  while read f
      do git blame -w -M -C -C --line-porcelain "$f" | grep -I "^author "
  done | sort -f | uniq -ic | sort -n --reverse'
fi


# ===================================================================
# External programs
# ===================================================================
# nVim
if command -v nvim &> /dev/null; then
  alias vi='nvim' vih='nvim +Rooter'
  alias vit='nvim +startinsert +terminal '
elif command -v vim &> /dev/null; then
  alias vi='vim' vih='vim +Rooter'
fi

# Veracrypt
if command -v veracrypt &> /dev/null
  then alias vera='veracrypt -t'; fi

# Vifm
if command -v vifm &> /dev/null
  then alias fm='vifm'; fi

# Vimiv
if command -v vimiv &> /dev/null
  then alias vii='vii.sh'; fi

# Qemu
if command -v qemu-system-x86_64 &> /dev/null
  then alias qemu='qemu-system-x86_64'; fi

# Python
if command -v python3 &> /dev/null
  then alias py='python3' venv='source ./bin/activate'; fi

# vim: set ft=bash ff=unix:
