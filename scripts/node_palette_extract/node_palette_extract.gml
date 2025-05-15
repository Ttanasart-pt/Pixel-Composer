#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Palette_Extract", "Algorithm > Toggle",   "A", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[3].setValue((_n.inputs[3].getValue() + 1) % 3); });
		addHotkey("Node_Palette_Extract", "Color Space > Toggle", "C", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[4].setValue((_n.inputs[4].getValue() + 1) % 2); });
	});
#endregion

function Node_Palette_Extract(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Palette Extract";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Surface("Surface In", self));
	
	newInput(1, nodeValue_Int("Max colors", self, 5, "Amount of color in a palette."))
		.rejectArray();
	
	newInput(2, nodeValueSeed(self))
		.rejectArray();
	
	newInput(3, nodeValue_Enum_Scroll("Algorithm", self,  0, { data: [ "K-mean", "Frequency", "All Colors" ], update_hover: false }))
		.rejectArray();
	
	newInput(4, nodeValue_Enum_Scroll("Color Space", self,  1, { data: [ "RGB", "HSV" ], update_hover: false }))
		.rejectArray();
	
	newInput(5, nodeValue_Surface("Mask", self));
	
	newInput(6, nodeValue_Float("Radius", self, .25))
		.setDisplay(VALUE_DISPLAY.slider)
		.rejectArray();
		
	newOutput(0, nodeValue_Output("Palette", self, VALUE_TYPE.color, [ ]))
		.setDisplay(VALUE_DISPLAY.palette);
	
	static getPreviewValues = function() { return getInputData(0); }
	
	input_display_list = [
		["Surfaces", true],	0, 5, 
		["Palette",	false],	3, 4, 1, 2, 6, 
	]
	
	temp_surface    = [ noone ];
	
	current_palette = [];
	current_color   = 0;
	
	extraction_step    = 0;
	extraction_total   = 0;
	extraction_current = 0;
	
	attribute_surface_depth();
	
	static processData_prebatch = function() {
		setDimension(96, process_length[0] * 32);
	}
	
	function sortPalette(pal) {
		array_sort(pal, function(c0, c1) {
			var r0 = _color_get_red(c0),   r1 = _color_get_red(c1);
			var g0 = _color_get_green(c0), g1 = _color_get_green(c1);
			var b0 = _color_get_blue(c0),  b1 = _color_get_blue(c1);
			
			var l0 = sqrt( .241 * r0 + .691 * g0 + .068 * b0 );
			var l1 = sqrt( .241 * r1 + .691 * g1 + .068 * b1 );
			
			if(abs(l0 - l1) > 0.05) return l0 > l1;
			
			var h0 = _color_get_hue(c0);
			var h1 = _color_get_hue(c1);
			
			if(abs(h0 - h1) > 0.05) return h0 > h1;
			
			var s0 = _color_get_saturation(c0);
			var s1 = _color_get_saturation(c1);
			
			var v0 = _color_get_value(c0);
			var v1 = _color_get_value(c1);
			
			return s0 * v0 > s1 * v1;
		})
	}
	
	function extractKmean(_surfFull, _size, _seed) {
		var _space = getInputData(4);
		var _surf  = surface_create_valid(min(32, surface_get_width_safe(_surfFull)), min(32, surface_get_height_safe(_surfFull)), attrDepth());
		_size = max(1, _size);
		
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		
		surface_set_shader(_surf, noone);
			draw_surface_stretched_safe(_surfFull, 0, 0, ww, hh);
		surface_reset_shader();
		
		var c_buffer = buffer_create(ww * hh * 4, buffer_fixed, 4);
		var colors   = array_create(ww * hh), ind = 0;
		
		buffer_get_surface(c_buffer, _surf, 0);
		buffer_seek(c_buffer, buffer_seek_start, 0);
		
		var _min = [ 1, 1, 1 ];
		var _max = [ 0, 0, 0 ];
		var a, b, c, col;
		
		for( var i = 0; i < ww * hh; i++ ) {
			b = buffer_read(c_buffer, buffer_u32);
			c = b & ~(0b11111111 << 24);
			a = b & (0b11111111 << 24);
			if(a == 0) continue;
			
			switch(_space) {
				case 0 : col = [ _color_get_red(c), _color_get_green(c),      _color_get_blue(c),  0 ]; break;
				case 1 : col = [ _color_get_hue(c), _color_get_saturation(c), _color_get_value(c), 0 ]; break;
				case 2 : col = [ _color_get_hue(c), _color_get_saturation(c), _color_get_value(c), 0 ]; break;
			}
			
			colors[ind++] = col;
			
			_min[0] = min(_min[0], col[0]); _max[0] = max(_max[0], col[0]);
			_min[1] = min(_min[1], col[1]); _max[1] = max(_max[1], col[1]);
			_min[2] = min(_min[2], col[2]); _max[2] = max(_max[2], col[2]);
		}
		
		array_resize(colors, ind);
		buffer_delete(c_buffer);
		
		random_set_seed(_seed);
		var cnt = array_create_ext(_size, function() /*=>*/ {return [ random(1), random(1), random(1), 0 ]});
		
		repeat(8) {
			// var _cnt = array_create_ext(_size, (i) => [ cnt[i][0], cnt[i][1], cnt[i][2], 0 ]);
			
			for( var i = 0, n = array_length(colors); i < n; i++ ) {
				var ind  = 0;
				var dist = 999;
				var _cl  = colors[i];
				
				for( var j = 0; j < _size; j++ ) {
					var _cn = cnt[j];
					var d   = point_distance_3d(_cl[0], _cl[1], _cl[2], _cn[0], _cn[1], _cn[2]);
					
					if(d < dist) {
						dist = d;
						ind = j;
					}
				}
				
				colors[i][3] = ind;
			}
			
			for( var i = 0; i < _size; i++ )
				cnt[i] = [ 0, 0, 0, 0 ];
				
			for( var i = 0, n = array_length(colors); i < n; i++ ) {
				var _cl = colors[i];
				var _co = _cl[3];
				
				cnt[_co][0] += _cl[0];
				cnt[_co][1] += _cl[1];
				cnt[_co][2] += _cl[2];
				cnt[_co][3]++;
			}
			
			for( var i = 0; i < _size; i++ ) {
				var _cc = cnt[i];
				cnt[i][0] = _cc[3]? _cc[0] / _cc[3] : 0;
				cnt[i][1] = _cc[3]? _cc[1] / _cc[3] : 0;
				cnt[i][2] = _cc[3]? _cc[2] / _cc[3] : 0;
			}
			
			// var del = array_reduce(cnt, (prev, cur, i) => max(prev, point_distance_3d(cnt[i][0], cnt[i][1], cnt[i][2], cur[0], cur[1], cur[2])), 0);
			// if(del < 0.001) break;
		}
		
		var palette = array_create(_size), ind = 0;
		var clr; 
		
		for( var i = 0; i < _size; i++ ) {
			var closet = 0;
			var dist   = 999;
			var _cl    = cnt[i];
			
			for( var j = 0, n = array_length(colors); j < n; j++ ) {
				var _cn = colors[j];
				var d   = point_distance_3d(_cl[0], _cl[1], _cl[2], _cn[0], _cn[1], _cn[2]);
				
				if(d < dist) {
					dist   = d;
					closet = j;
				}
			}
			
			var _cc = colors[closet];
			
			switch(_space) {
				case 0 : clr = make_color_rgba(_cc[0] * 255, _cc[1] * 255, _cc[2] * 255, 255); break;
				case 1 : clr = make_color_hsva(_cc[0] * 255, _cc[1] * 255, _cc[2] * 255, 255); break;
				case 2 : clr = make_color_hsva(_cc[0] * 255, _cc[1] * 255, _cc[2] * 255, 255); break;
			}
			
			palette[ind++] = clr;
		}
		
		surface_free(_surf);
		
		var palLen = array_unique_ext(palette, 0, ind);
		array_resize(palette, palLen);
		sortPalette(palette);
		
		return palette;
	}
	
	function extractAll(_surfFull) {
		var ww = surface_get_width_safe(_surfFull);
		var hh = surface_get_height_safe(_surfFull);
		
		var c_buffer = buffer_create(ww * hh * 4, buffer_fixed, 4);
		
		buffer_get_surface(c_buffer, _surfFull, 0);
		buffer_seek(c_buffer, buffer_seek_start, 0);
		
		var amo     = ww * hh;
		var palette = array_create(amo), ind = 0;
		var bm      = 0b11111111 << 24;
		
		for( var i = 0; i < amo; i++ ) {
			var c = buffer_read(c_buffer, buffer_u32);
			if(c & bm == 0) continue;
			palette[ind++] = c;
		}
		
		buffer_delete(c_buffer);
		
		var palLen = array_unique_ext(palette, 0, ind);
		array_resize(palette, palLen);
		return palette;
	}
	
	function extractFrequence(_surfFull, _size) {
		var msize = 128;
		var _surf = surface_create_valid(min(msize, surface_get_width_safe(_surfFull)), min(msize, surface_get_height_safe(_surfFull)));
		_size = max(1, _size);
		
		var ww = surface_get_width_safe(_surf);
		var hh = surface_get_height_safe(_surf);
		
		surface_set_target(_surf);
			DRAW_CLEAR
			BLEND_OVERRIDE
			draw_surface_stretched_safe(_surfFull, 0, 0, ww, hh);
			BLEND_NORMAL
		surface_reset_target();
		
		var c_buffer = buffer_create(ww * hh * 4, buffer_fixed, 2);
		var colors   = array_create(ww * hh);
		
		buffer_get_surface(c_buffer, _surf, 0);
		buffer_seek(c_buffer, buffer_seek_start, 0);
		
		var clrs = ds_map_create();
		for( var i = 0; i < ww * hh; i++ ) {
			var b = buffer_read(c_buffer, buffer_u32);
			var c = b;
			var a = b &  (0b_1111_1111 << 24) >> 24;
			if(a == 0) continue;
			
			c = make_color_rgba(color_get_red(c), color_get_green(c), color_get_blue(c), color_get_alpha(c));
			
			if(ds_map_exists(clrs, c)) clrs[? c].amount++;
			else                       clrs[? c] = { color: c, amount: 1 };
		}
			
		buffer_delete(c_buffer);
		
		var pr  = ds_priority_create();
		var k   = ds_map_find_first(clrs);
		var amo = ds_map_size(clrs);
		
		repeat(amo) {
			ds_priority_add(pr, clrs[? k].color, clrs[? k].amount);
			k = ds_map_find_next(clrs, k);
		}
		
		var amo = min(_size, ds_priority_size(pr));
		var pal = array_create(amo), ind = 0;
		repeat(amo) { pal[ind++] = ds_priority_delete_max(pr); }
		
		ds_priority_destroy(pr);
		ds_map_destroy(clrs);
		
		return pal;
	}
	
	function extractMeanShift(_surfFull) {
		var _r = getInputData(6);
		
		var ww = surface_get_width_safe(_surfFull);
		var hh = surface_get_height_safe(_surfFull);
		var cb = buffer_create(ww * hh * 4, buffer_fixed, 4);
		
		buffer_get_surface(cb, _surfFull, 0);
		buffer_seek(cb, buffer_seek_start, 0);
		
		var amo     = ww * hh;
		var palette = array_create(amo), ind = 0;
		var bm      = 0b11111111 << 24;
		
		for( var i = 0; i < amo; i++ ) {
			var c = buffer_read(cb, buffer_u32);
			if(c & bm == 0) continue;
			palette[ind++] = color_rgb(c);
		}
		
		buffer_delete(cb);
		var _com = variable_clone(palette);
		var _dd  = 0, _itr = 0;
		
		do {
			_dd = 0;
			
			for( var i = 0; i < ind; i++ ) {
				var _c   = _com[i];
				var _ttx = 0;
				var _tty = 0;
				var _ttz = 0;
				var _ta  = 0;
				
				var _cx = _c[0];
				var _cy = _c[1];
				var _cz = _c[2];
				
				for( var j = 0; j < ind; j++ ) {
					var _p = palette[j];
					var _d = point_distance_3d(_cx, _cy, _cz, _p[0], _p[1], _p[2]);
					if(_d > _r) continue;
					
					_ttx += _p[0];
					_tty += _p[1];
					_ttz += _p[2];
					_ta++;
				}
				
				if(_ta == 0) continue;
				var _tx  = _ttx / _ta;
				var _ty  = _tty / _ta;
				var _tz  = _ttz / _ta;
				    _dd += abs(_cx - _tx) + abs(_cy - _ty) + abs(_cz - _tz);
				
				_c[0] = _tx;
				_c[1] = _ty;
				_c[2] = _tz;
			}
			
		} until(_dd < 1 || ++_itr > 32);
		
		for( var i = 0; i < ind; i++ ) _com[i] = make_color_rgba(_com[i][0] * 255, _com[i][1] * 255, _com[i][2] * 255, 255);
		var palLen = array_unique_ext(_com);
		array_resize(_com, min(ind, palLen));
		
		return _com;
	}
	
	static extractPalette = function(_surf, _algo, _size, _seed) {
		if(!is_surface(_surf)) return [];
		
		switch(_algo) {
			case 0 : return extractKmean(_surf, _size, _seed);
			case 1 : return extractFrequence(_surf, _size);
			case 2 : return extractAll(_surf);
			case 3 : return extractMeanShift(_surf);
		}
		
		return [];
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf = _data[0];
		var _size = _data[1];
		var _seed = _data[2];
		var _algo = _data[3];
		var _mask = _data[5];
		
		inputs[1].setVisible(_algo <  2);
		inputs[2].setVisible(_algo == 0);
		inputs[4].setVisible(_algo == 0);
		inputs[6].setVisible(_algo == 3);
		
		if(!is_surface(_surf)) return;
		if(!is_surface(_mask)) return extractPalette(_surf, _algo, _size, _seed);
			
		var _dim = surface_get_dimension(_surf);
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
		
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			BLEND_OVERRIDE
			draw_surface(_surf, 0, 0);
			
			BLEND_MULTIPLY
			draw_surface(_mask, 0, 0);
			
			BLEND_NORMAL
		surface_reset_target();
		
		return extractPalette(temp_surface[0], _algo, _size, _seed);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var pal = outputs[0].getValue();
		if(array_empty(pal)) return;
		if(!is_array(array_safe_get(pal, 0))) pal = [ pal ];
		
		var _y = bbox.y0;
		var gh = bbox.h / array_length(pal);
			
		for( var i = 0, n = array_length(pal); i < n; i++ ) {
			drawPalette(pal[i], bbox.x0, _y, bbox.w, gh);
			_y += gh;
		}	
	}
}