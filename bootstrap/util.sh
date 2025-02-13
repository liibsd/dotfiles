#!/usr/bin/env sh
test -d ~/dotfiles || exit 1
cd ~/dotfiles
case "$1" in
	x|xbps) xbps-query -m | grep -Po '.*(?=-)' > bootstrap/xbps.txt ;;
esac
