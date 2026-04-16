#!/usr/bin/env python3

import sys
import os.path

WORKSPACES = {
    "work": ['app_id="code-oss"', 'app_id="nvim-qt"', 'app_id="kicad"'],
    "browser": ['app_id="Firefox"'],
    "term": [],
    "misc": ['app_id="thunar"'],
    "daemon": [],
    "media": ['app_id="com.discordapp.Discord"', 'class="Spotify"'],
}

with open((os.path.dirname(sys.argv[0]) or '.') + '/workspaces.conf', 'w') as w:
    keys = list(WORKSPACES.keys())
    for i in range(9):
        ws = f'"{(i*2)+1}:{keys[i]}"' if i < len(keys) else str(i+1)
        wextra = f'"{(i*2)+2}:{keys[i][0]}extra"' if i < len(keys) else None

        print(f"bindsym $mod+{i+1} workspace {ws}", file=w)
        print(
            f"bindsym $mod+Shift+{i+1} move container to workspace {ws}", file=w)
        if wextra:
            print(f"bindsym $mod+Ctrl+{i+1} workspace {wextra}", file=w)
            print(f"bindsym $mod+Ctrl+Shift+{i+1} move container to workspace {wextra}", file=w)

        if i < len(keys):
            for crit in WORKSPACES[keys[i]]:
                print(
                    f"for_window [{crit}] move window to workspace {ws} ; workspace {ws}", file=w)


'''
bindsym $mod+1 workspace 1:work
bindsym $mod+3 workspace 3:browser
bindsym $mod+4 workspace 4:term
bindsym $mod+5 workspace 5:misc
bindsym $mod+6 workspace 6:daemon
bindsym $mod+7 workspace 7:media
bindsym $mod+8 workspace 8
bindsym $mod+9 workspace 9

# Move focused container to workspace
bindsym $mod+Shift+1 move container to workspace 1:editor bindsym $mod+Shift+3 move container to workspace 3:browser
bindsym $mod+Shift+4 move container to workspace 4:term
bindsym $mod+Shift+5 move container to workspace 5:misc
bindsym $mod+Shift+6 move container to workspace 6:daemon
bindsym $mod+Shift+7 move container to workspace 7:media
bindsym $mod+Shift+8 move container to workspace 8
bindsym $mod+Shift+9 move container to workspace 9

for_window [app_id="code-oss"] move window to workspace 1:editor ; workspace 1:editor
for_window [app_id="nvim-qt"] move window to workspace 1:editor ; workspace 1:editor
for_window [app_id="Firefox"] move window to workspace 2:browser ; workspace 2:browser
for_window [app_id="foot"] move window to workspace 3:term ; workspace 3:term
for_window [app_id="com.discordapp.Discord"] move window to workspace 6:media ; workspace 6:media
for_window [class="Spotify"] move window to workspace 6:media ; workspace 6:media '''
