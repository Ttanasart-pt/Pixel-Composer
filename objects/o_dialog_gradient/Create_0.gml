/// @description init
event_inherited();

#region data
	dialog_w = ui(1068);
	dialog_h = ui(476);
	title_height = 52;
	
	name = __txtx("gradient_editor_title", "Gradient editor");
	gradient = noone;
	interactable = true;
	
	key_selecting = noone;
	key_dragging  = noone;
	key_drag_sx   = 0;
	key_drag_mx   = 0;
	key_drag_dead = true;
	
	destroy_on_click_out = true;
	
	sl_position = slider(0, 100, 0.1, function(val) { 
		if(!interactable) return;
		if(key_selecting == noone) return;
		setKeyPosition(key_selecting, val / 100);
	}, function() { removeKeyOverlap(key_selecting); })
	
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
	sp_preset_w = ui(240 - 32 - 16);
	sp_presets = new scrollPane(sp_preset_w, dialog_h - ui(62), function(_y, _m) {
		var ww  = sp_preset_w - ui(40);
		var hh = ui(32);
		var yy = _y + ui(8);
		var hg = ui(52);
		var _hover = sHOVER && sp_presets.hover;
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		for(var i = 0; i < array_length(GRADIENTS); i++) {
			var _gradient = GRADIENTS[i];
			var isHover   = point_in_rectangle(_m[0], _m[1], ui(4), yy, ui(4) + sp_preset_w - ui(16), yy + hg);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, ui(4), yy, sp_preset_w - ui(16), hg);
			if(_hover && isHover) 
				draw_sprite_stretched_ext(THEME.node_active, 1, ui(4), yy, sp_preset_w - ui(16), hg, COLORS._main_accent, 1);
				
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text(ui(16), yy + ui(8), _gradient.name);
			_gradient.gradient.draw(ui(16), yy + ui(28), ww, ui(16));
			
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
	
	sp_palette_w = ui(240 - 32 - 16);
	sp_palette_size = ui(24);
	click_block = true;
	
	sp_palettes = new scrollPane(sp_palette_w, dialog_h - ui(62), function(_y, _m) {
		var ww  = sp_palette_w - ui(40);
		var hh  = ui(32);
		var _gs = sp_palette_size;
		var yy  = _y + ui(8);
		var _height, pre_amo;
		var _hover = sHOVER && sp_palettes.hover;
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		for(var i = -1; i < array_length(PALETTES); i++) {
			var pal = i == -1? {
				name: "project",
				palette: PROJECT.attributes.palette,
				path: ""
			} : PALETTES[i];
			
			pre_amo = array_length(pal.palette);
			var col = floor(ww / _gs);
			var row = ceil(pre_amo / col);
			
			if(palette_selecting == i)
				_height = ui(28) + row * _gs + ui(12);
			else
				_height = ui(56);
			
			var isHover = _hover && point_in_rectangle(_m[0], _m[1], ui(4), yy, ui(4) + sp_palette_w - ui(16), yy + _height);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 3, ui(4), yy, sp_palette_w - ui(16), _height);
			if(isHover) 
				draw_sprite_stretched_ext(THEME.node_active, 1, ui(4), yy, sp_palette_w - ui(16), _height, COLORS._main_accent, 1);
			
			var x0 = ui(16) + (i == -1) * ui(8 + 6);
			var cc = i == palette_selecting? COLORS._main_accent : COLORS._main_text_sub;
			draw_set_text(f_p2, fa_left, fa_top, cc);
			draw_text(x0, yy + ui(8), pal.name);
			if(i == -1) {
				draw_set_color(cc);
				draw_circle_prec(ui(16) + ui(4), yy + ui(16), ui(4), false);
			}
			
			if(palette_selecting == i)
				drawPaletteGrid(pal.palette, ui(16), yy + ui(28), ww, _gs);
			else
				drawPalette(pal.palette, ui(16), yy + ui(28), ww, ui(20));
			
			if(!click_block && mouse_click(mb_left, interactable && sFOCUS)) {
				if(palette_selecting == i && _hover && point_in_rectangle(_m[0], _m[1], ui(16), yy + ui(28), ui(16) + ww, yy + ui(28) + _height)) {
					var m_ax = _m[0] - ui(16);
					var m_ay = _m[1] - (yy + ui(28));
					
					var m_gx = floor(m_ax / _gs);
					var m_gy = floor(m_ay / _gs);
						
					var _index = m_gy * col + m_gx;
					if(_index < pre_amo && _index >= 0) {
						var c = pal.palette[_index];
						
						if(is_real(c)) c = cola(c);
						
						selector.setColor(c);
						selector.setHSV();
					}
				} else if(isHover) {
					palette_selecting = i;
					click_block = true;
				}
			}	
			
			if(isHover) {
				if(i >= 0 && mouse_press(mb_right, interactable && sFOCUS)) {
					hovering = pal;
					
					menuCall("palette_window_preset_menu",,, [
						menuItem(__txtx("palette_editor_set_default", "Set as default"), function() { 
							PROJECT.setPalette(array_clone(hovering.palette));
						}),
						menuItem(__txtx("palette_editor_delete", "Delete palette"), function() { 
							file_delete(hovering.path); 
							__initPalette();
						}),
					]);
				}
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