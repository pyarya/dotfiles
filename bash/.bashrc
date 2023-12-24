#!/usr/bin/env bash

# Source all bash configs files, except prompt and profile
# Adapted from https://github.com/mathiasbynens/dotfiles/blob/main/.bash_profile
#
# Source bash_functions twice to fix interdependency between bash_functions and
# bash_aliases
source ~/.bash_env
source ~/.bash_functions
source ~/.bash_aliases
source ~/.bash_functions

# shopt -s histappend

# Suppress prompt warning when switching users
if [[ -r ~/.git-prompt.bash ]]; then
    source ~/.git-prompt.bash
fi
