#!/usr/bin/env sh
test -d ~/dotfiles || exit 1
cd ~/dotfiles
which doas >/dev/null 2>&1 && { test -e /etc/doas.conf || echo 'permit nopass :wheel' | doas tee /etc/doas.conf; }
for cfg in `ls config`; do
	test -d ~/.config/$cfg || mkdir ~/.config/$cfg
	for file in `ls config/$cfg`; do
		test -h ~/.config/$cfg/$file \
			|| ln -s ~/dotfiles/config/$cfg/$file ~/.config/$cfg/$file
	done
done
