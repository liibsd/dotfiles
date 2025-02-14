FLAGS = -lwlroots-0.18 -I/usr/include/wlroots-0.18 -I/usr/include/pixman-1 -Iprotocols -DWLR_USE_UNSTABLE

install: dwl
	doas mv dwl /bin
dwl:
	tcc dwl.c $(FLAGS) -o dwl
