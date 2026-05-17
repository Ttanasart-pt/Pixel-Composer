function Node_Palette_Shrink(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shrink Palette";	
	setDimension(96);
	
	////- =Palette
	newInput( 3, nodeValueSeed());
	newInput( 0, nodeValue_Palette( "Palette in" )).setVisible(true, true);
	newInput( 2, nodeValue_Int(     "Amount",      4 ));
	
	////- =Algorithm
	newInput( 4, nodeValue_EButton( "Color Space", 0, [ "RGB", "HSV" ] ))
	newInput( 1, nodeValue_EButton( "Algorithm",   1, [ "Histogram", "K-mean" ] )).rejectArray();
	newInput( 5, nodeValue_EScroll( "Sample Type", 0, [ "Uniform", "Random" ] ));
	newInput( 6, nodeValue_Int(     "Shift",       0 ));
	// 7
	
	newOutput(0, nodeValue_Output("Palette", VALUE_TYPE.color, [] )).setDisplay(VALUE_DISPLAY.palette);
	
	input_display_list = [
        [ "Palette",   false ],  3,  0,  2, 
        [ "Algorithm", false ],  4,  1,  5,  6,  
	];
	
	////- Node
	
	static processData_prebatch = function() {
		setDimension(96, process_length[0] * 32);
	}
	
	function kmean(_pal, _data) {
		var _seed  = _data[ 3];
		
		var _space = _data[ 4];
		var _size  = _data[ 2]; _size = max(1, _size);
		var _samp  = _data[ 5];
		var _shift = _data[ 6];
		
		var _cc, col = 0, colors = [];
		random_set_seed(_seed);
		
		_min = [ 1, 1, 1 ];
		_max = [ 0, 0, 0 ];
		
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
			
		var itr = 10, cnt = array_create(_size);
		for(var i = 0; i < _size; i++) {
			   
			if(_samp == 0) {
				if(_shift == 0) {
					cnt[i] = [ lerp(_min[0], _max[0], i / (_size - 1)), 
		                       lerp(_min[1], _max[1], i / (_size - 1)), 
		                       lerp(_min[2], _max[2], i / (_size - 1)), 0 ];
            		
				} else {
					cnt[i] = [ lerp(_min[0], _max[0], frac(i / _size + _shift)), 
		                       lerp(_min[1], _max[1], frac(i / _size + _shift)), 
		                       lerp(_min[2], _max[2], frac(i / _size + _shift)), 0 ];
            		
				}
				
			} else if(_samp == 1) {
				var _r = random(1);
				cnt[i] = [ lerp(_min[0], _max[0], _r), 
	                       lerp(_min[1], _max[1], _r), 
	                       lerp(_min[2], _max[2], _r), 0 ];
        		
			}
			
		}
		
		repeat(itr) {
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
			
		}
		
		var index = [];
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
			
			array_push(index, closet);
		}
		
		if(array_empty(index)) return [];
		
		array_sort(index, true);
		index = array_unique(index);
		
		var palette = [];
		for( var i = 0, n = array_length(index); i < n; i++ ) 
			array_push(palette, _pal[index[i]]);
		
		return palette;
	}
	
	function histogram(_pal, _data) {
		var _size  = max(1, _data[2]);
		var _space = _data[4];
		var _cc, col, colors = [];
		
		_min = [ 1, 1, 1 ];
		_max = [ 0, 0, 0 ];
		
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
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _pal = _data[ 0];
			var _amo = _data[ 2];
			
			var _alg = _data[ 1];
			var _sam = _data[ 5];
			
			inputs[ 3].setVisible(_alg == 1 && _sam == 1);
			
			inputs[ 5].setVisible(_alg == 1);
			inputs[ 6].setVisible(_alg == 1 && _sam == 0);
			
			if(!is_array(_pal)) return;
		#endregion
		
		if(array_length(_pal) <= _amo) return _pal;
		
		switch(_alg) {
		    case 0 : return histogram(_pal, _data); 
		    case 1 : return kmean(_pal, _data); 
		}
		
		return _pal;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		if(bbox.h < 1) return;
		
		var pal = outputs[0].getValue();
		if(array_empty(pal)) return;
		if(!is_array(pal[0])) pal = [ pal ];
		
		var _y = bbox.y0;
		var gh = bbox.h / array_length(pal);
			
		for( var i = 0, n = array_length(pal); i < n; i++ ) {
			drawPalette(pal[i], bbox.x0, _y, bbox.w, gh);
			_y += gh;
		}
	}
}