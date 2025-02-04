function Node_Shadow_Cast(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Cast Shadow";
	batch_output = false;
	
	newInput(0, nodeValue_Surface("Background", self));
	
	newInput(1, nodeValue_Surface("Solid", self));
	
	newInput(2, nodeValue_Vec2("Light Position", self, [ 0, 0 ]))
		.setUnitRef(function(index) { 
			var _surf = getInputData(0);
			if(is_array(_surf) && array_length(_surf) == 0)
				return [1, 1];
				
			if(is_array(_surf))
				_surf = _surf[0];
				
			if(!is_surface(_surf))
				return [1, 1];
			
			return [ surface_get_width_safe(_surf), surface_get_height_safe(_surf) ];
		}, VALUE_UNIT.reference);
		
	newInput(3, nodeValue_Float("Soft light radius", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 2, 0.01] });
	
	newInput(4, nodeValue_Int("Light density", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 0.1] });
	
	newInput(5, nodeValue_Enum_Scroll("Light type", self,  0, [ new scrollItem("Point", s_node_shadow_type, 0), 
												                new scrollItem("Sun",   s_node_shadow_type, 1) ]));
	
	newInput(6, nodeValue_Color("Ambient color", self, cola(c_grey)));
	
	newInput(7, nodeValue_Color("Light color", self, cola(c_white)));
	
	newInput(8, nodeValue_Float("Light radius", self, 16));
	
	newInput(9, nodeValue_Bool("Render solid", self, true));
	
	newInput(10, nodeValue_Bool("Use BG color", self, false, "If checked, background color will be used as shadow caster."));
	
	newInput(11, nodeValue_Float("BG threshold", self, 0.1))
		.setDisplay(VALUE_DISPLAY.slider);
	
	newInput(12, nodeValue_Float("Light intensity", self, 1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 2, 0.01] });
	
	newInput(13, nodeValue_Int("Banding", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 0.1] });
	
	newInput(14, nodeValue_Enum_Scroll("Attenuation", self,  0, [ new scrollItem("Quadratic",			s_node_curve_type, 0),
																  new scrollItem("Invert quadratic",	s_node_curve_type, 1),
																  new scrollItem("Linear",			    s_node_curve_type, 2), ]))
		.setTooltip("Control how light fade out over distance.");
	
	newInput(15, nodeValue_Int("Ambient occlusion", self, 0))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 0.1] });
		
	newInput(16, nodeValue_Float("Ambient occlusion strength", self, 0.1))
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.5, 0.001] });
	
	newInput(17, nodeValue_Bool("Active", self, true));
		active_index = 17;
	
	newOutput(0, nodeValue_Output("Surface Out", self, VALUE_TYPE.surface, noone));
	
	newOutput(1, nodeValue_Output("Light mask", self, VALUE_TYPE.surface, noone));
	
	input_display_list = [ 17, 
		["Surfaces",		   true], 0, 1, 
		["BG Shadow Caster",   true, 10], 11,
		["Light",			  false], 5, 12, 8, 2,
		["Soft Light",		  false], 4, 3, 
		["Render",			  false], 13, 14, 7, 6, 9, 
		["Ambient Occlusion", false], 15, 16,
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		PROCESSOR_OVERLAY_CHECK
		
		var _hov = false;
		var  hv  = inputs[2].drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny); _hov |= hv;
		if(array_length(current_data) != array_length(inputs)) return _hov;
		
		var _type = current_data[5];
		if(_type == 0) {
			var pos = current_data[2];
			var px = _x + pos[0] * _s;
			var py = _y + pos[1] * _s;
			
			var hv = inputs[8].drawOverlay(hover, active, px, py, _s, _mx, _my, _snx, _sny, 0, 1 / 4); _hov |= hv;
		}
		
		return _hov;
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _bg    = _data[0];
		var _solid = _data[1];
		var _pos   = _data[2];
		var _rad   = _data[3];
		var _den   = _data[4];
		var _type  = _data[5];
		var _lamb  = _data[6];
		var _lclr  = _data[7];
		var _lrad  = _data[8];
		var _sol   = _data[9];
		var _int   = _data[12];
		var _band  = _data[13];
		var _attn  = _data[14];
		var _ao    = _data[15];
		var _ao_str= _data[16];
		
		var _bg_use = _data[10];
		var _bg_thr = _data[11];
		
		inputs[8].setVisible(_type == 0);
		
		if(!is_surface(_bg)) return _outSurf;
		
		surface_set_shader(_outSurf, sh_shadow_cast);
			shader_set_f("dimension",         surface_get_width_safe(_bg), surface_get_height_safe(_bg));
			shader_set_2("lightPos",         _pos);
			shader_set_color("lightAmb",     _lamb);
			shader_set_color("lightClr",     _lclr);
			shader_set_f("lightRadius",      _rad);
			shader_set_f("pointLightRadius", _lrad);
			shader_set_f("lightDensity",     _den);
			shader_set_i("lightType",        _type);
			shader_set_i("renderSolid",      _sol);
			shader_set_f("lightInt",         _int);
			shader_set_f("lightBand",        _band);
			shader_set_f("lightAttn",        _attn);
			shader_set_f("ao",               _ao);
			shader_set_f("aoStr",            _ao_str);
			
			shader_set_i("mask",             _output_index);
			shader_set_i("bgUse",            _bg_use);
			shader_set_f("bgThres",          _bg_thr);
			
			shader_set_i("useSolid",         is_surface(_solid));
			shader_set_surface("solid",      _solid);
				
			draw_surface_safe(_bg);
		surface_reset_shader();
		
		return _outSurf;
	}
}