/* See LICENSE file for copyright and license details. */

#include <X11/XF86keysym.h>

static const char black[] = "#282828";
static const char blue[] = "#83a598";  // focused window border
static const char gray2[] = "#282828"; // unfocused window border
static const char gray3[] = "#3c3836";
static const char gray4[] = "#282828";
static const char green[] = "#8ec07c";
static const char orange[] = "#fe8019";
static const char pink[] = "#d3869b";
static const char red[] = "#fb4934";
static const char white[] = "#ebdbb2";
static const char yellow[] = "#b8bb26";
static const char col_borderbar[] = "#1e2122";

/* appearance */
static const unsigned int borderpx = 2; /* border pixel of windows */
static const unsigned int snap = 10;    /* snap pixel */
static const int horizpadbar = 10;      /* horizontal padding for statusbar */
static const int vertpadbar = 10;       /* vertical padding for statusbar */
static const int showbar = 1;           /* 0 means no bar */
static const int topbar = 1;            /* 0 means bottom bar */
static const unsigned int systraypinning =
    0; /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor
          X */
static const unsigned int systrayonleft =
    0; /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 2; /* systray spacing */
static const int systraypinningfailfirst =
    1; /* 1: if pinning fails, display systray on the first monitor, False:
          display systray on the last monitor*/
static const int showsystray = 1; /* 0 means no systray */
static const char *fonts[] = {"Source Code Pro:size=9"};
static const char *colors_[][3] = { // light
    /*               fg         bg         border   */
    [SchemeNorm] = {gray3, white, gray2},
    [SchemeSel] = {gray3, blue, blue},
    [SchemeUrg] = {gray3, orange, red},
    [3] = {gray3, orange, gray2},
    [4] = {gray3, green, gray2}};
static const char *colors[][3] = { // dark
    /*               fg         bg         border   */
    [SchemeNorm] = {white, gray2, gray2},
    [SchemeSel] = {blue, gray3, blue},
    [SchemeUrg] = {orange, gray3, red},
    [3] = {gray3, orange, gray2},
    [4] = {gray3, green, gray2}};

static const char dwmrc[] = ".dwmrc";

/* tagging */
static const char *tags[] = {"1", "2", "3", "4", "5"};

static const Rule rules[] = {
    /* xprop(1):
     *	WM_CLASS(STRING) = instance, class
     *	WM_NAME(STRING) = title
     */
    /* class      instance    title       tags mask     isfloating   monitor */
    {"Firefox", NULL, NULL, 1 << 5, 0, -1},
};

/* layout(s) */
static const float mfact = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster = 1;    /* number of clients in master area */
static const int resizehints =
    1; /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen =
    1; /* 1 will force focus on the fullscreen window */

static const Layout layouts[] = {
    /* symbol     arrange function */
    {"[]=", tile}, /* first entry is default */
    {"{ }", NULL}, /* no layout function means floating behavior */
    {"[o]", monocle},
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY, TAG)                                                      \
  {MODKEY, KEY, view, {.ui = 1 << TAG}},                                       \
      {MODKEY | ControlMask, KEY, toggleview, {.ui = 1 << TAG}},               \
      {MODKEY | ShiftMask, KEY, tag, {.ui = 1 << TAG}}, {                      \
    MODKEY | ControlMask | ShiftMask, KEY, toggletag, { .ui = 1 << TAG }       \
  }

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHELL(cmd)                                                             \
  {                                                                            \
    .v = (const char *[]) { "/bin/sh", "-c", cmd, NULL }                       \
  }
#define COMMAND(...)                                                           \
  {                                                                            \
    .v = (const char *[]) { __VA_ARGS__, NULL }                                \
  }
#define BACKLIGHT(device, value)                                               \
  COMMAND("brightnessctl", "-q", "-d", device, "set", value)

#define monitor_backlight "acpi_video0"
#define keyboard_backlight "smc::kbd_backlight"

