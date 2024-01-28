function Node_Shadow_Cast(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Cast Shadow";
	
	inputs[| 0] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Solid", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 2] = nodeValue("Light Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { 
			var _surf = getInputData(0);
			if(is_array(_surf) && array_length(_surf) == 0)
				return [1, 1];
				
			if(is_array(_surf))
				_surf = _surf[0];
				
			if(!is_surface(_surf))
				return [1, 1];
			
			return [surface_get_width_safe(_surf), surface_get_height_safe(_surf)];
		}, VALUE_UNIT.reference);
		
	inputs[| 3] = nodeValue("Soft light radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 2, 0.01] });
	
	inputs[| 4] = nodeValue("Light density", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 1] });
	
	inputs[| 5] = nodeValue("Light type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ new scrollItem("Point", s_node_shadow_type, 0), 
												 new scrollItem("Sun",   s_node_shadow_type, 1) ]);
	
	inputs[| 6] = nodeValue("Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey);
	
	inputs[| 7] = nodeValue("Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 8] = nodeValue("Light radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 16);
	
	inputs[| 9] = nodeValue("Render solid", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 10] = nodeValue("Use BG color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "If checked, background color will be used as shadow caster.");
	
	inputs[| 11] = nodeValue("BG threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 12] = nodeValue("Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 2, 0.01] });
	
	inputs[| 13] = nodeValue("Banding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 1] });
	
	inputs[| 14] = nodeValue("Attenuation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "Control how light fade out over distance.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ new scrollItem("Quadratic",		s_node_curve, 0),
												 new scrollItem("Invert quadratic", s_node_curve, 1),
												 new scrollItem("Linear",			s_node_curve, 2), ]);
	
	inputs[| 15] = nodeValue("Ambient occlusion", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 16, 1] });
		
	inputs[| 16] = nodeValue("Ambient occlusion strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [0, 0.5, 0.01] });
	
	inputs[| 17] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 17;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Light mask", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 17, 
		["Surfaces",		   true], 0, 1, 
		["Light",			  false], 5, 12, 8, 2, 3, 4,
		["BG Shadow Caster",   true, 10], 11,
		["Render",			  false], 13, 14, 7, 6, 9, 
		["Ambient Occlusion", false], 15, 16,
	];
	
	attribute_surface_depth();
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 2].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
		if(array_length(current_data) != ds_list_size(inputs)) return;
		
		var _type = current_data[5];
		if(_type == 0) {
			var pos = current_data[2];
			var px = _x + pos[0] * _s;
			var py = _y + pos[1] * _s;
			
			inputs[| 8].drawOverlay(active, px, py, _s, _mx, _my, _snx, _sny, 0, 1 / 4, THEME.anchor_scale_hori);
		}
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
		
		inputs[| 8].setVisible(_type == 0);
		inputs[| 11].setVisible(_bg_use);
		
		if(!is_surface(_bg)) return _outSurf;
	
		surface_set_shader(_outSurf, sh_shadow_cast);
			shader_set_f("dimension",         surface_get_width_safe(_bg), surface_get_height_safe(_bg));
			shader_set_f("lightPos",         _pos);
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