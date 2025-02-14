/*
 * Attempt to consolidate unavoidable suck into one file, away from dwl.c.  This
 * file is not meant to be pretty.  We use a .h file with static inline
 * functions instead of a separate .c module, or function pointers like sway, so
 * that they will simply compile out if the chosen #defines leave them unused.
 */

/* Leave these functions first; they're used in the others */
static inline int
client_is_x11(Client *c)
{
	return 0;
}

static inline struct wlr_surface *
client_surface(Client *c)
{
	return c->surface.xdg->surface;
}

static inline int
toplevel_from_wlr_surface(struct wlr_surface *s, Client **pc, LayerSurface **pl)
{
	struct wlr_xdg_surface *xdg_surface, *tmp_xdg_surface;
	struct wlr_surface *root_surface;
	struct wlr_layer_surface_v1 *layer_surface;
	Client *c = NULL;
	LayerSurface *l = NULL;
	int type = -1;

	if (!s)
		return -1;
	root_surface = wlr_surface_get_root_surface(s);


	if ((layer_surface = wlr_layer_surface_v1_try_from_wlr_surface(root_surface))) {
		l = layer_surface->data;
		type = LayerShell;
		goto end;
	}

	xdg_surface = wlr_xdg_surface_try_from_wlr_surface(root_surface);
	while (xdg_surface) {
		tmp_xdg_surface = NULL;
		switch (xdg_surface->role) {
		case WLR_XDG_SURFACE_ROLE_POPUP:
			if (!xdg_surface->popup || !xdg_surface->popup->parent)
				return -1;

			tmp_xdg_surface = wlr_xdg_surface_try_from_wlr_surface(xdg_surface->popup->parent);

			if (!tmp_xdg_surface)
				return toplevel_from_wlr_surface(xdg_surface->popup->parent, pc, pl);

			xdg_surface = tmp_xdg_surface;
			break;
		case WLR_XDG_SURFACE_ROLE_TOPLEVEL:
			c = xdg_surface->data;
			type = c->type;
			goto end;
		case WLR_XDG_SURFACE_ROLE_NONE:
			return -1;
		}
	}

end:
	if (pl)
		*pl = l;
	if (pc)
		*pc = c;
	return type;
}

/* The others */
static inline void
client_activate_surface(struct wlr_surface *s, int activated)
{
	struct wlr_xdg_toplevel *toplevel;
	if ((toplevel = wlr_xdg_toplevel_try_from_wlr_surface(s)))
		wlr_xdg_toplevel_set_activated(toplevel, activated);
}

static inline uint32_t
client_set_bounds(Client *c, int32_t width, int32_t height)
{
	if (wl_resource_get_version(c->surface.xdg->toplevel->resource) >=
			XDG_TOPLEVEL_CONFIGURE_BOUNDS_SINCE_VERSION && width >= 0 && height >= 0
			&& (c->bounds.width != width || c->bounds.height != height)) {
		c->bounds.width = width;
		c->bounds.height = height;
		return wlr_xdg_toplevel_set_bounds(c->surface.xdg->toplevel, width, height);
	}
	return 0;
}

static inline const char *
client_get_appid(Client *c)
{
	return c->surface.xdg->toplevel->app_id;
}

static inline void
client_get_clip(Client *c, struct wlr_box *clip)
{
	struct wlr_box xdg_geom = {0};
	*clip = (struct wlr_box){
		.x = 0,
		.y = 0,
		.width = c->geom.width - c->bw,
		.height = c->geom.height - c->bw,
	};


	wlr_xdg_surface_get_geometry(c->surface.xdg, &xdg_geom);
	clip->x = xdg_geom.x;
	clip->y = xdg_geom.y;
}

static inline void
client_get_geometry(Client *c, struct wlr_box *geom)
{
	wlr_xdg_surface_get_geometry(c->surface.xdg, geom);
}

static inline Client *
client_get_parent(Client *c)
{
	Client *p = NULL;
	if (c->surface.xdg->toplevel->parent)
		toplevel_from_wlr_surface(c->surface.xdg->toplevel->parent->base->surface, &p, NULL);
	return p;
}

static inline int
client_has_children(Client *c)
{
	/* surface.xdg->link is never empty because it always contains at least the
	 * surface itself. */
	return wl_list_length(&c->surface.xdg->link) > 1;
}

