function histogramInit() {
	his_colors = [ c_ui_red, c_ui_lime, c_ui_cyan, c_white ];
	for( var i = 0; i < 4; i++ ) {
		hist[i] = array_create(PREF_MAP[? "level_resolution"] + 1);
		histShow[i] = true;
	}
	histMax = 0;
}

function histogramDraw(_x, _y, _w, _h) {
	var _levels = array_length(hist[0]) - 1;
	var lw = _w / _levels;
	var ox, oy = array_create(4);
			
	draw_set_alpha(0.5);
	BLEND_ADD
					
	for( var i = 0; i < _levels; i++ ) {
		var _lx  = _x + i * lw, _lh = [];
		
		for( var j = 0; j < 4; j++ ) {
			_lh[@ j] = _y - hist[j][i] / histMax * _h;
		}
		
		if(i) {
			for( var j = 0; j < 4; j++ ) {
				if(!histShow[j]) continue;
				
				draw_set_color(his_colors[j]);
				draw_line(ox, oy[j], _lx, _lh[j]);
			}
		}
			
		for( var j = 0; j < 4; j++ ) {
			oy[@ j] = _lh[j];
		}
		
		ox = _lx;
	}
			
	draw_set_alpha(1);
	BLEND_NORMAL
}

function histogramUpdate(surface) {
	if(array_length(hist[0]) != PREF_MAP[? "level_resolution"] + 1)
		histogramInit();
		
	if(!is_surface(surface)) return;
		
	histMax = 0;
	var sw = surface_get_width(surface);
	var sh = surface_get_height(surface);
	var stw = max(1, sw / PREF_MAP[? "level_max_sampling"]);
	var sth = max(1, sh / PREF_MAP[? "level_max_sampling"]);
		
	for( var j = 0; j < 4; j++ )
	for( var i = 0; i < array_length(hist[0]); i++ ) {
		hist[j][i] = 0;
	}
		
	for( var i = 1; i <= sw; i += stw )
	for( var j = 1; j <= sh; j += sth ) {
		var col = surface_getpixel(surface, i, j);
		var colA = [];
		colA[0] = round(color_get_red(col)   / 256 * PREF_MAP[? "level_resolution"]);
		colA[1] = round(color_get_green(col) / 256 * PREF_MAP[? "level_resolution"]);
		colA[2] = round(color_get_blue(col)  / 256 * PREF_MAP[? "level_resolution"]);
		colA[3] = round((colA[0] + colA[1] + colA[2]) / 3);
			
		for( var k = 0; k < 4; k++ ) {
			if(!colA[k]) continue
			hist[k][colA[k]]++;
			histMax = max(histMax, hist[k][colA[k]]);
		}
	}
}