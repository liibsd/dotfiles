XWAYLAND =
XLIBS =
# Uncomment to build XWayland support
#XWAYLAND = -DXWAYLAND
#XLIBS = xcb xcb-icccm

DWLCPPFLAGS = -Iprotocols -DWLR_USE_UNSTABLE

PKGS      = wlroots-0.18 wayland-server xkbcommon libinput
DWLCFLAGS = `pkg-config --cflags $(PKGS)` $(DWLCPPFLAGS)
LDLIBS    = `pkg-config --libs $(PKGS)`

dwl: dwl.o util.o
	tcc dwl.o util.o $(DWLCFLAGS) $(LDFLAGS) $(LDLIBS) -o $@

.c.o:
	tcc $(CPPFLAGS) $(DWLCFLAGS) -o $@ -c $<
