xbps:
	xbps-query -m | grep -Po '.*(?=-)' > .xbps
