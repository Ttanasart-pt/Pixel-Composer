function Node_Surface_Replace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Replace Image";
	preview_channel = 1;
	
	inputs[| 0] = nodeValue("Base Image", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 1] = nodeValue("Target Image", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone )
		.setArrayDepth(1);
	
	inputs[| 2] = nodeValue("Replacement Image", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone )
		.setArrayDepth(1);
	
	inputs[| 3] = nodeValue("Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1 )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	inputs[| 4] = nodeValue("Draw Base Image", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true )
	
	inputs[| 5] = nodeValue("Fast Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true )
	
	outputs[| 0] = nodeValue("Surface Out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Surface",		 true], 0, 1, 2, 
		["Searching",	false], 5, 3, 
		["Render",		false], 4, 
	];
	
	temp_surface = [ surface_create(1, 1) ];
	
	static matchTemplate = function(_index, _surf, _base, _target, _thr, _fst) {
		surface_set_shader(_surf, _fst? sh_surface_replace_fast_find : sh_surface_replace_find, false);
			shader_set_f("dimension",  surface_get_width(_base), surface_get_height(_base));
			shader_set_surface("target",  _target);
			shader_set_f("target_dim",  surface_get_width(_target), surface_get_height(_target));
			shader_set_f("threshold", _thr);
			shader_set_f("index", _index);
			
			BLEND_ADD
			draw_surface_safe(_base);
			BLEND_NORMAL
		surface_reset_shader();
	}
	
	static replaceTemplate = function(_index, _surf, _base, _res, _replace, _thr, _fst) {
		surface_set_shader(_surf, _fst? sh_surface_replace_fast_replace : sh_surface_replace_replace, false, BLEND.normal);
			shader_set_f("dimension",  surface_get_width(_base), surface_get_height(_base));
			shader_set_surface("replace", _replace);
			shader_set_f("replace_dim", surface_get_width(_replace), surface_get_height(_replace));
			shader_set_surface("findRes", _res);
			shader_set_f("index", _index);
			
			draw_surface_safe(_base);
		surface_reset_shader();
	}
	
	static process_data = function(_outSurf, _data, _output_index, _array_index) {
		var _bas = _data[0];
		var _tar = _data[1];
		var _rep = _data[2];
		var _thr = _data[3];
		var _drw = _data[4];
		var _fst = _data[5];
		
		if(!is_array(_tar)) _tar = [ _tar ];
		if(!is_array(_rep)) _rep = [ _rep ];
		
		temp_surface[0] = surface_verify(temp_surface[0], surface_get_width(_bas), surface_get_height(_bas));
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR;
		surface_reset_target();
			
		var amo = array_length(_tar);
		for( var i = 0; i < amo; i++ )
			matchTemplate(i / amo, temp_surface[0], _bas, _tar[i], _thr, _fst);
		
		_outSurf = surface_verify(_outSurf, surface_get_width(_bas), surface_get_height(_bas));
		surface_set_target(_outSurf);
			DRAW_CLEAR;
			if(_drw) draw_surface_safe(_bas);
		surface_reset_target();
			
		var amo = array_length(_rep);
		for( var i = 0; i < amo; i++ )
			replaceTemplate(i / amo, _outSurf, _bas, temp_surface[0], _rep[i], _thr, _fst, _drw);
		return _outSurf;
	}
}