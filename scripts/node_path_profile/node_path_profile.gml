function Node_Path_Profile(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Draw Path Profile";
	
	newInput(0, nodeValue_Dimension(self));
	
	newInput(1, nodeValue_PathNode("Path", self, noone ))
		.setVisible(true, true);
	
	newInput(2, nodeValue_Int("Resolution", self, 64 ));
	
	newInput(3, nodeValue_Enum_Button("Side", self,  0 , [ "L", "R", "T", "D" ]));
	
	newInput(4, nodeValue_Bool("Mirror", self, false ));
	
	newInput(5, nodeValue_Color("Color", self, cola(c_white) ));
	
	newInput(6, nodeValue_Bool("Anti Aliasing", self, false ));
	
	newInput(7, nodeValue_Bool("Background", self, false ));
	
	newInput(8, nodeValue_Color("BG Color", self, cola(c_black) ));
	
	newInput(9, nodeValue_Enum_Button("Fill", self, 0, [ "Odd", "All" ] ));
	
	newOutput(0, nodeValue_Output("Output", self, VALUE_TYPE.surface, noone ));
	
	input_display_list = [ 0,
		[ "Profile",    false ], 1, 2, 
		[ "Render",     false ], 9, 3, 5, 4, 6, 
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
		var _mode = _data[9];
		
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
			shader_set_i("mode",	   _mode);
			shader_set_color("bgColor",_bgC);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
}