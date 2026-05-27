function Node_Path_Map(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Map Path";
	
	////- =Output
	newInput( 1, nodeValue_Dimension());
	
	////- =Mapping
	newInput( 3, nodeValue_Int(     "Subdivision", 16 )).setValidator(VV_min(2)).rejectArray();
	
	////- =Transform
	newInput( 8, nodeValue_Vec2(     "Position",  [0,0]   )).setUnitSimple();
	newInput( 9, nodeValue_Anchor(   "Anchor",    [.5,.5] ));
	newInput(10, nodeValue_Rot(      "Rotation",   0      ));
	newInput(11, nodeValue_Vec2(     "Scale",     [1,1]   ));
	
	////- =Rendering
	newInput( 2, nodeValue_Surface( "Texture" ));
	newInput( 7, nodeValue_Vec2(    "UV Position", [0,0] ));
	newInput( 6, nodeValue_Vec2(    "UV Range",    [1,1] ));
	
	////- =Paths
	newInput(12, nodeValue_Range(    "Range", [0,1] ));
	newInput( 4, nodeValue_Slider(   "Shift",  0     ));
	newInput( 5, nodeValue_Bool(     "Invert", false ));
	newInput( 0, nodeValue_PathNode( "Path" )).rejectArray();
	// input 13
		
	newOutput(0, nodeValue_Output("Rendered", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Output",    false ],  1, 
		[ "Mapping",   false ],  3,  
		[ "Transform", false ],  8,  9, 10, 11, 
		[ "Rendering", false ],  2,  6, 
		[ "Paths",     false ], 12,  4,  5,  0,
	];
	
	function createNewInput(index = array_length(inputs)) {
		newInput(index, nodeValue_PathNode( "Path" )).setVisible(true, true);
		array_push(input_display_list, index);
		return inputs[index];
	} setDynamicInput(1);
	
	////- Node
	
	attribute_surface_depth();
	attribute_interpolation();
	
	temp_surface = [ noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		InputDrawOverlay(inputs[0].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) 
			InputDrawOverlay(inputs[i].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _params));	
	}
		
	static update = function() {
		#region data
			var _path = getInputData(0);
			if(_path == noone) return;
			
			var _dim  = getInputData( 1);
			
			var _sub  = getInputData( 3);
			
		    var _pos  = getInputData( 8);
		    var _anc  = getInputData( 9);
		    var _rot  = getInputData(10);
		    var _sca  = getInputData(11);
		    
			var _surf = getInputData( 2);
			var _uvP  = getInputData( 7);
			var _uvS  = getInputData( 6);
			
			var _rng  = getInputData(12);
			var _sft  = getInputData( 4);
			var _inv  = getInputData( 5);
		#endregion
		
		var _pathData = [];
		var _lines = _path.getLineCount();
		for( var i = 0; i < _lines; i++ )
			array_push(_pathData, [_path, i]);
		
		for( var i = input_fix_len, n = array_length(inputs); i < n; i++ ) {
			var _path = getInputData(i);
			if(!is_path(_path)) continue;
			
			var _lamo = _path.getLineCount();
			_lines += _lamo;
			for( var j = 0; j < _lamo; j++ )
				array_push(_pathData, [_path, j]);
		}
		
		if(!is_surface(_surf)) {
			temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1]);
			
			surface_set_shader(temp_surface[0], sh_coord);
				draw_empty();
			surface_reset_shader()
			
			_surf = temp_surface[0];
		}
		
		var _pnt = array_create(_lines + 1);
		var _isb = .9999 / (_sub - 1);
		var _pp  = new __vec2P();
		
		for( var i = 0; i < _lines; i++ ) {
			var _pathD = _pathData[i];
			var _p   = array_create(_sub + 1);
			var _ind = 0;
			
			for( var j = 0; j <= _sub; j++ ) {
				var _prog = clamp(frac(lerp(_rng[0], _rng[1], j * _isb) + _sft), 0., 0.9999);
				if(_inv) _prog = 1 - _prog;
				
				_pp = _pathD[0].getPointRatio(_prog, _pathD[1], _pp);
				_p[_ind++] = [ _pp.x, _pp.y ];
			}
			
			_pnt[i] = _p;
		}
		
		var _out = outputs[0].getValue();
		    _out = surface_verify(_out, _dim[0], _dim[1], attrDepth());
		
		var _ind = 0;
		
		surface_set_shader(_out, sh_path_map_render);
			shader_set_interpolation(_surf);
			
			draw_set_color(c_white);
			shader_set_2("uvP", _uvP);
			shader_set_2("uvS", _uvS);
			
			var ancx = _anc[0] * _dim[0];
			var ancy = _anc[1] * _dim[1];
			
			var trans = matrix_compose(
				matrix_transform_2d(-ancx, -ancy),
				matrix_transform_2d(_pos[0], _pos[1], _rot, _sca[0], _sca[1]),
				matrix_transform_2d(ancx, ancy),
			);
			matrix_set(matrix_world, trans);
			
			draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_surf));
				for( var j = 0; j < _sub   - 1; j++ )
				for( var i = 0; i < _lines - 1; i++ ) {
					var p0 = _pnt[i + 0][j + 0];
					var p1 = _pnt[i + 1][j + 0];
					var p2 = _pnt[i + 0][j + 1];
					var p3 = _pnt[i + 1][j + 1];
				
					var p0u = (j + 0) / (_sub - 1), p0v = (i + 0) / (_lines - 1);
					var p1u = (j + 0) / (_sub - 1), p1v = (i + 1) / (_lines - 1);
					var p2u = (j + 1) / (_sub - 1), p2v = (i + 0) / (_lines - 1);
					var p3u = (j + 1) / (_sub - 1), p3v = (i + 1) / (_lines - 1);
				
					draw_vertex_texture(p0[0], p0[1], p0u, p0v);
					draw_vertex_texture(p1[0], p1[1], p1u, p1v);
					draw_vertex_texture(p2[0], p2[1], p2u, p2v);
					
					draw_vertex_texture(p1[0], p1[1], p1u, p1v);
					draw_vertex_texture(p2[0], p2[1], p2u, p2v);
					draw_vertex_texture(p3[0], p3[1], p3u, p3v);
					
					if(_ind++ > 64) {
						_ind = 0;
						draw_primitive_end();
						draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(_surf));
					}
				}
			draw_primitive_end();
			
			matrix_set(matrix_world, MATRIX_IDENTITY);
			
		surface_reset_shader();
		
		outputs[0].setValue(_out);
	}
} 