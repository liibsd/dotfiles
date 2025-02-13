#!/usr/bin/env sh
test -d ~/dotfiles || exit 1
cd ~/dotfiles
which xbps-install >/dev/null 2>&1 && {
	sudo xbps-install -Syu `cat .xbps`
	test -e /etc/xbps.d/00-ignorepkg-main.conf \
		|| echo 'ignorepkg=openssh\nignorepkg=sudo\nignorepkg=nvi' | sudo tee /etc/xbps.d/00-ignorepkg-main.conf
}
which doas >/dev/null 2>&1 && { test -e /etc/doas.conf || echo 'permit nopass :wheel' | sudo tee /etc/doas.conf; }
which xbps-remove >/dev/null 2>&1 && {
	which ssh >/dev/null 2>&1 && doas xbps-remove -y openssh
	test -h /usr/bin/sudo || { which sudo >/dev/null 2>&1 && doas xbps-remove -y sudo; }
	which nvi >/dev/null 2>&1 && doas xbps-remove -y nvi
}
test -h /usr/bin/sudo || doas ln -s /usr/bin/doas /usr/bin/sudo
for cfg in `ls config`; do
	test -d ~/.config/$cfg || mkdir ~/.config/$cfg
	for file in `ls config/$cfg`; do
		test -h ~/.config/$cfg/$file \
			|| ln -s ~/dotfiles/config/$cfg/$file ~/.config/$cfg/$file
	done
done
test -e ~/.bash_profile || echo "test -f ~/.bashrc && . ~/.bashrc" > ~/.bash_profile
test -h ~/.bashrc || ln -s ~/dotfiles/bashrc ~/.bashrc
