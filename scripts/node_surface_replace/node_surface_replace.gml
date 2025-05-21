function Node_Surface_Replace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Replace Image";
	
	newInput(0, nodeValue_Surface("Base Image"));
	
	newInput(1, nodeValue_Surface("Target Image"))
		.setArrayDepth(1);
	
	newInput(2, nodeValue_Surface("Replacement Image"))
		.setArrayDepth(1);
	
	newInput(3, nodeValue_Float("Color Threshold", 0.1, "How similiar the color need to be in order to be count as matched." ))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(4, nodeValue_Bool("Draw Base Image", true ));
	
	newInput(5, nodeValue_Bool("Fast Mode", true ));
	
	newInput(6, nodeValue_Float("Pixel Threshold", 0.1, "How many pixel need to me matched to replace with replacement image." ))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(7, nodeValue_Enum_Scroll("Array mode",  0, { data: [ "Match index", "Randomized" ], update_hover: false }));
	
	newInput(8, nodeValueSeed(self));
	
	newInput(9, nodeValue_Bool("Replace Empty", false))
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [
		["Surfaces",	 true], 0, 1, 2, 7, 8, 
		["Searching",	false], 5, 3, 6, 
		["Render",		false], 4, 9, 
	];
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1), surface_create(1, 1) ];
	
	static matchTemplate = function(_index, _surf, _base, _target, _cthr, _pthr, _fst) {
		
		surface_set_shader(_surf, _fst? sh_surface_replace_fast_find : sh_surface_replace_find, false);
			shader_set_f("dimension", surface_get_width_safe(_base), surface_get_height_safe(_base));
			
			shader_set_surface("target", _target);
			shader_set_f("targetDimension", surface_get_width_safe(_target), surface_get_height_safe(_target));
			
			shader_set_f("colorThreshold", _cthr);
			shader_set_f("pixelThreshold", _pthr);
			shader_set_f("index", _index);
			shader_set_i("mode", getInputData(7));
			shader_set_f("seed", getInputData(8));
			
			var dest = getInputData(2);
			var size = is_array(dest)? array_length(dest) : 1;
			shader_set_f("size", size);
			
			BLEND_ADD
			draw_surface_safe(_base);
			BLEND_NORMAL
		surface_reset_shader();
	}
	
	static replaceTemplate = function(_index, _base, _res, _replace, _fst) {
		
		shader_set(_fst? sh_surface_replace_fast_replace : sh_surface_replace_replace);
		surface_set_target_ext(0, temp_surface[1]);
		surface_set_target_ext(1, temp_surface[2]);
		
			shader_set_f("dimension",  surface_get_width_safe(_base), surface_get_height_safe(_base));
			
			shader_set_surface("replace", _replace);
			shader_set_f("replace_dim", surface_get_width_safe(_replace), surface_get_height_safe(_replace));
			
			shader_set_surface("findRes", _res);
			shader_set_f("index", _index);
			
			draw_surface_safe(_base);
		surface_reset_shader();
	}
	
	static step = function() {
		var _mode = getInputData(7);
		inputs[8].setVisible(_mode == 1);
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _bas = _data[0];
		var _tar = _data[1];
		var _rep = _data[2];
		var _drw = _data[4];
		var _fst = _data[5];
		
		var _cthr = _data[3];
		var _pthr = _data[6];
		var _oalp = _data[9];
		
		if(!is_array(_tar)) _tar = [ _tar ]; 
		if(!is_array(_rep)) _rep = [ _rep ];
		
		var _sw = surface_get_width_safe(_bas);
		var _sh = surface_get_height_safe(_bas);
		
		for (var i = 0, n = array_length(temp_surface); i < n; i++) {
			temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
			surface_clear(temp_surface[i]);
		}
		
		var tamo = array_length(_tar);
		var ramo = array_length(_rep);
		
		for( var i = 0; i < tamo; i++ ) matchTemplate(i / tamo, temp_surface[0], _bas, _tar[i], _cthr, _pthr, _fst);
		// return temp_surface[0];
		
		var amo = max(tamo, ramo);
		for( var i = 0; i < amo; i++ ) {
			var _ri = i % ramo;
			replaceTemplate(_ri / amo, _bas, temp_surface[0], _rep[_ri], _fst);
		}
		
		_outSurf = surface_verify(_outSurf, _sw, _sh);
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_ALPHA
			if(_drw) draw_surface_safe(_bas);
			if(_oalp) {
				BLEND_SUBTRACT
				draw_surface_safe(temp_surface[2]);
				BLEND_ALPHA
			}
			draw_surface_safe(temp_surface[1]);
		surface_reset_target();
		
		return _outSurf;
	}
}