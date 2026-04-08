# Oh-My-Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # disabled in favor of oh-my-posh
plugins=(git docker dotnet)
source $ZSH/oh-my-zsh.sh

# Oh-My-Posh
export PATH="$HOME/.local/bin:$PATH"
eval "$(oh-my-posh init zsh --config ~/dotfiles/oh-my-posh/config.json)"

# Zoxide (smart cd — equivalent to 'z' in PowerShell)
eval "$(zoxide init zsh)"

# fzf — fuzzy history search with Ctrl+R (equivalent to PSReadLine ListView)
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh

# History (equivalent to PSReadLine history settings)
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

# Arrow key history search (equivalent to PSReadLine HistorySearchBackward/Forward)
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Tab completion menu (equivalent to PSReadLine MenuComplete)
zstyle ':completion:*' menu select
autoload -Uz compinit && compinit
