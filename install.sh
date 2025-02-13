#!/usr/bin/env sh
test -d ~/dotfiles || exit 1
which doas >/dev/null 2>&1 && { test -e /etc/doas.conf || echo 'permit nopass :wheel' | doas tee /etc/doas.conf; }
test -d ~/.config/qutebrowser || mkdir ~/.config/qutebrowser
test -h ~/.config/qutebrowser/config.py || ln -s ~/dotfiles/config/qutebrowser/config.py ~/.config/qutebrowser/config.py
test -h ~/.config/foot || ln -s ~/dotfiles/config/foot ~/.config/foot
test -h ~/.config/kak || ln -s ~/dotfiles/config/kak ~/.config/kak
test -h ~/.config/git || ln -s ~/dotfiles/config/git ~/.config/git
