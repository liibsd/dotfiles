#!/usr/bin/env sh
## Checks
test "$USER" = main || exit 1
test -d ~/dotfiles || exit 2
cd ~/dotfiles

## Helper
exists() {
	which "$@" >/dev/null 2>&1 || return 1
}

## Install packages
exists xbps-install && sudo xbps-install -Syu `cat bootstrap/xbps.txt`

## Doas config
exists doas && { test -e /etc/doas.conf || echo 'permit nopass :wheel' | sudo tee /etc/doas.conf; }

## Remove packages
exists xbps-remove && {
	test -e /etc/xbps.d/00-ignorepkg-main.conf \
		|| echo 'ignorepkg=openssh\nignorepkg=sudo\nignorepkg=nvi' | sudo tee /etc/xbps.d/00-ignorepkg-main.conf
	exists ssh && doas xbps-remove -y openssh
	test -h /usr/bin/sudo || { exists sudo && doas xbps-remove -y sudo; }
	exists nvi && doas xbps-remove -y nvi
}

## Link sudo to doas
test -h /usr/bin/sudo || doas ln -s /usr/bin/doas /usr/bin/sudo

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
	doas mkdir /etc/sv/runsvdir-main
	echo '#!/bin/sh\nexec chpst -u "main:`id -Gn main | tr " " ":"`" runsvdir /home/main/dotfiles/service' \
		| doas tee /etc/sv/runsvdir-main/run
	doas chmod +x /etc/sv/runsvdir-main/run
	doas ln -s /etc/sv/runsvdir-main /var/service
}; }
