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

static int topbar = 1;   /* -b  option; if 0, dmenu appears at bottom     */
static int user_bh = 10; /* add an defined amount of pixels to the bar height */
static int centered = 0; /* -c option; centers dmenu on screen */
static int min_width = 500; /* minimum width when centered */

/* -fn option overrides fonts[0]; default X11 font or font set */
static const char *prompt =
    NULL; /* -p  option; prompt to the left of input field */
static const char *dynamic =
    NULL; /* -dy option; dynamic command to run on input change */
static const char *fonts[] = {"Monaco:size=9"};
static const char *colors[][3] = {
    // one dark
    /*               fg         bg         border   */
    [SchemeNorm] = {"#abb2bf", "#171b23", "#171b23"},
    [SchemeSel] = {"#61afef", "#282c34", "#61afef"},
    [SchemeOut] = {"#d19a66", "#282c34", "#be5046"},
    [3] = {"#282c34", "#d19a66", "#171b23"},
    [4] = {"#282c34", "#98c379", "#171b23"},
};

static const char *colors_[][3] = {
    /*               fg         bg         border   */
    [SchemeNorm] = {"#000000", "#eaffea",
                    "#9eeeee"}, // fg = white, bg = gray2, border = gray2
    [SchemeSel] = {"#eaffea", "#448844",
                   "#55aaaa"}, // fg = blue, bg = gray3, border = blue
    [SchemeOut] =
        {"#eaffea", "#999999",
         "#ff0000"}, // fg = orange (light green), bg = gray3, border = red
    [3] = {"#999999", "#eaffea",
           "#cccccc"}, // fg = gray3, bg = orange (light green), border = gray2
    [4] = {"#999999", "#448844",
           "#cccccc"} // fg = gray3, bg = green, border = gray2
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
