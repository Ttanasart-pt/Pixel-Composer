function Node_Path_Bake(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Bake Path";
	w    = 96;
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Segment length", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	outputs[| 0] = nodeValue("Segment", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [[]])
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDepth(1);
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _path = getInputData(0);
		if(_path) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
		
		var _segs = outputs[| 0].getValue();
		var ox, oy, nx, ny;
		
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
	} #endregion
	
	static update = function() { #region
		var _path = getInputData(0);
		var _dist = getInputData(1);
		
		if(_path == noone)	return;
		if(_dist <= 0)		return;
		
		var _amo  = _path.getLineCount();
		var _segs = array_create(_amo);
		
		var _p = new __vec2();
		
		for( var i = 0; i < _amo; i++ ) {
			var _len = _path.getLength(i);
			var _seg = [];
			
			for( var j = 0; j <= _len; j += _dist ) {
				_p = _path.getPointDistance(j, i, _p);
				
				_seg[j] = [ _p.x, _p.y ];
			}
			
			_segs[i] = _seg;
		}
		
		outputs[| 0].setValue(_segs);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(THEME.node_draw_path, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}