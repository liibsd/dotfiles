#!/usr/bin/env sh
test -d ~/dotfiles || exit 1
cd ~/dotfiles/password
case "$1" in
	d|decrypt) ls encrypted/*.age | fzf | xargs -r age -d ;;
	g|generate)
		test -z "$2" && exit 2
		cat /dev/urandom | tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' | head -c 30 > "encrypted/$2.txt"
		;;
	e|encrypt)
		test -z "$2" && exit 3
		test -e "encrypted/$2.txt" || exit 4
		age -e -a -p "encrypted/$2.txt" > "encrypted/$2.age"
		rm "encrypted/$2.txt"
		;;
esac
