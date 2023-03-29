function Node_Surface_Replace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Replace Image";
	preview_channel = 1;
	
	inputs[| 0] = nodeValue("Base image", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 1] = nodeValue("Target image", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 2] = nodeValue("Replacement image", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 3] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	outputs[| 0] = nodeValue("Mapping", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Surface",		 false], 0, 1, 2, 
		["Repalcement",	 false], 3, 
	];
	
	output_display_list = [ 1, 0 ]
	
	temp_surface = [ surface_create(1, 1) ];
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _bas = _data[0];
		var _tar = _data[1];
		var _rep = _data[2];
		var _thr = _data[3];
		
		if(!is_surface(_tar)) return _outSurf;
		if(!is_surface(_rep)) return _outSurf;
		
		if(_output_index == 0) {
			_outSurf = surface_verify(_outSurf, surface_get_width(_bas), surface_get_height(_bas));
		
			surface_set_shader(_outSurf, sh_surface_replace_find);
				DRAW_CLEAR
				shader_set_f("dimension",  surface_get_width(_bas), surface_get_height(_bas));
				shader_set_surface("target",  _tar);
				shader_set_f("target_dim",  surface_get_width(_tar), surface_get_height(_tar));
				shader_set_f("threshold", _thr);
			
				draw_surface_safe(_bas);
			surface_reset_shader();
			
			temp_surface[0] = _outSurf;
			return _outSurf;
		}
		
		if(_output_index == 1) {
			surface_set_shader(_outSurf, sh_surface_replace_replace);
				DRAW_CLEAR
				shader_set_surface("replace", _rep);
				shader_set_f("replace_dim", surface_get_width(_rep), surface_get_height(_rep));
				shader_set_surface("findRes", temp_surface[0]);
			
				draw_surface_safe(_bas);
			surface_reset_shader();
		
			return _outSurf;
		}
	}
}