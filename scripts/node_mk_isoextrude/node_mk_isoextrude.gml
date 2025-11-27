function Node_MK_Isoextrude(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Isoextrude";
	
	////- =Surface
	newInput(0, nodeValue_Surface( "Surface In"  ));
	newInput(3, nodeValue_Surface( "Surface Top" ));
	
	////- =Depth
	newInput(1, nodeValue_Int( "Depth", 8 ));
	
	////- =Rendering
	newInput(2, nodeValue_Color( "Blending", ca_white ));
	// input
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 
		["Surface",   false ], 0, 3, 
		["Depth",     false ], 1, 
		["Rendering", false ], 2, 
	];
	
	////- Nodes
	
	temp_surface = [ noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf  = _data[0]; 
			var _surfT = _data[3], _surfTu = is_surface(_surfT);
			
			var _dept = _data[1]; 
			
			var _colr = _data[2]; 
			
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		var sw = surface_get_width_safe(  _surf );
		var sh = surface_get_height_safe( _surf );
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], sw, sh);
		
		var cx = sw / 2;
		var cy = sh / 2;
		
		var ww = sw / 2;
		var hh = ww / 2;
		
		var x0 = cx,      y0 = cy - hh;
		var x1 = cx + ww, y1 = cy;
		var x2 = cx - ww, y2 = cy;
		var x3 = cx,      y3 = cy + hh;
		
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR
			draw_rectangle_pr_surf(x0, y0, x1, y1, x2, y2, x3, y3, _surf);
		surface_reset_target();
		
		surface_set_target(temp_surface[1]);
			DRAW_CLEAR
			draw_rectangle_pr_surf(x0, y0, x1, y1, x2, y2, x3, y3, _surfTu? _surfT : _surf);
		surface_reset_target();
				
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			var xx = 0;
			var yy = 0 + _dept / 2;
			var ii = 0;
			
			repeat(_dept) {
				if(ii == _dept - 1)
					draw_surface_ext(temp_surface[1], xx, yy, 1, 1, 0, c_white, 1);
				else 
					draw_surface_ext(temp_surface[0], xx, yy, 1, 1, 0, _colr, 1);
				
				yy--;
				ii++;
			}
		surface_reset_target();
		
		return _outSurf; 
	}
}