enum PB_EFFECT_TYPES {
	fill,
	stroke,
	corner,
	highlight,
	extrude,
	shine,
}

function Node_PB_Draw(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "PB Draw";
	color = COLORS.node_blend_feedback;
	preview_channel = 1;
	
	newInput(0, nodeValue_Pbbox("Base PBBOX"));
	newInput(1, nodeValue_Pbbox("PBBOX"));
	inputs[0].editWidget = noone;
	
	newInput(2, nodeValue_Float("PBBOX Left", 0));
	newInput(3, nodeValue_Float("PBBOX Top", 0));
	newInput(4, nodeValue_Float("PBBOX Right", 0));
	newInput(5, nodeValue_Float("PBBOX Bottom", 0));
	newInput(6, nodeValue_Float("PBBOX Width", 0));
	newInput(7, nodeValue_Float("PBBOX Height", 0));
	
	typeList = [ "Fill", "Stroke", "Corner", "Highlight", "Extrude", "Shine" ];
	
	fill_pattern_data = [ "Solid", 
           -1, "Stripe X", "Stripe Y", "Stripe D0", "Stripe D1",  
           -1, "Checker", "Checker Diag", 
           -1, "Grid", "Grid Diag",    
           -1, "Half X", "Half Y", "Half D0", "Half D1", 
           -1, "Grad X", "Grad Y", "Grad D0", "Grad D1",
           -1, "Grad Both X", "Grad Both Y", "Grad Both D0", "Grad Both D1",
           -1, "Grad Circular", "Grad Radial", 
           -1, "Brick X", "Brick Y",
           -1, "Zigzag X", "Zigzag Y", "Half Zigzag X", "Half Zigzag Y", 
           -1, "Half Wave X", "Half Wave Y", 
           -1, "Noise", 
	];
    fill_pattern_scroll_data = array_create_ext(array_length(fill_pattern_data), 
    	function(i) /*=>*/ {return fill_pattern_data[i] == -1? -1 : new scrollItem(fill_pattern_data[i], s_node_pb_pattern, i)});
    
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		dynamic_input_inspecting = getInputAmount();
		
		newInput(index + 0, nodeValue_Enum_Scroll("Effect Type", 0, typeList));
		
		newInput(index + 1, nodeValue_Color(  "Color", ca_white));
		newInput(index + 2, nodeValue_Slider(  "Intensity", 1));
		
		newInput(index + 3, nodeValue_Enum_Scroll( "Pattern", 0, { data: fill_pattern_scroll_data, horizontal: true, text_pad: ui(16) } ));
		newInput(index + 4, nodeValue_Color(  "Color", ca_white));
		newInput(index + 5, nodeValue_Slider(  "Intensity", 1));
		newInput(index + 6, nodeValue_Vec2(  "Scale", [1,1])).setUnitRef(function(i) /*=>*/ {return group.dimension});
		newInput(index + 7, nodeValue_Vec2(  "Position", [0,0])).setUnitRef(function(i) /*=>*/ {return group.dimension});
		newInput(index + 8, nodeValue_Bool(  "Map BBOX", false));
		
		// Stroke
		newInput(index +  9, nodeValue_Int(  "Thickness", 1));
		newInput(index + 10, nodeValue_Enum_Button( "Position", 1, array_create(3, THEME.stroke_position) ));
		newInput(index + 11, nodeValue_Enum_Button( "Corner", 0, array_create(2, THEME.stroke_profile)  ));
		
		// Corner
		newInput(index + 12, nodeValue_Int(  "Radius", 1));
		
		// Highlight
		newInput(index + 13, nodeValue_Int(  "Widths", [ 0, 0, 0, 0 ])).setDisplay(VALUE_DISPLAY.padding);
		newInput(index + 14, nodeValue_Color(  "Color Left", ca_white));
		newInput(index + 15, nodeValue_Color(  "Color Right", ca_white));
		newInput(index + 16, nodeValue_Color(  "Color Top", ca_white));
		newInput(index + 17, nodeValue_Color(  "Color Bottom", ca_white));
		
		// Generic Props
		newInput(index + 18, nodeValue_Float(  "Modify", 4));
		newInput(index + 19, nodeValue_Bool(  "Subtract", false));
		newInput(index + 20, nodeValue_Rotation(  "Direction", -90));
		
		// Shines
		newInput(index + 21, nodeValue_Float(  "Shines", [ 2, 1, 1 ]))
	    	.setDisplay(VALUE_DISPLAY.number_array);
		newInput(index + 22, nodeValue_Slider(  "Progress", .5));
		newInput(index + 23, nodeValue_Float(  "Slope",  1));
		newInput(index + 24, nodeValue_Enum_Button( "Axis",  0, [ "X", "Y" ]));
		newInput(index + 25, nodeValue_Float(  "Seed",  seed_random()));
		
		refreshDynamicDisplay();
		return inputs[index];
	} 
	
	////////////////////////////////////////////////////////////////////////////////
	
	newOutput(0, nodeValue_Output("PBBOX", VALUE_TYPE.pbBox, noone));
	
	newOutput(1, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	pbi = array_length(inputs);
	
	effect_dragging = noone;
	effect_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		if(array_length(current_data) != array_length(inputs)) return 0;
		
		var bs = ui(24);
		var bx = _x;
		var by = _y;
		
		for( var i = 0, n = array_length(typeList); i < n; i++ ) {
			var _txt = $"New {typeList[i]}";
			
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, _txt, s_node_pb_effect_types, i, COLORS._main_icon, 1, .75) == 2) {
				var _inTyp = createNewInput(); 
			    _inTyp.setValue(i);
				triggerRender();
			}
			
			bx += bs + ui(4);
		}
			
		var amo = getInputAmount();
		var lh  = ui(28);
		var _h  = ui(12) + lh * amo;
		var yy  = _y + bs + ui(4);
		var hoverIndex = noone;
		
		var del_fx = -1;
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, yy, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		for(var i = 0; i < amo; i++) {
			var _x0 = _x + ui(12);
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
					effect_dragging = i;
				}
				
				if(effect_dragging != noone) {
					hoverIndex = i;
					
					draw_set_color(COLORS._main_accent);
					     if(effect_dragging > i) draw_line_width(_x + ui(16), _yy - lh / 2 + 2, _x + _w - ui(16), _yy - lh / 2 + ui(2), 2);
					else if(effect_dragging < i) draw_line_width(_x + ui(16), _yy + lh / 2 - 2, _x + _w - ui(16), _yy + lh / 2 - ui(2), 2);
				}
			}
			
			draw_sprite_ext(s_node_pb_effect_types, _typ, _x0 + ui(8), _yy, 1, 1, 0, _col, 1);
			
			draw_set_text(f_p2, fa_left, fa_center, tc);
			draw_text_add(_x0 + ui(28), _yy, typeList[_typ]);
			
			var bs = ui(24);
			var bx = _x1 - bs;
			var by = _yy - bs / 2;
			if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, hov? COLORS._main_value_negative : COLORS._main_icon) == 2) 
				del_fx = i;	
		}
		
		if(effect_dragging != noone && mouse_release(mb_left)) {
			if(effect_dragging != hoverIndex && hoverIndex != noone) {
				var index = input_fix_len + effect_dragging * data_length;
				var targt = input_fix_len + hoverIndex * data_length;
				
				var ext = [];
				for( var i = 0; i < data_length; i++ ) {
					ext[i] = inputs[index];
					array_delete(inputs, index, 1);
				}
				
				for( var i = 0; i < data_length; i++ )
					array_insert(inputs, targt + i, ext[i]);
				
				dynamic_input_inspecting = hoverIndex;
				refreshDynamicDisplay(); 
				triggerRender();
			}
			
			effect_dragging = noone;
			refreshDynamicDisplay();
		}
		
		if(del_fx > -1) deleteDynamicInput(del_fx);
		
		
		return ui(32) + _h;
	});
	
	input_display_dynamic = [ 0, 
		["Properties", false],  2,  9, 10, 11, 12, 13, 19, 20, 21, 22, 23, 24, 
		["Base Color", false],  1, 14, 15, 16, 17, 
		["Pattern",    false],  3, 25,  4,  5,  6,  7,  8, 18, 
	];
	
	input_display_list = [
		["Layout",         false], 0, 1, 
		["Layout Override", true], 2, 3, 4, 5, 6, 7, 
		["Effects",        false], effect_renderer, 
	]
	
	input_display_shape_index = array_length(input_display_list) - 2;
	setDynamicInput(26, false);
	if(!LOADING && !APPENDING) run_in(1, function() /*=>*/ {return createNewInput()});
	
	temp_surface = [ noone, noone ];
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var _pbase = getSingleValue(0);
		var _pbbox = getSingleValue(1);
		
		if(is(_pbase, __pbBox)) {
			draw_set_color(COLORS._main_icon);
			_pbase.drawOverlayBBOX(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
		}
		
		if(is(_pbbox, __pbBox)) _pbbox.drawOverlay(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, self);
	}
	
	static getBBOX = function(_data) {
		var _dim   = group.dimension;
		var _pbase = _data[0];
		var _pbbox = _data[1];
		
		if(inputs[0].value_from == noone) _pbase.base_bbox = [ 0, 0, _dim[0], _dim[1] ];
		if(inputs[2].value_from != noone || inputs[2].is_anim) _pbbox.anchor_l = _data[2];
		if(inputs[3].value_from != noone || inputs[3].is_anim) _pbbox.anchor_t = _data[3];
		if(inputs[4].value_from != noone || inputs[4].is_anim) _pbbox.anchor_r = _data[4];
		if(inputs[5].value_from != noone || inputs[5].is_anim) _pbbox.anchor_b = _data[5];
		if(inputs[6].value_from != noone || inputs[6].is_anim) _pbbox.anchor_w = _data[6];
		if(inputs[7].value_from != noone || inputs[7].is_anim) _pbbox.anchor_h = _data[7];
		
		_pbbox.base_bbox = is(_pbase, __pbBox)? _pbase.getBBOX() : [ 0, 0, _dim[0], _dim[1] ];
		return _pbbox.getBBOX();
	}
	
	static pbDrawSurface = function(_data, _bbox) {}
	
	function dynamic_visibility() {
		dynamic_input_inspecting = clamp(dynamic_input_inspecting, 0, getInputAmount() - 1);
		var _ind = input_fix_len + dynamic_input_inspecting * data_length;
		
		var _type = getSingleValue(_ind + 0);
		var _patt = getSingleValue(_ind + 3);
		
		inputs[_ind +  4].setVisible(_patt > 0);
		inputs[_ind +  5].setVisible(_patt > 0);
		inputs[_ind +  6].setVisible(_patt > 0);
		inputs[_ind +  7].setVisible(_patt > 0);
		inputs[_ind +  8].setVisible(_patt > 0);
		inputs[_ind + 18].setVisible(_patt >= 18 && _patt <= 29);
		inputs[_ind + 25].setVisible(_patt == 42);
		
		inputs[_ind +  9].setVisible(_type == PB_EFFECT_TYPES.stroke || _type == PB_EFFECT_TYPES.extrude);
		inputs[_ind + 10].setVisible(_type == PB_EFFECT_TYPES.stroke);
		inputs[_ind + 11].setVisible(_type == PB_EFFECT_TYPES.stroke);
		
		inputs[_ind + 12].setVisible(_type == PB_EFFECT_TYPES.corner);
		
		inputs[_ind +  1].setVisible(_type != PB_EFFECT_TYPES.highlight);
		inputs[_ind + 13].setVisible(_type == PB_EFFECT_TYPES.highlight);
		inputs[_ind + 14].setVisible(_type == PB_EFFECT_TYPES.highlight);
		inputs[_ind + 15].setVisible(_type == PB_EFFECT_TYPES.highlight);
		inputs[_ind + 16].setVisible(_type == PB_EFFECT_TYPES.highlight);
		inputs[_ind + 17].setVisible(_type == PB_EFFECT_TYPES.highlight);
		
		inputs[_ind + 20].setVisible(_type == PB_EFFECT_TYPES.extrude);
		
		inputs[_ind + 21].setVisible(_type == PB_EFFECT_TYPES.shine);
		inputs[_ind + 22].setVisible(_type == PB_EFFECT_TYPES.shine);
		inputs[_ind + 23].setVisible(_type == PB_EFFECT_TYPES.shine);
		inputs[_ind + 24].setVisible(_type == PB_EFFECT_TYPES.shine);
	}
	
	static processData = function(_outData, _data, _array_index) { 
		if(getInputAmount() == 0) return _outData;
		dynamic_visibility();
		
		var _dim     = group.dimension;
		var _outSurf = surface_verify(_outData[0], _dim[0], _dim[1]);
		for( var i = 0, n = array_length(temp_surface); i < n; i++ )
			temp_surface[i] = surface_verify(temp_surface[i], _dim[0], _dim[1]);
		
		var _pbbox = _data[1];
		var _bbox  = getBBOX(_data);
		
		var _draws = temp_surface[0];
		var _bboxw = _bbox[2] - _bbox[0];
		var _bboxh = _bbox[3] - _bbox[1];
		
		surface_set_shader(_draws, noone);
			draw_set_color(c_white);
			if(_bboxw && _bboxh) 
				pbDrawSurface(_data, _bbox);
		surface_reset_shader();
		
		////
		
		var bg = 0;
		for( var i = 0; i < getInputAmount(); i++ ) {
			var _ind = input_fix_len + i * data_length;
			
			bg = !bg;
			surface_set_shader(temp_surface[bg], sh_pb_draw);
				shader_set_i("empty",     i == 0 );
				shader_set_2("dimension", _dim );
				shader_set_4("bbox",      _bbox);
				shader_set_i("subtract",  _data[_ind + 19]);
				shader_set_f("seed",      _data[_ind + 25]);
				
				shader_set_i("type",            _data[_ind +  0]);
				shader_set_c("color",           _data[_ind +  1]);
				shader_set_f("intensity",       _data[_ind +  2]);
				shader_set_f("direction",       degtorad(_data[_ind + 20]));
			
				shader_set_i("pattern",         _data[_ind +  3]);
				shader_set_c("pattern_color",   _data[_ind +  4]);
				shader_set_f("pattern_inten",   _data[_ind +  5]);
				shader_set_2("pattern_scale",   _data[_ind +  6]);
				shader_set_2("pattern_pos",     _data[_ind +  7]);
				shader_set_i("pattern_map",     _data[_ind +  8]);
				shader_set_f("pattern_mod",     _data[_ind + 18]);
				
				shader_set_f("stroke_thickness",_data[_ind +  9]);
				shader_set_i("stroke_position", _data[_ind + 10]);
				shader_set_i("stroke_corner",   _data[_ind + 11]);
				
				shader_set_f("corner_radius",   _data[_ind + 12]);
				
				shader_set_4("highlight_width", _data[_ind + 13]);
				shader_set_c("highlight_l",     _data[_ind + 14]);
				shader_set_c("highlight_r",     _data[_ind + 15]);
				shader_set_c("highlight_t",     _data[_ind + 16]);
				shader_set_c("highlight_b",     _data[_ind + 17]);
				
				var _shine = _data[_ind + 21];
				shader_set_f("shines",          _shine);
				shader_set_i("shines_amount",   array_length(_shine));
            	shader_set_f("shines_width",    array_sum(_shine));
				shader_set_f("progress",        _data[_ind + 22]);
				shader_set_f("shines_slope",    _data[_ind + 23]);
				shader_set_i("shines_axis",     _data[_ind + 24]);
				
				draw_surface_safe(temp_surface[!bg]);
			surface_reset_shader();
		}
		
		surface_set_shader(_outSurf);
			draw_surface_safe(temp_surface[bg]);
		surface_reset_shader();
		
		return [ _pbbox, _outSurf ];
	}
	
	
}