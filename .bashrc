#
# ~/.bashrc
#

# Display Pokemon (no color)
pokemon-colorscripts --no-title -r 1,3,6 | sed 's/\x1b\[[0-9;]*m//g'

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
