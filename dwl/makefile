XWAYLAND =
XLIBS =
# Uncomment to build XWayland support
#XWAYLAND = -DXWAYLAND
#XLIBS = xcb xcb-icccm

DWLCPPFLAGS = -I. -DWLR_USE_UNSTABLE

PKGS      = wlroots-0.18 wayland-server xkbcommon libinput
DWLCFLAGS = `pkg-config --cflags $(PKGS)` $(DWLCPPFLAGS)
LDLIBS    = `pkg-config --libs $(PKGS)`

dwl: dwl.o util.o
	tcc dwl.o util.o $(DWLCFLAGS) $(LDFLAGS) $(LDLIBS) -o $@

.PHONY: protocols

protocols:
	wayland-scanner enum-header /usr/share/wayland-protocols/staging/cursor-shape/cursor-shape-v1.xml cursor-shape-v1-protocol.h
	wayland-scanner enum-header /usr/share/wayland-protocols/unstable/pointer-constraints/pointer-constraints-unstable-v1.xml pointer-constraints-unstable-v1-protocol.h
	wayland-scanner enum-header protocols/wlr-layer-shell-unstable-v1.xml wlr-layer-shell-unstable-v1-protocol.h
	wayland-scanner server-header protocols/wlr-output-power-management-unstable-v1.xml wlr-output-power-management-unstable-v1-protocol.h
	wayland-scanner server-header /usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml xdg-shell-protocol.h

.c.o:
	tcc $(CPPFLAGS) $(DWLCFLAGS) -o $@ -c $<
