function __Panel_Linear_Setting_Item(name, editWidget, data, onEdit = noone, getDefault = noone) constructor { #region
	self.name       = name;
	self.editWidget = editWidget;
	self.data       = data;
	
	self.onEdit     = onEdit;
	self.getDefault = getDefault;
	
	self.is_patreon = false;
	
	static patreon = function() { is_patreon = true; return self; }
} #endregion

function __Panel_Linear_Setting_Item_Preference(name, key, editWidget, _data = noone) : __Panel_Linear_Setting_Item(name, editWidget, _data) constructor { #region
	self.key = key;
	
	data = function() {
		INLINE
		return PREFERENCES[$ key];
	}
	
	onEdit = function(val) {
		INLINE
		PREFERENCES[$ key] = val;
		PREF_SAVE();
	}
	
	getDefault = function() {
		INLINE
		return PREFERENCES_DEF[$ key];
	}
} #endregion

function __Panel_Linear_Setting_Label(name, sprite, s_index = 0, s_color = c_white) constructor { #region
	self.name    = name;
	self.sprite  = sprite;
	self.s_index = s_index;
	self.s_color = s_color;
} #endregion

function Panel_Linear_Setting() : PanelContent() constructor { #region
	title = __txtx("preview_3d_settings", "3D Preview Settings");
	
	w = ui(400);
	
	bg_y    = -1;
	bg_y_to = -1;
	bg_a    = 0;
	
	properties = []
	static setHeight = function() { h = ui(12 + 36 * array_length(properties)); }
	
	static drawSettings = function(panel) { #region
		var yy = ui(24);
		var th = ui(36);
		var ww = w - ui(180);
		var wh = TEXTBOX_HEIGHT;
		
		var _hov = false;
		if(bg_y) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, ui(4), bg_y, w - ui(8), th, COLORS.panel_prop_bg, 0.5 * bg_a);
		
		for( var i = 0, n = array_length(properties); i < n; i++ ) {
			var _prop = properties[i];
			
			if(is_instanceof(_prop, __Panel_Linear_Setting_Label)) {
				var _text = _prop.name;
				var _spr  = _prop.sprite;
				var _ind  = _prop.s_index;
				var _colr = _prop.s_color;
				
				draw_sprite_stretched_ext(THEME.group_label, 0, ui(4), yy - th / 2 + ui(2), w - ui(8), th - ui(4), _colr, 1);
				draw_sprite_ui(_spr, _ind, ui(4) + th / 2, yy);
				
				draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
				draw_text_add(ui(4) + th, yy, _text);
				
				yy += th;
				continue;
			}
			
			if(is_instanceof(_prop, __Panel_Linear_Setting_Item)) {
				var _text = _prop.name;
				var _data = _prop.data;
				var _widg = _prop.editWidget;
				if(is_callable(_data)) _data = _data();
				
				_widg.setFocusHover(pFOCUS, pHOVER);
				_widg.register();
				
				//if(i % 2) draw_sprite_stretched_ext(THEME.ui_panel_bg, 0, ui(4), yy - th / 2, w - ui(8), th, COLORS.panel_prop_bg, 0.25);
				
				if(pHOVER && point_in_rectangle(mx, my, 0, yy - th / 2, w, yy + th / 2)) {
					bg_y_to = yy - th / 2;
					_hov    = true;
				}
				
				draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
				draw_text_add(ui(16), yy, _text);
			
				var _x1  = w - ui(8);
				var _wdw = ww;
			
				if(_prop.getDefault != noone)
					_wdw -= ui(32 + 8);
				
				var params = new widgetParam(_x1 - ww, yy - wh / 2, _wdw, wh, _data, {}, [ mx, my ], x, y);
				if(is_instanceof(_widg, checkBox)) {
					params.halign = fa_center;
					params.valign = fa_center;
				}
				
				_widg.drawParam(params); 
				
				if(_prop.getDefault != noone) {
					var _defVal = is_method(_prop.getDefault)? _prop.getDefault() : _prop.getDefault;
					var _bs = ui(32);
					var _bx = _x1 - _bs;
					var _by = yy - _bs / 2;
					
					if(isEqual(_data, _defVal))
						draw_sprite_ext(THEME.refresh_16, 0, _bx + _bs / 2, _by + _bs / 2, 1, 1, 0, COLORS._main_icon_dark);
					else {
						if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, [ mx, my ], pFOCUS, pHOVER, __txt("Reset"), THEME.refresh_16) == 2)
							_prop.onEdit(_defVal);
					}
				}
				
				yy += th;
				continue;
			}
		}
		
		bg_a = lerp_float(bg_a, _hov, 2);
		
		if(bg_y == -1) bg_y = bg_y_to;
		else           bg_y = lerp_float(bg_y, bg_y_to, 2);
	} #endregion
	
	function drawContent(panel) { drawSettings(panel); }
} #endregion