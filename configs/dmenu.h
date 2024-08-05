#include "theme.h"

static int topbar = 1;   /* -b  option; if 0, dmenu appears at bottom     */
static int user_bh = 10; /* add an defined amount of pixels to the bar height */
static int centered = 0; /* -c option; centers dmenu on screen */
static int min_width = 500; /* minimum width when centered */

/* -fn option overrides fonts[0]; default X11 font or font set */
static const char *prompt = NULL; /* -p  option; prompt to the left of input field */
static const char *dynamic = NULL; /* -dy option; dynamic command to run on input change */
static const char *fonts[] = {"Source Code Pro:size=9"};
static const char *colors[][3] = {
    /*               fg         bg         border   */
    [SchemeNorm] = {white, gray3, blue},
    [SchemeSel] = {gray4, blue, gray3},
    [SchemeOut] = {gray2, red, gray3},

    [SchemeSelHighlight] = {blue, gray4},
    [SchemeNormHighlight] = {gray3, white},
};

/* -l and -g options; controls number of lines and columns in grid if > 0 */
static unsigned int lines = 0;
static unsigned int columns = 0;

/*
 * Characters not considered part of a word while deleting words
 * for example: " /?\"&[]"
 */
static const char worddelimiters[] = " ";

/* Size of the window border */
static unsigned int border_width = 2;
