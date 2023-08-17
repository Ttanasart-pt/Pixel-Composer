function Node_Surface_Replace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Replace Image";
	preview_channel = 1;
	
	inputs[| 0] = nodeValue("Base Image", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone );
	
	inputs[| 1] = nodeValue("Target Image", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone )
		.setArrayDepth(1);
	
	inputs[| 2] = nodeValue("Replacement Image", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone )
		.setArrayDepth(1);
	
	inputs[| 3] = nodeValue("Color Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1, "How similiar the color need to be in order to be count as matched." )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	inputs[| 4] = nodeValue("Draw Base Image", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true )
	
	inputs[| 5] = nodeValue("Fast Mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true )
	
	inputs[| 6] = nodeValue("Pixel Threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1, "How many pixel need to me matched to replace with replacement image." )
		.setDisplay(VALUE_DISPLAY.slider, [ 0, 1, 0.01 ]);
	
	inputs[| 7] = nodeValue("Array mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Match index", "Randomized" ], { update_hover: false });
	
	inputs[| 8] = nodeValue("Seed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, irandom_range(10000, 99999));
	
	outputs[| 0] = nodeValue("Surface Out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [
		["Output", 		 true], 0, 1, 2, 7, 8, 
		["Searching",	false], 5, 3, 6, 
		["Render",		false], 4, 
	];
	
	temp_surface = [ surface_create(1, 1) ];
	
	static matchTemplate = function(_index, _surf, _base, _target, _cthr, _pthr, _fst) {
		surface_set_shader(_surf, _fst? sh_surface_replace_fast_find : sh_surface_replace_find, false);
			shader_set_f("dimension", surface_get_width(_base), surface_get_height(_base));
			
			shader_set_surface("target", _target);
			shader_set_f("targetDimension", surface_get_width(_target), surface_get_height(_target));
			
			//print($"{surface_get_width(_base)}, {surface_get_height(_base)} | {surface_get_width(_target)}, {surface_get_height(_target)}");
			
			shader_set_f("colorThreshold", _cthr);
			shader_set_f("pixelThreshold", _pthr);
			shader_set_f("index", _index);
			shader_set_i("mode", inputs[| 7].getValue());
			shader_set_f("seed", inputs[| 8].getValue());
			
			var dest = inputs[| 2].getValue();
			var size = is_array(dest)? array_length(dest) : 1;
			shader_set_f("size", size);
			
			BLEND_ADD
			draw_surface_safe(_base);
			BLEND_NORMAL
		surface_reset_shader();
	}
	
	static replaceTemplate = function(_index, _surf, _base, _res, _replace, _fst) {
		surface_set_shader(_surf, _fst? sh_surface_replace_fast_replace : sh_surface_replace_replace, false, BLEND.normal);
			shader_set_f("dimension",  surface_get_width(_base), surface_get_height(_base));
			shader_set_surface("replace", _replace);
			shader_set_f("replace_dim", surface_get_width(_replace), surface_get_height(_replace));
			shader_set_surface("findRes", _res);
			shader_set_f("index", _index);
			
			draw_surface_safe(_base);
		surface_reset_shader();
	}
	
	static step = function() {
		var _mode = inputs[| 7].getValue();
		inputs[| 8].setVisible(_mode == 1);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _bas = _data[0];
		var _tar = _data[1];
		var _rep = _data[2];
		var _drw = _data[4];
		var _fst = _data[5];
		
		var _cthr = _data[3];
		var _pthr = _data[6];
		
		if(!is_array(_tar)) _tar = [ _tar ]; 
		if(!is_array(_rep)) _rep = [ _rep ];
		
		temp_surface[0] = surface_verify(temp_surface[0], surface_get_width(_bas), surface_get_height(_bas));
		surface_set_target(temp_surface[0]);
			DRAW_CLEAR;
		surface_reset_target();
			
		var amo = array_length(_tar);
		for( var i = 0; i < amo; i++ )
			matchTemplate(i / amo, temp_surface[0], _bas, _tar[i], _cthr, _pthr, _fst);
		//return temp_surface[0];
		
		_outSurf = surface_verify(_outSurf, surface_get_width(_bas), surface_get_height(_bas));
		surface_set_target(_outSurf);
			DRAW_CLEAR;
			if(_drw) draw_surface_safe(_bas);
		surface_reset_target();
			
		var amo = array_length(_rep);
		for( var i = 0; i < amo; i++ )
			replaceTemplate(i / amo, _outSurf, _bas, temp_surface[0], _rep[i], _fst, _drw);
		return _outSurf;
	}
}