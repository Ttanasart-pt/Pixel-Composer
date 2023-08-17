function Node_Shadow_Cast(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Cast Shadow";
	
	shader = sh_shadow_cast;
	uniform_dim   = shader_get_uniform(shader, "dimension");
	uniform_lpos  = shader_get_uniform(shader, "lightPos");
	uniform_prad  = shader_get_uniform(shader, "pointLightRadius");
	uniform_lrad  = shader_get_uniform(shader, "lightRadius");
	uniform_lden  = shader_get_uniform(shader, "lightDensity");
	uniform_ltyp  = shader_get_uniform(shader, "lightType");
	uniform_lamb  = shader_get_uniform(shader, "lightAmb");
	uniform_lclr  = shader_get_uniform(shader, "lightClr");
	uniform_lint  = shader_get_uniform(shader, "lightInt");
	uniform_sol   = shader_get_uniform(shader, "renderSolid");
	
	uniform_band  = shader_get_uniform(shader, "lightBand");
	uniform_attn  = shader_get_uniform(shader, "lightAttn");
	
	uniform_ao		= shader_get_uniform(shader, "ao");
	uniform_ao_str  = shader_get_uniform(shader, "aoStr");
	
	uniform_bg_use = shader_get_uniform(shader, "bgUse");
	uniform_bg_thr = shader_get_uniform(shader, "bgThres");
	uniform_mask   = shader_get_uniform(shader, "mask");
	
	uniform_sld_use = shader_get_uniform(shader, "useSolid");
	uniform_solid   = shader_get_sampler_index(shader, "solid");
	
	inputs[| 0] = nodeValue("Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Solid", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 2] = nodeValue("Light Position", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setUnitRef(function(index) { 
			var _surf = inputs[| 0].getValue();
			if(is_array(_surf) && array_length(_surf) == 0)
				return [1, 1];
				
			if(is_array(_surf))
				_surf = _surf[0];
				
			if(!is_surface(_surf))
				return [1, 1];
			
			return [surface_get_width(_surf), surface_get_height(_surf)];
		}, VALUE_UNIT.reference);
		
	inputs[| 3] = nodeValue("Soft light radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 2, 0.01]);
	
	inputs[| 4] = nodeValue("Light density", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.slider, [1, 16, 1]);
	
	inputs[| 5] = nodeValue("Light type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Point", "Sun"]);
	
	inputs[| 6] = nodeValue("Ambient color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_grey);
	
	inputs[| 7] = nodeValue("Light color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 8] = nodeValue("Light radius", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 16);
	
	inputs[| 9] = nodeValue("Render solid", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 10] = nodeValue("Use BG color", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false, "If checked, background color will be used as shadow caster.");
	
	inputs[| 11] = nodeValue("BG threshold", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 1, 0.01]);
	
	inputs[| 12] = nodeValue("Light intensity", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 2, 0.01]);
	
	inputs[| 13] = nodeValue("Banding", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 16, 1]);
	
	inputs[| 14] = nodeValue("Attenuation", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0, "Control how light fade out over distance.")
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Quadratic", "Invert quadratic", "Linear"]);
	
	inputs[| 15] = nodeValue("Ambient occlusion", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.slider, [0, 16, 1]);
		
	inputs[| 16] = nodeValue("Ambient occlusion strength", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.1)
		.setDisplay(VALUE_DISPLAY.slider, [0, 0.5, 0.01]);
	
	inputs[| 17] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 17;
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Light mask", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	input_display_list = [ 17, 
		["Output",			 true], 0, 1, 
		["Light",			false], 5, 12, 8, 2, 3, 4,
		["Shadow caster",	false], 10, 11,
		["Render",			false], 13, 14, 7, 6, 9, 15, 16,
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
		
		surface_set_target(_outSurf);
		DRAW_CLEAR
		BLEND_OVERRIDE;
		
		shader_set(shader);
			shader_set_uniform_f(uniform_dim, surface_get_width(_bg), surface_get_height(_bg));
			shader_set_uniform_f_array_safe(uniform_lpos, _pos);
			shader_set_uniform_f_array_safe(uniform_lamb, colToVec4(_lamb));
			shader_set_uniform_f_array_safe(uniform_lclr, colToVec4(_lclr));
			shader_set_uniform_f(uniform_lrad, _rad);
			shader_set_uniform_f(uniform_prad, _lrad);
			shader_set_uniform_f(uniform_lden, _den);
			shader_set_uniform_i(uniform_ltyp, _type);
			shader_set_uniform_i(uniform_sol, _sol);
			shader_set_uniform_f(uniform_lint, _int);
			shader_set_uniform_f(uniform_band, _band);
			shader_set_uniform_f(uniform_attn, _attn);
			shader_set_uniform_f(uniform_ao, _ao);
			shader_set_uniform_f(uniform_ao_str, _ao_str);
			
			shader_set_uniform_i(uniform_mask, _output_index);
			shader_set_uniform_i(uniform_bg_use, _bg_use);
			shader_set_uniform_f(uniform_bg_thr, _bg_thr);
			
			shader_set_uniform_i(uniform_sld_use, is_surface(_solid));
			if(is_surface(_solid))
				texture_set_stage(uniform_solid, surface_get_texture(_solid));
				
			draw_surface_safe(_bg, 0, 0);
		shader_reset();
		
		BLEND_NORMAL;
		surface_reset_target();
		
		return _outSurf;
	}
}