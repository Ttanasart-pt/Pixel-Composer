/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(s_dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(FOCUS == self)
		draw_sprite_stretched(s_dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	
	draw_set_text(f_p0, fa_left, fa_center, c_ui_blue_ltgrey);
	draw_text(dialog_x + 24, dialog_y + 24, "Import multiple images");
#endregion

#region nodes
	draw_sprite_stretched(s_ui_panel_bg, 1, dialog_x + 16, dialog_y + 44, dialog_w - 32, 132);
	var grid_size  = 64;
	var grid_width = 80;
	var grid_space = 16;
	
	for(var i = 0; i < array_length(nodes); i++) {
		var _node = nodes[i];
		var xx    = dialog_x + 16 + 16 + i * (grid_size + grid_space);
		var yy    = dialog_y + 44 + 16;
		
		var nx = PANEL_GRAPH.mouse_grid_x;
		var ny = PANEL_GRAPH.mouse_grid_y;
		
		draw_sprite_stretched(s_node_bg, 0, xx, yy, grid_size, grid_size);
		if(point_in_rectangle(mouse_mx, mouse_my, xx, yy, xx + grid_width, yy + grid_size)) {
			draw_sprite_stretched(s_node_active, 0, xx, yy, grid_size, grid_size);	
			if(mouse_check_button_pressed(mb_left)) {
				var path_arr = paths_to_array(paths, dir_recursive, dir_filter);
				switch(i) {
					case 0 :
						for( var i = 0; i < array_length(path_arr); i++ )  {
							var path = path_arr[i];
							Node_create_Image_path(nx, ny, path);
							ny += 160;
						}
						break;
					case 1 :
						Node_create_Image_Sequence_path(nx, ny, path_arr);
						break;
					case 2 :
						Node_create_Image_Animated_path(nx, ny, path_arr);
						break;
				}
				PANEL_GRAPH.fullView();
				instance_destroy();
			}
		}
					
		draw_sprite(_node.spr, 0, xx + grid_size / 2, yy + grid_size / 2);
				
		draw_set_text(f_p1, fa_center, fa_top, c_white);
		draw_text_ext(xx + grid_size / 2, yy + grid_size + 4, _node.name, -1, grid_width);	
	}
#endregion

#region directory option
	if(is_dir) {
		var dir_y = dialog_y + 188;
		
		cb_recursive.active = FOCUS == self;
		cb_recursive.hover  = HOVER == self;
		cb_recursive.draw(dialog_x + dialog_w - 48, dir_y, dir_recursive, [mouse_mx, mouse_my]);
		
		draw_set_text(f_p1, fa_left, fa_center, c_white);
		draw_text(dialog_x + 20, dir_y + 14, "Recursive");
		
		dir_y += 40;
		tb_filter.active = FOCUS == self;
		tb_filter.hover  = HOVER == self;
		tb_filter.draw(dialog_x + 100, dir_y, dialog_w - 100 - 20, 36, dir_filter, [mouse_mx, mouse_my]);
		
		draw_set_text(f_p1, fa_left, fa_center, c_white);
		draw_text(dialog_x + 20, dir_y + 18, "Filter");
	}
#endregion