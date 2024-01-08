function Node_Color_adjust(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Color Adjust";
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Brightness", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] })
		.setMappable(18);
	
	inputs[| 2] = nodeValue("Contrast",   self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0.5)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(19);
	
	inputs[| 3] = nodeValue("Hue",        self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] })
		.setMappable(20);
	
	inputs[| 4] = nodeValue("Saturation", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] })
		.setMappable(21);
	
	inputs[| 5] = nodeValue("Value",      self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ -1, 1, 0.01 ] })
		.setMappable(22);
	
	inputs[| 6] = nodeValue("Blend",   self, JUNCTION_CONNECT.input, VALUE_TYPE.color, c_white);
	
	inputs[| 7] = nodeValue("Blend amount",  self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(23);
	
	inputs[| 8] = nodeValue("Mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 9] = nodeValue("Alpha", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider)
		.setMappable(24);
	
	inputs[| 10] = nodeValue("Exposure", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [ 0, 4, 0.01 ] })
		.setMappable(25);
	
	inputs[| 11] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
		active_index = 11;
		
	inputs[| 12] = nodeValue("Input Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Surface", "Color" ]);
	
	inputs[| 13] = nodeValue("Color", self, JUNCTION_CONNECT.input, VALUE_TYPE.color, DEF_PALETTE )
		.setDisplay(VALUE_DISPLAY.palette)
		.setVisible(true, true);
	
	inputs[| 14] = nodeValue("Blend mode", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, BLEND_TYPES);
		
	inputs[| 15] = nodeValue("Channel", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0b1111)
		.setDisplay(VALUE_DISPLAY.toggle, { data: array_create(4, THEME.inspector_channel) });
	
	inputs[| 16] = nodeValue("Invert mask", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 17] = nodeValue("Mask feather", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.setDisplay(VALUE_DISPLAY.slider, { range: [1, 16, 1] });
	
	////////////////////////////////////////////////////////////////////////////////////////
	
	inputs[| 18] = nodeValue("Brightness map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(false, false);
	
	inputs[| 19] = nodeValue("Contrast map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(false, false);
	
	inputs[| 20] = nodeValue("Hue map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(false, false);
	
	inputs[| 21] = nodeValue("Saturation map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(false, false);
	
	inputs[| 22] = nodeValue("Value map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(false, false);
	
	inputs[| 23] = nodeValue("Blend map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(false, false);
	
	inputs[| 24] = nodeValue("Alpha map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(false, false);
	
	inputs[| 25] = nodeValue("Exposure map", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(false, false);
		
	////////////////////////////////////////////////////////////////////////////////////////
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	outputs[| 1] = nodeValue("Color out", self, JUNCTION_CONNECT.output, VALUE_TYPE.color, [])
		.setDisplay(VALUE_DISPLAY.palette);
	
	input_display_list = [11, 12, 15, 9, 24, 
		["Surface",		false], 0, 8, 16, 17, 13, 
		["Brightness",	false], 1, 18, 10, 25, 2, 19, 
		["HSV",			false], 3, 20, 4, 21, 5, 22, 
		["Color blend", false], 6, 14, 7, 23, 
	];
	
	temp_surface = [ surface_create(1, 1), surface_create(1, 1) ];
	
	attribute_surface_depth();
	
	static step = function() { #region
		var type = getInputData(12);
		
		inputs[|  0].setVisible(type == 0, type == 0);
		inputs[|  8].setVisible(type == 0, type == 0);
		inputs[|  9].setVisible(type == 0);
		inputs[| 13].setVisible(type == 1, type == 1);
		inputs[| 14].setVisible(type == 0);
		
		outputs[| 0].setVisible(type == 0, type == 0);
		outputs[| 1].setVisible(type == 1, type == 1);
		
		var _msk = is_surface(getSingleValue(8));
		inputs[| 16].setVisible(_msk);
		inputs[| 17].setVisible(_msk);
		
		inputs[|  1].mappableStep();
		inputs[|  2].mappableStep();
		inputs[|  3].mappableStep();
		inputs[|  4].mappableStep();
		inputs[|  5].mappableStep();
		inputs[|  7].mappableStep();
		inputs[|  9].mappableStep();
		inputs[| 10].mappableStep();
	} #endregion
	
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
		var _blm  = _data[14];
		
		var _mskInv = _data[16];
		var _mskFea = _data[17];
		
		if(_type == 0 && _output_index != 0) return [];
		if(_type == 1 && _output_index != 1) return noone;
		
		var _surf     = _data[0];
		var _baseSurf = _outSurf;
		
		_col = array_clone(_col);
		
		if(_type == 1) { #region color adjust
			if(is_array(_bri)) _bri = array_safe_get(_bri, 0);
			if(is_array(_con)) _con = array_safe_get(_con, 0);
			if(is_array(_hue)) _hue = array_safe_get(_hue, 0);
			if(is_array(_sat)) _sat = array_safe_get(_sat, 0);
			if(is_array(_val)) _val = array_safe_get(_val, 0);
			if(is_array(_bla)) _bla = array_safe_get(_bla, 0);
			if(is_array(_alp)) _alp = array_safe_get(_alp, 0);
			if(is_array(_exp)) _exp = array_safe_get(_exp, 0);
			
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
		} #endregion
		
		#region param
			var sw = surface_get_width_safe(_baseSurf);
			var sh = surface_get_height_safe(_baseSurf);
		
			temp_surface[0] = surface_verify(temp_surface[0], sw * 2, sh * 2);
			temp_surface[1] = surface_verify(temp_surface[1], sw * 2, sh * 2);
		
			surface_set_target(temp_surface[0]);
				DRAW_CLEAR
				
				draw_surface_stretched_safe(_data[18], sw * 0, sh * 0, sw, sh); //Brightness
				draw_surface_stretched_safe(_data[25], sw * 1, sh * 0, sw, sh); //Exposure
				draw_surface_stretched_safe(_data[19], sw * 0, sh * 1, sw, sh); //Contrast
				draw_surface_stretched_safe(_data[20], sw * 1, sh * 1, sw, sh); //Hue
			surface_reset_target();
		
			surface_set_target(temp_surface[1]);
				DRAW_CLEAR
				
				draw_surface_stretched_safe(_data[21], sw * 0, sh * 0, sw, sh); //Sat
				draw_surface_stretched_safe(_data[22], sw * 1, sh * 0, sw, sh); //Val
				draw_surface_stretched_safe(_data[23], sw * 0, sh * 1, sw, sh); //Blend
				draw_surface_stretched_safe(_data[24], sw * 1, sh * 1, sw, sh); //Alpha
			surface_reset_target();
		#endregion
		
		#region surface adjust
			_m = mask_modify(_m, _mskInv, _mskFea);
			surface_set_shader(_baseSurf, sh_color_adjust);
				shader_set_surface("param0", temp_surface[0]);
				shader_set_surface("param1", temp_surface[1]);
				
				shader_set_f_map_s("brightness", _bri, _data[18], inputs[|  1]);
				shader_set_f_map_s("exposure",   _exp, _data[25], inputs[| 10]);
				shader_set_f_map_s("contrast",   _con, _data[19], inputs[|  2]);
				shader_set_f_map_s("hue",        _hue, _data[20], inputs[|  3]);
				shader_set_f_map_s("sat",        _sat, _data[21], inputs[|  4]);
				shader_set_f_map_s("val",        _val, _data[22], inputs[|  5]);
			
				shader_set_color("blend",   _bl);
				shader_set_f_map_s("blendAmount", _bla * _color_get_alpha(_bl), _data[23], inputs[| 7]);
				shader_set_i("blendMode",   _blm);
				
				shader_set_f_map_s("alpha", _alp, _data[24], inputs[| 9]);
				shader_set_i("use_mask", is_surface(_m));
				shader_set_surface("mask", _m);
				
				gpu_set_colorwriteenable(1, 1, 1, 0);
				draw_surface_safe(_surf, 0, 0);				//replace clear color with surface color
				gpu_set_colorwriteenable(1, 1, 1, 1);
			
				draw_surface_ext_safe(_surf, 0, 0, 1, 1, 0, c_white, 1);
			surface_reset_shader();
		#endregion
		
		return _outSurf;
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var type = getInputData(12);
		if(preview_draw != (type == 0)) { 
			preview_draw   = (type == 0);
			will_setHeight = true;
		}
		
		if(type == 0) return;
		
		var bbox = drawGetBbox(xx, yy, _s);
		if(bbox.h < 1) return;
		
		var pal = outputs[| 1].getValue();
		if(array_empty(pal)) return;
		if(!is_array(pal[0])) pal = [ pal ];
		
		var _h = array_length(pal) * 32;
		var _y = bbox.y0;
		var gh = bbox.h / array_length(pal);
			
		for( var i = 0, n = array_length(pal); i < n; i++ ) {
			drawPalette(pal[i], bbox.x0, _y, bbox.w, gh);
			_y += gh;
		}
		
		if(_h != min_h) will_setHeight = true;
		min_h = _h;	
	} #endregion
}