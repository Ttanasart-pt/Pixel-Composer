function Node_Shadow_Cast(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Cast Shadow";
	
	typeListStr = ["Point", "Sun"];
	__ltype = __enum_array_gen(typeListStr, s_node_shadow_type);
	__atype = __enum_array_gen(["Quadratic", "Invert quadratic", "Linear", "Custom"], s_node_curve_type);
	
	////- =Surfaces
	newInput( 0, nodeValue_Surface( "Background"       ));
	newInput( 1, nodeValue_Surface( "Solid"            ));
	newInput( 2, nodeValue_Slider(  "BG Threshold", .1 ));
		
	////- =Rendering
	newInput( 3, nodeValue_Color( "Ambient Color", cola(c_grey) ));
	newInput( 4, nodeValue_Bool(  "Render Solid",  true         ));
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		dynamic_input_inspecting = getInputAmount();
		
		////- =Shape
		newInput(index+ 0, nodeValue_EScroll( "Type",       0, __ltype   ));
		newInput(index+ 3, nodeValue_Vec2(    "Position", [.5,.5]        )).setUnitSimple().hideLabel();
		newInput(index+ 4, nodeValue_Float(   "Radius",    .5            )).setUnitSimple().hideLabel();
		
		////- =Light
		newInput(index+ 2, nodeValue_Slider(  "Intensity",  1, [0,2,.01] ));
		newInput(index+ 1, nodeValue_Color(   "Color",      ca_white     ));
		
		////- =Attenuation
		newInput(index+ 5, nodeValue_EScroll( "Attenuation",0, __atype   )).setTooltip("Control how light fade out over distance.");
		newInput(index+13, nodeValue_Curve(   "Att. Curve", CURVE_DEF_01 ));
		newInput(index+ 6, nodeValue_ISlider( "Banding",    0, [0,16,.1] ));
			
		////- =Soft Light
		newInput(index+ 7, nodeValue_Bool(    "Use Soft Light",    false        ));
		newInput(index+ 8, nodeValue_ISlider( "Density",           1, [1,16,.1] ));
		newInput(index+ 9, nodeValue_Slider(  "Soft Light Radius", 1, [0,2,.01] ));
		
		////- =Ambient Occlusion
		newInput(index+10, nodeValue_Bool(    "Use AO",       false          ));
		newInput(index+11, nodeValue_ISlider( "AO Radius",    0, [0,16,.1]   ));
		newInput(index+12, nodeValue_Slider(  "AO Strength", .1, [0,.5,.001] ));
		// inputs 14
		
		refreshDynamicDisplay();
		return inputs[index];
	} 
	
	newOutput(0, nodeValue_Output( "Surface Out", VALUE_TYPE.surface, noone));
	newOutput(1, nodeValue_Output( "Light mask",  VALUE_TYPE.surface, noone));
	
	lights_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(array_length(current_data) != array_length(inputs)) return 0;
		
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
			var _col = current_data[_ind + 1];
			
			var tc   = i == dynamic_input_inspecting? COLORS._main_text_accent : COLORS._main_icon;
			var hov  = _hover && point_in_rectangle(_m[0], _m[1], _x0, _yy - lh / 2, _x1, _yy + lh / 2 - 1);
			
			if(hov && _m[0] < _x1 - ui(32)) {
				tc = COLORS._main_text;
				
				if(mouse_press(mb_left, _focus)) {
					dynamic_input_inspecting = i;
					refreshDynamicDisplay();
				}
			}
			
			draw_sprite_ext(s_node_2d_light_shape, _typ, _x0 + ui(8), _yy, 1, 1, 0, _col, .5 + .5 * (i == dynamic_input_inspecting));
			
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
	
	input_display_list = [ 
		[ "Surfaces",   true ], 0, 1, 2, 
		[ "Rendering", false ], 3, 4, 
		new Inspector_Spacer(ui(4), true, false), lights_renderer, 
	];
	
	input_display_dynamic = [ 
		[ "Shape",             false     ],  0,  3, 4, 
		[ "Light",             false     ],  2,  1, 
		[ "Attenuation",       false     ],  5, 13, 6, 
		[ "Soft Light",        false, 7  ],  8,  9, 
		[ "Ambient Occlusion", false, 10 ], 11, 12, 
	];
	
	setDynamicInput(14, false);
	if(!LOADING && !APPENDING) createNewInput();
	
	////- Node
	
	attribute_surface_depth();
	
	temp_surface = [ noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _params) { 
		PROCESSOR_OVERLAY_CHECK
		if(getInputAmount() == 0) return;
		
		var hvAny = false;
		for( var i = 0, n = getInputAmount(); i < n; i++ ) {
			if(i == dynamic_input_inspecting) continue;
			
			var _ind = input_fix_len + i * data_length;
			var typ = current_data[_ind+0];
			var col = current_data[_ind+1];
			var pos = current_data[_ind+3];
			var px = _x + pos[0] * _s;
			var py = _y + pos[1] * _s;
			
			var hv = w_hoverable && point_in_circle(_mx, _my, px, py, ui(6));
			var ss = 1 + .25 * hv;
			draw_sprite_ext(     s_node_shadow_type, typ, px+1, py+1, ss, ss, 0, COLORS._main_icon );
			draw_sprite_ext_add( s_node_shadow_type, typ, px,   py,   ss, ss, 0, c_white           );
			
			BLEND_ALPHA_MULP
			draw_sprite_ext(s_node_shadow_type, typ, px, py, ss, ss, 0, col, 1);
			BLEND_NORMAL
			
			if(hv) {
				hvAny = true;
				if(mouse_lpress(active)) {
					dynamic_input_inspecting = i;
					refreshDynamicDisplay();
				}
			}
		}
		
		dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
		var _ind = input_fix_len + dynamic_input_inspecting * data_length;
		
		InputDrawOverlay(inputs[_ind+3].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, 1));
		
		var _type = current_data[_ind+0];
		if(_type == 0) {
			var pos = current_data[_ind+3];
			var rad = current_data[_ind+4];
			var px = _x + pos[0] * _s;
			var py = _y + pos[1] * _s;
			var rr = rad * _s;
			
			draw_set_color(COLORS._main_accent);
			draw_circle_dash(px, py, rr/2);
			InputDrawOverlay(inputs[_ind+4].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, 0, 1/2, 1));
		}
		
		if(hvAny) w_hoverable = false;
		
		return w_hovering;
	}
	
	static processData = function(_outData, _data, _array_index) {
		#region data
			var _bg     = _data[ 0];
			var _solid  = _data[ 1], _solidUse = is_surface(_solid);
			var _bg_thr = _data[ 2];
			
			var _lamb   = _data[ 3];
			var _solRen = _data[ 4];
		#endregion
		
		if(!is_surface(_bg)) return _outData;
		
		var _dim = surface_get_dimension(_bg);
		temp_surface[0] = surface_verify(temp_surface[0], _dim[0], _dim[1], surface_r8unorm);
		_outData[0]     = surface_verify(_outData[0],     _dim[0], _dim[1]);
		_outData[1]     = surface_verify(_outData[1],     _dim[0], _dim[1], surface_rgba16float);
		
		if(_solidUse) {
			surface_set_shader(temp_surface[0], sh_shadow_cast_bg_convert);
				draw_surface(_solid, 0, 0);
			surface_reset_shader();
		}
		
		for( var i = 0; i < getInputAmount(); i++ ) {
			var _ind = input_fix_len + i * data_length;
			
			var _type   = _data[_ind +  0];
			var _lclr   = _data[_ind +  1];
			var _int    = _data[_ind +  2];
			var _pos    = _data[_ind +  3];
			var _lrad   = _data[_ind +  4];
			
			var _attn   = _data[_ind +  5];
			var _attC   = _data[_ind + 13];
			var _band   = _data[_ind +  6];
			
			var _soft   = _data[_ind +  7];
			var _den    = _data[_ind +  8];
			var _rad    = _data[_ind +  9];
			
			var _ao     = _data[_ind + 10];
			var _ao_rad = _data[_ind + 11];
			var _ao_str = _data[_ind + 12];
			
			inputs[_ind +  4].setVisible(_type == 0);
			inputs[_ind + 13].setVisible(_attn == 3);
			
			if(!_solidUse) {
				var _refColor = surface_getpixel_ext(_bg, 
					clamp(_pos[0], 0, _dim[0] - 1), 
					clamp(_pos[1], 0, _dim[1] - 1)
				);
				
				surface_set_shader(temp_surface[0], sh_shadow_cast_bg_extract);
					shader_set_c("refColor",  _refColor);
					shader_set_f("threshold", _bg_thr);
					
					draw_surface(_bg, 0, 0);
				surface_reset_shader();
			}
			
			surface_set_shader(_outData[1], sh_shadow_cast, i == 0);
				BLEND_ADD
				
				shader_set_2("dimension", _dim            );
				shader_set_s("solid",     temp_surface[0] );
				
				shader_set_i("lightType",        _type    );
				shader_set_c("lightClr",         _lclr    );
				shader_set_f("lightInt",         _int     );
				shader_set_2("lightPos",         _pos     );
				shader_set_f("pointLightRadius", _lrad    );
				
				shader_set_i("lightAttn",        _attn    );
				shader_set_curve("attenCurve",   _attC    );
				shader_set_f("lightBand",        _band    );
				
				shader_set_i("lightSoft",        _soft    );
				shader_set_f("lightDensity",     _den     );
				shader_set_f("lightRadius",      _rad     );
				
				shader_set_i("ao",               _ao      );
				shader_set_f("aoRadius",         _ao_rad  );
				shader_set_f("aoStrength",       _ao_str  );
					
				draw_surface_safe(_bg);
			surface_reset_shader();
		}
			
		surface_set_shader(_outData[0], noone);
			draw_surface_ext(_bg, 0, 0, 1, 1, 0, _lamb, 1);
			
			shader_set(sh_shadow_cast_add);
				shader_set_f("intensity", 1);
				
				BLEND_ADD
				draw_surface(_outData[1], 0, 0);
				BLEND_NORMAL
			shader_reset();
			
			if(_solRen && _solidUse) draw_surface(_solid, 0, 0);
		surface_reset_shader();
			
		return _outData;
	}
	
	static preDeserialize = function() {
		if(CLONING) return;
		
		if(LOADING_VERSION < 1_20_01_4) {
			if(array_length(load_map.inputs) > 2)
				array_resize(load_map.inputs, 2);
		}
	}
}