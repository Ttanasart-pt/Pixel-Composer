function Node_Segment_Filter(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Filter Segment";
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Vector("Segment"))
		.setVisible(true, true)
		.setArrayDepth(1);
	
	newInput(1, nodeValue_Rotation("Angle", 0));
	
	newInput(2, nodeValue_Float("Spread", 15));
	
	newInput(3, nodeValue_Bool("Both side", true));
		
	newOutput(0, nodeValue_Output("Segments", VALUE_TYPE.float, [[]]))
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDepth(2);
	
	input_display_list = [
		["Segments",	false], 0, 
		["Filter",		false], 1, 2, 3, 
	];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _segs = outputs[0].getValue();
		var ox, oy, nx, ny;
		
		if(array_invalid(_segs) || array_invalid(_segs[0])) return;
		if(!is_array(_segs[0][0])) _segs = [ _segs ];
		
		draw_set_color(COLORS._main_icon);
		
		for( var i = 0, n = array_length(_segs); i < n; i++ ) {
			var _seg = _segs[i];
			var ox   = _x + _seg[0][0] * _s;
			var oy   = _y + _seg[0][1] * _s;
			
			for( var j = 1, m = array_length(_seg); j < m; j++ ) {
				nx = _x + _seg[j][0] * _s;
				ny = _y + _seg[j][1] * _s;
				
				draw_line_width(ox, oy, nx, ny, 3);
				
				ox = nx; 
				oy = ny;
			}
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _segments = getInputData(0);
		var _angle    = getInputData(1);
		var _spread   = getInputData(2);
		var _both     = getInputData(3);
		
		if(array_invalid(_segments) || array_invalid(_segments[0])) return;
		if(!is_array(_segments[0][0])) //spreaded single path
			_segments = [ _segments ];
			
		var _amo = array_length(_segments);
		var _segOut = [];
		
		for(var i = 0; i < _amo; i++) {
			var _segIn = _segments[i];
			if(array_empty(_segIn)) continue;
			
			var _ox  = _segIn[0][0], _oy = _segIn[0][1], _nx, _ny;
			var _inc = false;
			var _dir, _drv;
			var _seg = [];
			
			for (var j = 1, n = array_length(_segIn); j < n; j++) {
				_nx = _segIn[j][0];
				_ny = _segIn[j][1];
				
				_dir = point_direction(_ox, _oy, _nx, _ny);
				_drv = abs(angle_difference(_dir, _angle));
				if(_both) _drv = min(_drv, abs(angle_difference(_dir, _angle + 180)));
				
				if(_drv < _spread) {
					if(!_inc) array_push(_seg, [ _ox, _oy ]);
					
					array_push(_seg, [ _nx, _ny ]);
					_inc = true;
					
				} else {
					if(!array_empty(_seg)) {
						array_push(_segOut, _seg);
						_seg = [];
					}
					
					_inc = false;
				}
				
				_ox = _nx;
				_oy = _ny;
			}
			
			if(!array_empty(_seg)) array_push(_segOut, _seg);
		}
		
		outputs[0].setValue(_segOut);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		draw_sprite_bbox_uniform(s_node_segment_filter, 0, bbox);
	}
}