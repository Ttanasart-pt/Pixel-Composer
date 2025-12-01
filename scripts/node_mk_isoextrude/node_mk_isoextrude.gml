function Node_MK_Isoextrude(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Isoextrude";
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface Base" ));
	newInput( 6, nodeValue_Surface( "Surface Side" ));
	newInput( 3, nodeValue_Surface( "Surface Top"  ));
	newInput( 5, nodeValue_Surface( "Height Map"   ));
	
	////- =Isoextrude
	newInput( 4, nodeValue_EButton( "Side",      0, [ "Top", "Left", "Right" ] ));
	newInput( 1, nodeValue_Int(     "Depth",     8 )).setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	newInput( 9, nodeValue_Int(     "Depth Ref", 0 )).setUnitRef(function(i) /*=>*/ {return getDimension(i)});
	
	////- =Transform
	newInput( 7, nodeValue_Rotation( "Rotation",  0    ));
	newInput( 8, nodeValue_Vec2(     "Scale",    [1,1] ));
	
	////- =Hole
	newInput(12, nodeValue_EButton( "Mixing", 0, [ "Subtractive", "Additive" ] ));
	newInput(10, nodeValue_Surface( "Hole Map 1" ));
	newInput(11, nodeValue_Surface( "Hole Map 2" ));
	
	////- =Rendering
	newInput( 2, nodeValue_Color( "Blending", ca_white ));
	// input 13
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output("Depth",       VALUE_TYPE.surface, noone));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 
		[ "Surface",   false ], 0, 6, 3, 5, 
		[ "Depth",     false ], 4, 1, 9, 
		[ "Transform", false ], 7, 8, 
		[ "Hole",      false ], 12, 10, 11, 
		[ "Rendering", false ], 2, 
	];
	
	////- Nodes
	
	temp_surface = [ noone, noone, noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _surf  = _data[ 0]; 
			var _surfS = _data[ 6], _surfSu = is_surface(_surfS);
			var _surfT = _data[ 3], _surfTu = is_surface(_surfT);
			var _surfH = _data[ 5], _surfHu = is_surface(_surfH);
			
			var _side    = _data[ 4]; 
			var _dept    = _data[ 1]; 
			var _deptRef = _data[ 9]; if(_deptRef == 0) _deptRef = _dept;
			
			var _rota  = _data[ 7]; 
			var _scal  = _data[ 8]; 
			
			var _hType  = _data[12]; 
			var _surfO1 = _data[10], _surfO1u = is_surface(_surfO1);
			var _surfO2 = _data[11], _surfO2u = is_surface(_surfO2);
			
			var _colr  = _data[ 2]; 
			
			if(!is_surface(_surf)) return _outData;
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
				yy = _deptRef / 2;
				
				dx =  0;
				dy = -1;
	
			} else if(_side == 1) {
				ww = sw / 2;
				hh = ww + ww / 2;
				
				x0 = cx - ww/2; y0 = cy - hh/2;
				x1 = cx + ww/2; y1 = y0 + ww/2;
				x2 = x0;        y2 = y0 + ww;
				x3 = x1;        y3 = cy + hh/2;
				
				xx =  _deptRef / 2;
				yy = -_deptRef / 4;
				
				dx = -1;
				dy = .5;
				
			} else if(_side == 2) {
				ww = sw / 2;
				hh = ww + ww / 2;
				
				x1 = cx + ww/2; y1 = cy - hh/2;
				x0 = cx - ww/2; y0 = y1 + ww/2;
				x2 = x0;        y2 = cy + hh/2;
				x3 = x1;        y3 = y1 + ww;
				
				xx = -_deptRef / 2;
				yy = -_deptRef / 4;
				
				dx =  1;
				dy = .5;
			}
		#endregion
		
		shader_set(sh_mk_isoextrude_transform);
			shader_set_f("rotation", _rota);
			shader_set_2("scale",    _scal);
		shader_reset();
		
		surface_set_shader(temp_surface[0], sh_mk_isoextrude_transform);
			draw_rectangle_pr_surf(x0, y0, x1, y1, x2, y2, x3, y3, _surf);
		surface_reset_shader();
		
		surface_set_shader(temp_surface[1], sh_mk_isoextrude_transform);
			draw_rectangle_pr_surf(x0, y0, x1, y1, x2, y2, x3, y3, _surfTu? _surfT : _surf);
		surface_reset_shader();
		
		if(_surfHu) {
			surface_set_shader(temp_surface[2], sh_mk_isoextrude_transform);
				draw_rectangle_pr_surf(x0, y0, x1, y1, x2, y2, x3, y3, _surfH);
			surface_reset_shader();
		}
		
		surface_set_shader(temp_surface[3], sh_mk_isoextrude_coordinate);
			draw_rectangle_pr_surf(x0, y0, x1, y1, x2, y2, x3, y3, _surf);
		surface_reset_shader();
		
		_outData[0] = surface_verify(_outData[0], sw, sh); surface_clear(_outData[0]);
		_outData[1] = surface_verify(_outData[1], sw, sh); surface_clear(_outData[1], c_white, 1);
		
		surface_set_shader(_outData, sh_mk_isoextrude_apply_height, false, BLEND.normal);
			DRAW_CLEAR
			
			shader_set_i("useHeight",  _surfHu);
			shader_set_s("heightmap",  temp_surface[2]);
			shader_set_s("topmap",     temp_surface[1]);
			shader_set_s("coordMap",   temp_surface[3]);
			
			shader_set_i("useSide",     _surfSu);
			shader_set_s("sideTexture", _surfS);
			
			shader_set_i("holeType",     _hType);
			
			shader_set_i("useHole1",     _surfO1u);
			shader_set_s("holeTexture1", _surfO1);
			
			shader_set_i("useHole2",     _surfO2u);
			shader_set_s("holeTexture2", _surfO2);
			
			shader_set_f("maxDepth",   _dept - 1);
			shader_set_f("rotation",   _rota / 360);
			
			var ii = 0;
			repeat(_dept) {
				shader_set_f("curDepth",   ii);
				draw_surface_ext(temp_surface[0], xx, yy, 1, 1, 0, _colr, 1);
				
				xx += dx;
				yy += dy;
				ii++;
			}
		surface_reset_shader();
		
		return _outData; 
	}
}