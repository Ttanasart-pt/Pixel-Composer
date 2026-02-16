function __Panel_Linear_Setting_Item(_name, _editWidget, _data = noone, _onEdit = noone, _getDefault = noone, _action = noone, _prefKey = noone) constructor {
	name       = _name;
	editWidget = _editWidget;
	data       = _data;
	
	onEdit     = _onEdit;
	getDefault = _getDefault;
	action     = _action == noone? noone : struct_try_get(FUNCTIONS, string_to_var2(_action[0], _action[1]), noone);
	
	prefKey    = _prefKey;
	key        = "";
	is_patreon = false;
	
	static setKey  = function(k) /*=>*/ { key = k;           return self; }
	static patreon = function( ) /*=>*/ { is_patreon = true; return self; }
}

function __Panel_Linear_Setting_Label(_name, _sprite, _index = 0, _color = c_white) constructor {
	name    = _name;
	sprite  = _sprite;
	index   = _index;
	color   = _color;
}

function Panel_Linear_Setting() : PanelContent() constructor {
	title   = __txt("Settings");
	w       = ui(400);
	wdgw    = ui(200);
	hpad    = 0;
	
	bg_y    = -1;
	bg_y_to = -1;
	bg_a    =  0;
	
	resizable     = false;
	hk_editing    = noone;
	selecting_key = noone;
	properties    = [];
	
	font = PANEL_INSPECTOR.viewMode? f_p2 : f_p3;
	prop_height   = line_get_height(font, 12);
	curr_height   = 0;
	shift_height  = true;
	
	static setHeight   = function() { 
		h = ui(16) + hpad; 
		
		for( var i = 0, n = array_length(properties); i < n; i++ ) {
			var _prop = properties[i];
			
			if(_prop == -1) h += ui(8)
			else            h += prop_height;
		}
	}
	
	static resetHeight = function(_h) { 
		if(h == _h) return;
		
		if(shift_height && in_dialog) {
			panel.dialog_y -= _h - h; 
			panel.dialog_h  = _h 
			h = _h;
			panel.contentResize();
		}
		
		h = _h; 
	}
	
	static drawSettings = function() {
		var yy = ui(4);
		var th = prop_height;
		var ww = max(wdgw, w * 0.5); 
		var wh = prop_height - ui(6);
	
		var _bs = ui(32);
		var _mm = [ mx, my ];
		
		var _hov = false;
		if(bg_y) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, ui(4), bg_y, w - ui(8), th, COLORS.panel_prop_bg, 0.5 * bg_a);
		
		for( var i = 0, n = array_length(properties); i < n; i++ ) {
			var _prop = properties[i];
			
			if(_prop == -1) {
				draw_set_color(CDEF.main_mdblack);
				draw_line_round(ui(16), yy + ui(4), w - ui(16), yy + ui(4), 2);
				yy += ui(8);
				continue;
			}
			
			if(is_array(_prop)) {
				yy += bool(i) * ui(4);
				
				var txt  = __txt(_prop[0]);
                var coll = _prop[1];
                
                var lbx = ui(4);
                var lby = ui(0);
                var lbh = th - ui(4);
                var lbw =  w - ui(8);
                
                if(pHOVER && point_in_rectangle(mx, my, lbx, yy, lbx + lbw, yy + lbh)) {
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
                        if(is_array(properties[j])) break;
                        j++;
                    }
                    i = j - 1;
                }
                
                yy += lbh + (!coll) * ui(4);
                continue;
			}
			
			if(is(_prop, __Panel_Linear_Setting_Label)) {
				var _text = _prop.name;
				var _spr  = _prop.sprite;
				var _ind  = _prop.index;
				var _colr = _prop.color;
				
				draw_sprite_stretched_ext(THEME.box_r5_clr, 0, ui(4), yy + ui(2), w - ui(8), th - ui(4), _colr, 1);
				draw_sprite_ui(_spr, _ind, ui(4) + th / 2, yy + th / 2);
				
				draw_set_text(font, fa_left, fa_center, COLORS._main_text);
				draw_text_add(ui(4) + th, yy + th / 2, _text);
				
				yy += th;
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
				if(pHOVER && point_in_rectangle(mx, my, 0, yy, w, yy + th)) {
					bg_y_to = yy;
					_hov    = true;
					_whover = true;
				}
				
				draw_set_text(font, fa_left, fa_center, COLORS._main_text);
				draw_text_add(ui(16), yy + th / 2, _text);
			
				var _x1  =  w - ui(4);
				var _wdw = ww - ui(4);
				
				if(_prop.prefKey    != noone) _wdw -= ui(24) + ui(4);
				if(_prop.getDefault != noone) _wdw -= ui(24) + ui(4);
				
				var params = new widgetParam(_x1 - ww, yy + th / 2 - wh / 2, _wdw, wh, _data, {}, [ mx, my ], x, y).setFont(font);
				if(is(_widg, checkBox)) { 
					params.s = wh;
					params.halign = fa_center; 
					params.valign = fa_center; 
				}
				
				_widg.drawParam(params); 
				
				if(_prop.action != noone) {
					var _key = _prop.action.hotkey;
					
					if(_whover && !_widg.inBBOX([ mx, my ]) && mouse_press(mb_right)) {
						selecting_key = _key;
						
						var context_menu_settings = [
							_key.getNameFull(),
							menuItem(__txt("Edit Hotkey"),  function() /*=>*/ { hk_editing = selecting_key.modify(); }),
							menuItem(__txt("Reset Hotkey"), function() /*=>*/ {return selecting_key.reset(true)}, THEME.refresh_20).setActive(selecting_key.isModified()),
						];
						
						menuCall("", context_menu_settings);
					}
					
								
					if(_key) {
						draw_set_font(font);
						var _ktxt = _key.getName();
						var _tw   = string_width(_ktxt);
						var _th   = line_get_height();
						
						var _hx = _x1 - ww - ui(16);
						var _hy = yy + th / 2;
							
						var _bx = _hx - _tw - ui(4);
						var _by = _hy - _th / 2 - ui(3);
						var _bw = _tw + ui(8);
						var _bh = _th + ui(6);
						
						if(hk_editing == _key) {
							draw_set_text(font, fa_right, fa_center, COLORS._main_accent);
							draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _bw, _bh, COLORS._main_text_accent);
							
						} else if(_ktxt != "") {
							draw_set_text(font, fa_right, fa_center, COLORS._main_text_sub);
							// draw_sprite_stretched_ext(THEME.ui_panel, 1, _bx, _by, _bw, _bh, CDEF.main_dkgrey);
						}
						
						draw_text(_hx, _hy, _ktxt);
					}
		
				}
				
				var _bx = _x1;
				var _by =  yy + th / 2 - _bs / 2;
				var _cc = [ COLORS._main_icon, COLORS._main_icon_light ];
				
				if(_prop.prefKey != noone) {
					_bx -= ui(24);
					
					var _prefVal = getPreference(_prop.prefKey);
					
					if(isEqual(_data, _prefVal))
						draw_sprite_ui(THEME.icon_default, 0, _bx + ui(24) / 2, _by + _bs / 2, 1, 1, 0, COLORS._main_icon_dark);
						
					else {
						if(buttonInstant(noone, _bx, _by, ui(24), _bs, _mm, pHOVER, pFOCUS, __txt("Set default"), THEME.icon_default, 0, _cc, .75) == 2)
							setPreference(_prop.prefKey, _data);
					}
					
					_bx -= ui(2);
				}
				
				if(_prop.getDefault != noone) {
					var _defVal = _prop.getDefault;
					
					if(_prop.prefKey != noone) _defVal = getPreference(_prop.prefKey);
					else if(is_method(_prop.getDefault)) _defVal = _prop.getDefault();
					
					_bx -= ui(24);
					
					if(isEqual(_data, _defVal))
						draw_sprite_ui(THEME.refresh_16, 0, _bx + ui(24) / 2, _by + _bs / 2, 1, 1, 0, COLORS._main_icon_dark);
					else {
						if(buttonInstant(noone, _bx, _by, ui(24), _bs, _mm, pHOVER, pFOCUS, __txt("Reset"), THEME.refresh_16, 0, _cc, .75) == 2)
							_prop.onEdit(_defVal);
					}
				}
				
				yy += th;
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
		
		curr_height = yy + ui(4) + hpad;
	}
	
	function drawContent() { drawSettings(); }
	function preDraw()     { resetHeight(curr_height); }
}