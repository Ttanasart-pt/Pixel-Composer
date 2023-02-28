/// @description 
event_inherited();

#region data
	destroy_on_click_out = true;
	dialog_w = ui(648);
	dialog_h = ui(640);
	
	dialog_resizable = true;
	dialog_w_min = ui(400);
	dialog_h_min = ui(400);
	dialog_w_max = WIN_W;
	dialog_h_max = WIN_H;
	
	target = noone;
	
	function onResize() {
		sp_content.resize(dialog_w - ui(padding + padding), dialog_h - ui(title_height + padding));
	}	
#endregion

#region content
	menuOn = -1;
	dragging = -1;
	drag_spr = -1;
	
	sp_content = new scrollPane(dialog_w - ui(padding + padding), dialog_h - ui(title_height + padding), function(_y, _m) {
		if(!target) return 0;
		draw_clear_alpha(COLORS.dialog_array_edit_bg, 0);
		
		var _h = ui(8);
		
		var ww  = ui(100);
		var hh  = ui(100);
		var pad = ui(16);
		
		var arr = target.inputs[| 0].getValue();
		if(array_length(arr) != array_length(target.spr)) 
			target.updatePaths(arr);
		
		var len = array_length(arr);
		var col = floor((sp_content.surface_w - pad) / (ww + pad));
		var row = ceil(len / col);
		
		var yy			= _y + ui(8);
		var menu		= -1;
		var drag		= -1;
		var inb_hover	= -1;
		
		for( var i = 0; i < row; i++ ) {
			var ch = hh;
			for( var j = 0; j < col; j++ ) {
				var index = i * col + j;
				if(index >= len) break;
				
				var xx = pad + (ww + pad) * j;
				
				draw_sprite_stretched(THEME.ui_panel_bg, 0, xx, yy, ww, hh);
				
				if(sHOVER && sp_content.hover && point_in_rectangle(_m[0], _m[1], xx, yy, xx + ww, yy + hh)) {
					inb_hover = index;
					if(dragging == -1)
						draw_sprite_stretched_ext(THEME.ui_panel_active, 0, xx, yy, ww, hh, COLORS._main_accent, 1);
					
					if(mouse_press(mb_left, sFOCUS))
						dragging = index;
					
					if(mouse_press(mb_right, sFOCUS)) {
						menu   = index;
						menuOn = index;
					}
				}
				
				var spr = target.spr[index];
				var spr_w = sprite_get_width(spr);
				var spr_h = sprite_get_height(spr);
				var spr_s = min((ww - ui(16)) / spr_w, (hh - ui(16)) / spr_h);
				var spr_x = xx + ww / 2 - spr_w * spr_s / 2;
				var spr_y = yy + hh / 2 - spr_h * spr_s / 2;
				
				var aa = dragging == -1? 1 : (dragging == index? 1 : 0.5);
				draw_sprite_ext(spr, 0, spr_x, spr_y, spr_s, spr_s, 0, c_white, aa);
				
				draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text);
				var path  = arr[index];
				var name  = string_cut_line(string_replace(filename_name(path), filename_ext(path), ""), ww);
				var txt_h = string_height_ext(name, -1, ww);
				
				draw_text_ext(xx + ww / 2, yy + hh + ui(16), name, -1, ww);
				
				ch = max(ch, hh + txt_h + ui(32));
			}
			
			yy += ch;
			_h += ch;
		}
		
		if(dragging != -1) {
			if(inb_hover != -1) {
				rearrange(dragging, inb_hover);
				dragging = inb_hover;
			}
			
			if(mouse_release(mb_left))
				dragging = -1;
		}
		
		if(menu > -1) {
			menuCall(,, [
				menuItem("Remove", function() {
					var arr = target.inputs[| 0].getValue();
					array_delete(arr, menuOn, 1);
					target.inputs[| 0].setValue(arr);
				})
			] );	
		}
		
		return _h;
	})
#endregion

#region function
	function rearrange(oldindex, newindex) {
		if(oldindex == newindex) return;
		
		var arr = target.inputs[| 0].getValue();
		var val = arr[oldindex];
		array_delete(arr, oldindex, 1);
		array_insert(arr, newindex, val);
		target.inputs[| 0].setValue(arr);
		target.doUpdate();
	}
	
	sortAsc = true;
	function sortByName() {
		if(!target) return 0;
		var arr = target.inputs[| 0].getValue();
		
		array_sort(arr, bool(sortAsc));
		sortAsc = !sortAsc;
		
		target.inputs[| 0].setValue(arr);
		target.doUpdate();
	}
#endregion