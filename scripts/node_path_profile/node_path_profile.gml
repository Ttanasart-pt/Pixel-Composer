function Node_Path_Profile(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Path Profile";
	
	inputs[| 0] = nodeValue("Dimension", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, DEF_SURF )
		.setDisplay(VALUE_DISPLAY.vector);
	
	inputs[| 1] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.pathnode, noone )
		.setVisible(true, true);
	
	inputs[| 2] = nodeValue("Resolution", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 64 );
	
	inputs[| 3] = nodeValue("Side", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0 )
		.setDisplay(VALUE_DISPLAY.enum_button, [ "L", "R", "T", "D" ]);
	
	inputs[| 4] = nodeValue("Mirror", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| 5] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white );
	
	inputs[| 6] = nodeValue("Anti Aliasing", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| 7] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false );
	
	inputs[| 8] = nodeValue("BG Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_black );
	
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone );
	
	input_display_list = [ 0,
		[ "Profile",    false ], 1, 2, 
		[ "Render",     false ], 3, 5, 4, 6, 
		[ "Background", false, 7 ], 8, 
	];
	
	brush_prev = noone;
	brush_next_dist = 0;
	
	temp_surface = [ surface_create(1, 1) ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) { #region
		var _path = getInputData(1);
		if(_path && struct_has(_path, "drawOverlay")) _path.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny);
	} #endregion
	
	static processData = function(_outSurf, _data, _output_index, _array_index = 0) { #region
		var _dim  = _data[0];
		var _path = _data[1];
		var _res  = _data[2]; _res = max(_res, 2);
		var _side = _data[3];
		var _mirr = _data[4];
		var _colr = _data[5];
		var _aa   = _data[6];
		var _bg   = _data[7];
		var _bgC  = _data[8];
		
		if(_path == noone) return;
		
		var _points = array_create(_res * 2);
		var _p = new __vec2();
		
		for( var i = 0; i < _res; i++ ) {
			_p = _path.getPointRatio(i / _res, 0, _p);
			
			_points[i * 2 + 0] = _p.x;
			_points[i * 2 + 1] = _p.y;
		}
		
		surface_set_shader(_outSurf, sh_path_fill_profile, true, _bg? BLEND.alphamulp : BLEND.over);
			if(_bg) draw_clear_alpha(_bgC, color_get_alpha(_bgC));
			
			shader_set_f("dimension",  _dim);
			shader_set_f("path",       _points);
			shader_set_i("pathLength", _res);
			shader_set_i("side",	   _side);
			shader_set_i("mirror",	   _mirr);
			shader_set_i("aa",		   _aa);
			shader_set_color("color",  _colr);
			shader_set_i("bg",		   _bg);
			shader_set_color("bgColor",_bgC);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}