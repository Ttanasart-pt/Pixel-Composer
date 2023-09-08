function histogramInit() {
	attributes.preview_resolution = 64;
	array_push(attributeEditors, ["Preview resolution", function() { return attributes.preview_resolution; }, 
		new textBox(TEXTBOX_INPUT.number, function(val) { attributes.preview_resolution = val; })]);
	
	attributes.preview_sample = 32;
	array_push(attributeEditors, ["Preview sample", function() { return attributes.preview_sample; }, 
		new textBox(TEXTBOX_INPUT.number, function(val) { attributes.preview_sample = val; })]);
	
	for( var i = 0; i < 4; i++ ) {
		hist[i] = array_create(attributes.preview_resolution + 1);
		histShow[i] = true;
	}
	histMax = 0;
}

function histogramDraw(_x, _y, _w, _h) {
	var _levels = array_length(hist[0]) - 1;
	var lw = _w / _levels;
	var ox, oy = array_create(4);
			
	draw_set_alpha(0.5);
	BLEND_OVERRIDE
					
	for( var i = 0; i < _levels; i++ ) {
		var _lx  = _x + i * lw, _lh = [];
		
		for( var j = 0; j < 4; j++ ) {
			_lh[@ j] = _y - hist[j][i] / histMax * _h;
		}
		
		if(i) {
			for( var j = 0; j < 4; j++ ) {
				if(!histShow[j]) continue;
				
				draw_set_color(COLORS.histogram[j]);
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
	if(array_length(hist[0]) != attributes.preview_resolution + 1)
		histogramInit();
		
	if(!is_surface(surface)) return;
		
	histMax = 0;
	var sw = surface_get_width_safe(surface);
	var sh = surface_get_height_safe(surface);
	var stw = max(1, sw / attributes.preview_sample);
	var sth = max(1, sh / attributes.preview_sample);
		
	for( var j = 0; j < 4; j++ )
	for( var i = 0, n = array_length(hist[0]); i < n; i++ ) {
		hist[j][i] = 0;
	}
	
	var surface_buffer = buffer_create(sw * sh * 4, buffer_grow, 1);
	buffer_get_surface(surface_buffer, surface, 0);
		
	for( var i = 0; i < sw; i += stw )
	for( var j = 0; j < sh; j += sth ) {
		var col = buffer_get_color(surface_buffer, i, j, sw, sh);
		var colA = [];
		colA[0] = round(color_get_red(col)   / 256 * attributes.preview_resolution);
		colA[1] = round(color_get_green(col) / 256 * attributes.preview_resolution);
		colA[2] = round(color_get_blue(col)  / 256 * attributes.preview_resolution);
		colA[3] = round((colA[0] + colA[1] + colA[2]) / 3);
			
		for( var k = 0; k < 4; k++ ) {
			if(!colA[k]) continue
			hist[k][colA[k]]++;
			histMax = max(histMax, hist[k][colA[k]]);
		}
	}
}