static inline const char *
client_get_title(Client *c)
{
	return c->surface.xdg->toplevel->title;
}

static inline int
client_is_float_type(Client *c)
{
	struct wlr_xdg_toplevel *toplevel;
	struct wlr_xdg_toplevel_state state;


	toplevel = c->surface.xdg->toplevel;
	state = toplevel->current;
	return toplevel->parent || (state.min_width != 0 && state.min_height != 0
		&& (state.min_width == state.max_width
			|| state.min_height == state.max_height));
}

static inline int
client_is_rendered_on_mon(Client *c, Monitor *m)
{
	/* This is needed for when you don't want to check formal assignment,
	 * but rather actual displaying of the pixels.
	 * Usually VISIBLEON suffices and is also faster. */
	struct wlr_surface_output *s;
	int unused_lx, unused_ly;
	if (!wlr_scene_node_coords(&c->scene->node, &unused_lx, &unused_ly))
		return 0;
	wl_list_for_each(s, &client_surface(c)->current_outputs, link)
		if (s->output == m->wlr_output)
			return 1;
	return 0;
}

static inline int
client_is_stopped(Client *c)
{
	int pid;
	siginfo_t in = {0};

	wl_client_get_credentials(c->surface.xdg->client->client, &pid, NULL, NULL);
	if (waitid(P_PID, pid, &in, WNOHANG|WCONTINUED|WSTOPPED|WNOWAIT) < 0) {
		/* This process is not our child process, while is very unluckely that
		 * it is stopped, in order to do not skip frames assume that it is. */
		if (errno == ECHILD)
			return 1;
	} else if (in.si_pid) {
		if (in.si_code == CLD_STOPPED || in.si_code == CLD_TRAPPED)
			return 1;
		if (in.si_code == CLD_CONTINUED)
			return 0;
	}

	return 0;
}

static inline int
client_is_unmanaged(Client *c)
{
	return 0;
}

static inline void
client_notify_enter(struct wlr_surface *s, struct wlr_keyboard *kb)
{
	if (kb)
		wlr_seat_keyboard_notify_enter(seat, s, kb->keycodes,
				kb->num_keycodes, &kb->modifiers);
	else
		wlr_seat_keyboard_notify_enter(seat, s, NULL, 0, NULL);
}

static inline void
client_restack_surface(Client *c)
{
	return;
}

static inline void
client_send_close(Client *c)
{
	wlr_xdg_toplevel_send_close(c->surface.xdg->toplevel);
}

static inline void
client_set_border_color(Client *c, const float color[static 4])
{
	int i;
	for (i = 0; i < 4; i++)
		wlr_scene_rect_set_color(c->border[i], color);
}

static inline void
client_set_fullscreen(Client *c, int fullscreen)
{
	wlr_xdg_toplevel_set_fullscreen(c->surface.xdg->toplevel, fullscreen);
}

static inline uint32_t
client_set_size(Client *c, uint32_t width, uint32_t height)
{
	if ((int32_t)width == c->surface.xdg->toplevel->current.width
			&& (int32_t)height == c->surface.xdg->toplevel->current.height)
		return 0;
	return wlr_xdg_toplevel_set_size(c->surface.xdg->toplevel, (int32_t)width, (int32_t)height);
}

static inline void
client_set_tiled(Client *c, uint32_t edges)
{
	if (wl_resource_get_version(c->surface.xdg->toplevel->resource)
			>= XDG_TOPLEVEL_STATE_TILED_RIGHT_SINCE_VERSION) {
		wlr_xdg_toplevel_set_tiled(c->surface.xdg->toplevel, edges);
	} else {
		wlr_xdg_toplevel_set_maximized(c->surface.xdg->toplevel, edges != WLR_EDGE_NONE);
	}
}

static inline void
client_set_suspended(Client *c, int suspended)
{

	wlr_xdg_toplevel_set_suspended(c->surface.xdg->toplevel, suspended);
}

static inline int
client_wants_focus(Client *c)
{
	return 0;
}

static inline int
client_wants_fullscreen(Client *c)
{
	return c->surface.xdg->toplevel->requested.fullscreen;
}
