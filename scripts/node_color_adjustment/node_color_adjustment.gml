function Node_Color_adjust(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Color Adjust";
	
	shader = sh_color_adjust;
	uniform_bri = shader_get_uniform(shader, "brightness");
	uniform_exp = shader_get_uniform(shader, "exposure");
	uniform_con = shader_get_uniform(shader, "contrast");
	uniform_hue = shader_get_uniform(shader, "hue");
	uniform_sat = shader_get_uniform(shader, "sat");
	uniform_val = shader_get_uniform(shader, "val");
	uniform_alp = shader_get_uniform(shader, "alpha");
	
	uniform_bl  = shader_get_uniform(shader, "blend");
	uniform_bla = shader_get_uniform(shader, "blendAlpha");
	
	uniform_mask_use	= shader_get_uniform(shader, "use_mask");
	uniform_mask		= shader_get_sampler_index(shader, "mask");
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Brightness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] });
	
	inputs[| 2] = nodeValue("Contrast",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 3] = nodeValue("Hue",        self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] });
	
	inputs[| 4] = nodeValue("Saturation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] });
	
	inputs[| 5] = nodeValue("Value",      self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] });
	
	inputs[| 6] = nodeValue("Blend",   self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 7] = nodeValue("Blend alpha",  self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 8] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 9] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider);
	
	inputs[| 10] = nodeValue("Exposure", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] });
	
	inputs[| 11] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 11;
		
	inputs[| 12] = nodeValue("Input Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Surface", "Color" ]);
	
	inputs[| 13] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Color out", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [])
		.setDisplay(VALUE_DISPLAY.palette);
	
	input_display_list = [11, 12, 0, 8, 13, 
		["Brightness",	false], 1, 10, 2, 
		["HSV",			false], 3, 4, 5, 
		["Color blend", false], 6, 7, 9
	];
	
	temp_surface = [ surface_create(1, 1) ];
	
	attribute_surface_depth();
	
	static step = function() {
		var type = getInputData(12);
		
		inputs[|  0].setVisible(type == 0, type == 0);
		inputs[|  8].setVisible(type == 0, type == 0);
		inputs[| 13].setVisible(type == 1, type == 1);
		
		outputs[| 0].setVisible(type == 0, type == 0);
		outputs[| 1].setVisible(type == 1, type == 1);
	}
	
	static processData = function(_outSurf, _data, _output_index, _array_index) { #region
		var _bri = _data[1];
		var _con = _data[2];
		var _hue = _data[3];
		var _sat = _data[4];
		var _val = _data[5];
		
		var _bl  = _data[6];
		var _bla = _data[7];
		var _m   = _data[8];
		var _alp = _data[9];
		var _exp = _data[10];
		
		var _type = _data[12];
		var _col  = _data[13];
		
		if(_type == 0 && _output_index != 0) return [];
		if(_type == 1 && _output_index != 1) return noone;
		
		var _surf     = _data[0];
		var _baseSurf = _outSurf;
		
		_col = array_clone(_col);
		
		if(_type == 1) {
			if(!is_array(_col)) _col = [ _col ];
			
			for( var i = 0, n = array_length(_col); i < n; i++ ) {
				var _c = _col[i];
				
				var r = color_get_red(_c)   / 255;
				var g = color_get_green(_c) / 255;
				var b = color_get_blue(_c)  / 255;
				
				_c = make_color_rgb(
					clamp((.5 + _con * 2 * (r - .5) + _bri) * _exp, 0, 1) * 255,
					clamp((.5 + _con * 2 * (g - .5) + _bri) * _exp, 0, 1) * 255,
					clamp((.5 + _con * 2 * (b - .5) + _bri) * _exp, 0, 1) * 255,
				);
				
				var h = color_get_hue(_c)        / 255;
				var s = color_get_saturation(_c) / 255;
				var v = color_get_value(_c)      / 255;
				
				h = clamp(frac(h + _hue), -1, 1);
				if(h < 0) h = 1 + h;
				v = clamp((v + _val) * (1 + _sat * s * 0.5), 0, 1);
				s = clamp(s * (_sat + 1), 0, 1);
				
				_c = make_color_hsv(h * 255, s * 255, v * 255);
				_c = merge_color(_c, _bl, _bla);
				_col[i] = _c;
			}
			
			return _col;
		}
		
		surface_set_shader(_baseSurf, shader);
			shader_set_uniform_i(uniform_mask_use, _m != DEF_SURFACE);
			texture_set_stage(uniform_mask, surface_get_texture(_m));
			
			shader_set_uniform_f(uniform_bri, _bri);
			shader_set_uniform_f(uniform_exp, _exp);
			shader_set_uniform_f(uniform_con, _con);
			shader_set_uniform_f(uniform_hue, _hue);
			shader_set_uniform_f(uniform_sat, _sat);
			shader_set_uniform_f(uniform_val, _val);
			
			shader_set_uniform_f_array_safe(uniform_bl, [color_get_red(_bl) / 255, color_get_green(_bl) / 255, color_get_blue(_bl) / 255, 1.0]);
			shader_set_uniform_f(uniform_bla, _bla);
			
			gpu_set_colorwriteenable(1, 1, 1, 0);
			draw_surface_safe(_surf, 0, 0);
			gpu_set_colorwriteenable(1, 1, 1, 1);
			draw_surface_ext_safe(_surf, 0, 0, 1, 1, 0, c_white, _alp);
		surface_reset_shader();
		
		return _outSurf;
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var type = getInputData(12);
		if(type == 0) return;
		
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var pal = outputs[| 1].getValue();
		if(array_length(pal) && is_array(pal[0])) return;
		
		drawPalette(pal, bbox.x0, bbox.y0, bbox.w, bbox.h);
	} #endregion
}