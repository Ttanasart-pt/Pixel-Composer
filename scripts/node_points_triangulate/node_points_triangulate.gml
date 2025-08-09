function Node_Points_Triangulate(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Triangulate Points";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Vec2("Points", [ 0, 0 ])).setVisible(true, true).setArrayDepth(1);
		
	newOutput(0, nodeValue_Output("Segments", VALUE_TYPE.float, [ 0, 0 ])).setDisplay(VALUE_DISPLAY.vector).setArrayDepth(2);
	
	input_display_list = [
		["Points", false], 0,  
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
				
				draw_line(ox, oy, nx, ny);
				
				ox = nx; 
				oy = ny;
			}
		}
	}
	
	static update = function(frame = CURRENT_FRAME) {
		_points = getInputData(0);
		if(!is_array(_points)) return;
		
		var _d = array_get_depth(_points);
		if(_d == 1) _points = [ _points ];
		
		var _pnts   = array_create_ext(array_length(_points), function(i) /*=>*/ {return new __vec2(_points[i][0], _points[i][1])});
		var _tris   = delaunay_triangulation_c(_pnts);
		var _segOut = array_create(array_length(_tris));
		
		for( var i = 0, n = array_length(_tris); i < n; i++ ) {
		    var _tri = _tris[i];
		    var _p0  = _tri[0];
		    var _p1  = _tri[1];
		    var _p2  = _tri[2];
		    
		    _segOut[i] = [[ _p0.x, _p0.y, 1 ], [ _p1.x, _p1.y, 1 ], [ _p2.x, _p2.y, 1 ]];
		}
		
		outputs[0].setValue(_segOut);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_points_triangulate, 0, bbox);
	}
}