/// @description 

var pal = palette;
var col = min(array_length(pal), 8);
var row = ceil(array_length(pal) / col);

var ss  = ui(24);
var ww  = ui(16) + ss * col;
var hh  = ui(16) + ss * row;

var x0  = min(x, WIN_W - ww);
var y0  = min(y, WIN_H - hh);

var x1  = x0 + ww;
var y1  = y0 + hh;

draw_sprite_stretched(THEME.dialog, 0, x0 - ui(8), y0 - ui(8), ww + ui(8) * 2, hh + ui(8) * 2);

for( var i = 0, n = array_length(pal); i < n; i++ ) {
	var r = floor(i / col);
	var c = i % col;
	
	var _x = x0 + ui(8) + c * ss;
	var _y = y0 + ui(8) + r * ss;
	
	draw_sprite_stretched_ext(THEME.s_box_r2, 0, _x + 1, _y + 1, ss - 2, ss - 2, pal[i]);
	
	if(point_in_rectangle(mouse_mx, mouse_my, _x, _y, _x + ss - 1, _y + ss - 1)) {
		draw_sprite_stretched_add(THEME.s_box_r2, 1, _x + 1, _y + 1, ss - 2, ss - 2, c_white, 0.3);
		
		if(selecting != i && onApply) onApply(pal[i]);
		selecting = i;
	}
}

if(mouse_release(mb_left))
	instance_destroy();
