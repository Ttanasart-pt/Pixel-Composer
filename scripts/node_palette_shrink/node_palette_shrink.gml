function Node_Palette_Shrink(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shrink Palette";	
	setDimension(96);
	
	newInput(0, nodeValue_Palette("Palette in", self, array_clone(DEF_PALETTE)))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Enum_Button("Algorithm", self,  1, [ "Histogram", "K-mean" ]))
		.rejectArray();
	
	newInput(2, nodeValue_Int("Amount", self, 4));
	
	newInput(3, nodeValueSeed(self, VALUE_TYPE.float));
	
	newInput(4, nodeValue_Enum_Button("Color Space", self, 0, [ "RGB", "HSV" ]))
	
	newOutput(0, nodeValue_Output("Palette", self, VALUE_TYPE.color, []))
		.setDisplay(VALUE_DISPLAY.palette);
	
	input_display_list = [
        0, 4, 1, 2, 
	];
	
	function kmean(_pal) {
		_size  = max(1, getInputData(2));
		_space = getInputData(4);
		
		_min = [ 1, 1, 1 ];
		_max = [ 0, 0, 0 ];
		var _cc, col = 0, colors = [];
		
		for( var i = 0, n = array_length(_pal); i < n; i++ ) {
			_cc = _pal[i];
			
			switch(_space) {
				case 0 : col = [ _color_get_red(_cc), _color_get_green(_cc),      _color_get_blue(_cc),  0 ]; break;
				case 1 : col = [ _color_get_hue(_cc), _color_get_saturation(_cc), _color_get_value(_cc), 0 ]; break;
			}
			
			array_push(colors, col);
			
			_min[0] = min(_min[0], col[0]); _max[0] = max(_max[0], col[0]);
			_min[1] = min(_min[1], col[1]); _max[1] = max(_max[1], col[1]);
			_min[2] = min(_min[2], col[2]); _max[2] = max(_max[2], col[2]);
		}
			
// 		random_set_seed(_seed);
// 		var cnt = array_create_ext(_size, () => [ random_range(_min[0], _max[0]), random_range(_min[1], _max[1]), random_range(_min[2], _max[2]), 0 ]);
		var cnt = array_create_ext(_size, function(i) /*=>*/ {return [ lerp(_min[0], _max[0], i / (_size - 1)), lerp(_min[1], _max[1], i / (_size - 1)), lerp(_min[2], _max[2], i / (_size - 1)), 0 ]});
		
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
						ind  = j;
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
		
		var palette = [];
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
			}
			
			array_push_unique(palette, clr);
		}
		
		return palette;
	}
	
	function histogram(_pal) {
		var _size  = max(1, getInputData(2));
		var _space = getInputData(4);
		
		var _min = [ 1, 1, 1 ];
		var _max = [ 0, 0, 0 ];
		var _cc, col, colors = [];
		
		for( var i = 0, n = array_length(_pal); i < n; i++ ) {
			_cc = _pal[i];
			
			switch(_space) {
				case 0 : col = [ _color_get_red(_cc), _color_get_green(_cc),      _color_get_blue(_cc),  0 ]; break;
				case 1 : col = [ _color_get_hue(_cc), _color_get_saturation(_cc), _color_get_value(_cc), 0 ]; break;
			}
			
			array_push(colors, col);
			
			_min[0] = min(_min[0], col[0]); _max[0] = max(_max[0], col[0]);
			_min[1] = min(_min[1], col[1]); _max[1] = max(_max[1], col[1]);
			_min[2] = min(_min[2], col[2]); _max[2] = max(_max[2], col[2]);
		}
		
		var palette = array_create(_size);
		var clr, _c0, _c1, _c2;
		
		for( var i = 0, n = array_length(palette); i < n; i++ ) {
		    _c0 = lerp(_min[0], _max[0], i / (n - 1)) * 255;
		    _c1 = lerp(_min[1], _max[1], i / (n - 1)) * 255;
		    _c2 = lerp(_min[2], _max[2], i / (n - 1)) * 255;
			
			switch(_space) {
				case 0 : clr = make_color_rgba(_c0, _c1, _c2, 255); break;
				case 1 : clr = make_color_hsva(_c0, _c1, _c2, 255); break;
			}
			
		    palette[i] = clr;
		}
		
		return palette;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _pal = _data[0];
		var _alg = _data[1];
		if(!is_array(_pal)) return;
		
		switch(_alg) {
		    case 0 : return histogram(_pal); 
		    case 1 : return kmean(_pal); 
		}
		
		return _pal;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var pal = outputs[0].getValue();
		if(array_empty(pal)) return;
		if(!is_array(pal[0])) pal = [ pal ];
		
		var _h = array_length(pal) * 32;
		var _y = bbox.y0;
		var gh = bbox.h / array_length(pal);
			
		for( var i = 0, n = array_length(pal); i < n; i++ ) {
			drawPalette(pal[i], bbox.x0, _y, bbox.w, gh);
			_y += gh;
		}
		
		if(_h != min_h) will_setHeight = true;
		min_h = _h;	
	}
}