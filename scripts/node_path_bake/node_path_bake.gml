function Node_Path_Bake(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Bake Path";
	setDimension(96, 48);
	
	newInput(0, nodeValue_PathNode( "Path" ));
	newInput(2, nodeValue_Bool(     "Spread Single Path", true ));
	
	////- =Type
	newInput(3, nodeValue_Enum_Scroll( "Sample Type",    0, [ "Length", "Amount" ] ));
	newInput(1, nodeValue_Float(       "Segment Length", 1 ));
	newInput(4, nodeValue_Int(         "Output Amount",  1 ));
	// input 5
	
	newOutput(0, nodeValue_Output("Segments", VALUE_TYPE.float, [])).setDisplay(VALUE_DISPLAY.vector).setArrayDepth(2);
	
	input_display_list = [ 0, 2, 
		[ "Type", false ], 3, 1, 4, 
	];
	
	path_amount = 1;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		InputDrawOverlay(inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
		
		var _segs = outputs[0].getValue();
		var ox, oy, nx, ny;
		
		if(array_invalid(_segs) || array_invalid(_segs[0])) return;
		if(!is_array(_segs[0][0])) _segs = [ _segs ];
		
		draw_set_color(COLORS._main_icon);
		
		for( var i = 0, n = array_length(_segs); i < n; i++ ) {
			var _seg = _segs[i];
			
			for( var j = 0, m = array_length(_seg); j < m; j++ ) {
				nx = _x + _seg[j][0] * _s;
				ny = _y + _seg[j][1] * _s;
				
				if(j) draw_line_width(ox, oy, nx, ny, 3);
				
				ox = nx; 
				oy = ny;
			}
		}
	}
	
	static update = function() {
		var _path = getInputData(0);
		var _sped = getInputData(2);
		
		var _type = getInputData(3);
		var _dist = getInputData(1);
		var _amou = getInputData(4); _amou = max(2, _amou);
		
		inputs[1].setVisible(_type == 0);
		inputs[4].setVisible(_type == 1);
		
		if(_path == noone)	return;
		
		var _loop   = struct_try_get(_path, "path_loop", false);
		var _amo    = _path.getLineCount();
		path_amount = _amo;
		var _segs   = array_create(_amo);
		
		var _p = new __vec2P();
		var st = 1 / _amou;
		
		for( var i = 0; i < _amo; i++ ) {
			var _len = _path.getLength(i);
			var _seg = [];
			_segs[i] = _seg;
			
			if(_len == 0) continue;
			
			switch(_type) {
				case 0 : 
					for( var j = 0; j <= _len; j += _dist ) {
						_p = _path.getPointDistance(j, i, _p);
						array_push(_seg, [ _p.x, _p.y, j / _len ]);
					}
					break;
				
				case 1 : 
					for( var j = 0; j <= _amou; j++ ) {
						_p = _path.getPointRatio(j * st, i, _p);
						array_push(_seg, [ _p.x, _p.y, j * st ]);
					}
					break;
			}
			
			if(_loop) array_push(_seg, [ _seg[0][0], _seg[0][1], 1 ]);
		}
		
		if(_sped && _amo == 1) _segs = _segs[0];
		outputs[0].setValue(_segs);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_bbox_uniform(THEME.node_draw_path, 0, bbox);
	}
}