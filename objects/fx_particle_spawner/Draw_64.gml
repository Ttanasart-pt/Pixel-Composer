/// @description Insert description here
draw_set_color(COLORS._main_accent);
var r = max(1, life / 20 * size);

random_set_seed(seed);

for( var i = 0, n = array_length(parts); i < n; i++ ) {
	draw_circle(parts[i][0], parts[i][1], r, false);
	
	parts[i][0]  += speeds[i][0];
	parts[i][1]  += speeds[i][1];
	speeds[i][1] += 1;
}

if(--life <= 0) instance_destroy();