function Node_RM_Terrain(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "RM Terrain";
	
	newInput(0, nodeValue_Dimension());
	
	newInput(1, nodeValue_Surface("Surface"));
	
	newInput(2, nodeValue_Vec3("Position", [ 0, 0, 0 ]));
	
	newInput(3, nodeValue_Vec3("Rotation", [ 30, 45, 0 ]));
	
	newInput(4, nodeValue_Float("Scale", 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	newInput(5, nodeValue_Float("FOV", 30))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 90, 1 ] });
	
	newInput(6, nodeValue_Vec2("View Range", [ 0, 6 ]));
	
	newInput(7, nodeValue_Float("BG Bleed", 1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(8, nodeValue_Color("Ambient", ca_white));
	
	newInput(9, nodeValue_Float("Height", 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	newInput(10, nodeValue_Bool("Tile", true))
	
	newInput(11, nodeValue_Surface("Texture"));
	
	newInput(12, nodeValue_Color("Background", ca_black));
	
	newInput(13, nodeValue_Surface("Reflection"));
	
	newInput(14, nodeValue_Vec3("Sun Position", [ .5, 1, .5 ]));
	
	newInput(15, nodeValue_Float("Shadow", 0.2))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 0,
		["Extrusion", false], 1, 9, 10,
		["Textures",  false], 11, 13, 
		["Transform", false], 2, 3, 4, 
		["Camera",    false], 5, 6, 
		["Render",    false], 12, 7, 8,
		["Light",     false], 14, 15, 
	];
	
	temp_surface = [ noone, noone, noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {}
	
	static step = function() {
		
	}
	
	static processData = function(_outSurf, _data, _array_index = 0) {
		var _dim  = _data[0];
		var _surf = _data[1];
		
		var _pos  = _data[2];
		var _rot  = _data[3];
		var _sca  = _data[4];
		
		var _fov  = _data[5];
		var _rng  = _data[6];
		
		var _dpi  = _data[7];
		var _amb  = _data[8];
		var _thk  = _data[9];
		var _tile = _data[10];
		var _text = _data[11];
		var _bgc  = _data[12];
		var _refl = _data[13];
		var _sun  = _data[14];
		var _sha  = _data[15];
		
		_outSurf = surface_verify(_outSurf, _dim[0], _dim[1]);
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++)
			temp_surface[i] = surface_verify(temp_surface[i], 8192, 8192);
		
		var tx = 1024;
		surface_set_shader(temp_surface[0]);
			draw_surface_stretched_safe(_surf, tx * 0, tx * 0, tx, tx);
			draw_surface_stretched_safe(_text, tx * 1, tx * 0, tx, tx);
			draw_surface_stretched_safe(_refl, tx * 2, tx * 0, tx, tx);
		surface_reset_shader();
		
		gpu_set_texfilter(true);
		
		surface_set_shader(_outSurf, sh_rm_terrain);
		
			for (var i = 0, n = array_length(temp_surface); i < n; i++)
				shader_set_surface($"texture{i}", temp_surface[i]);
			
			shader_set_i("shape",       1);
			shader_set_i("tile",        _tile);
			shader_set_i("useTexture",  is_surface(_text));
			shader_set_3("position",    _pos);
			shader_set_3("rotation",    _rot);
			shader_set_f("objectScale", _sca);
			shader_set_f("thickness",   _thk);
			
			shader_set_f("fov",         _fov);
			shader_set_2("viewRange",   _rng);
			shader_set_f("depthInt",    _dpi);
			
			shader_set_3("sunPosition", _sun);
			shader_set_f("shadow",      _sha);
			
			shader_set_color("background", _bgc);
			shader_set_color("ambient",    _amb);
			
			draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _dim[0], _dim[1]);
		surface_reset_shader();
		
		return _outSurf; 
	}
} 
