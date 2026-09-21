function Panel_Toolbar() : PanelContent() constructor {
	title    = "Toolbar";
	auto_pin = true;
	
	w = ui(480);
	h = ui(24);
	
	min_w = ui(4);
	min_h = ui(4);
	
	padding	= ui(4);
	
	key = $"custom_toolbar_{array_length(struct_get_names(PREFERENCES_MENUITEMS))}";
	
	scroll    = 0;
	scroll_to = 0;
	
	icon_size = ui(28);
	
	function drawContent(panel) {
		title = key;
		
		var menus = menuItems_gen(key);
		var pd = padding;
		var bs = icon_size;
		var bx = pd - scroll;
		var by = pd;
		
		var cy = h / 2;
		var ww = ui(16);
		var sp = ui(2);
		
		var _spFrm = THEME_VALUE.panel_separation_type == "frame";
		var _m  = [mx,my];
		var _cc = [COLORS._main_icon, c_white];
		
		var hover = pHOVER;
		var focus = pFOCUS;
		
		for( var i = 0, n = array_length(menus); i < n; i++ ) {
			var _menu = menus[i];
			
			if(_menu == -1) {
				draw_set_color(COLORS.panel_separator);
				if(_spFrm) draw_line_width(bx + ui(1), by, bx + ui(1), by + bs, ui(1));
				else       draw_line(bx + ui(1), by, bx + ui(1), by + bs);
				
				bx += ui(6);
				ww += ui(6);
				continue;
			} 
			
			var _name = _menu.name;
			var _spr  = _menu.getSpr();
			if(!sprite_exists(_spr)) _spr = THEME.pxc_hub;
			
			var b = buttonInstant_Pad(THEME.button_hide_fill, bx, by, bs, bs, _m, hover, focus, _name, _spr, 0, _cc, 1, ui(8));
			if(b == 2) {
				global.FUNCTION_CALL_EVENT.type = "button";
				var _res = _menu.toggleFunction();
			}
			
			if(_menu.isShelf) draw_sprite_ui_uniform(THEME.menu_shelf, 0, bx+bs-ui(3), by+bs-ui(3), 1, COLORS._main_icon, .75 + b * .25);
			
			bx += bs + sp;
			ww += bs + sp;
			
			if(bx > w - bs) {
				bx  = pd - scroll;
				by += bs + sp;
			}
		}
		
		var scroll_max = max(ww - w + ui(16), 0);
		// scroll = lerp_float(scroll, scroll_to, 5);
		
		if(pHOVER) {
			// scroll_to = scroll_to + MOUSE_WHEEL * (bs + ui(2));
			// scroll_to = clamp(scroll_to, -scroll_max, 0);
			
			if(mouse_rpress(pFOCUS)) menuCall("", [ 
				menuItem(__txt("Edit") + "...", function() /*=>*/ {return menuItemEdit(key)}),
				-1,
				menuItem(__txt("Rename Key"),   function() /*=>*/ {return textboxCall(key, function(txt) /*=>*/ { 
					if(txt == "") return;
					PREFERENCES_MENUITEMS[$ txt] = PREFERENCES_MENUITEMS[$ key];
					key = txt; 
					PREF_SAVE();
				})}),
					
				menuItem(__txt("Set Key"),      function() /*=>*/ {return textboxCall(key, function(txt) /*=>*/ { if(txt == "") return; key = txt; })}),
			]);
			
			if(key_mod_press(CTRL)) icon_size = clamp(icon_size + MOUSE_WHEEL * 4, ui(12), ui(64));
		}
	}
	
    ////- Serialize
    
    static serialize = function() { 
        _map = { 
            name: instanceof(self), 
            key,
        }; 
        
        return _map;
    }
    
    static deserialize = function(data) { 
        key = data[$ "key"] ?? key;
        
        return self; 
    }
    
}