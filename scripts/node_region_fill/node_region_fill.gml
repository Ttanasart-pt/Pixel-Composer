function Node_Region_Fill(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Region Fill";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 1] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	inputs[| 2] = nodeValue("Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 3] = nodeValue("Fill Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 4] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom_range(10000, 99999));
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output",	false], 0, 1, 
		["Fill",	false], 3, 4, 2,
	];
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1) ];
		
	static step = function() {
		var _fill = current_data[3];
		
		inputs[| 2].setVisible(_fill);
		inputs[| 4].setVisible(_fill);
	}
		
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _surf = _data[0];
		var _mask = _data[1];
		
		var _colr = _data[2];
		var _fill = _data[3];
		var _seed = _data[4];
		
		var _sw   = surface_get_width(_surf);
		var _sh   = surface_get_height(_surf)
		
		temp_surface[0] = surface_verify(temp_surface[0], _sw, _sh); 
		temp_surface[1] = surface_verify(temp_surface[1], _sw, _sh);
		
		surface_set_target(temp_surface[0])
			DRAW_CLEAR
		surface_reset_target();
		
		surface_set_target(temp_surface[1])
			DRAW_CLEAR
			draw_surface(_surf, 0, 0);
		surface_reset_target();
		
		var base = 0;
		var amo  = ceil(log2(max(_sw, _sh))) + 1;
		
		repeat(amo) {
			surface_set_shader(temp_surface[base], sh_region_fill_coordinate);
				shader_set_f("dimension", _sw, _sh);
				draw_surface(temp_surface[!base], 0, 0);
			surface_reset_shader();
			
			base = !base;
		}
		
		if(_fill) {
			var _pal = [];
			for( var i = 0; i < array_length(_colr); i++ )
				array_append(_pal, colToVec4(_colr[i]));
				
			surface_set_shader(_outSurf, sh_region_fill_color);
				shader_set_f("colors", _pal);
				shader_set_f("seed",   _seed);
				shader_set_f("colorAmount", array_length(_colr));
				
				draw_surface(temp_surface[base], 0, 0);
			surface_reset_shader();
		} else {
			surface_set_shader(_outSurf);
				draw_surface(temp_surface[base], 0, 0);
			surface_reset_shader();
		}
		
		return _outSurf;
	}
}