#!/usr/bin/env sh
## Checks
test -d ~/dotfiles || exit 1
cd ~/dotfiles

## Helper
exists() {
	which "$@" >/dev/null 2>&1 || return 1
}

## Install packages
exists xbps-install && sudo xbps-install -Syu `cat bootstrap/xbps.txt`

## Config
for config in `ls config -I bashrc`; do
	test -d ~/.config/$config || mkdir ~/.config/$config
	for file in `ls config/$config`; do
		test -h ~/.config/$config/$file \
			|| ln -s ~/dotfiles/config/$config/$file ~/.config/$config/$file
	done
done

## Bash
test -e ~/.bash_profile || echo "test -e ~/.bashrc && . ~/.bashrc" > ~/.bash_profile
test -h ~/.bashrc || ln -s ~/dotfiles/config/bashrc ~/.bashrc

## User services
test -d /etc/sv/ && { test -d /etc/sv/runsvdir-main || {
	sudo mkdir /etc/sv/runsvdir-main
	echo '#!/bin/sh\nexec chpst -u "main:`id -Gn main | tr " " ":"`" runsvdir /home/main/.local/service' \
		| sudo tee /etc/sv/runsvdir-main/run
	sudo chmod +x /etc/sv/runsvdir-main/run
	sudo ln -s /etc/sv/runsvdir-main /var/service
}; }
