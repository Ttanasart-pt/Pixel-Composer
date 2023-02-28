/// @description init
event_inherited();

#region data
	dialog_w = ui(1068);
	dialog_h = ui(476);
	title_height = 52;
	
	name = get_text("gradient_editor_title", "Gradient editor");
	gradient = noone;
	grad_data = noone;
	interactable = true;
	
	key_selecting = noone;
	key_dragging  = noone;
	key_drag_sx   = 0;
	key_drag_mx   = 0;
	key_drag_dead = true;
	
	destroy_on_click_out = true;
	
	sl_position = new slider(0, 100, 0.1, function(val) { 
		if(!interactable) return;
		if(key_selecting == noone) return;
		setKeyPosition(key_selecting, val / 100);
	}, function() { removeKeyOverlap(key_selecting); })
	
	setColor = function(color) {
		if(key_selecting == noone) return;
		key_selecting.value = color;
		
		onApply(gradient);
	}
	
	function setGradient(grad, data) {
		gradient = grad;	
		grad_data = data;
		if(array_length(grad))
			key_selecting = grad[0];
	}
	
	selector = new colorSelector(setColor);
	selector.dropper_close = false;
	
	previous_gradient = [];
	previous_data	  = 0;
	
	function setDefault(grad, data) {
		var _grad = [];
		for( var i = 0; i < array_length(grad); i++ )
			_grad[i] = grad[i].clone();
		
		setGradient(_grad, data);
		previous_data = data[| 0];
		
		previous_gradient = [];
		for( var i = 0; i < array_length(grad); i++ )
			array_push(previous_gradient, grad[i].clone());
	}
	
	b_cancel = button(function() {
		grad_data[| 0] = previous_data;
		onApply(previous_gradient);
		DIALOG_CLICK = false;
		instance_destroy();
	}).setIcon(THEME.revert, 0, COLORS._main_icon)
	  .setTooltip("Revert and exit");
	
	b_apply = button(function() {
		onApply(gradient);
		instance_destroy();
	}).setIcon(THEME.accept, 0, COLORS._main_icon_dark);
	
	function setKeyPosition(key, position) {
		key.time = position;
		
		array_remove(gradient, key);
		gradient_add(gradient, key, false);
		
		onApply(gradient);
	}
	
	function removeKeyOverlap(key) {
		for(var i = 0; i < array_length(gradient); i++) {
			var _key = gradient[i];
			if(_key == key || _key.time != key.time) 
				continue;
			
			_key.value = key.value;
			array_remove(gradient, key);
		}
		
		onApply(gradient);
	}
#endregion

#region preset
	function loadGradient(path) {
		if(path == "") return noone;
		if(!file_exists(path)) return noone;
		
		var grad = [];
		var _t = file_text_open_read(path);
		while(!file_text_eof(_t)) {
			var key = file_text_readln(_t);
			var _col = 0, _pos = 0;
			
			if(string_pos(",", key)) {
				var keys = string_splice(key, ",");
				if(array_length(keys) != 2) continue;
				
				_col = toNumber(keys[0]);
				_pos = toNumber(keys[1]);
			} else {
				_col = toNumber(key);
				if(file_text_eof(_t)) break;
				_pos = toNumber(file_text_readln(_t));
			}
			
			array_push(grad, new gradientKey(_pos, _col));
		}
		file_text_close(_t);
		return grad;
	}
	
	presets		= ds_list_create();
	preset_name = ds_list_create();
	
	function presetCollect() {
		ds_list_clear(presets);
		ds_list_clear(preset_name);
		
		var path = DIRECTORY + "Gradients/"
		var file = file_find_first(path + "*", 0);
		while(file != "") {
			ds_list_add(presets,		loadGradient(path + file));
			ds_list_add(preset_name,	filename_name(file));
			file = file_find_next();
		}
		file_find_close();
	}
	presetCollect();
	
	sp_preset_w = ui(240 - 32 - 16);
	sp_presets = new scrollPane(sp_preset_w, dialog_h - ui(62), function(_y, _m) {
		var ww  = sp_preset_w - ui(40);
		var hh = ui(32);
		var yy = _y + ui(8);
		var hg = ui(52);
		var _hover = sHOVER && sp_presets.hover;
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		for(var i = 0; i < ds_list_size(presets); i++) {
			var isHover = point_in_rectangle(_m[0], _m[1], ui(4), yy, ui(4) + sp_preset_w - ui(16), yy + hg);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(4), yy, sp_preset_w - ui(16), hg);
			if(_hover && isHover) 
				draw_sprite_stretched_ext(THEME.node_active, 1, ui(4), yy, sp_preset_w - ui(16), hg, COLORS._main_accent, 1);
				
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text(ui(16), yy + ui(8), filename_name_only(preset_name[| i]));
			draw_gradient(ui(16), yy + ui(28), ww, ui(16), presets[| i]);
			
			if(_hover && isHover && mouse_press(mb_left, interactable && sFOCUS)) { 
				var target = presets[| i];
				gradient = [];
				for( var i = 0; i < array_length(target); i++ )
					array_push(gradient, new gradientKey(target[i].time, target[i].value));
			}
			
			yy += hg + ui(4);
			hh += hg + ui(4);
		}
		
		return hh;
	})