static const Key keys[] = {
    /* modifier                     key        function        argument */
    {MODKEY, XK_Return, spawn, COMMAND("st")},
    {MODKEY | ShiftMask, XK_w, spawn, COMMAND("surf")},
    {MODKEY, XK_w, spawn, COMMAND("firefox")},
    {MODKEY, XK_space, spawn, COMMAND("dmenu_run")},
    {MODKEY, XK_m, spawn, SHELL("man -k . | dmenu -l 25 | cut -d' ' -f1-2 | sed -E 's/(\\S+) \\((\\S+)\\)/\\2 \\1/' | xargs st -f 'SF Mono' -e man -s")},
    {0, XF86XK_MonBrightnessUp, spawn, BACKLIGHT(monitor_backlight, "+5%")},
    {0, XF86XK_MonBrightnessDown, spawn, BACKLIGHT(monitor_backlight, "5%-")},
    {0, XF86XK_KbdBrightnessUp, spawn, BACKLIGHT(keyboard_backlight, "+5%")},
    {0, XF86XK_KbdBrightnessDown, spawn, BACKLIGHT(keyboard_backlight, "5%-")},
    {MODKEY, XK_o, spawn, COMMAND("dfm")},
    {MODKEY | ShiftMask, XK_o, spawn, COMMAND("dfm", "-c")},
    {MODKEY, XK_b, togglebar, {0}},
    {MODKEY, XK_j, focusstack, {.i = +1}},
    {MODKEY, XK_k, focusstack, {.i = -1}},
    {MODKEY, XK_i, incnmaster, {.i = +1}},
    {MODKEY, XK_d, incnmaster, {.i = -1}},
    {MODKEY, XK_Left, setmfact, {.f = -0.05}},
    {MODKEY, XK_Right, setmfact, {.f = +0.05}},
    {MODKEY | ShiftMask, XK_Return, zoom, {0}},
    {MODKEY, XK_Tab, view, {0}},
    {MODKEY, XK_q, killclient, {0}},
    {MODKEY | ControlMask, XK_comma, cyclelayout, {.i = -1}},
    {MODKEY | ControlMask, XK_period, cyclelayout, {.i = +1}},
    {MODKEY | ControlMask, XK_space, setlayout, {0}},
    {MODKEY | ShiftMask, XK_space, togglefloating, {0}},
    {MODKEY, XK_0, view, {.ui = ~0}},
    {MODKEY | ShiftMask, XK_0, tag, {.ui = ~0}},
    {MODKEY, XK_comma, focusmon, {.i = -1}},
    {MODKEY, XK_period, focusmon, {.i = +1}},
    {MODKEY | ShiftMask, XK_comma, tagmon, {.i = -1}},
    {MODKEY | ShiftMask, XK_period, tagmon, {.i = +1}},
    TAGKEYS(XK_1, 0),
    TAGKEYS(XK_2, 1),
    TAGKEYS(XK_3, 2),
    TAGKEYS(XK_4, 3),
    TAGKEYS(XK_5, 4),
    {MODKEY | ShiftMask, XK_q, quit, {0}},
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle,
 * ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
    /* click                event mask      button          function argument */
    {ClkLtSymbol, 0, Button1, cyclelayout, {.i = +1}},
    {ClkWinTitle, 0, Button2, zoom, {0}},
    {ClkStatusText, 0, Button2, spawn, COMMAND("st")},
    {ClkClientWin, MODKEY, Button1, movemouse, {0}},
    {ClkClientWin, MODKEY, Button2, togglefloating, {0}},
    {ClkClientWin, MODKEY, Button3, resizemouse, {0}},
    {ClkTagBar, 0, Button1, view, {0}},
    {ClkTagBar, 0, Button3, toggleview, {0}},
    {ClkTagBar, MODKEY, Button1, tag, {0}},
    {ClkTagBar, MODKEY, Button3, toggletag, {0}},
};
