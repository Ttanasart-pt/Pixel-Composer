function Node_Path_Map(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Map Path";
	
	////- =Mapping
	newInput( 1, nodeValue_Dimension());
	newInput( 2, nodeValue_Surface( "Texture" ));
	newInput( 3, nodeValue_Int(     "Subdivision", 16 )).setValidator(VV_min(2)).rejectArray();
	newInput( 6, nodeValue_Vec2(    "UV Range", [1,1] ));
	
	////- =Paths
	newInput( 4, nodeValue_Slider(   "Shift",  0     ));
	newInput( 5, nodeValue_Bool(     "Invert", false ));
	newInput( 0, nodeValue_PathNode( "Path" )).rejectArray();
	// input 7
		
	newOutput(0, nodeValue_Output("Rendered", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 
		[ "Mapping", false ],  1,  2,  3,  6, 
		[ "Paths",   false ],  4,  5,  0,
	];
	
	function createNewInput(index = array_length(inputs)) {
		newInput(index, nodeValue_PathNode( "Path" )).setVisible(true, true);
		array_push(input_display_list, index);
		return inputs[index];
	} setDynamicInput(1);
	
	////- Node
	
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
			
			var _dim  = getInputData(1);
			var _surf = getInputData(2);
			var _sub  = getInputData(3);
			var _uv   = getInputData(6);
			
			var _sft  = getInputData(4);
			var _inv  = getInputData(5);
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
				var _prog = clamp(frac(j * _isb + _sft), 0., 0.9999);
				if(_inv) _prog = 1 - _prog;
				
				_pp = _pathD[0].getPointRatio(_prog, _pathD[1], _pp);
				_p[_ind++] = [ _pp.x, _pp.y ];
			}
			
			_pnt[i] = _p;
		}
		
		var _out = outputs[0].getValue();
		    _out = surface_verify(_out, _dim[0], _dim[1])
		
		var _ind = 0;
		
		surface_set_shader(_out, sh_path_map_render);
			draw_set_color(c_white);
			shader_set_2("uv", _uv);
			
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
		surface_reset_shader();
		
		outputs[0].setValue(_out);
	}
} 