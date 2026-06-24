function Node_Path_Revolve(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Revolve Path";
	
	////- =Output
	newInput( 1, nodeValue_Dimension());
	
	////- =Paths
	newInput( 0, nodeValue_Path( "Path" )).rejectArray();
	newInput(14, nodeValue_Range(    "Range",     [0,1]  ));
	newInput( 4, nodeValue_Slider(   "Shift",      0     ));
	newInput( 5, nodeValue_Bool(     "Invert",     false ));
	newInput( 7, nodeValue_Int(      "Resolution", 16    )).setValidator(VV_min(2)).rejectArray();
	
	////- =Revolve
	newInput( 8, nodeValue_Vec2(     "Center",        [.5,.5] )).setUnitSimple();
	newInput( 9, nodeValue_Rotation( "Direction",      90     ));
	newInput(11, nodeValue_RotRange( "Revolve Range", [0,360] ));
	newInput(13, nodeValue_Rotation( "Revolve Offset", 0      ));
	newInput(10, nodeValue_Slider(   "Ratio",         .5      ));
	newInput(15, nodeValue_Slider(   "Scale",          1      )).setCurvable(16, CURVE_DEF_11);
	
	newInput( 3, nodeValue_Int(      "Subdivision",    16     )).setValidator(VV_min(2)).rejectArray();
	
	////- =Transform
	newInput(18, nodeValue_Vec2(     "Position",  [0,0]   )).setUnitSimple();
	newInput(19, nodeValue_Anchor(   "Anchor",    [.5,.5] ));
	newInput(20, nodeValue_Rot(      "Rotation",   0      ));
	newInput(21, nodeValue_Vec2(     "Scale",     [1,1]   ));
	
	////- =Rendering
	newInput(17, nodeValue_EButton( "Blend Mode", 0, [ "Normal", "Additive", "Maximum" ] ));
	newInput( 2, nodeValue_Surface( "Texture"             ));
	newInput(12, nodeValue_Vec2(    "UV Position", [0,0]  ));
	newInput( 6, nodeValue_Vec2(    "UV Range",    [1,1]  ));
	newInput(30, nodeValue_Bool(    "Scale to Path Range", false ));
	
	////- =Caps
	
		////- =/Start Caps
	newInput(22, nodeValue_Bool(    "Start Cap",  false                                  ));
	newInput(26, nodeValue_EButton( "Draw Order", 1, [ "Front", "Back" ]                 ));
	newInput(23, nodeValue_Surface( "Start Cap Texture"                                  ));
	newInput(28, nodeValue_EButton( "Blend Mode", 0, [ "Normal", "Additive", "Maximum" ] ));
	newInput(31, nodeValue_EButton( "Mapping",    1, [ "None", "Cartesian", "Polar" ]    ));
	
		////- =/End Caps
	newInput(25, nodeValue_Bool(    "End Cap",    false                                  ));
	newInput(27, nodeValue_EButton( "Draw Order", 0, [ "Front", "Back" ]                 ));
	newInput(24, nodeValue_Surface( "End Cap Texture"                                    ));
	newInput(29, nodeValue_EButton( "Blend Mode", 0, [ "Normal", "Additive", "Maximum" ] ));
	newInput(32, nodeValue_EButton( "Mapping",    1, [ "None", "Cartesian", "Polar" ]    ));
	// input 33
		
	newOutput( 0, nodeValue_Output("Rendered",  VALUE_TYPE.surface, noone));
	newOutput( 1, nodeValue_Output("Start Cap", VALUE_TYPE.surface, noone));
	newOutput( 2, nodeValue_Output("End Cap",   VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Output",          false ],  1, 
		[ "Paths",           false ],  0, 14,  4,  5,  7, 
		[ "Revolve",         false ],  8,  9, 11, 13, 10, 15, 16,  3, 
		[ "Transform",       false ], 18, 19, 20, 21, 
		[ "Rendering",       false ], 17,  2, 12,  6, 30, 
		[ "Caps",             true ], 
			[ "/Start Caps", false, 22 ], 26, 23, 28, 31, 
			[ "/End Caps",   false, 25 ], 27, 24, 29, 32, 
	];
	
	////- Node
	
	attribute_surface_depth();
	attribute_interpolation();
	
	temp_surface = [ noone ];
	
	curve_scale = new curveMap();
	
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
		
		drawOverlayInput(inputs[ 8].drawOverlay(hover, active, _x, _y, _s, _mx, _my));
		drawOverlayInput(inputs[ 9].drawOverlay(hover, active, px, py, _s, _mx, _my));
		
		drawOverlayInput(inputs[ 0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
	}
	
	static processData = function(_outData, _data, _array_index = 0) { 
		#region data
			var _dim  = _data[ 1];
			
			var _path = _data[ 0];
			var _prng = _data[14];
			var _sft  = _data[ 4];
			var _inv  = _data[ 5];
			var _pres = _data[ 7];
			
			var _cen  = _data[ 8];
			var _dir  = _data[ 9];
			var _rev  = _data[11];
			var _shf  = _data[13];
			var _rat  = _data[10];
			var _scal = _data[15];
			var _scaC = _data[16], _scaleCurve = inputs[15].attributes.curved? curve_scale.set(_scaC) : undefined;
			
			var _sub  = _data[ 3];
			
		    var _pos  = _data[18];
		    var _anc  = _data[19];
		    var _rot  = _data[20];
		    var _sca  = _data[21];
		    
			var _blnd = _data[17];
			var _surf = _data[ 2];
			var _uvP  = _data[12];
			var _uvS  = _data[ 6];
			var _uvSP = _data[30];
			
			var _caps = _data[22];
			var _scOr = _data[26];
			var _scTx = _data[23];
			var _scBl = _data[28];
			var _scMp = _data[31];
			
			var _cape = _data[25];
			var _ecOr = _data[27];
			var _ecTx = _data[24];
			var _ecBl = _data[29];
			var _ecMp = _data[32];
			
			inputs[23].setVisible(true, _caps);
			inputs[24].setVisible(true, _cape);
			
			outputs[1].setVisible(_caps);
			outputs[2].setVisible(_cape);
			
			if(!is_path(_path)) return _outData;
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
			
			var _samp = lerp(_prng[0], _prng[1], _prog);
			_path.getPointRatio(_samp, 0, _pp);
			
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
		
		var ancx = _anc[0] * _dim[0];
		var ancy = _anc[1] * _dim[1];
		var trans = matrix_compose(
			matrix_transform_2d(-ancx, -ancy),
			matrix_transform_2d(_pos[0], _pos[1], _rot, _sca[0], _sca[1]),
			matrix_transform_2d(ancx, ancy),
		);
		
		var ast = _dir + 90 + _shf + _rev[0];
		var aed = _dir + 90 + _shf + _rev[1];
		var stp = 1 / _sub;
	
		if(_caps) {
			var _outCapS = surface_verify(_outData[1], _dim[0], _dim[1], attrDepth());
		
			surface_set_shader(_outCapS, sh_path_map_render, true, BLEND.normal);
				shader_set_interpolation(_surf);
				draw_set_color(c_white);
				
				shader_set_2( "uvP",        [1,1]    );
				shader_set_2( "uvS",        [1,1]    );
				shader_set_2( "trimRange",  [0,1]    );
				shader_set_c( "blendColor", ca_white );
				
				matrix_set(matrix_world, trans);
				
				switch(_scBl) { case 0 : BLEND_NORMAL; break; case 1 : BLEND_ADD; break; case 2 : BLEND_MAX; break; }
				draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_scTx));
				for( var j = 0; j < _sub; j++ ) {
					var a0 = lerp(ast, aed, (j+0) * stp);
					var a1 = lerp(ast, aed, (j+1) * stp);
					
					var sc0 = _scal * (_scaleCurve? _scaleCurve.getFast((j+0) * stp) : 1);
					var sc1 = _scal * (_scaleCurve? _scaleCurve.getFast((j+1) * stp) : 1);
					
					var p0 = _pnt[0];
					
					var p0dx = lengthdir_x(p0[4], a0) * sc0;
					var p0dy = lengthdir_y(p0[4], a0) * sc0;
					
					var p0x = p0[2] + p0dx * rax + p0dy * rbx;
					var p0y = p0[3] + p0dx * ray + p0dy * rby;
					
					var p1dx = lengthdir_x(p0[4], a1) * sc1;
					var p1dy = lengthdir_y(p0[4], a1) * sc1;
					
					var p1x = p0[2] + p1dx * rax + p1dy * rbx;
					var p1y = p0[3] + p1dx * ray + p1dy * rby;
					
					switch(_scMp) {
						case 0 : 
							var pcu = p0[2] / _dim[0];
							var pcv = p0[3] / _dim[1];
							var p0u = p0x   / _dim[0];
							var p0v = p0y   / _dim[1];
							var p1u = p1x   / _dim[0];
							var p1v = p1y   / _dim[1];
							break;
						
						case 1 : 
							var pcu = .5;
							var pcv = .5;
							var p0u = .5 + lengthdir_x(.5, a0);
							var p0v = .5 + lengthdir_y(.5, a0);
							var p1u = .5 + lengthdir_x(.5, a1);
							var p1v = .5 + lengthdir_y(.5, a1);
							break;
							
						case 2 : 
							var pcu = .0;
							var pcv = .0;
							var p0u = a0 / 360;
							var p0v = 1;
							var p1u = a1 / 360;
							var p1v = 1;
							break;
							
					}
					
					draw_vertex_texture( p0x,   p0y,   p0u, p0v );
					draw_vertex_texture( p0[2], p0[3], pcu, pcv );
					draw_vertex_texture( p1x,   p1y,   p1u, p1v );
				
				}
				draw_primitive_end();
				BLEND_NORMAL
					
				matrix_set(matrix_world, MATRIX_IDENTITY);
			surface_reset_shader();
		}
		
		if(_cape) {
			var _outCapE = surface_verify(_outData[2], _dim[0], _dim[1], attrDepth());
			
			surface_set_shader(_outCapE, sh_path_map_render, true, BLEND.normal);
				shader_set_interpolation(_surf);
				draw_set_color(c_white);
				
				shader_set_2( "uvP",        [1,1]    );
				shader_set_2( "uvS",        [1,1]    );
				shader_set_2( "trimRange",  [0,1]    );
				shader_set_c( "blendColor", ca_white );
				
				matrix_set(matrix_world, trans);
				
				switch(_ecBl) { case 0 : BLEND_NORMAL; break; case 1 : BLEND_ADD; break; case 2 : BLEND_MAX; break; }
				draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_ecTx));
				for( var j = 0; j < _sub; j++ ) {
					var a0 = lerp(ast, aed, (j+0) * stp);
					var a1 = lerp(ast, aed, (j+1) * stp);
					
					var sc0 = _scal * (_scaleCurve? _scaleCurve.getFast((j+0) * stp) : 1);
					var sc1 = _scal * (_scaleCurve? _scaleCurve.getFast((j+1) * stp) : 1);
					
					var p0 = _pnt[_pres - 1];
					
					var p0dx = lengthdir_x(p0[4], a0) * sc0;
					var p0dy = lengthdir_y(p0[4], a0) * sc0;
					
					var p0x = p0[2] + p0dx * rax + p0dy * rbx;
					var p0y = p0[3] + p0dx * ray + p0dy * rby;
					
					var p1dx = lengthdir_x(p0[4], a1) * sc1;
					var p1dy = lengthdir_y(p0[4], a1) * sc1;
					
					var p1x = p0[2] + p1dx * rax + p1dy * rbx;
					var p1y = p0[3] + p1dx * ray + p1dy * rby;
					
					switch(_ecMp) {
						case 0 :
							var pcu = p0[2] / _dim[0];
							var pcv = p0[3] / _dim[1];
							var p0u = p0x   / _dim[0];
							var p0v = p0y   / _dim[1];
							var p1u = p1x   / _dim[0];
							var p1v = p1y   / _dim[1];
							break;
						
						case 1 : 
							var pcu = .5;
							var pcv = .5;
							var p0u = .5 + lengthdir_x(.5, a0);
							var p0v = .5 + lengthdir_y(.5, a0);
							var p1u = .5 + lengthdir_x(.5, a1);
							var p1v = .5 + lengthdir_y(.5, a1);
							break;
							
						case 2 : 
							var pcu = .0;
							var pcv = .0;
							var p0u = a0 / 360;
							var p0v = 1;
							var p1u = a1 / 360;
							var p1v = 1;
							break;
							
					}
					
					draw_vertex_texture( p0x,   p0y,   p0u, p0v );
					draw_vertex_texture( p0[2], p0[3], pcu, pcv );
					draw_vertex_texture( p1x,   p1y,   p1u, p1v );
				
				}
				draw_primitive_end();
				BLEND_NORMAL
				
				matrix_set(matrix_world, MATRIX_IDENTITY);
			surface_reset_shader();
		}
		
		var _outSurf = surface_verify(_outData[0], _dim[0], _dim[1], attrDepth());
		surface_set_shader(_outSurf, sh_path_map_render, true, BLEND.normal);
			shader_set_interpolation(_surf);
			draw_set_color(c_white);
			
			shader_set_2( "uvP",        [1,1]    );
			shader_set_2( "uvS",        [1,1]    );
			shader_set_2( "trimRange",  [0,1]    );
			shader_set_c( "blendColor", ca_white );
			
			if(_caps && _scOr == 1) { // start cap
				switch(_scBl) { case 0 : BLEND_NORMAL; break; case 1 : BLEND_ADD; break; case 2 : BLEND_MAX; break; }
				draw_surface(_outCapS, 0, 0);
				BLEND_NORMAL
			}
			
			if(_cape && _ecOr == 1) { // end cap
				switch(_ecBl) { case 0 : BLEND_NORMAL; break; case 1 : BLEND_ADD; break; case 2 : BLEND_MAX; break; }
				draw_surface(_outCapE, 0, 0);
				BLEND_NORMAL
			}
			
			shader_set_2("uvP",       _uvP);
			shader_set_2("uvS",       _uvS);
			shader_set_2("trimRange", _uvSP? _prng : [0,1]);
			
			matrix_set(matrix_world, trans);
			switch(_blnd) { case 0 : BLEND_NORMAL; break; case 1 : BLEND_ADD; break; case 2 : BLEND_MAX; break; }
			draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_surf));
				var _ind = 0;
				for( var j = 0; j < _sub; j++ ) {
					var a0 = lerp(ast, aed, (j+0) * stp);
					var a1 = lerp(ast, aed, (j+1) * stp);
					
					var sc0 = _scal * (_scaleCurve? _scaleCurve.getFast((j+0) * stp) : 1);
					var sc1 = _scal * (_scaleCurve? _scaleCurve.getFast((j+1) * stp) : 1);
					
					for( var i = 0; i < _pres - 1; i++ ) {
						var p0 = _pnt[i+0];
						var p1 = _pnt[i+1];
						
						var p0dx = lengthdir_x(p0[4], a0) * sc0;
						var p0dy = lengthdir_y(p0[4], a0) * sc0;
						
						var p0x = p0[2] + p0dx * rax + p0dy * rbx;
						var p0y = p0[3] + p0dx * ray + p0dy * rby;
						
						var p1dx = lengthdir_x(p1[4], a0) * sc0;
						var p1dy = lengthdir_y(p1[4], a0) * sc0;
						
						var p1x = p1[2] + p1dx * rax + p1dy * rbx;
						var p1y = p1[3] + p1dx * ray + p1dy * rby;
						
						var p2dx = lengthdir_x(p0[4], a1) * sc1;
						var p2dy = lengthdir_y(p0[4], a1) * sc1;
						
						var p2x = p0[2] + p2dx * rax + p2dy * rbx;
						var p2y = p0[3] + p2dx * ray + p2dy * rby;
						
						var p3dx = lengthdir_x(p1[4], a1) * sc1;
						var p3dy = lengthdir_y(p1[4], a1) * sc1;
						
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
			BLEND_NORMAL
			matrix_set(matrix_world, MATRIX_IDENTITY);
			
			shader_set_2("uvP",       [1,1]);
			shader_set_2("uvS",       [1,1]);
			shader_set_2("trimRange", [0,1]);
			
			if(_caps && _scOr == 0) { // start cap
				switch(_scBl) { case 0 : BLEND_NORMAL; break; case 1 : BLEND_ADD; break; case 2 : BLEND_MAX; break; }
				draw_surface(_outCapS, 0, 0);
				BLEND_NORMAL
			}
			
			if(_cape && _ecOr == 0) { // end cap
				switch(_ecBl) { case 0 : BLEND_NORMAL; break; case 1 : BLEND_ADD; break; case 2 : BLEND_MAX; break; }
				draw_surface(_outCapE, 0, 0);
				BLEND_NORMAL
			}
			
		surface_reset_shader();
		
		return _outData;
	}
} 