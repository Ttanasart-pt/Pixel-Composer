function Node_Shadow(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Shadow";
	
	inputs[| 0] = nodeValue_Surface("Surface in", self);
	inputs[| 1] = nodeValue_Color("Color",   self, c_black);
	
	inputs[| 2] = nodeValue_Float("Strength", self, .5)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 2, 0.01] });
	
	inputs[| 3] = nodeValue_Vector("Shift", self, [ 4, 4 ])
		.setUnitRef(function(index) { return getDimension(index); });
	
	inputs[| 4] = nodeValue_Float("Grow", self, 3)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 0.1] });
	
	inputs[| 5] = nodeValue_Float("Blur", self, 3)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] });
	
	inputs[| 6] = nodeValue_Surface("Mask", self);
	
	inputs[| 7] = nodeValue_Float("Mix", self, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 8] = nodeValue_Bool("Active", self, true);
		active_index = 8;
	
	__init_mask_modifier(6); // inputs 9, 10
	
	inputs[| 11] = nodeValue_Enum_Scroll("Positioning", self,  0, [ "Shift", "Light" ]);
	
	inputs[| 12] = nodeValue_Vector("Light Position", self, [ 0, 0 ])
		.setUnitRef(function(index) { return getDimension(index); });
		
	outputs[| 0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 8, 
		["Surfaces", true], 0, 6, 7, 9, 10, 
		["Shadow",	false], 1, 2, 11, 3, 12, 4, 5, 
	];
	
	surface_blur_init();
	attribute_surface_depth();
		
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _surf = outputs[| 0].getValue();
		var _hov  = false;
		
		if(is_array(_surf)) {
			if(array_length(_surf) == 0) return _hov;
			_surf = _surf[preview_index];
		}
		
		var ww = surface_get_width_safe(_surf) * _s;
		var hh = surface_get_height_safe(_surf) * _s;
		
		var _typ = getSingleValue(11);
		
			 if(_typ == 0) { var hv = inputs[|  3].drawOverlay(hover, active, _x + ww / 2, _y + hh / 2, _s, _mx, _my, _snx, _sny); _hov |= hv; }
		else if(_typ == 1) { var hv = inputs[| 12].drawOverlay(hover, active, _x,          _y,          _s, _mx, _my, _snx, _sny); _hov |= hv; }
		
		return _hov;
	}
	
	static step = function() { 
		__step_mask_modifier();
		
		var _typ = getSingleValue(11);
		
		inputs[|  3].setVisible(_typ == 0);
		inputs[| 12].setVisible(_typ == 1);
	} 
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
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
		var _shax = _shf[0], 
		var _shay = _shf[1];
		
		if(_posi == 1) {
			_shax = _dim[0] / 2 - _lgh[0];
			_shay = _dim[1] / 2 - _lgh[1];
		}
		
		surface_set_shader(pass1, sh_outline_only);
			shader_set_f("dimension",   _dim);
			shader_set_f("borderSize",  _border);
			shader_set_f("borderColor", [ 1., 1., 1., 1. ]);
				
			draw_surface_safe(_data[0], _shax, _shay);
		surface_reset_shader();
		
		surface_set_target(_outSurf);
			DRAW_CLEAR
			BLEND_OVERRIDE
				draw_surface_ext_safe(surface_apply_gaussian(pass1, _size, false, cl), 0, 0, 1, 1, 0, cl, _stre * _color_get_alpha(cl));
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