/// @description init
event_inherited();

#region data
	dialog_w = ui(812);
	dialog_h = ui(476);
	
	name = "Gradient editor";
	gradient = noone;
	grad_data = noone;
	
	key_selecting = noone;
	key_dragging  = noone;
	key_drag_sx   = 0;
	key_drag_mx   = 0;
	
	destroy_on_click_out = true;
	
	sl_position = new slider(0, 100, 0.1, function(val) { 
		if(key_selecting == noone) return;
		setKeyPosition(key_selecting, val / 100);
	}, function() { removeKeyOverlap(key_selecting); })
	
	setColor = function(color) {
		if(key_selecting == noone) return;
		key_selecting.value = color;
	}
	function setGradient(grad, data) {
		gradient = grad;	
		grad_data = data;
		if(!ds_list_empty(grad))
			key_selecting = grad[| 0];
	}
	
	selector = new colorSelector(setColor);
	selector.dropper_close = false;
	
	function setKeyPosition(key, position) {
		key.time = position;
		
		ds_list_remove(gradient, key);
		gradient_add(gradient, key, false);
	}
	
	function removeKeyOverlap(key) {
		for(var i = 0; i < ds_list_size(gradient); i++) {
			var _key = gradient[| i];
			if(_key == key || _key.time != key.time) 
				continue;
				
			_key.value = key.value;
			ds_list_remove(gradient, key);
		}
	}
#endregion

#region preset
	function loadGradient(path) {
		if(path == "") return noone;
		if(!file_exists(path)) return noone;
		
		var grad = ds_list_create();
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
			
			ds_list_add(grad, new valueKey(_pos, _col));
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
			draw_text(ui(16), yy + ui(8), preset_name[| i]);
			draw_gradient(ui(16), yy + ui(28), ww, ui(16), presets[| i]);
			
			if(_hover && isHover && mouse_press(mb_left, sFOCUS)) { 
				var target = presets[| i];
				ds_list_clear(gradient);
				for( var i = 0; i < ds_list_size(target); i++ ) {
					ds_list_add(gradient, new valueKey(target[| i].time, target[| i].value));
				}
			}
			
			yy += hg + ui(4);
			hh += hg + ui(4);
		}
		
		return hh;
	})
#endregion

#region action
	function checkMouse() {}
#endregion