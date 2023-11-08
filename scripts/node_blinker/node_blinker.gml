function Node_Blinker(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Blinker";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 2] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, irandom_range( 100000, 999999 ))
	
	inputs[| 3] = nodeValue("Amount", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
		
	inputs[| 4] = nodeValue("Target Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette);
		
	inputs[| 5] = nodeValue("Light Colors", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette);
	
	inputs[| 6] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 6;
		
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	input_display_list = [ 6, 
		["Surfaces",	false], 0, 1, 
		["Blink",		false], 2, 3, 4, 5, 
	]
	
	temp_surface = [ surface_create( 1, 1 ) ];
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		//var _surf = _data[0];
		//var _mask = _data[1];
		//var _seed = _data[2];
		//var _amou = _data[3];
		//var _trgC = _data[4];
		//var _ligC = _data[5];
		
		//if(!is_surface(_surf)) return _outSurf;
		
		//temp_surface[0] = surface_verify(temp_surface[0], surface_get_width_safe(_outSurf), surface_get_height_safe(_outSurf));
		
		//surface_set_shader(temp_surface[0], sh_blink_extract);
		//	draw_surface_safe(_surf);
		//surface_reset_shader();
		
		//surface_set_shader(_outSurf, sh_blink_replace);
		//	draw_surface_safe(temp_surface[0]);
		//surface_reset_shader();
		
		//return _outSurf;
	}
}