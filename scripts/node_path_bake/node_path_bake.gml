function Node_Path_Bake(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Bake Path";
	setDimension(96, 48);
	
	inputs[0] = nodeValue_PathNode("Path", self, noone)
		.setVisible(true, true);
	
	inputs[1] = nodeValue_Float("Segment length", self, 1);
	
	inputs[2] = nodeValue_Bool("Spread single path", self, true);
	
	outputs[0] = nodeValue_Output("Segments", self, VALUE_TYPE.float, [[]])
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDepth(2);
	
	path_amount = 1;
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _path = getInputData(0);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
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
		var _dist = getInputData(1);
		var _sped = getInputData(2);
		
		if(_path == noone)	return;
		if(_dist <= 0)		return;
		
		var _loop   = struct_try_get(_path, "path_loop", false);
		var _amo    = _path.getLineCount();
		path_amount = _amo;
		var _segs   = array_create(_amo);
		
		var _p = new __vec2();
		
		for( var i = 0; i < _amo; i++ ) {
			var _len = _path.getLength(i);
			var _seg = [];
			_segs[i] = _seg;
			
			if(_len == 0) continue;
			
			for( var j = 0; j <= _len; j += _dist ) {
				_p = _path.getPointDistance(j, i, _p);
				array_push(_seg, [ _p.x, _p.y, j / _len ]);
			}
			
			if(_loop) array_push(_seg, [ _seg[0][0], _seg[0][1], 1 ]);
		}
		
		if(_sped && _amo == 1) _segs = _segs[0];
		outputs[0].setValue(_segs);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(THEME.node_draw_path, 0, bbox);
	}
}