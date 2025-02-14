XWAYLAND =
XLIBS =
# Uncomment to build XWayland support
#XWAYLAND = -DXWAYLAND
#XLIBS = xcb xcb-icccm

FLAGS = -lwlroots-0.18 -I/usr/include/wlroots-0.18 -I/usr/include/pixman-1 -Iprotocols -DWLR_USE_UNSTABLE

dwl:
	tcc dwl.c $(FLAGS) -o dwl
