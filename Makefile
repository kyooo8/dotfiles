link:
	ln -fnsv "$(HOME)/dotfiles/hyper/.hyper.js" "$(HOME)/.hyper.js"

unlink:
	rm -f "$(HOME)/.hyper.js"

.PHONY: link unlink