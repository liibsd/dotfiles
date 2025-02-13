install:
	./install.sh
xbps:
	xbps-query -m | grep -Po '.*(?=-)' > .xbps
