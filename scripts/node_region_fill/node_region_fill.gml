function Node_Region_Fill(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Region Fill";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 1] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 2] = nodeValue("Fill Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, array_clone(DEF_PALETTE))
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 3] = nodeValue("Fill", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 4] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, seed_random(6))
		.setDisplay(VALUE_DISPLAY._default, { side_button : button(function() { inputs[| 4].setValue(seed_random(6)); }).setIcon(THEME.icon_random, 0, COLORS._main_icon) });
	
	inputs[| 5] = nodeValue("Target Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 6] = nodeValue("Inner only", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "Only fill regions with surrounding pixels.");
	
	inputs[| 7] = nodeValue("Draw original", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "None", "Above", "Behind" ]);
	
	inputs[| 8] = nodeValue("Fill type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Random", "Color map", "Texture map" ]);
	
	inputs[| 9] = nodeValue("Color map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 10] = nodeValue("Texture map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 4, 
		["Surfaces", false], 0, 1, 
		["Fill",	 false], 5, 8, 2, 9, 10, 6, 
		["Render",	 false], 7, 
	];
	
	temp_surface = array_create(3);
		
	static step = function() { #region
		var _filt = getInputData(8);
		
		inputs[|  2].setVisible(_filt == 0);
		inputs[|  9].setVisible(_filt == 1, _filt == 1);
		inputs[| 10].setVisible(_filt == 2, _filt == 2);
	} #endregion
		
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _mask = _data[1];
		
		var _colr = _data[2];
		var _fill = _data[3];
		var _seed = _data[4];
		var _targ = _data[5];
		var _innr = _data[6];
		var _rnbg = _data[7];
		var _filt = _data[8];
		var _cmap = _data[9];
		var _tmap = _data[10];
		
		var _sw = surface_get_width_safe(_surf);
		var _sh = surface_get_height_safe(_surf)
		
		for( var i = 0, n = array_length(temp_surface); i < n; i++ ) {
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh); 
			surface_clear(temp_surface[i]);
		}
		
		#region filter color
			surface_set_shader(temp_surface[1], sh_region_fill_init);
				shader_set_color("targetColor", _targ);
			
				draw_surface_safe(_surf);
			surface_reset_shader();
		#endregion
		
		#region inner region
			var base = 0;
			var amo  = _sw;
		
			if(_innr) {
				repeat( amo ) {
					surface_set_shader(temp_surface[base], sh_region_fill_inner);
						shader_set_f("dimension", _sw, _sh);
				
						draw_surface_safe(temp_surface[!base]);
					surface_reset_shader();
				
					base = !base;
				}
			
				surface_set_shader(temp_surface[2], sh_region_fill_inner_remove);
					draw_surface_safe(temp_surface[!base]);
				surface_reset_shader();
			
			} else {
				surface_set_shader(temp_surface[2], sh_region_fill_inner_remove);
					draw_surface_safe(temp_surface[1]);
				surface_reset_shader();
			}
		#endregion
		
		#region coordinate
			surface_set_shader(temp_surface[base], sh_region_fill_coordinate_init);
				draw_surface_safe(temp_surface[2]);
			surface_reset_shader();
			
			base = !base;
			var amo = _sw + _sh;
		
			repeat( amo ) {
				surface_set_shader(temp_surface[base], sh_region_fill_coordinate);
					shader_set_f("dimension",   _sw, _sh);
					shader_set_surface("base",	temp_surface[2]);
				
					draw_surface_safe(temp_surface[!base]);
				surface_reset_shader();
			
				base = !base;
			}
		
			surface_set_shader(temp_surface[base], sh_region_fill_border);
				shader_set_f("dimension",       _sw, _sh);
				shader_set_surface("original",	_surf);
			
				draw_surface_safe(temp_surface[!base]);
			surface_reset_shader();
		#endregion
		
		var _pal = [];
		for( var i = 0, n = array_length(_colr); i < n; i++ )
			array_append(_pal, colToVec4(_colr[i]));
				
		surface_set_target(_outSurf);
			DRAW_CLEAR
			
			if(_rnbg == 2) draw_surface_safe(_surf); // render original
				
			switch(_filt) {
				case 0 : 
					shader_set(sh_region_fill_color);
						shader_set_f("colors",		_pal);
						shader_set_f("seed",		_seed);
						shader_set_f("colorAmount", array_length(_colr));
						
						draw_surface_safe(temp_surface[base]);
					shader_reset();
					break;
						
				case 1 :
					shader_set(sh_region_fill_map);
						shader_set_surface("colorMap",	_cmap);
						
						draw_surface_safe(temp_surface[base]);
					shader_reset();
					break;
						
				case 2 :
					shader_set(sh_region_fill_rg_map);
						shader_set_surface("textureMap", _tmap);
						
						draw_surface_safe(temp_surface[base]);
					shader_reset();
					break;
			}
				
			if(_rnbg == 1) draw_surface_safe(_surf); // render original
				
		surface_reset_target();
		
		return _outSurf;
	}
}