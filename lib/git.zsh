# get the name of the branch we are on
function git_prompt_info() {
  if [[ "$(command git config --get oh-my-zsh.hide-status 2>/dev/null)" != "1" ]]; then
    ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
    echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}


# Checks if working tree is dirty
parse_git_dirty() {
  local STATUS=''
  local FLAGS
  FLAGS=('--porcelain')
  if [[ "$(command git config --get oh-my-zsh.hide-dirty)" != "1" ]]; then
    if [[ $POST_1_7_2_GIT -gt 0 ]]; then
      FLAGS+='--ignore-submodules=dirty'
    fi
    if [[ "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]]; then
      FLAGS+='--untracked-files=no'
    fi
    STATUS=$(command git status ${FLAGS} 2> /dev/null | tail -n1)
  fi
  if [[ -n $STATUS ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

# get the difference between the local and remote branches
git_remote_status() {
    remote=${$(command git rev-parse --verify ${hook_com[branch]}@{upstream} --symbolic-full-name 2>/dev/null)/refs\/remotes\/}
    if [[ -n ${remote} ]] ; then
        ahead=$(command git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
        behind=$(command git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)

        if [ $ahead -eq 0 ] && [ $behind -eq 0 ]
        then
          	git_remote_status="$ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE"
        elif [ $ahead -gt 0 ] && [ $behind -eq 0 ]
        then
            git_remote_status="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE"
            git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))%{$reset_color%}"
        elif [ $behind -gt 0 ] && [ $ahead -eq 0 ] 
        then
            git_remote_status="$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE"
            git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))%{$reset_color%}"
        elif [ $ahead -gt 0 ] && [ $behind -gt 0 ]
        then
            git_remote_status="$ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE"
            git_remote_status_detailed="$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE$((ahead))%{$reset_color%}$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE_COLOR$ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE$((behind))%{$reset_color%}"
        fi

        if [ $ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_DETAILED ]
        then
            git_remote_status="$ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_PREFIX$remote$git_remote_status_detailed$ZSH_THEME_GIT_PROMPT_REMOTE_STATUS_SUFFIX"
        fi

        echo $git_remote_status
    fi
}

# Gets the number of commits ahead from remote
function git_commits_ahead() {
  if $(echo "$(command git log @{upstream}..HEAD 2> /dev/null)" | grep '^commit' &> /dev/null); then
    COMMITS=$(command git log @{upstream}..HEAD | grep '^commit' | wc -l | tr -d ' ')
    echo "$ZSH_THEME_GIT_COMMITS_AHEAD_PREFIX$COMMITS$ZSH_THEME_GIT_COMMITS_AHEAD_SUFFIX"
  fi
}

# Outputs if current branch is ahead of remote
function git_prompt_ahead() {
  if [[ -n "$(command git rev-list origin/$(current_branch)..HEAD 2> /dev/null)" ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_AHEAD"
  fi
}

# Outputs if current branch is behind remote
function git_prompt_behind() {
  if [[ -n "$(command git rev-list HEAD..origin/$(current_branch) 2> /dev/null)" ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_BEHIND"
  fi
}

# Outputs if current branch exists on remote or not
function git_prompt_remote() {
  if [[ -n "$(command git show-ref origin/$(current_branch) 2> /dev/null)" ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_REMOTE_EXISTS"
  else
    echo "$ZSH_THEME_GIT_PROMPT_REMOTE_MISSING"
  fi
}

# Formats prompt string for current git commit short SHA
function git_prompt_short_sha() {
  SHA=$(command git rev-parse --short HEAD 2> /dev/null) && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}

# Formats prompt string for current git commit long SHA
function git_prompt_long_sha() {
  SHA=$(command git rev-parse HEAD 2> /dev/null) && echo "$ZSH_THEME_GIT_PROMPT_SHA_BEFORE$SHA$ZSH_THEME_GIT_PROMPT_SHA_AFTER"
}

# Get the status of the working tree
git_prompt_status() {
  INDEX=$(command git status --porcelain -b 2> /dev/null)
  STATUS=""
  if $(echo "$INDEX" | command grep -E '^\?\? ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNTRACKED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^A  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  elif $(echo "$INDEX" | grep '^M  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_ADDED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^AM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^MM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^RM ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  elif $(echo "$INDEX" | grep '^ T ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^R  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_RENAMED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^ D ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^D  ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  elif $(echo "$INDEX" | grep '^AD ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DELETED$STATUS"
  fi
  if $(command git rev-parse --verify refs/stash >/dev/null 2>&1); then
    STATUS="$ZSH_THEME_GIT_PROMPT_STASHED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^UU ' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_UNMERGED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## .*ahead' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_AHEAD$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## .*behind' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_BEHIND$STATUS"
  fi
  if $(echo "$INDEX" | grep '^## .*diverged' &> /dev/null); then
    STATUS="$ZSH_THEME_GIT_PROMPT_DIVERGED$STATUS"
  fi
  echo $STATUS
}

git_prompt_own_status() {
  INDEX=$(git status --porcelain 2> /dev/null)
  INDEX_FULL=$(git status --porcelain -b)
  STATUS=""
  COMMITS=""
  BEHIND=$(echo "$INDEX_FULL" | grep --color=never -oE "behind [[:digit:]]+" | grep -oE "[[:digit:]]+");
  AHEAD=$(echo "$INDEX_FULL" | grep --color=never -oE "ahead [[:digit:]]+" | grep -oE "[[:digit:]]+");
  local -i STAGED; local -i UNSTAGED; local -i UNTRACKED; local -i UNMERGED;
  STAGED=0; UNSTAGED=0; UNTRACKED=0; UNMERGED=0;

  if $(echo "$INDEX_FULL" | grep 'behind' &> /dev/null); then
    COMMITS="$COMMITS$ZSH_THEME_GIT_PROMPT_BEHIND↓$BEHIND"
  fi
  if $(echo "$INDEX_FULL" | grep 'ahead' &> /dev/null); then
    COMMITS="$COMMITS$ZSH_THEME_GIT_PROMPT_AHEAD↑$AHEAD"
  fi

  if $(echo "$INDEX" | grep '^?? ' &> /dev/null); then
    UNTRACKED=$UNTRACKED+$(echo "$INDEX" | grep '^?? ' | wc -l | grep --color=never -oE "[[:digit:]]+")
  fi
  if $(echo "$INDEX" | grep '^A ' &> /dev/null); then
    STAGED=$STAGED+$(echo "$INDEX" | grep '^A  ' | wc -l | grep --color=never -oE "[[:digit:]]+")
  elif $(echo "$INDEX" | grep '^M  ' &> /dev/null); then
    STAGED=$STAGED+$(echo "$INDEX" | grep '^M  ' | wc -l | grep --color=never -oE "[[:digit:]]+")
  elif $(echo "$INDEX" | grep '^MM ' &> /dev/null); then
    STAGED=$STAGED+$(echo "$INDEX" | grep '^MM ' | wc -l | grep --color=never -oE "[[:digit:]]+")
    UNSTAGED=$UNSTAGED+$(echo "$INDEX" | grep '^MM ' | wc -l | grep --color=never -oE "[[:digit:]]+")
  fi
  if $(echo "$INDEX" | grep '^ M ' &> /dev/null); then
    UNSTAGED=$UNSTAGED+$(echo "$INDEX" | grep '^ M ' | wc -l | grep --color=never -oE "[[:digit:]]+")
  elif $(echo "$INDEX" | grep '^AM ' &> /dev/null); then
    STAGED=$STAGED+$(echo "$INDEX" | grep '^AM ' | wc -l | grep --color=never -oE "[[:digit:]]+")
  # git 1.8.0 doesn't know " T"
  #elif $(echo "$INDEX" | grep '^ T ' &> /dev/null); then
  #  STATUS="$ZSH_THEME_GIT_PROMPT_MODIFIED$STATUS"
  fi
  if $(echo "$INDEX" | grep '^R  ' &> /dev/null); then
    STAGED=$STAGED+$(echo "$INDEX" | grep '^R  ' | wc -l | grep --color=never -oE "[[:digit:]]+")
  fi
  if $(echo "$INDEX" | grep '^ D ' &> /dev/null); then
    UNSTAGED=$UNSTAGED+$(echo "$INDEX" | grep '^ D ' | wc -l | grep --color=never -oE "[[:digit:]]+")
  elif $(echo "$INDEX" | grep '^AD ' &> /dev/null); then
    STAGED=$STAGED+$(echo "$INDEX" | grep '^AD ' | wc -l | grep --color=never -oE "[[:digit:]]+")
  fi
  if $(echo "$INDEX" | grep '^UU ' &> /dev/null); then
    UMERGED=$UNMERGED+$(echo "$INDEX" | grep '^UU ' | wc -l | grep --color=never -oE "[[:digit:]]+")
  fi
  if [[ ($UNMERGED -gt 0) ]]; then;
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNMERGED$UNMERGED"
  fi
  if [[ ($STAGED -gt 0) ]]; then;
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED$STAGED"
  fi
  if [[ ($UNSTAGED -gt 0) ]]; then;
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNSTAGED$UNSTAGED"
  fi
  if [[ ($UNTRACKED -gt 0) ]]; then;
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED$UNTRACKED"
  fi
  if [[ (-n  "$COMMITS" && -n "$STATUS") ]]; then
    COMMITS="$COMMITS$ZSH_THEME_GIT_PROMPT_INTERNAL_DELIMITER" 
  fi

  echo "$COMMITS$STATUS"
}



#compare the provided version of git to the version installed and on path
#prints 1 if input version <= installed version
#prints -1 otherwise
function git_compare_version() {
  local INPUT_GIT_VERSION=$1;
  local INSTALLED_GIT_VERSION
  INPUT_GIT_VERSION=(${(s/./)INPUT_GIT_VERSION});
  INSTALLED_GIT_VERSION=($(command git --version 2>/dev/null));
  INSTALLED_GIT_VERSION=(${(s/./)INSTALLED_GIT_VERSION[3]});

  for i in {1..3}; do
    if [[ $INSTALLED_GIT_VERSION[$i] -gt $INPUT_GIT_VERSION[$i] ]]; then
      echo 1
      return 0
    fi
    if [[ $INSTALLED_GIT_VERSION[$i] -lt $INPUT_GIT_VERSION[$i] ]]; then
      echo -1
      return 0
    fi
  done
  echo 0
}

#this is unlikely to change so make it all statically assigned
POST_1_7_2_GIT=$(git_compare_version "1.7.2")
#clean up the namespace slightly by removing the checker function
unset -f git_compare_version
