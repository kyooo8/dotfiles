init:
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"  
	echo 'eval' $(/opt/homebrew/bin/brew shellenv) >> $(HOME)/.zprofile
	eval $(/opt/homebrew/bin/brew shellenv)
	brew bundle

link:
	ln -fnsv "$(HOME)/dotfiles/hyper/.hyper.js" "$(HOME)/.hyper.js"
	ln -fnsv "$(HOME)/dotfiles/starship.toml" "$(HOME)/.config/starship.toml"
	ln -fnsv "$(HOME)/dotfiles/zshrc" "$(HOME)/.zshrc"
	ln -fnsv "$(HOME)/dotfiles/zimrc" "$(HOME)/.zimrc"

unlink:
	rm -f "$(HOME)/.hyper.js"
	rm -f "$(HOME)/.config/starship.toml"
	rm -f "$(HOME)/.zshrc"
	rm -f "$(HOME)/.zimrc"

.PHONY: link unlink