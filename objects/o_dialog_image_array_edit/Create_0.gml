/// @description 
event_inherited();

#region data
	destroy_on_click_out = true;
	dialog_w = 648;
	dialog_h = max(500, WIN_H - 200);
	
	dialog_resizable = true;
	dialog_w_min = 400;
	dialog_h_min = 500;
	dialog_w_max = WIN_W;
	dialog_h_max = WIN_H;
	
	target = noone;
	
	function onResize() {
		sp_content.resize(dialog_w - 150, dialog_h - 64);
	}	
#endregion

#region content
	menuOn = -1;
	dragging = -1;
	drag_spr = -1;
	
	sp_content = new scrollPane(dialog_w - 150, dialog_h - 64, function(_y, _m) {
		if(!target) return 0;
		draw_clear_alpha(c_ui_blue_grey, 0);
		
		var _h = 8;
		
		var ww  = 100;
		var hh  = 100;
		var pad = 16;
		
		var arr = target.inputs[| 0].getValue();
		if(array_length(arr) != array_length(target.spr)) 
			target.updatePaths(arr);
		
		var len = array_length(arr);
		var col = floor((sp_content.surface_w - pad) / (ww + pad));
		var row = ceil(len / col);
		
		var yy			= _y + 8;
		var menu		= -1;
		var drag		= -1;
		var inb_hover	= 0;
		
		for( var i = 0; i < row; i++ ) {
			var ch = hh;
			for( var j = 0; j < col; j++ ) {
				var index = i * col + j;
				if(index >= len) break;
				
				var xx = pad + (ww + pad) * j;
				
				draw_sprite_stretched(s_ui_panel_bg, 0, xx, yy, ww, hh);
				
				if(point_in_rectangle(_m[0], _m[1], xx, yy, xx + ww, yy + hh)) {
					if(dragging == -1)
						draw_sprite_stretched(s_ui_panel_active, 0, xx, yy, ww, hh);
					
					if(mouse_check_button_pressed(mb_left))
						dragging = index;
					
					if(mouse_check_button_pressed(mb_right)) {
						menu   = index;
						menuOn = index;
					}
				}
				
				if(dragging != -1 && dragging != index) {
					draw_set_color(c_ui_blue_dkgrey);
					if(point_in_rectangle(_m[0], _m[1], xx - pad / 2, yy, xx + ww / 2, yy + hh)) {
						inb_hover = index;
						draw_line_round(xx - pad / 2, yy, xx - pad / 2, yy + hh, 4);
					} else if(point_in_rectangle(_m[0], _m[1], xx + ww / 2, yy, xx + ww + pad / 2, yy + hh)) {
						inb_hover = index + 1;
						draw_line_round(xx + ww + pad / 2, yy, xx + ww + pad / 2, yy + hh, 4);
					} 
				}
				
				var spr = target.spr[index];
				var spr_w = sprite_get_width(spr);
				var spr_h = sprite_get_height(spr);
				var spr_s = min((ww - 16) / spr_w, (hh - 16) / spr_h);
				var spr_x = xx + ww / 2 - spr_w * spr_s / 2;
				var spr_y = yy + hh / 2 - spr_h * spr_s / 2;
				
				if(dragging == index)
					draw_sprite_ext(spr, 0, spr_x, spr_y, spr_s, spr_s, 0, c_white, 0.5);
				else
					draw_sprite_ext(spr, 0, spr_x, spr_y, spr_s, spr_s, 0, c_white, 1);

				
				draw_set_text(f_p2, fa_center, fa_top, c_white);
				var path  = arr[index];
				var name  = string_cut_line(string_replace(filename_name(path), filename_ext(path), ""), ww);
				var txt_h = string_height_ext(name, -1, ww);
				
				draw_text_ext(xx + ww / 2, yy + hh + 16, name, -1, ww);
				
				ch = max(ch, hh + txt_h + 32);
			}
			
			yy += ch;
			_h += ch;
		}
		
		if(dragging != -1) {
			if(mouse_check_button_released(mb_left) && dragging != inb_hover) {
				var val = arr[dragging];
				array_delete(arr, dragging, 1);
				array_insert(arr, dragging < inb_hover? inb_hover - 1 : inb_hover, val);
				target.inputs[| 0].setValue(arr);
				target.update();
				dragging = -1;
			}
		}
		
		if(menu > -1) {
			var dia = dialogCall(o_dialog_menubox, mouse_mx, mouse_my);
			dia.setMenu( [
				[ "Remove", function() {
					var arr = target.inputs[| 0].getValue();
					array_delete(arr, menuOn, 1);
					target.inputs[| 0].setValue(arr);
				}]
			] );	
		}
		
		return _h;
	})
#endregion