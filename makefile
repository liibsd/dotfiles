xbps:
	xbps-query -m | grep -Po '.*(?=-)' > bootstrap/xbps.txt
