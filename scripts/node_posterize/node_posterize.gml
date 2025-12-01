#region
	FN_NODE_CONTEXT_INVOKE {
		addHotkey("Node_Posterize", "Use Palette > Toggle", "P", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[2].setValue((_n.inputs[2].getValue() + 1) % 2); });
		addHotkey("Node_Posterize", "Space > Toggle",       "S", MOD_KEY.none, function() /*=>*/ { GRAPH_FOCUS _n.inputs[8].setValue((_n.inputs[8].getValue() + 1) % 2); });
	});
#endregion

function Node_Posterize(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Posterize";
	
	newActiveInput(5);
	newInput(0, nodeValue_Surface("Surface In"));
	
	////- =Palette
	newInput(2, nodeValue_Bool(        "Use Palette", true));
	newInput(1, nodeValue_Palette(     "Palette" ));
	newInput(9, nodeValue_Bool(        "Use Global Range", true));
	newInput(3, nodeValue_ISlider(     "Steps", 4, [2, 16, 0.1]));
	newInput(4, nodeValue_Slider(      "Gamma", 1, [0, 2, 0.01])).setMappable(7);
	newInput(8, nodeValue_Enum_Button( "Space", 0, [ "RGB", "LAB" ]));
	
	////- =Bias
	newInput(11, nodeValue_Surface( "Reference"));
	newInput(10, nodeValue_Slider(  "Hue Bias", 0));
	
	////- =Alpha
	newInput(6, nodeValue_Bool( "Posterize alpha", true));
	// inputs 12
	
	input_display_list = [ 5, 0, 
		["Palette", false, 2], 1, 9, 3, 4, 7, 8, 
		["Bias",    false],    11, 10, 
		["Alpha",   false],    6, 
	];
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	attribute_surface_depth();
	
	temp_surface = array_create(4);
	
	static processData = function(_outSurf, _data, _array_index) {
		var _surf    = _data[ 0];
		var _pal     = _data[ 1];
		var _use_pal = _data[ 2];
		var _alp     = _data[ 6];
		var _spce    = _data[ 8];
		var _glob    = _data[ 9];
		
		var _hbas    = _data[10];
		var _href    = _data[11];
		
		inputs[ 1].setVisible( _use_pal);
		inputs[ 8].setVisible( _use_pal);
		inputs[10].setVisible( _use_pal);
		
		inputs[ 3].setVisible(!_use_pal);
		inputs[ 4].setVisible(!_use_pal);
		inputs[ 9].setVisible(!_use_pal);
		
		if(_use_pal) {
			surface_set_shader(_outSurf, sh_posterize_palette);
				shader_set_surface("reference", _href);
				shader_set_palette(_pal, "palette", "keys");
				shader_set_i("alpha", _alp);
				shader_set_i("space", _spce);
				shader_set_f("hBias", _hbas);
				
				draw_surface_safe(_surf);
			surface_reset_shader();
			
		} else {
			
			var _max  = [ 0, 0, 0 ];
			var _min  = [ 1, 1, 1 ];
				
			if(!_glob) { // get range
				var _sw  = surface_get_width(_surf);
				var _sh  = surface_get_height(_surf);
				var _itr = ceil(logn(4, _sw * _sh / 1024));
				
				var _sww = ceil(_sw / 2);
				var _shh = ceil(_sh / 2);
				
				for (var i = 0, n = array_length(temp_surface); i < n; i++) 
					temp_surface[i] = surface_verify(temp_surface[i], _sw, _sh);
				
				surface_set_shader(temp_surface[0]);
					draw_surface_safe(_surf);
				surface_reset_shader();
				
				surface_set_shader(temp_surface[1]);
					draw_surface_safe(_surf);
				surface_reset_shader();
				
				surface_clear(temp_surface[2]);
				surface_clear(temp_surface[3]);
				
				var _ind = 1;
				repeat(_itr) {
					surface_resize(temp_surface[(_ind) * 2 + 0], _sww, _shh);
					surface_resize(temp_surface[(_ind) * 2 + 1], _sww, _shh);
					
					shader_set(sh_get_max_downsampled);
					surface_set_target_ext(0, temp_surface[(_ind) * 2 + 0]);
					surface_set_target_ext(1, temp_surface[(_ind) * 2 + 1]);
						shader_set_f("dimension", _sww, _shh);
						shader_set_surface("surfaceMax", temp_surface[(!_ind) * 2 + 0]);
						shader_set_surface("surfaceMin", temp_surface[(!_ind) * 2 + 1]);
						
						draw_sprite_stretched(s_fx_pixel, 0, 0, 0, _sww, _shh);
					surface_reset_target();
					shader_reset();
					
					_sww = ceil(_sww / 2);
					_shh = ceil(_shh / 2);
					
					_ind = !_ind;
				}
				
				var _sMax = temp_surface[(!_ind) * 2 + 0];
				var _sMin = temp_surface[(!_ind) * 2 + 1];
				var _ssw  = surface_get_width(_sMax);
				var _ssh  = surface_get_height(_sMax);
				
				var _bMax = buffer_from_surface(_sMax, false);
				var _bMin = buffer_from_surface(_sMin, false);
				
				buffer_to_start(_bMax);
				buffer_to_start(_bMin);
				
					repeat(_ssw * _ssh) {
						var _cc = buffer_read(_bMax, buffer_u32);
						_max[0] = max(_max[0], _color_get_red(_cc));
						_max[1] = max(_max[1], _color_get_green(_cc));
						_max[2] = max(_max[2], _color_get_blue(_cc));
						
						var _cc = buffer_read(_bMin, buffer_u32);
						_min[0] = min(_min[0], _color_get_red(_cc));
						_min[1] = min(_min[1], _color_get_green(_cc));
						_min[2] = min(_min[2], _color_get_blue(_cc));
						
					}
					
				buffer_delete(_bMax);
				buffer_delete(_bMin);
			}
			
			surface_set_shader(_outSurf, sh_posterize);
				shader_set_f("cMax",      _max);
				shader_set_f("cMin",      _min);
				shader_set_f("colors",    _data[3]);
				shader_set_f_map("gamma", _data[4], _data[7], inputs[4]);
				shader_set_i("alpha",     _alp);
			
				draw_surface_safe(_surf);
			surface_reset_shader();
		}
		
		return _outSurf;
	}

	static drawProcessShort = function(_x, _y, _prog) {
		var _usepal = getSingleValue(2);
		if(!_usepal) return;
		
		var _pal    = getSingleValue(1);
		var _pname = attributes.annotation;
		
		var ww = 480
		var hh = lerp(68, 112, clamp(_prog * 3, 0, 1));
		
		var x0 = _x - ww / 2;
		var y0 = _y - 32 - hh;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 3, x0, y0, ww, hh);
		var py = y0 + 8;
		var ph = hh - 16;
		
		if(_pname != "") {
			draw_set_text(f_pixel, fa_center, fa_top, COLORS._main_text_sub);
			draw_text_transformed(_x, y0 + 8, _pname, 3, 3, 0);
			
			py += 52;
			ph -= 52;
		}
		
		drawPalette(_pal, x0 + 8, py, ww - (8+8), ph);
	}
}