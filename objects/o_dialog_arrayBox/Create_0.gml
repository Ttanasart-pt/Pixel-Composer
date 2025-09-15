/// @description init
event_inherited();

#region dialog
	destroy_on_click_out = true;
	max_h     = 640;
	align     = fa_left;
	draggable = false;
#endregion

#region data
	selecting = -1;
	
	font     = f_p1;
	arrayBox = noone;
	mode     = 0;
	anchor   = ANCHOR.top | ANCHOR.left;
	
	data     = [];
	arraySet = [];
	
	onModify = undefined;
	onClose  = undefined;
	
	addable  = false;
	
	adding      = false;
	WIDGET_CURRENT = self;
#endregion

sc_content = new scrollPane(0, 0, function(_y, _m) {
	draw_clear(COLORS.panel_bg_clear, 1);
	
	var hght  = line_get_height(font, 8);
	var _amo  = array_length(data);
	var _h    = _amo * hght;
	var _dw   = sc_content.surface_w;
	var _cx   = ui(20);
	
	var _hover = sc_content.hover;
	var _focus = sc_content.active;
	
	_y += ui(4);
	
	for( var i = 0; i < _amo; i++ ) {
		var _ly = _y + i * hght;	
		var  yc = _ly + hght / 2;
		var exists = 0;
		
		if(mode == 0) {
			for( var j = 0; j < array_length(arraySet); j++ ) 
				if(data[i] == arraySet[j]) exists = 1;
				
		} else if(mode == 1) {
			for( var j = 0; j < array_length(arraySet); j++ ) {
				if("+" + data[i] == arraySet[j]) exists =  1;
				if("-" + data[i] == arraySet[j]) exists = -1;
			}
		}
		
		var ind = 0;
		var hov = _hover && point_in_rectangle(_m[0], _m[1], 0, _ly + 1, _dw, _ly + hght - 1);
		
		if(hov) {
			selecting = i;
			sc_content.hover_content = true;
		}
		
		if(selecting == i) {
			draw_sprite_stretched_ext(THEME.textbox, 3, ui(4), _ly, _dw - ui(4), hght, COLORS.dialog_menubox_highlight, 1);
			ind = 1;
			
			if(_focus && (!adding && (mouse_press(mb_left) || keyboard_check_pressed(vk_enter)))) {
				if(mode == 0) {
					if(exists)	array_remove(arraySet, data[i]);
					else		array_push(arraySet, data[i]);
					
				} else if(mode == 1) {
					switch(exists) {
						case 0  : array_push(arraySet, "+" + data[i]); break;
							
						case 1  : 
							array_remove(arraySet, "+" + data[i]); 
							array_push(arraySet, "-" + data[i]); 
							break;
							
						case -1 : array_remove(arraySet, "-" + data[i]); break;
					}
				}
				
				if(onModify) onModify();
			}
		}
		
		var bs = hght - ui(8);
		draw_sprite_stretched(THEME.checkbox_def, ind, _cx - bs / 2, yc - bs / 2, bs, bs);
		
		if(mode == 0) {
			if(exists) draw_sprite_stretched_ext(THEME.checkbox_def, 2, _cx - bs / 2, yc - bs / 2, bs, bs, COLORS._main_accent, 1);
			
		} else if(mode == 1) {
			     if(exists ==  1) draw_sprite_ui(THEME.arrow, 1, _cx, yc,         1, 1, 0, COLORS._main_value_positive, 1);
			else if(exists == -1) draw_sprite_ui(THEME.arrow, 3, _cx, yc + ui(2), 1, 1, 0, COLORS._main_value_negative, 1);
		}
		
		draw_set_text(font, fa_left, fa_center, COLORS._main_text);
		draw_text_add(ui(40), yc, data[i]);
	}
	
	if(addable) {
		var _ly = _y + _amo * hght;
		var yc  = _ly + hght / 2;
		
		var hov = _hover && point_in_rectangle(_m[0], _m[1], 0, _ly + 1, _dw, _ly + hght - 1);
		
		if(adding) {
			selecting = noone;
			var _str = KEYBOARD_STRING;
			if(current_time % (PREFERENCES.caret_blink * 2000) > PREFERENCES.caret_blink * 1000)
				_str += "|";
				
			draw_set_text(font, fa_left, fa_center, COLORS._main_text_accent);
			draw_text_add(ui(40), yc, _str);
			
			if(keyboard_check_pressed(vk_enter)) {
				if(KEYBOARD_STRING != "") array_push(arraySet, KEYBOARD_STRING);
				if(onModify) onModify();
				adding = false;
			}
			
			if(keyboard_check_pressed(vk_escape)) {
				adding = false;
			}
			
		} else {
			if(hov) {
				selecting = noone;
				sc_content.hover_content = true;
				draw_sprite_stretched_ext(THEME.textbox, 3, ui(4), _ly, _dw - ui(4), hght, COLORS.dialog_menubox_highlight, 1);
				
				if(mouse_lpress(_focus)) {
					adding      = true;
					KEYBOARD_RESET
				}
			}
			
			draw_set_text(font, fa_left, fa_center, COLORS._main_text_sub);
			draw_text_add(ui(40), yc, __txt("Add value..."));
		}
		
		draw_sprite_ui(THEME.add_16, 0, _cx, yc, 1, 1, 0, COLORS._main_value_positive);
	}
	
	if(sFOCUS && !adding) {
		if(KEYBOARD_PRESSED == vk_up) {
			selecting--;
			if(selecting < 0) selecting = array_length(data) - 1;
		}
		
		if(KEYBOARD_PRESSED == vk_down)
			selecting = safe_mod(selecting + 1, array_length(data));
			
		if(keyboard_check_pressed(vk_escape))
			instance_destroy();
	}
	
	return _h;
});

function trigger() {}

function setArrayBox(_arrayBox) {
	arrayBox = _arrayBox;
	dialog_w = arrayBox.w;
	
	data     = arrayBox.data;
	arraySet = arrayBox.arraySet;
	onModify = arrayBox.onModify;
	addable  = arrayBox.addable;
	
	font     = arrayBox.font;
	mode     = arrayBox.mode;
}