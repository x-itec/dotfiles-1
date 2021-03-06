#fpath=(~/lib/zsh ~/.zsh-completions $fpath)
fpath=(~/lib/zsh $fpath)

############ options
# CD
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushd_silent

# Completion
setopt auto_menu
unsetopt list_beep
setopt menu_complete
setopt always_last_prompt
setopt auto_name_dirs
unsetopt cdable_vars
setopt auto_param_keys

# Globing
setopt extended_glob
setopt list_types
setopt magic_equal_subst

# History
setopt extended_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt share_history

# Input/Output
setopt correct
setopt print_eight_bit
setopt sun_keyboard_hack
#setopt interactive_comments
unsetopt hup

# Prompting
setopt prompt_subst

# ZLE
unsetopt beep


############ env for zsh

export ZSHFG=`expr $RANDOM % 250` # initial

setprompt() {
  prompt_vcs='%1(v|%F{green}%1v%f|)'
  #export PROMPT="[%n@%m %3d]%(#.#.$) "
  export YUNO='✘╹◡╹✘ '
  #export YUNO='× / _ / ×'
  export ZSHFG=`expr \( $ZSHFG + 1 \) % 250`
  #export PROMPT="%F{$ZSHFG}${YUNO}%f< "
  #export PROMPT="[%n@%m %3d${prompt_vcs}]%(#.#.$) "
  export PROMPT="[%n@%m %2d] %F{$ZSHFG}${YUNO}%f< "
  RPROMPT=$prompt_vcs
}

setprompt
export HISTFILE=$HOME/.zsh_history
export SAVEHIST=1000
export HISTSIZE=8192
if [ -z $LANG ]; then
  export LANG=ja_JP.UTF-8
fi

#export WORDCHARS='*?_.[]~=&;!#$%^(){}<>'


############ autoload

autoload -U compinit ; compinit
zstyle ':completion:*:default' menu select=1
#zstyle ':completion:*' list-colors di=34 fi=0

autoload -U zmv

autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '(%r)-(%b)-(%S)'
zstyle ':vcs_info:*' actionformats '(%r)-(%b:%a)-(%S)'

############ bindkey

bindkey -e
bindkey ' ' magic-space
bindkey "^[h" backward-kill-word

#compctl -g '(|.)*(-/)' cd pushd
#compctl -K ftp_hosts_complete ftp ncftp

bindkey -s "^xi" '\C-a`\C-e`\C-aforeach i \(\C-e\)'
bindkey -s "^xe" '\C-a =( \C-e )\C-a'

bindkey -s maek make
bindkey -s amke make
bindkey -s grpe grep
bindkey -s 'sv ndi' 'svn di'
bindkey -s 'sv nst' 'svn st'


#bindkey -v
#bindkey '^r' history-incremental-search-backward


############ functions

chpwd () {
  ls -F
}

precmd () {
  psvar=()
  LANG=en_US.UTF-8 vcs_info
  [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
  setprompt
}

## Ctrl-Z
#run-fg-editor() {
#  zle push-input
#  BUFFER="fg %$EDITOR:t"
#  zle accept-line
#}
#zle -N run-fg-editor
#bindkey '^Z' run-fg-editor


# URL Handler
#if autoload +X -U _accept_line_with_url > /dev/null 2>&1; then
#  zle -N accept-line-with-url _accept_line_with_url
#  bindkey '^M' accept-line-with-url
#  bindkey '^J' accept-line-with-url
#  export WWW_BROWSER="w3m %s"
#  export DOWNLOADER="wget"
#  browse_of_download_method="auto"
#fi


# for screen
# http://www.nijino.com/ari/diary/?20020614

if [ "$TERM" = "screen" ]; then
  chpwd () { echo -n "k`dirs`\\" }
  preexec() {
    # see [zsh-workers:13180]
    # http://www.zsh.org/mla/workers/2000/msg03993.html
    emulate -L zsh
    local -a cmd; cmd=(${(z)2})
    case $cmd[1] in
      fg)
        if (( $#cmd == 1 )); then
          cmd=(builtin jobs -l %+)
        else
          cmd=(builtin jobs -l $cmd[2])
        fi
      ;;
      %*)
        cmd=(builtin jobs -l $cmd[1])
      ;;
      sudo)
        if (($#cmd == 2)); then
          echo -n "k(sudo)$cmd[2]:t\\"
          return
        else
          echo -n "k$cmd[1]:t\\"
          return
        fi
      ;;
#      cd)
#        if (( $#cmd == 2)); then
#          cmd[1]=$cmd[2]
#        fi
#      ;;
      *)
        echo -n "k$cmd[1]:t\\"
        return
      ;;
    esac

    local -A jt; jt=(${(kv)jobtexts})

    echo $cmd
    $cmd >>(read num rest
    cmd=(${(z)${(e):-\$jt$num}})
    echo -n "k$cmd[1]:t\\") 2>/dev/null
  }
  chpwd
fi



# dabbrev
HARDCOPYFILE=/tmp/${USERNAME}-screen-hardcopy
touch $HARDCOPYFILE

dabbrev-complete () {
  local reply lines=80
  screen -X eval "hardcopy -h $HARDCOPYFILE"
  reply=($(sed '/^$/d' $HARDCOPYFILE | sed '$ d' | tail -$lines))
  compadd - "${reply[@]%[*/=@|]}"
}

zle -C dabbrev-complete menu-complete dabbrev-complete
bindkey '^xn'  dabbrev-complete
bindkey '^x^_'  dabbrev-menu-complete

alias xulfx="TERM=xterm-color /Applications/Firefox.app/Contents/MacOS/firefox -P xuldev -jsconsole"
alias gvim="TERM=xterm-color /Applications/MacPorts/Vim/Vim.app/Contents/MacOS/Vim -g"

alias g='git'
alias gs='git status'
alias t='git status'
alias gup="git stash; git pull --rebase origin master; git stash apply"
alias a='git add'
alias d='git diff'
alias gg='git grep'

alias b='bundle'
alias be='bundle exec'

alias r="rails"
alias rs="rake spec"
alias rr="rake routes"
alias fs="foreman start"

alias s="screen -U"
alias sx="screen -U -x"

alias w-rails="watchr ~/rails.watchr"
ffrmig() {
  git config alias.ffr >/dev/null && git ffr $1 $2 && bundle install && rake db:create db:migrate
}

# vim: set sw=2 sts=2 ts=2:
