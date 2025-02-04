function Node_Path_Fill(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Fill Path";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_PathNode("Path", self, noone))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Int("Resolution", self, 64))
		.setValidator(VV_min(2));
	
	newInput(3, nodeValue_Color("Color", self, cola(c_white)))
	
	newInput(4, nodeValue_Bool("Inverted", self, false))
	
	newInput(5, nodeValue_Color("Bachground", self, cola(c_black, 0)))
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		["Path",  false], 1, 2, 
		["Color", false], 3, 4, 5, 
	]
	
	temp_surface = [ 0 ];
	path_points  = [];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
	    var _path = getSingleValue(1);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	static step = function() {}
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) { 
	    var _dim  = _data[0];
	    var _path = _data[1];
	    var _reso = _data[2];
	    var _colr = _data[3];
	    var _invt = _data[4];
	    var _bg   = _data[5];
	    
	    _outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
	    if(!struct_has(_path, "getPointRatio")) return _outSurf; 
	    
	    __tpath  = _path;
		__step   = 1 / _reso;
		path_points = array_verify_ext(path_points, _reso, function() /*=>*/ {return new __vec2P()});
		
	    surface_set_target(_outSurf);
	        if(_invt) { draw_clear(_colr); BLEND_SUBTRACT }
	        else      { draw_clear(_bg); }
	        draw_set_color(_invt? c_white : _colr);
			
			array_map_ext(path_points, function(p, i) /*=>*/ {return __tpath.getPointRatio(i * __step, 0, p)});
			var _ts = polygon_triangulate(path_points, 0)[0];
			
			draw_primitive_begin(pr_trianglelist);
			for( var i = 0, n = array_length(_ts); i < n; i++ ) {
				var _t = _ts[i];
				var p0 = _t[0];
				var p1 = _t[1];
				var p2 = _t[2];
				
				draw_vertex(p0.x, p0.y);
				draw_vertex(p1.x, p1.y);
				draw_vertex(p2.x, p2.y);
			}
			draw_primitive_end();
			
			BLEND_NORMAL
		surface_reset_target();
	    
	    return _outSurf; 
	}
}