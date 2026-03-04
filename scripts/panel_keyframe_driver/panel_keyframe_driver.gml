function Panel_Keyframe_Driver() : PanelContent() constructor {
	title = __txtx("driver_settings", "Driver Settings");
	w     = ui(300);
	h     = ui(240);
	auto_pin = true;
	padding  = ui(8);
	
	key   = noone;
	wdgw  = ui(128);
	
	title_actions_show_graph = [ THEME.timeline_graph, 0, COLORS._main_icon ];
	
	title_actions_override = false;
	title_actions = [
		[ "Graph",  title_actions_show_graph, function() /*=>*/ { if(key == noone) return; key.anim.prop.show_graph = !key.anim.prop.show_graph; }  ], 
	];
	
	#region data
		bg_y    = -1;
		bg_y_to = -1;
		bg_a    =  0;
		
		hk_editing    = noone;
		selecting_key = noone;
		
		font = PANEL_INSPECTOR.viewMode? f_p2 : f_p3;
		prop_height   = line_get_height(font, 12);
		curr_height   = 0;
		shift_height  = true;
	#endregion
	
	#region properties
		var __enum_driver = __enum_array_gen([ "None", "Linear", "Wiggle", "Sine" ], s_driver_type);
		sb_type = new scrollBox(__enum_driver, function(val) /*=>*/ { key.drivers.type = val; }, false);
		
		prop_linear = [
			new __Panel_Linear_Setting_Item(
				__txt("Speed"),
				textBox_Number(function(val) /*=>*/ { key.drivers.speed = val; }),
				function() /*=>*/ {return key.drivers.speed}
			),
		];
		
		prop_wiggle = [
			new __Panel_Linear_Setting_Item(
				__txt("Seed"),
				textBox_Number(function(val) /*=>*/ { key.drivers.seed = val; }),
				function() /*=>*/ {return key.drivers.seed}
			),
			new __Panel_Linear_Setting_Item(
				__txt("Sync axis"),
				new checkBox( function() /*=>*/ { key.drivers.axis_sync = !key.drivers.axis_sync; }),
				function() /*=>*/ {return key.drivers.axis_sync}
			),
			new __Panel_Linear_Setting_Item(
				__txt("Frequency"),
				textBox_Number(function(val) /*=>*/ { key.drivers.frequency = val; }),
				function() /*=>*/ {return key.drivers.frequency}
			),
			new __Panel_Linear_Setting_Item(
				__txt("Amplitude"),
				textBox_Number(function(val) /*=>*/ { key.drivers.amplitude = val; }),
				function() /*=>*/ {return key.drivers.amplitude}
			),
			new __Panel_Linear_Setting_Item(
				__txt("Octave"),
				textBox_Number(function(val) /*=>*/ { key.drivers.octave = val; }),
				function() /*=>*/ {return key.drivers.octave}
			),
		];
		
		prop_sine = [
			new __Panel_Linear_Setting_Item(
				__txt("Sync axis"),
				new checkBox( function() /*=>*/ { key.drivers.axis_sync = !key.drivers.axis_sync; }),
				function() /*=>*/ {return key.drivers.axis_sync}
			),
			new __Panel_Linear_Setting_Item(
				__txt("Frequency"),
				textBox_Number(function(val) /*=>*/ { key.drivers.frequency = val; }),
				function() /*=>*/ {return key.drivers.frequency}
			),
			new __Panel_Linear_Setting_Item(
				__txt("Amplitude"),
				textBox_Number(function(val) /*=>*/ { key.drivers.amplitude = val; }),
				function() /*=>*/ {return key.drivers.amplitude}
			),
			new __Panel_Linear_Setting_Item(
				__txt("Phase"),
				textBox_Number(function(val) /*=>*/ { key.drivers.phase = val; }),
				function() /*=>*/ {return key.drivers.phase}
			),
		];
	#endregion
	
	sc_content = new scrollPane(0, 0, function(_y, _m) /*=>*/ {
		draw_clear_alpha(COLORS.panel_bg_clear_inner, 1);
		if(key == noone) return 0;
		
		var props = [];
		switch(key.drivers.type) {
			case DRIVER_TYPE.linear : props = prop_linear; break;
			case DRIVER_TYPE.wiggle : props = prop_wiggle; break;
			case DRIVER_TYPE.sine   : props = prop_sine;   break;
		}
		
		var yy = ui(4) + _y;
		var hh = ui(4);
		var th = prop_height;
		var _w = sc_content.surface_w;
		var ww = max(wdgw, _w * 0.5); 
		var wh = prop_height - ui(6);
	
		var _bs = ui(32);
		
		var _hov = false;
		if(bg_y) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, ui(4), bg_y, _w - ui(8), th, CDEF.main_mdwhite, 1);
		
		for( var i = 0, n = array_length(props); i < n; i++ ) {
			var _prop = props[i];
			
			if(_prop == -1) {
				draw_set_color(CDEF.main_mdblack);
				draw_line_round(ui(16), yy + ui(4), _w - ui(16), yy + ui(4), 2);
				yy += ui(8);
				hh += ui(8);
				continue;
			}
			
			if(is_array(_prop)) {
				yy += bool(i) * ui(4);
				hh += bool(i) * ui(4);
				
				var txt  = __txt(_prop[0]);
                var coll = _prop[1];
                
                var lbx = ui(4);
                var lby = ui(0);
                var lbh = th - ui(4);
                var lbw = _w - ui(8);
                
                if(pHOVER && point_in_rectangle(_m[0], _m[1], lbx, yy, lbx + lbw, yy + lbh)) {
                    draw_sprite_stretched_ext(THEME.box_r5_clr, 0, lbx, yy, lbw, lbh, COLORS.panel_inspector_group_hover, 1);
                	if(mouse_press(mb_left, pFOCUS)) _prop[@ 1] = !coll;
                	
                } else
                    draw_sprite_stretched_ext(THEME.box_r5_clr, 0, lbx, yy, lbw, lbh, CDEF.main_ltgrey, 1);
            	
                draw_sprite_ui(THEME.arrow, coll * 3, lbx + ui(16), yy + lbh / 2, 1, 1, 0, COLORS.panel_inspector_group_bg, 1);
                draw_set_text(font, fa_left, fa_center, COLORS.panel_inspector_group_bg, 1);
                draw_text_add(lbx + ui(32), yy + lbh / 2, txt);
                draw_set_alpha(1);
                
                if(coll) { // skip 
                    var j = i + 1;
                    while(j < n) {
                        if(is_array(props[j])) break;
                        j++;
                    }
                    i = j - 1;
                }
                
                yy += lbh + (!coll) * ui(4);
                hh += lbh + (!coll) * ui(4);
                continue;
			}
			
			if(is(_prop, __Panel_Linear_Setting_Label)) {
				var _text = _prop.name;
				var _spr  = _prop.sprite;
				var _ind  = _prop.index;
				var _colr = _prop.color;
				
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, ui(4), yy + ui(2), _w - ui(8), th - ui(4), _colr, 1);
				draw_sprite_ui(_spr, _ind, ui(4) + th / 2, yy + th / 2);
				
				draw_set_text(font, fa_left, fa_center, COLORS._main_text);
				draw_text_add(ui(4) + th, yy + th / 2, _text);
				
				yy += th;
				hh += th;
				continue;
			}
			
			if(is(_prop, __Panel_Linear_Setting_Item)) {
				var _text = _prop.name;
				var _data = _prop.data;
				var _widg = _prop.editWidget;
				if(is_callable(_data)) _data = _data();
				
				_widg.setFocusHover(pFOCUS, pHOVER);
				_widg.register();
				
				var _whover = false;
				if(pHOVER && point_in_rectangle(_m[0], _m[1], 0, yy, _w, yy + th)) {
					bg_y_to = yy;
					_hov    = true;
					_whover = true;
				}
				
				draw_set_text(font, fa_left, fa_center, COLORS._main_text);
				draw_text_add(ui(16), yy + th / 2, _text);
				
				var _x1  = _w - ui(4);
				var _wdw = ww - ui(4);
				
				var params = new widgetParam(_x1 - ww, yy + th / 2 - wh / 2, _wdw, wh, _data, {}, _m, x, y).setFont(font);
				if(is(_widg, checkBox)) { 
					params.s = wh;
					params.halign = fa_center; 
					params.valign = fa_center; 
				}
				
				_widg.drawParam(params); 
				
				yy += th;
				hh += th;
				continue;
			}
		}
		
		bg_a = lerp_float(bg_a, _hov, 2);
		bg_y = bg_y == -1? bg_y_to : lerp_float(bg_y, bg_y_to, 2);
		
		if(hk_editing != noone) { 
			if(key_press(vk_enter))  hk_editing = noone;
			else hotkey_editing(hk_editing);
			
			if(key_press(vk_escape)) hk_editing = noone;
		}
		
		return hh;
	});
	
	function drawContent() {
		key = array_safe_get(PANEL_ANIMATION.keyframe_selecting, 0, noone);
		title_actions_show_graph[2] = key && key.anim.prop.show_graph? COLORS._main_accent : COLORS._main_icon;
		
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		var tw = max(wdgw, pw * 0.5); 
		var th = prop_height - ui(6);
		
		if(key) {
			draw_set_text(font, fa_left, fa_center, COLORS._main_text);
			draw_text_add(px + ui(16), py + th / 2, __txt("Type"));
			
			var tx   = w - padding - tw;
			var ty   = py;
			var _typ = key.drivers.type;
			sb_type.setFocusHover(pFOCUS, pHOVER);
			sb_type.register();
			
			var params = new widgetParam(tx, ty, tw, th, _typ, {}, [mx,my], x, y).setFont(font);
			sb_type.drawParam(params); 
			
		} else {
			draw_set_text(font, fa_center, fa_center, COLORS._main_text_sub);
			draw_text_add(w / 2, py + th / 2, __txt("No key selected"));
			
		}
		
		py += th + ui(10);
		ph -= th + ui(10);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(4), py - ui(4), pw + ui(8), ph + ui(8));
		
		sc_content.setFocusHover(pFOCUS, pHOVER);
		sc_content.verify(pw, ph);
		sc_content.drawOffset(px, py, mx, my);
	}
}