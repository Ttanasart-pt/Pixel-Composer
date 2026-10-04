function Node_Colors_Replace(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Replace Colors";
	
	newActiveInput(6);
	
	////- =Surface
	newInput( 0, nodeValue_Surface( "Surface In" )).setRequired();
	newInput( 4, nodeValue_Surface( "Mask"       ));
	newInput( 5, nodeValue_Slider(  "Mix",     1 ));
	__init_mask_modifier(4, 7); // inputs 7, 8, 
	
	////- =Replace
	newInput( 1, nodeValue_Palette( "Palette from",   []    ));
	newInput( 2, nodeValue_Palette( "Palette to",     []    )).setVisible(false, false);
	
	////- =Matching
	newInput( 3, nodeValue_Slider(  "Threshold",            0     ));
	newInput( 9, nodeValue_Bool(    "Multiply Alpha",       true  ));
	newInput(10, nodeValue_Bool(    "Apply Original Alpha", false ));
	// 11
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	////- Inspector
	
	palette_selecting = noone;
	palette_select    = [-1,-1];
	index_select      = -1;
	
	static setColorFrom = function(colr) { inputs[index_select].setValue(colr); } 
	static setColorTo   = function(colr) {
		palette_selecting = noone;
		for (var i = palette_select[0]; i <= palette_select[1]; i++)
			inputs[input_fix_len + palette_select[0] * data_length + 1].setValue(colr);
	} 
	
	sort_menu = [
		new MenuItem("Sort Brightness", function() /*=>*/ { sortPalette(0) }),
		new MenuItem("Sort Dark",		function() /*=>*/ { sortPalette(1) }),
		
		new MenuItem("Sort Hue",		function() /*=>*/ { sortPalette(2) }),
		new MenuItem("Sort Saturation", function() /*=>*/ { sortPalette(3) }),
		new MenuItem("Sort Value",		function() /*=>*/ { sortPalette(4) }),
		
		new MenuItem("Sort Red",		function() /*=>*/ { sortPalette(5) }),
		new MenuItem("Sort Green",		function() /*=>*/ { sortPalette(6) }),
		new MenuItem("Sort Blue",		function() /*=>*/ { sortPalette(7) }),
	];
	
	render_palette_h = 0;
	render_palette   = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var bx = _x;
		var by = _y;
		
		var bs = ui(24);
		
		var bt = __txt("Add Color");
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, bt, THEME.add_16, 0, COLORS._main_value_positive) == 2) 
			createNewInput();
		bx += bs + ui(4);
			
		var bt = __txt("Extract All Colors");
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, bt, THEME.refresh_16) == 2) 
			refreshPalette();
		bx += bs + ui(4);
			
		var bt = __txt("Sort...");
		if(buttonInstant(THEME.button_hide_fill, bx, by, bs, bs, _m, _hover, _focus, bt, THEME.sort_16) == 2)
			menuCall("", sort_menu);
		
		var amo   = getInputAmount();
		
		var ss  = ui(24);
		var top = bs  + ui(4);
		var hh  = top + ui(4);
		var _yy = _y + top;
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _yy, _w, render_palette_h - top, COLORS.node_composite_bg_blend, 1);
		
		var _selecting_y = 0;
		var _selecting_h = 0;
		var _sample = PANEL_PREVIEW.sample_color;
		
		var _sel_x0 = 0;
		var _sel_x1 = 0;
		var _sel_y0 = 0;
		var _sel_y1 = 0;
		
		var  bb = THEME.button_hide_fill;
		var  bs = ss;
		
		var _x0 = _x  + ui(8);
		var _y0 = _yy + ui(8);
		
		var toDel = undefined;
		
		for( var i = 0; i < amo; i++ ) {
			var ind = input_fix_len + i * data_length;
			
			var jfr = inputs[ind + 0];
			var jto = inputs[ind + 1];
			
			var fr = getInputData(ind + 0);
			var to = getInputData(ind + 1);
			
			var cc = _sample == fr? c_white : COLORS._main_icon;
			var aa = 0.5 + (_sample == fr) * 0.5;
			
			var xx = _x0;
			var ww = _w - ui(8);
			
			by = _y0 + ss / 2 - bs / 2;
			
			#region Left Buttons
				var bi = jfr.value_from == noone? jfr.is_anim : 2;
				var bc = bi? COLORS._main_accent : COLORS._main_icon;
				if(buttonInstant_Pad(bb, xx, by, bs, bs, _m, _hover, _focus, "", THEME.animate_clock, bi, bc, 1, ui(8)) == 2)
					jfr.setAnim(!jfr.is_anim);
				
				xx += bs + ui(4);
				ww -= bs + ui(4);
			#endregion
			
			draw_sprite_stretched_ext(THEME.box_r5, 0, xx, _y0, ss, ss, fr,  1);
			draw_sprite_stretched_ext(THEME.box_r5, 2, xx, _y0, ss, ss, COLORS._main_icon_dark);
			draw_sprite_stretched_ext(THEME.box_r5, 1, xx, _y0, ss, ss, COLORS._main_icon);
			
			if(_hover && point_in_rectangle(_m[0], _m[1], xx, _y0, xx + ss, _y0 + ss)) {
				draw_sprite_stretched_add(THEME.box_r5, 1, xx, _y0, ss, ss, c_white, .3);
				index_select = ind;
				if(mouse_lpress(_focus)) colorSelectorCall(fr, function(c) /*=>*/ {return setColorFrom(c)});
			}
			
			xx += ss + ui(16);
			ww -= ss + ui(16);
			
			#region Right Buttons
				bx = xx + ww - bs - ui(4);
				
				if(buttonInstant_Pad(bb, bx, by, bs, bs, _m, _hover, _focus, "", THEME.minus_16, 0, CARRAY.button_negative, 1, ui(8)) == 2)
					toDel = ind;
				
				bx -= bs + ui(4);
				ww -= bs + ui(4);
				
				if(buttonInstant_Pad(bb, bx, by, bs, bs, _m, _hover, _focus, "", THEME.color_picker_dropper, 0, c_white, 1, ui(8)) == 2) {
					colorSelectorCall(undefined, function(c) /*=>*/ {return setColor(c)}).dropperActive();
					palette_select = [ i, i ];
				}
				
				bx -= bs + ui(4);
				ww -= bs + ui(4);
				
				if(buttonInstant_Pad(bb, bx, by, bs, bs, _m, _hover, _focus, "", THEME.color_wheel, 0, c_white, 1, ui(8)) == 2) {
					var pick = instance_create(mouse_mx, mouse_my, o_dialog_color_quick_pick);
					array_insert(pick.palette, 0, to);
					pick.onModify = function(c) /*=>*/ {return setColor(c)};
					palette_select = [ i, i ];
				}
				
				bx -= bs + ui(4);
				ww -= bs + ui(4);
				
				ww -= ui(4);
			#endregion
			
			draw_sprite_ui(THEME.arrow, 0, xx - ui(8), _y0 + ss / 2, .75, .75, 0, c_white, 0.5);
			
			#region Left Buttons
				var bi = jto.value_from == noone? jto.is_anim : 2;
				var bc = bi? COLORS._main_accent : COLORS._main_icon;
				if(buttonInstant_Pad(bb, xx, by, bs, bs, _m, _hover, _focus, "", THEME.animate_clock, bi, bc, 1, ui(8)) == 2)
					jto.setAnim(!jto.is_anim);
				
				xx += bs + ui(4);
				ww -= bs + ui(4);
			#endregion
			
			draw_sprite_stretched_ext(THEME.box_r5, 0, xx, _y0, ww, ss, to, 1);
			draw_sprite_stretched_ext(THEME.box_r5, 2, xx, _y0, ww, ss, COLORS._main_icon_dark);
			draw_sprite_stretched_ext(THEME.box_r5, 1, xx, _y0, ww, ss, COLORS._main_icon);
			
			if(_hover && point_in_rectangle(_m[0], _m[1], xx, _y0, xx + ww, _y0 + ss)) {
				if(palette_selecting == noone)
					draw_sprite_stretched_add(THEME.box_r5, 1, xx, _y0, ww, ss, c_white, .3);
				
				if(palette_selecting == noone && mouse_lpress(_focus)) {
					palette_selecting = 1;
					palette_select[0] = i;
				}
				
				if(palette_selecting == 1)
					palette_select[1] = i;
			}
				
			if(i == min(palette_select[0], palette_select[1])) {
				_sel_x0 =  xx;
				_sel_y0 = _y0;
			}
			
			if(i == max(palette_select[0], palette_select[1])) {
				_sel_x1 =  xx + ww;
				_sel_y1 = _y0 + ss;
			}
			
			_y0 += ss + ui(4);
			 hh += ss + ui(4);
		}
		
		if(palette_selecting) {
			var _mn = min(palette_select[0], palette_select[1]);
			var _mx = max(palette_select[0], palette_select[1]);
			
			draw_sprite_stretched_add(THEME.box_r5, 2, _sel_x0, _sel_y0, _sel_x1 - _sel_x0, _sel_y1 - _sel_y0, COLORS._main_accent, 1);
			
			if(palette_selecting == 1 && mouse_lrelease(_focus)) {
				palette_selecting = 2;
				palette_select    = [ _mn, _mx ];
				
				var _col = getInputData(input_fix_len + palette_select[0] * data_length + 1);
				colorSelectorCall(_col, function(c) /*=>*/ {return setColorTo(c)});
			}
		}
		
		if(toDel != undefined) {
			array_delete(inputs, toDel, 2);
			triggerRender();
		}
		
		render_palette_h = hh + ui(8);
		return hh + ui(8);
	});
	
	input_display_list = [  6, 
		[ "Surfaces",  true ],  0,  4,  5,  7,  8, 
		[ "Replace",  false ], render_palette, 
		[ "Matching", false ],  3,  9, 10, 
	];
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		var ifrom = newInput(index+0, nodeValue_Color( "Color From", ca_white ));
		var ito   = newInput(index+1, nodeValue_Color( "Color To",   ca_white ));
		return [ifrom,ito];
	} 
	
	setDynamicInput( 2, false );
	
	////- Node
	
	attribute_surface_depth();
	
	attributes.auto_refresh = true;
		
	array_push(attributeEditors, Node_Attribute("Auto refresh", function() /*=>*/ {return attributes.auto_refresh}, function() /*=>*/ {return new checkBox(function() /*=>*/ {return toggleAttribute("auto_refresh", true)})}));
		
	static sortPalette = function(type) {
		var amo = getInputAmount();
		var fr  = array_create(amo);
		var to  = array_create(amo);
		
		for( var i = 0; i < amo; i++ ) {
			fr[i] = getInputData(input_fix_len + i * data_length + 0);
			to[i] = getInputData(input_fix_len + i * data_length + 1);
		}
		
		var _map = ds_map_create();
		for (var i = 0, n = array_length(fr); i < n; i++)
			_map[? fr[i]] = to[i];
		
		switch(type) {
			case 0 : array_sort(fr, __sortBright); break;
			case 1 : array_sort(fr, __sortDark);   break;
			
			case 2 : array_sort(fr, __sortHue);    break;
			case 3 : array_sort(fr, __sortSat);    break;
			case 4 : array_sort(fr, __sortVal);    break;
			
			case 5 : array_sort(fr, __sortRed);    break;
			case 6 : array_sort(fr, __sortGreen);  break;
			case 7 : array_sort(fr, __sortBlue);   break;
		}
		
		for (var i = 0, n = array_length(to); i < n; i++)
			to[i] = _map[? fr[i]]
		
		ds_map_destroy(_map);
		
		for( var i = 0; i < amo; i++ ) {
			inputs[input_fix_len + i * data_length + 0].setValue(fr[i]);
			inputs[input_fix_len + i * data_length + 1].setValue(to[i]);
		}
	}
			
	static refreshPalette = function() {
		var _surf = inputs[0].getValue();
		
		if(!is_array(_surf)) _surf = [ _surf ];
		
		var _pall = ds_map_create();
		var _amsk = 0b11111111 << 24;
		
		for( var i = 0, n = array_length(_surf); i < n; i++ ) {
			var _s = _surf[i];
			if(!is_surface(_s)) continue;
			
			var ww = surface_get_width_safe(_s);
			var hh = surface_get_height_safe(_s);
			var aa = ww * hh;
			var c_buffer = buffer_create(aa * 4, buffer_fixed, 2);
			
			buffer_get_surface(c_buffer, _s, 0);
			buffer_seek(c_buffer, buffer_seek_start, 0);
		
			repeat(aa) {
				var b = buffer_read(c_buffer, buffer_u32);
				if((b & _amsk) == 0) continue;
				
				var c = b | _amsk;
				_pall[? c] = 1;
			}
		
			buffer_delete(c_buffer);
		}
		
		var palette = ds_map_keys_to_array(_pall);
		ds_map_destroy(_pall);
		
		var len = array_length(palette);
		if(len > 128) noti_warning($"Large amount of color ({len}) can causes performance issues.");
		
		array_sort(palette, __sortHue);
		
		for(var i = input_fix_len, n = array_length(inputs); i < n; i++)
			delete inputs[i];
		array_resize(inputs, input_fix_len);
		
		for( var i = 0, n = array_length(palette); i < n; i++ ) {
			var pal  = palette[i];
			var inps = createNewInput();
			
			inps[0].setValue(pal);
			inps[1].setValue(pal);
		}
		
	}
	
	static processData = function(_outSurf, _data, _array_index) {		
		#region data
			var msk = _data[ 4];
			
			var thr = _data[ 3];
			var mul = _data[ 9];
			var ori = _data[10];
		#endregion
		
		var amo = getInputAmount();
		var fr  = array_create(amo);
		var to  = array_create(amo);
		
		for( var i = 0; i < amo; i++ ) {
			fr[i] = _data[input_fix_len + i * data_length + 0];
			to[i] = _data[input_fix_len + i * data_length + 1];
		}
		
		surface_set_shader(_outSurf, sh_colours_replace);
			shader_set_palette( fr, "colorFrom", "colorFromAmount" );
			shader_set_palette( to, "colorTo",   "colorToAmount"   );
			
			shader_set_i( "useMask", is_surface(msk) );
			shader_set_s( "mask",    msk );
			
			shader_set_f( "threshold",    thr );
			shader_set_i( "alpha",        mul );
			shader_set_i( "multiplyOrig", ori );
			
			draw_surface_safe(_data[0]);
		surface_reset_shader();
		
		__process_mask_modifier(_data);
		_outSurf = mask_apply_input(_data[0], _outSurf, _data[4], _data[5], inputs[4]);
		
		return _outSurf;
	}
	
	////- Serialize
	
	static postLoad = function() {
		if(LOADING_VERSION >= 1_22_00_2) return;
		
		var i1 = load_map.inputs[1];
		var i2 = load_map.inputs[2];
		
		var _frOld = has(i1, "r")? i1.r.d : i1.raw_value.d;
		var _toOld = has(i2, "r")? i2.r.d : i2.raw_value.d;
		var _amo   = min(array_length(_frOld), array_length(_toOld));
		
		for( var i = 0; i < _amo; i++ ) {
			var inps = createNewInput();
			
			inps[0].setValue(_frOld[i]);
			inps[1].setValue(_toOld[i]);
		}
	}
	
}