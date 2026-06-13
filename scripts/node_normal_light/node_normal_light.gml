function Node_Normal_Light(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Normal Light";
	
	////- =Input
	newInput( 0, nodeValue_Surface( "Surface In"           ));
	newInput( 1, nodeValue_Surface( "Normal map"           ));
	newInput( 3, nodeValue_Color(   "Ambient",    ca_black ));
	newInput( 5, nodeValue_Bool(    "Keep Alpha", true     ));
	
	////- =Input
	newInput( 2, nodeValue_Float(   "Height", 1  ));
	newInput( 4, nodeValue_Surface( "Height map" ));
	// input 6
	
	typeListStr = ["Point", "Sun", "Line", "Spot"];
	typeList    = __enum_array_gen(typeListStr, s_node_normal_light_type);
	attnList    = __enum_array_gen([ "Quadratic", "Invert quadratic", "Linear", "Custom" ], s_node_curve_type);
	
	function createNewInput(i = array_length(inputs)) {
		var inAmo = array_length(inputs);
		dynamic_input_inspecting = getInputAmount();
		
		////- =Shape
		newInput(i+ 0, nodeValue_EScroll( "Type", 0, typeList ));
		newInput(i+ 1, nodeValue_Vec2(    "Position",     [0,0]    )).setUnitSimple();
		newInput(i+ 7, nodeValue_Float(   "Distance",      0       ));
		newInput(i+ 5, nodeValue_Vec2(    "End Position", [0,0]    )).setUnitSimple();
		newInput(i+ 8, nodeValue_Float(   "End Distance",  0       ));
		newInput(i+ 2, nodeValue_Float(   "Range",         16      ));
		
		////- =Light
		newInput(i+ 3, nodeValue_Float(   "Intensity", 4        ));
		newInput(i+ 4, nodeValue_Color(   "Color",     ca_white ));
		newInput(i+ 6, nodeValue_Color(   "End Color", ca_white ));
		
			////- =/Attenuation
		newInput(i+ 9, nodeValue_EScroll( "Attenuation",   0, attnList       )).setTooltip("Control how light fade out over distance.");
		newInput(i+10, nodeValue_Curve(   "AttenCurve",    CURVE_DEF_01      ));
			
			////- =/Banding
		newInput(i+11, nodeValue_ISlider(  "Radial Banding",     0, [0, 16, 0.1]   ));
		newInput(i+12, nodeValue_Rotation( "Radial Start",       0                 ));
		newInput(i+13, nodeValue_Slider(   "Radial Band Ratio", .5                 ));
		newInput(i+14, nodeValue_ISlider(  "Banding",            0, [0, 16, 0.1]   ));
		// input 15
		
		inputs[i + 2].overlay_text_valign = fa_bottom;
		
		refreshDynamicDisplay();
		return inputs[i];
	}
	
	lights_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		PROCESSOR_OVERLAY_CHECK
		
		var bs = ui(24);
		var bx = _x + ui(20);
		var by = _y;
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.add_16, 0, COLORS._main_value_positive) == 2) {
			createNewInput();
			triggerRender();
		}
			
		var amo = getInputAmount();
		var lh  = ui(28);
		var _h  = ui(12) + lh * amo;
		var yy  = _y + bs + ui(4);
		
		var del_light = -1;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, yy, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		for(var i = 0; i < amo; i++) {
			var _x0 = _x + ui(24);
			var _x1 = _x + _w - ui(16);
			var _yy = ui(6) + yy + i * lh + lh / 2;
			
			var _ind = input_fix_len + i * data_length;
			var _typ = current_data[_ind + 0];
			var _col = current_data[_ind + 4];
			
			var tc   = i == dynamic_input_inspecting? COLORS._main_text_accent : COLORS._main_icon;
			var hov  = _hover && point_in_rectangle(_m[0], _m[1], _x0, _yy - lh / 2, _x1, _yy + lh / 2 - 1);
			
			if(hov && _m[0] < _x1 - ui(32)) {
				tc = COLORS._main_text;
				
				if(mouse_lpress(_focus)) {
					dynamic_input_inspecting = i;
					refreshDynamicDisplay();
				}
			}
			
			draw_sprite_ext(s_node_normal_light_type, _typ, _x0 + ui(8), _yy, 1, 1, 0, _col, .5 + .5 * (i == dynamic_input_inspecting));
			
			draw_set_text(f_p2, fa_left, fa_center, tc);
			draw_text_add(_x0 + ui(28), _yy, typeListStr[_typ]);
			
			if(amo > 1) {
				var bs = ui(24);
				var bx = _x1 - bs;
				var by = _yy - bs / 2;
				if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, hov? COLORS._main_value_negative : COLORS._main_icon) == 2) 
					del_light = i;	
			}
		}
		
		if(del_light > -1) 
			deleteDynamicInput(del_light);
		
		return ui(32) + _h;
	});
	
	input_display_dynamic = [ // 14, 
		[ "Shape",            false ],  0,  1,  7,  5,  8,  2, 
		[ "Light",            false ],  3,  4,  6, 
			[ "/Attenuation", false ],  9, 10, 
			[ "/Banding",     false ], 11, 12, 13, 14, 
	];
	
	input_display_list = [ 
		[ "Input",  false ], 0, 1, 3, 5, 
		new Inspector_Spacer(8, true),
		new Inspector_Spacer(2, false, false),
		lights_renderer, 
		[ "Lights", false ], 
	];
	
	setDynamicInput(15, false);
	if(!LOADING && !APPENDING) createNewInput();
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone ));
	newOutput(1, nodeValue_Output( "Light Only",  VALUE_TYPE.surface, noone ));
	
	////- Nodes
	
	attribute_surface_depth();
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		if(getInputAmount() == 0) return;
		
		dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
		var _ind = input_fix_len + dynamic_input_inspecting * data_length;
		
		var typ  = current_data[_ind + 0];
		var pos  = current_data[_ind + 1];
		var rad  = current_data[_ind + 2];
		var px   = _x + pos[0] * _s;
		var py   = _y + pos[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		draw_set_alpha(0.5);
		draw_circle_dash(px, py, rad * _s, 1, 8);
		draw_set_alpha(1);
		
		if(typ == 2 || typ == 3) {
			if(typ == 2) {
				var p2  = current_data[_ind + 5];
				var px2 = _x + p2[0] * _s;
				var py2 = _y + p2[1] * _s;
				
				draw_set_color(COLORS._main_accent);
				draw_line(px, py, px2, py2);
			}
			
			InputDrawOverlay(inputs[_ind + 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
			InputDrawOverlay(inputs[_ind + 2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
			InputDrawOverlay(inputs[_ind + 5].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
			
		} else {
			InputDrawOverlay(inputs[_ind + 1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my));
			InputDrawOverlay(inputs[_ind + 2].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my));
		}
		
		return w_hovering;
	}
	
	static applyLight = function(_data, _dim, _ind, _ligSurf) {
		var _map  = _data[1];
		var _hei  = _data[2];
		var _hmap = _data[4];
		
		var _light_typ = _data[_ind + 0];
		
		var _light_pos = _data[_ind + 1];
		var _light_dis = _data[_ind + 7];
		
		var _light_ps2 = _data[_ind + 5];
		var _light_ds2 = _data[_ind + 8];
		var _light_ran = _data[_ind + 2];
		
		var _light_int = _data[_ind + 3];
		var _light_col = _data[_ind + 4];
		var _light_cl2 = _data[_ind + 6];
		
		var _light_attn = _data[_ind + 9];
		var _light_attC = _data[_ind +10];
		
		var _light_rbnd = _data[_ind +11];
		var _light_rbns = _data[_ind +12];
		var _light_rbnr = _data[_ind +13];
		var _light_band = _data[_ind +14];
		
		surface_set_shader(_ligSurf, sh_normal_light, false, BLEND.add);
			shader_set_s( "normalMap",        _map              );
			shader_set_s( "heightMap",        _hmap             );
			shader_set_i( "useHeightMap",     is_surface(_hmap) );
			shader_set_f( "normalHeight",     _hei              );
			shader_set_f( "dimension",        _dim              );
			
			shader_set_i( "lightType",        _light_typ        );
			shader_set_f( "lightPosition",    _light_pos[0], _light_pos[1], -_light_dis / 100, _light_ran );
			shader_set_f( "lightPosition2",   _light_ps2[0], _light_ps2[1], -_light_ds2 / 100, _light_ran );
			
			shader_set_f( "lightIntensity",   _light_int        );
			shader_set_c( "lightColor",       _light_col        );
			shader_set_c( "lightColor2",      _light_cl2        );
			
			shader_set_i(     "atten",        _light_attn       );
			shader_set_curve( "attenCurve",   _light_attC       );
			
			shader_set_f( "band",             _light_band       );
			shader_set_f( "radialBandAmo",    _light_rbnd       );
			shader_set_f( "radialBandStart",  _light_rbns       );
			shader_set_f( "radialBandRatio",  _light_rbnr       );
			
			draw_empty();
		surface_reset_shader();
		
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _surf = _data[0];
			var _norm = _data[1];
			var _amb  = _data[3];
			var _alph = _data[5];
			var _dim  = is_surface(_surf)? surface_get_dimension(_surf) : surface_get_dimension(_norm);
		#endregion
		
		if(getInputAmount()) {
			dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
			var _ind = input_fix_len + dynamic_input_inspecting * data_length;
			
			var _ltype = _data[_ind + 0];
			var _lattn = _data[_ind + 9];
			
			inputs[_ind + 5].setVisible(_ltype == 2 || _ltype == 3);
			inputs[_ind + 8].setVisible(_ltype == 2 || _ltype == 3);
			inputs[_ind + 6].setVisible(_ltype == 2);
			
			inputs[_ind +10].setVisible(_lattn == 3);
			
			inputs[_ind +11].setVisible(_ltype == 0);
			inputs[_ind +12].setVisible(_ltype == 0);
			inputs[_ind +13].setVisible(_ltype == 0);
		}
		
		var _outSurf = surface_verify(_outData[0], _dim[0], _dim[1]);
		var _ligSurf = surface_verify(_outData[1], _dim[0], _dim[1]);
		
		surface_set_target(_ligSurf);
			draw_clear(c_black);
		surface_reset_target();
		
		for( var i = 0; i < getInputAmount(); i++ ) {
			var _ind = input_fix_len + i * data_length;
			applyLight(_data, _dim, _ind, _ligSurf);
		}
		
		surface_set_shader(_outSurf, sh_normal_light_apply);
			shader_set_surface("baseSurface",  _surf);
			shader_set_surface("lightSurface", _ligSurf);
			shader_set_color("ambient", _amb);
			shader_set_i("keepAlpha",   _alph);
			
			draw_empty();
		surface_reset_shader();
		
		return [ _outSurf, _ligSurf ];
	}
}