<kbd>f</kbd>↓<kbd>j</kbd>↓<kbd>f</kbd>↑<kbd>w</kbd>              	`fW` (f while another modtap is being held should count as a regular f key, the next W quick tap should work just like regular j↓w↓↑ quick W tap)
<kbd>f</kbd>↓<kbd>j</kbd>↕<kbd>f</kbd>↑                          	`J`, not `jfjfjjf`
<kbd>o</kbd>↓<kbd>f</kbd>↓<kbd>␠</kbd>↓<kbd>o</kbd>↑<kbd>f</kbd>↑	`of ` not swallowing anything (inputhook prints ␠ even without waiting for a space key up, that's fine as you get regular typing on key down as well)
<kbd>f</kbd>↓<kbd>j</kbd>↓<kbd>w</kbd>↕↑<kbd>f</kbd>↑            	`W` (with ⇧› enabled since <kbd>j</kbd> was the last activated inputhook so it has a priority over <kbd>f</kbd>'s ‹⇧
<kbd>f</kbd>🠿 <kbd>j</kbd>🠿 for ~.5sec and release was bugging with unreachable 2b), though seems to be resolved with moving dbg tooltips to fire after the keypresses
