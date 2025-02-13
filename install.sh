#!/usr/bin/env sh
test "$USER" = main || exit 1
test -d ~/dotfiles || exit 2
cd ~/dotfiles

exists() {
	which "$@" >/dev/null 2>&1 || return 1
}

exists xbps-install && {
	sudo xbps-install -Syu `cat .xbps`
	test -e /etc/xbps.d/00-ignorepkg-main.conf \
		|| echo 'ignorepkg=openssh\nignorepkg=sudo\nignorepkg=nvi' | sudo tee /etc/xbps.d/00-ignorepkg-main.conf
}
exists doas && { test -e /etc/doas.conf || echo 'permit nopass :wheel' | sudo tee /etc/doas.conf; }
exists xbps-remove && {
	exists ssh && doas xbps-remove -y openssh
	test -h /usr/bin/sudo || { exists sudo && doas xbps-remove -y sudo; }
	exists nvi && doas xbps-remove -y nvi
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
