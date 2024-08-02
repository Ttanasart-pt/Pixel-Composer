/// @description init
event_inherited();

#region data
	dialog_w = ui(1068);
	dialog_h = ui(468);
	title_height = 52;
	
	name = __txtx("gradient_editor_title", "Gradient editor");
	gradient      = noone;
	interactable  = true;
	drop_target   = noone;
	
	key_selecting = noone;
	key_dragging  = noone;
	key_deleting  = false;
	key_drag_dead = true;
	key_drag_sx   = 0;
	key_drag_sy   = 0;
	key_drag_mx   = 0;
	key_drag_my   = 0;
	
	destroy_on_click_out = true;
	
	sl_position = slider(0, 100, 0.1, function(val) { 
		if(!interactable) return;
		if(key_selecting == noone) return;
		setKeyPosition(key_selecting, val / 100);
	}, function() { removeKeyOverlap(key_selecting); }).setLabel(__txt("Position"));
	
	setColor = function(color) {
		if(key_selecting == noone) return;
		key_selecting.value = int64(color);
		
		onApply(gradient);
	}
	
	function setGradient(grad) { 
		gradient = grad;
		if(array_empty(grad.keys)) return;
		
		key_selecting = grad.keys[0];
		selector.setColor(key_selecting.value, false);
	}
	
	selector = new colorSelector(setColor);
	selector.dropper_close = false;
	
	previous_gradient = noone;
	
	function setDefault(grad) {
		setGradient(grad);
		previous_gradient = grad.clone();
	}
	
	b_cancel = button(function() {
		onApply(previous_gradient);
		instance_destroy();
	}).setIcon(THEME.undo, 0, COLORS._main_icon)
	  .setTooltip(__txtx("dialog_revert_and_exit", "Revert and exit"));
	
	b_apply = button(function() {
		onApply(gradient);
		instance_destroy();
	}).setIcon(THEME.accept, 0, COLORS._main_icon_dark);
	
	function setKeyPosition(key, position) {
		key.time = position;
		
		array_remove(gradient.keys, key);
		gradient.add(key, false);
		
		onApply(gradient);
	}
	
	function removeKeyOverlap(key) {
		var keys = gradient.keys;
		for(var i = 0; i < array_length(keys); i++) {
			var _key = keys[i];
			if(_key == key || _key.time != key.time) 
				continue;
			
			_key.value = key.value;
			array_remove(keys, key);
		}
		
		onApply(gradient);
	}
#endregion

#region preset
	hovering_name = "";
	
	pal_padding = ui(9);
	sp_preset_w = ui(240) - pal_padding * 2 - ui(8);
	
	sp_presets = new scrollPane(sp_preset_w, dialog_h - ui(48 + 8) - pal_padding, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var ww  = sp_presets.surface_w;
		var _gs = ui(16);
		var hh  = ui(24);
		var nh  = ui(20);
		var pd  = ui(6);
		var _ww = ww - pd * 2;
		var hg  = nh + _gs + pd;
		var yy  = _y;
		
		var _hover = sHOVER && sp_presets.hover;
		
		for(var i = 0; i < array_length(GRADIENTS); i++) {
			var _gradient = GRADIENTS[i];
			var isHover   = point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + hg);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, 0, yy, ww, hg);
			if(_hover && isHover) {
				sp_presets.hover_content = true;
				draw_sprite_stretched_ext(THEME.node_active, 1, 0, yy, ww, hg, COLORS._main_accent, 1);
			}
				
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text_add(pd, yy + ui(2), _gradient.name);
			_gradient.gradient.draw(pd, yy + nh, _ww, _gs);
			
			if(_hover && isHover) {
				if(mouse_press(mb_left, interactable && sFOCUS)) {
					gradient.keys = [];
					for( var i = 0, n = array_length(_gradient.gradient.keys); i < n; i++ ) {
						var k = _gradient.gradient.keys[i].clone();
						gradient.keys[i] = k;
						
						if(is_real(k.value)) k.value = cola(k.value);
					}
					
					onApply(gradient);
				}
				
				if(mouse_press(mb_right, interactable && sFOCUS)) {
					hovering_name = _gradient.path;
					menuCall("gradient_window_preset_menu",,, [
						menuItem(__txtx("gradient_editor_delete", "Delete gradient"), function() { 
							file_delete(hovering_name); 
							__initGradient();
						})
					]);
				}
			}
			
			yy += hg + ui(4);
			hh += hg + ui(4);
		}
		
		return hh;
	});
	
	sp_presets.always_scroll = true;
