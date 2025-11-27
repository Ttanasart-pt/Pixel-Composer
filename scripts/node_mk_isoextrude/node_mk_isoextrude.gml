function Node_MK_Isoextrude(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Isoextrude";
	
	////- =Surface
	newInput(0, nodeValue_Surface( "Surface In"  ));
	newInput(3, nodeValue_Surface( "Surface Top" ));
	newInput(5, nodeValue_Surface( "Height Map"  ));
	
	////- =Isoextrude
	newInput(4, nodeValue_EButton( "Side",  0, [ "Top", "Left", "Right" ] ));
	newInput(1, nodeValue_Int(     "Depth", 8 ));
	
	////- =Rendering
	newInput(2, nodeValue_Color( "Blending", ca_white ));
	// input 5
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 
		["Surface",   false ], 0, 3, 5, 
		["Depth",     false ], 4, 1, 
		["Rendering", false ], 2, 
	];
	
	////- Nodes
	
	temp_surface = [ noone, noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) { 
		#region data
			var _surf  = _data[0]; 
			var _surfT = _data[3], _surfTu = is_surface(_surfT);
			var _surfH = _data[5], _surfHu = is_surface(_surfH);
			
			var _side = _data[4]; 
			var _dept = _data[1]; 
			
			var _colr = _data[2]; 
			
			if(!is_surface(_surf)) return _outSurf;
		#endregion
		
		var sw = surface_get_width_safe(  _surf );
		var sh = surface_get_height_safe( _surf );
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) 
			temp_surface[i] = surface_verify(temp_surface[i], sw, sh);
		
		#region geometry
			var cx = sw / 2;
			var cy = sh / 2;
			
			var ww = sw / 2;
			var hh = sh / 2;
				
			var x0 = 0, y0 = 0;
			var x1 = 0, y1 = 0;
			var x2 = 0, y2 = 0;
			var x3 = 0, y3 = 0;
				
			var xx = 0, dx = 0;
			var yy = 0, dy = 0;
				
			if(_side == 0) {
				ww = sw / 2;
				hh = ww / 2;
				
				x0 = cx;       y0 = cy - hh;
				x1 = cx + ww;  y1 = cy;
				x2 = cx - ww;  y2 = cy;
				x3 = cx;       y3 = cy + hh;
				
				xx = 0;
				yy = _dept / 2;
				
				dx =  0;
				dy = -1;
	
			} else if(_side == 1) {
				ww = sw / 2;
				hh = ww + ww / 2;
				
				x0 = cx - ww/2; y0 = cy - hh/2;
				x1 = cx + ww/2; y1 = y0 + ww/2;
				x2 = x0;        y2 = y0 + ww;
				x3 = x1;        y3 = cy + hh/2;
				
				xx =  _dept / 2;
				yy = -_dept / 4;
				
				dx = -1;
				dy = .5;
				
			} else if(_side == 2) {
				ww = sw / 2;
				hh = ww + ww / 2;
				
				x1 = cx + ww/2; y1 = cy - hh/2;
				x0 = cx - ww/2; y0 = y1 + ww/2;
				x2 = x0;        y2 = cy + hh/2;
				x3 = x1;        y3 = y1 + ww;
				
				xx = -_dept / 2;
				yy = -_dept / 4;
				
				dx =  1;
				dy = .5;
			}
		#endregion
		
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR draw_rectangle_pr_surf(x0, y0, x1, y1, x2, y2, x3, y3, _surf);
		surface_reset_target();
		
		surface_set_target(temp_surface[1]);
			DRAW_CLEAR draw_rectangle_pr_surf(x0, y0, x1, y1, x2, y2, x3, y3, _surfTu? _surfT : _surf);
		surface_reset_target();
		
		if(_surfHu) {
			surface_set_target(temp_surface[2]);
				DRAW_CLEAR draw_rectangle_pr_surf(x0, y0, x1, y1, x2, y2, x3, y3, _surfH);
			surface_reset_target();
		}
		
		surface_set_shader(_outSurf, sh_mk_isoextrude_apply_height);
			DRAW_CLEAR
			
			shader_set_i("useHeight",  _surfHu);
			shader_set_s("heightmap",  temp_surface[2]);
			shader_set_s("topmap",     temp_surface[1]);
			
			shader_set_f("maxDepth",   _dept - 1);
			
			var ii = 0;
			repeat(_dept) {
				shader_set_f("curDepth",   ii);
				draw_surface_ext(temp_surface[0], xx, yy, 1, 1, 0, _colr, 1);
				
				xx += dx;
				yy += dy;
				ii++;
			}
		surface_reset_shader();
		
		return _outSurf; 
	}
}