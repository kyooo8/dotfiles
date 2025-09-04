ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source /opt/homebrew/opt/zimfw/share/zimfw.zsh init
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# バツ丸ターミナルに切り替えて起動
hello-bat() {
  ln -fnsv ~/.hyper-batsumaru.js ~/.hyper.js
  ln -fnsv ~/.config/starship-batsumaru.toml ~/.config/starship.toml
  hyper
}

# 通常ターミナルに戻して起動
bey-bat() {
  ln -fnsv ~/dotfiles/hyper/.hyper.js ~/.hyper.js
  ln -fnsv ~/dotfiles/starship.toml ~/.config/starship.toml
  hyper
}

bat_art() {
  cat << 'EOF'
EOF
}

alias ls='eza --group-directories-first --icons'

eval "$(starship init zsh)"
# 起動時に表示（バツ丸モードのときだけ）
if [[ -L ~/.config/starship.toml && "$(readlink ~/.config/starship.toml)" == *"starship-batsumaru.toml" ]]; then
  bat_art
fi