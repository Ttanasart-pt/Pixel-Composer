function Node_Palette_Extract(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Palette extract";
	
	
	w = 96;
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue(1, "Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 5);
	
	inputs[| 2] = nodeValue(2, "Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom(99999));
	
	outputs[| 0] = nodeValue(0, "Palette", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [ ])
		.setDisplay(VALUE_DISPLAY.palette);
	
	static getPreviewValue = function() { return inputs[| 0]; }
	
	input_display_list = [
		["Surface",	false],	0,
		["Palette",	false],	1, 2,
	]
	
	current_palette = [];
	current_color = 0;
	
	function extractPalette(_surfFull, _size, _seed) {
		var _surf = surface_create(min(32, surface_get_width(_surfFull)), min(32, surface_get_height(_surfFull)));
		_size = max(1, _size);
		
		var ww = surface_get_width(_surf);
		var hh = surface_get_height(_surf);
		
		surface_set_target(_surf);
		draw_clear_alpha(0, 0);
		BLEND_OVERRIDE
		gpu_set_texfilter(true);
		draw_surface_stretched(_surfFull, 0, 0, ww, hh);
		gpu_set_texfilter(false);
		BLEND_NORMAL
		surface_reset_target();
		
		var c_buffer = buffer_create(ww * hh * 4, buffer_fixed, 2);
		var colors = array_create(ww * hh);
		
		buffer_get_surface(c_buffer, _surf, 0);
		buffer_seek(c_buffer, buffer_seek_start, 0);
		
		var _min = [ 1, 1, 1 ];
		var _max = [ 0, 0, 0 ];
		
		for( var i = 0; i < ww * hh; i++ ) {
			var c = buffer_read(c_buffer, buffer_u32) & ~(0b11111111 << 24);
			colors[i] = [ color_get_hue(c) / 255, color_get_saturation(c) / 255, color_get_value(c) / 255, 0 ];
			for( var j = 0; j < 3; j++ ) {
				_min[j] = min(_min[j], colors[i][j]);
				_max[j] = max(_max[j], colors[i][j]);
			}
		}
			
		buffer_delete(c_buffer);
		
		var cnt = [];
		random_set_seed(_seed);
		for( var i = 0; i < _size; i++ )
			cnt[i] = [ random(1), random(1), random(1), 0 ];
			
		repeat(8) {
			var _cnt = [];
			for( var i = 0; i < _size; i++ ) {
				_cnt[i][0] = cnt[i][0];
				_cnt[i][1] = cnt[i][1];
				_cnt[i][2] = cnt[i][2];
			}
			
			for( var i = 0; i < ww * hh; i++ ) {
				var ind = 0;
				var dist = 999;
				var _cl = colors[i];
				
				for( var j = 0; j < _size; j++ ) {
					var _cn = cnt[j];
					var d = point_distance_3d(_cl[0], _cl[1], _cl[2], _cn[0], _cn[1], _cn[2]);
					if(d < dist) {
						dist = d;
						ind = j;
					}
				}
				
				colors[i][3] = ind;
			}
			
			for( var i = 0; i < _size; i++ )
				cnt[i] = [ 0, 0, 0, 0 ];
				
			for( var i = 0; i < ww * hh; i++ ) {
				var _cl = colors[i];
				cnt[_cl[3]][0] += _cl[0];
				cnt[_cl[3]][1] += _cl[1];
				cnt[_cl[3]][2] += _cl[2];
				cnt[_cl[3]][3]++;
			}
			
			for( var i = 0; i < _size; i++ ) {
				cnt[i][0] = cnt[i][3]? cnt[i][0] / cnt[i][3] : 0;
				cnt[i][1] = cnt[i][3]? cnt[i][1] / cnt[i][3] : 0;
				cnt[i][2] = cnt[i][3]? cnt[i][2] / cnt[i][3] : 0;
			}
			
			var del = 0;
			for( var i = 0; i < _size; i++ ) {
				del = max(del, point_distance_3d(cnt[i][0], cnt[i][1], cnt[i][2], _cnt[i][0], _cnt[i][1], _cnt[i][2]));
			}
			
			if(del < 0.001) break;
		}
		
		var palette = array_create(_size);
		
		for( var i = 0; i < _size; i++ ) {
			var closet = 0;
			var dist = 999;
			var _cl = cnt[i];
			
			for( var j = 0; j < ww * hh; j++ ) {
				var _cn = colors[j];
				var d = point_distance_3d(_cl[0], _cl[1], _cl[2], _cn[0], _cn[1], _cn[2]);
				
				if(d < dist) {
					dist = d;
					closet = j;
				}
			}
			
			palette[i] = make_color_hsv(colors[closet][0] * 255, colors[closet][1] * 255, colors[closet][2] * 255);
		}
		
		surface_free(_surf);
		
		return palette;
	}
	
	function process_data(_output, _data, index = 0) { 
		var _surf = _data[0];
		var _size = _data[1];
		var _seed = _data[2];
		
		if(!is_surface(_surf)) return [];
		
		return extractPalette(_surf, _size, _seed);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		drawPalette(outputs[| 0].getValue(), bbox.x0, bbox.y0, bbox.w, bbox.h);
	}
}