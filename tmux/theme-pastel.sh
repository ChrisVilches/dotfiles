# Pastel theme: soft, varied pastel colours with rounded pills. Each window gets
# its own colour (rose, orchid, butter, mint, sky, lavender), used for its text,
# its pill when it's the current window, and the active pane label. The program
# pill switches from soft grey to peach while the prefix key is pressed.

menu_key=p
shape=pill zoom=$zoom_arrow
window_colors=('#f4a6b8' '#e3a6e8' '#f2e3a0' '#a8e0c0' '#a6c8f0' '#c5b3f0')
bar_bg='#1e1f2b' bar_fg='#7f849c'
program_fg='#1e1f2b' program_bg='#bac2de' program_prefix_bg='#f7c59f'
window_fg='#{E:@window_color}'
current_fg='#1e1f2b' current_bg='#{E:@window_color}'
border_fg='#3a3d4f'
label_fg='#6c7086' label_active_fg='#{E:@window_color}'
message_bg='#2b2d3c' message_fg='#f7c59f'
command_bg='#2b2d3c' command_fg='#a8e0c0'
mode_bg='#33364a'
