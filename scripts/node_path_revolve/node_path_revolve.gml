function Node_Path_Revolve(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Revolve Path";
	
	////- =Output
	newInput( 1, nodeValue_Dimension());
	
	////- =Paths
	newInput( 0, nodeValue_PathNode( "Path" )).rejectArray();
	newInput( 4, nodeValue_Slider(   "Shift",      0     ));
	newInput( 5, nodeValue_Bool(     "Invert",     false ));
	newInput( 7, nodeValue_Int(      "Resolution", 16    )).setValidator(VV_min(2)).rejectArray();
	
	////- =Revolve
	newInput( 8, nodeValue_Vec2(     "Center",    [.5,.5] )).setUnitSimple();
	newInput( 9, nodeValue_Rotation( "Direction",   90    ));
	newInput(11, nodeValue_RotRange( "Revolve Range", [0,360] ));
	newInput(13, nodeValue_Rotation( "Revolve Offset", 0  ));
	newInput(10, nodeValue_Slider(   "Ratio",      .5     ));
	
	newInput( 3, nodeValue_Int(      "Subdivision", 16    )).setValidator(VV_min(2)).rejectArray();
	
	////- =Rendering
	newInput( 2, nodeValue_Surface( "Texture" ));
	newInput(12, nodeValue_Vec2(    "UV Position", [0,0] ));
	newInput( 6, nodeValue_Vec2(    "UV Range",    [1,1] ));
	// input 14
		
	newOutput(0, nodeValue_Output("Rendered", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Output",    false ],  1, 
		[ "Paths",     false ],  0,  4,  5,  7, 
		[ "Revolve",   false ],  8,  9, 11, 13, 10,  3, 
		[ "Rendering", false ],  2, 12,  6, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_interpolation();
	
	temp_surface = [ noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		var _cen = getInputData( 8);
		var _dir = getInputData( 9);
		
		var px  = _x + _cen[0] * _s;
		var py  = _y + _cen[1] * _s;
		
		var x0 = px - lengthdir_x(9999, _dir);
		var y0 = py - lengthdir_y(9999, _dir);
		var x1 = px + lengthdir_x(9999, _dir);
		var y1 = py + lengthdir_y(9999, _dir);
		
		draw_set_color(COLORS._main_accent);
		draw_line_dashed(x0, y0, x1, y1);
		
		InputDrawOverlay(inputs[ 8].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
		InputDrawOverlay(inputs[ 9].drawOverlay(hover, active, px, py, _s, _mx, _my));
		
		InputDrawOverlay(inputs[ 0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
	}
		
	static update = function() {
		#region data
			var _dim  = getInputData( 1);
			
			var _path = getInputData( 0);
			var _sft  = getInputData( 4);
			var _inv  = getInputData( 5);
			var _pres = getInputData( 7);
			
			var _cen  = getInputData( 8);
			var _dir  = getInputData( 9);
			var _rev  = getInputData(11);
			var _shf  = getInputData(13);
			var _rat  = getInputData(10);
			var _sub  = getInputData( 3);
			
			var _surf = getInputData( 2);
			var _uvP  = getInputData(12);
			var _uvS  = getInputData( 6);
			
			if(!is_path(_path)) return;
		#endregion
		
		if(!is_surface(_surf)) {
			temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
			
			surface_set_shader(temp_surface[0], sh_coord);
				draw_empty();
			surface_reset_shader()
			
			_surf = temp_surface[0];
		}
		
		var dx = lengthdir_x(1, _dir);
		var dy = lengthdir_y(1, _dir);
		
		var rax = lengthdir_x(1, _dir - 90);
		var ray = lengthdir_y(1, _dir - 90);
		
		var rbx = dx * _rat;
		var rby = dy * _rat;
		
		var _pnt = array_create(_pres + 1);
		var _isb = .9999 / (_pres - 1);
		var _pp  = new __vec2P();
		
		for( var i = 0; i <= _pres; i++ ) {
			var _prog = clamp(frac(i * _isb + _sft), 0., 0.9999);
			if(_inv) _prog = 1 - _prog;
			
			_path.getPointRatio(_prog, 0, _pp);
			
			var _x = _pp.x;
			var _y = _pp.y;
			
			var adir = point_direction(_cen[0], _cen[1], _x, _y);
			var adif = angle_difference(adir, _dir);
			
			var distA = point_distance(_cen[0], _cen[1], _x, _y);
			var distL = distA * dsin(adif);
			var distC = distA * dcos(adif);
			
			var lx = _cen[0] + distC * dx;
			var ly = _cen[1] + distC * dy;
			
			_pnt[i] = [ _x, _y, lx, ly, distL ];
		}
		
		var _outSurf = outputs[0].getValue();
		    _outSurf = surface_verify(_outSurf, _dim[0], _dim[1], attrDepth());
		var _ind = 0;
		
		surface_set_shader(_outSurf, sh_path_map_render, true, BLEND.normal);
			shader_set_interpolation(_surf);
			
			draw_set_color(c_white);
			shader_set_2("uvP", _uvP);
			shader_set_2("uvS", _uvS);
			
			draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_surf));
				var ast = _dir + 90 + _shf + _rev[0];
				var aed = _dir + 90 + _shf + _rev[1];
				var stp = 1 / _sub;
			
				for( var j = 0; j < _sub; j++ ) {
					var a0 = lerp(ast, aed, (j+0) * stp);
					var a1 = lerp(ast, aed, (j+1) * stp);
					
					for( var i = 0; i < _pres - 1; i++ ) {
						var p0 = _pnt[i+0];
						var p1 = _pnt[i+1];
						
						var p0dx = lengthdir_x(p0[4], a0);
						var p0dy = lengthdir_y(p0[4], a0);
						
						var p0x = p0[2] + p0dx * rax + p0dy * rbx;
						var p0y = p0[3] + p0dx * ray + p0dy * rby;
						
						var p1dx = lengthdir_x(p1[4], a0);
						var p1dy = lengthdir_y(p1[4], a0);
						
						var p1x = p1[2] + p1dx * rax + p1dy * rbx;
						var p1y = p1[3] + p1dx * ray + p1dy * rby;
						
						var p2dx = lengthdir_x(p0[4], a1);
						var p2dy = lengthdir_y(p0[4], a1);
						
						var p2x = p0[2] + p2dx * rax + p2dy * rbx;
						var p2y = p0[3] + p2dx * ray + p2dy * rby;
						
						var p3dx = lengthdir_x(p1[4], a1);
						var p3dy = lengthdir_y(p1[4], a1);
						
						var p3x = p1[2] + p3dx * rax + p3dy * rbx;
						var p3y = p1[3] + p3dx * ray + p3dy * rby;
					
						var p0u = (j + 0) / (_sub - 1), p0v = (i + 0) / (_pres - 1);
						var p1u = (j + 0) / (_sub - 1), p1v = (i + 1) / (_pres - 1);
						var p2u = (j + 1) / (_sub - 1), p2v = (i + 0) / (_pres - 1);
						var p3u = (j + 1) / (_sub - 1), p3v = (i + 1) / (_pres - 1);
					
						draw_vertex_texture(p0x, p0y, p0u, p0v);
						draw_vertex_texture(p1x, p1y, p1u, p1v);
						draw_vertex_texture(p2x, p2y, p2u, p2v);
					
						draw_vertex_texture(p1x, p1y, p1u, p1v);
						draw_vertex_texture(p2x, p2y, p2u, p2v);
						draw_vertex_texture(p3x, p3y, p3u, p3v);
						
						if(_ind++ > 64) {
							_ind = 0;
							draw_primitive_end();
							draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_surf));
						}
					}
				}
			draw_primitive_end();
		surface_reset_shader();
		
		outputs[0].setValue(_outSurf);
	}
} 