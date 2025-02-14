xbps-install:
	sudo xbps-install -Sy `cat bootstrap/xbps.txt`
xbps-generate:
	xbps-query -m | grep -Po '.*(?=-)' > bootstrap/xbps.txt