#endregion

#region palette
	palette_selecting = -1;
	
	sp_palette_w    = ui(240) - pal_padding * 2 - ui(8);
	sp_palette_size = ui(20);
	click_block     = true;
	
	sp_palettes = new scrollPane(sp_palette_w, dialog_h - ui(48 + 8) - pal_padding, function(_y, _m) {
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		var ww  = sp_palettes.surface_w;
		var _gs = sp_palette_size;
		var hh  = ui(24);
		var nh  = ui(20);
		var pd  = ui(6);
		var _ww = ww - pd * 2;
		var _bh = nh + _gs + pd;
		var yy  = _y;
		
		var _height, pre_amo, _palRes;
		var _hover = sHOVER && sp_palettes.hover;
		var col = max(1, floor(_ww / _gs)), row;
		
		for(var i = -1; i < array_length(PALETTES); i++) {
			var pal = i == -1? {
				name    : "project",
				palette : PROJECT.attributes.palette,
				path    : ""
			} : PALETTES[i];
			
			pre_amo = array_length(pal.palette);
			row     = ceil(pre_amo / col);
			_height = palette_selecting == i? nh + row * _gs + pd : _bh;
			
			var isHover = _hover && point_in_rectangle(_m[0], _m[1], 0, yy, ww, yy + _height);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, 0, yy, ww, _height);
			if(isHover) {
				sp_palettes.hover_content = true;
				draw_sprite_stretched_ext(THEME.node_active, 1, 0, yy, ww, _height, COLORS._main_accent, 1);
			}
			
			var cc = i == palette_selecting? COLORS._main_accent : COLORS._main_text_sub;
			draw_set_text(f_p2, fa_left, fa_top, cc);
			draw_text_add(pd, yy + ui(2), pal.name);
			
			if(i == -1) { draw_set_color(cc); draw_circle_prec(ww - ui(10), yy + ui(10), ui(4), false); }
			
			if(palette_selecting == i) 
				_palRes = drawPaletteGrid(pal.palette, pd, yy + nh, _ww, _gs, { mx : _m[0], my : _m[1] });
			else
				drawPalette(pal.palette, pd, yy + nh, _ww, _gs);
			
			if(!click_block && mouse_click(mb_left, interactable && sFOCUS)) {
				if(palette_selecting == i && _hover && _palRes.hoverIndex > noone) {
					var c = _palRes.hoverColor;
					if(is_real(c)) c = cola(c);
					
					selector.setColor(c);
					selector.setHSV();
					
				} else if(isHover) {
					palette_selecting = i;
					click_block = true;
				}
			}	
			
			if(isHover && mouse_press(mb_right, interactable && sFOCUS)) {
				hovering = pal;
				
				menuCall("palette_window_preset_menu",,, [
					menuItem(__txtx("gradient_set_palette", "Convert to Gradient"), function() { 
						var _p = hovering.palette;
						if(array_length(_p) < 2) return;
						
						gradient.keys = [];
						for( var i = 0, n = array_length(_p); i < n; i++ )
							gradient.keys[i] = new gradientKey(i / (n - 1), cola(_p[i]));
					}),
				]);
			}
			
			yy += _height + ui(4);
			hh += _height + ui(4);
		}
		
		if(mouse_release(mb_left))
			click_block = false;
		
		return hh;
	});
	
	sp_palettes.always_scroll = true;
#endregion

#region action
	function checkMouse() {}
#endregion