#endregion

#region palette
	palettes = ds_list_create();
	palette_name = ds_list_create();
	palette_selecting = -1;
	
	function paletteCollect() {
		ds_list_clear(palettes);
		ds_list_clear(palette_name);
		
		var path = DIRECTORY + "Palettes/"
		var file = file_find_first(path + "*", 0);
		while(file != "") {
			ds_list_add(palettes,		loadPalette(path + file));
			ds_list_add(palette_name,	filename_name(file));
			file = file_find_next();
		}
		file_find_close();
	}
	paletteCollect();
	
	sp_palette_w = ui(240 - 32 - 16);
	sp_palette_size = ui(24);
	click_block = false;
	
	sp_palettes = new scrollPane(sp_palette_w, dialog_h - ui(62), function(_y, _m) {
		var ww  = sp_palette_w - ui(40);
		var hh  = ui(32);
		var _gs = sp_palette_size;
		var yy  = _y + ui(8);
		var _height, pre_amo;
		var _hover = sHOVER && sp_palettes.hover;
		draw_clear_alpha(COLORS.panel_bg_clear, 0);
		
		for(var i = 0; i < ds_list_size(palettes); i++) {
			pre_amo = array_length(palettes[| i]);
			var col = floor(ww / _gs);
			var row = ceil(pre_amo / col);
			
			if(palette_selecting == i)
				_height = ui(28) + row * _gs + ui(12);
			else
				_height = ui(56);
			
			var isHover = _hover && point_in_rectangle(_m[0], _m[1], ui(4), yy, ui(4) + sp_palette_w - ui(16), yy + _height);
			
			draw_sprite_stretched(THEME.ui_panel_bg, 1, ui(4), yy, sp_palette_w - ui(16), _height);
			if(isHover) 
				draw_sprite_stretched_ext(THEME.node_active, 1, ui(4), yy, sp_palette_w - ui(16), _height, COLORS._main_accent, 1);
			
			draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
			draw_text(ui(16), yy + ui(8), filename_name_only(palette_name[| i]));
			if(palette_selecting == i)
				drawPaletteGrid(palettes[| i], ui(16), yy + ui(28), ww, _gs);
			else
				drawPalette(palettes[| i], ui(16), yy + ui(28), ww, ui(20));
			
			if(!click_block && mouse_click(mb_left, interactable && sFOCUS)) {
				if(palette_selecting == i && _hover && point_in_rectangle(_m[0], _m[1], ui(16), yy + ui(28), ui(16) + ww, yy + ui(28) + _height)) {
					var m_ax = _m[0] - ui(16);
					var m_ay = _m[1] - (yy + ui(28));
					
					var m_gx = floor(m_ax / _gs);
					var m_gy = floor(m_ay / _gs);
						
					var _index = m_gy * col + m_gx;
					if(_index < pre_amo && _index >= 0) {
						selector.setColor(palettes[| i][_index]);
						selector.setHSV();
					}
				} else if(isHover) {
					palette_selecting = i;
					click_block = true;
				}
			}	
			
			yy += _height + ui(4);
			hh += _height + ui(4);
		}
		
		if(mouse_release(mb_left))
			click_block = false;
		
		return hh;
	})
#endregion

#region action
	function checkMouse() {}
#endregion