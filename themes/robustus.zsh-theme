#RVM settings
if [[ -s ~/.rvm/scripts/rvm ]] ; then 
  RPS1="%{$fg[yellow]%}rvm:%{$reset_color%}%{$fg[red]%}\$(~/.rvm/bin/rvm-prompt)%{$reset_color%} $EPS1"
else
  RPS1="@%B%3d%b"
fi

# ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[green]%}["
# ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
# ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$reset_color%}"
# ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_GIT_PROMPT_PREFIX="%B%{$fg[yellow]%}(%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%B%{$fg[yellow]%})%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}!"
ZSH_THEME_GIT_PROMPT_AHEAD="%B$fg[white]%}"
ZSH_THEME_GIT_PROMPT_BEHIND="%B$fg[white]%}"
ZSH_THEME_GIT_PROMPT_STAGED="%B%{$fg[green]%}●"
ZSH_THEME_GIT_PROMPT_UNSTAGED="%B%{$fg[blue]%}✚"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%B%{$fg[white]%}✚"
ZSH_THEME_GIT_PROMPT_UNMERGED="%B%{$fg[magenta]%}✖"
ZSH_THEME_GIT_PROMPT_INTERNAL_DELIMITER="|"
ZSH_THEME_GIT_PROMPT_CLEAN=""

#Customized git status, oh-my-zsh currently does not allow render dirty status before branch
git_custom_status() {
  local cb=$(current_branch)
  if [ -n "$cb" ]; then
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)$(git_prompt_own_status)$ZSH_THEME_GIT_PROMPT_SUFFIX%(1l.
.)"
  fi
}

# PROMPT='$(git_custom_status)%{$fg[cyan]%}[%~% ]%{$reset_color%}%B$%b '
# PS1='%B%{$fg[yellow]%}?>%b%{$fg[default]%}'
PROMPT='$(git_custom_status)%B%{$fg[yellow]%}?>%b%{$fg[default]%}'
