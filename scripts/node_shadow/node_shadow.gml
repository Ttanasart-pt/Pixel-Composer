function Node_Shadow(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shadow";
	
	newInput(0, nodeValue_Surface("Surface In"));
	newInput(1, nodeValue_Color("Color", ca_black));
	
	newInput(2, nodeValue_Slider("Strength", .5, [ 0, 2, 0.01] ));
	
	newInput(3, nodeValue_Vec2("Shift", [ 4, 4 ]))
		.setUnitRef(function(index) { return getDimension(index); });
	
	newInput(4, nodeValue_Slider("Grow", 3, [0, 16, 0.1] ));
	
	newInput(5, nodeValue_Slider("Blur", 3, [1, 16, 0.1] ));
	
	newInput(6, nodeValue_Surface("Mask"));
	
	newInput(7, nodeValue_Slider("Mix", 1));
	
	newActiveInput(8);
	
	__init_mask_modifier(6, 9); // inputs 9, 10
	
	newInput(11, nodeValue_Enum_Scroll("Positioning",  0, [ "Shift", "Light" ]));
	
	newInput(12, nodeValue_Vec2("Light Position", [ 0, 0 ]))
		.setUnitRef(function(index) { return getDimension(index); });
		
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ 8, 
		["Surfaces", true], 0, 6, 7, 9, 10, 
		["Shadow",	false], 1, 2, 11, 3, 12, 4, 5, 
	];
	
	surface_blur_init();
	attribute_surface_depth();
		
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		var _surf = outputs[0].getValue();
		
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return w_hovering;
			_surf = _surf[preview_index];
		}
		
		var ww = surface_get_width_safe(_surf) * _s;
		var hh = surface_get_height_safe(_surf) * _s;
		
		var _typ = getSingleValue(11);
		
			 if(_typ == 0) InputDrawOverlay(inputs[ 3].drawOverlay(w_hoverable, active, _x + ww / 2, _y + hh / 2, _s, _mx, _my, _snx, _sny));
		else if(_typ == 1) InputDrawOverlay(inputs[12].drawOverlay(w_hoverable, active, _x,          _y,          _s, _mx, _my, _snx, _sny));
		
		return w_hovering;
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf   = _data[0];
		var cl      = _data[1];
		var _stre   = _data[2];
		var _border = _data[4];
		var _size   = _data[5];
		
		var _posi   = _data[11];
		var _shf    = _data[ 3];
		var _lgh    = _data[12];
		var _dim    = surface_get_dimension(_surf);
		
		var pass1 = surface_create_valid(_dim[0], _dim[1], attrDepth());	
		var _shax = _shf[0]; 
		var _shay = _shf[1];
		
		if(_posi == 1) {
			_shax = _dim[0] / 2 - _lgh[0];
			_shay = _dim[1] / 2 - _lgh[1];
		}
		
		inputs[ 3].setVisible(_posi == 0);
		inputs[12].setVisible(_posi == 1);
		
		surface_set_shader(pass1, sh_outline_only);
			shader_set_f("dimension",   _dim);
			shader_set_f("borderSize",  _border);
			shader_set_f("borderColor", [ 1., 1., 1., 1. ]);
				
			draw_surface_safe(_data[0], _shax, _shay);
		surface_reset_shader();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE
				var _s = surface_apply_gaussian(pass1, _size, false, cl, 2);
				draw_surface_ext_safe(_s, 0, 0, 1, 1, 0, cl, _stre * _color_get_alpha(cl));
			BLEND_ALPHA_MULP
				draw_surface_safe(_surf);
			BLEND_NORMAL
		surface_reset_target();
		
		surface_free(pass1);
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply(_data[0], _outSurf, _data[6], _data[7]);
		
		return _outSurf;
	}
}