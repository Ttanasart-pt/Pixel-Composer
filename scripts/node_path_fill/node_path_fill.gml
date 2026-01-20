function Node_Path_Fill(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Fill Path";
	
	////- =Data
	newInput(0, nodeValue_Dimension());
	
	////- =Path
	newInput(1, nodeValue_PathNode( "Path" ));
	newInput(2, nodeValue_Int(      "Resolution", 64   )).setValidator(VV_min(2));
	newInput(6, nodeValue_Vec2(     "Scale",     [1,1] ));
	
	////- =Rendering
	newInput(3, nodeValue_Color(   "Color",      ca_white ));
	newInput(4, nodeValue_Bool(    "Inverted",   false    ));
	newInput(7, nodeValue_EScroll( "Background", 0, [ "None", "Solid", "Surface" ]  ));
	newInput(5, nodeValue_Color(   "BG Color",   ca_zero  ));
	newInput(8, nodeValue_Surface( "BG Surface"           ));
	// inputs 9
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0, 
		[ "Path",      false ], 1, 2, 6, 
		[ "Rendering", false ], 3, 4, 7, 5, 8, 
	];
	
	////- Node
	
	temp_surface = [ noone ];
	path_points  = [];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
	    InputDrawOverlay(inputs[1].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params));
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
		    var _dim  = _data[0];
		    var _path = _data[1];
		    var _reso = _data[2];
		    var _sca  = _data[6];
		    
		    var _colr = _data[3];
		    var _invt = _data[4];
		    
		    var _bg   = _data[7];
		    var _bgC  = _data[5];
		    var _bgS  = _data[8];
	    	
	    	inputs[5].setVisible(_bg == 1);
	    	inputs[8].setVisible(_bg == 2, _bg == 2);
	    	
		    _outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		    if(!is_path(_path)) return _outSurf; 
	    #endregion
	    
	    __tpath  = _path;
		__step   = 1 / _reso;
		path_points = array_verify_ext(path_points, _reso, function() /*=>*/ {return new __vec2P()});
		
	    surface_set_target(_outSurf);
	        if(_invt) { draw_clear(_colr); BLEND_SUBTRACT }
	        else switch(_bg) {
        		case 0 : DRAW_CLEAR;                    break;
        		case 1 : draw_clear(_bgC);              break;
        		case 2 : draw_surface_safe(_bgS, 0, 0); break;
        	}
	        
	        draw_set_color(_invt? c_white : _colr);
			
			array_map_ext(path_points, function(p, i) /*=>*/ {return __tpath.getPointRatio(i * __step, 0, p)});
			var _ts = polygon_triangulate(path_points, 0)[0];
			
			draw_primitive_begin(pr_trianglelist);
			for( var i = 0, n = array_length(_ts); i < n; i++ ) {
				var _t = _ts[i];
				var p0 = _t[0];
				var p1 = _t[1];
				var p2 = _t[2];
				
				draw_vertex(p0.x * _sca[0], p0.y * _sca[1]);
				draw_vertex(p1.x * _sca[0], p1.y * _sca[1]);
				draw_vertex(p2.x * _sca[0], p2.y * _sca[1]);
			}
			draw_primitive_end();
			
			BLEND_NORMAL
		surface_reset_target();
	    
	    return _outSurf; 
	}
}