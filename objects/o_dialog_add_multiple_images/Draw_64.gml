/// @description init
if !ready exit;

#region base UI
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
	
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(dialog_x + ui(24), dialog_y + ui(16), __txtx("add_images_title_images", "Import multiple images"));
#endregion

#region nodes
	draw_sprite_stretched(THEME.ui_panel_bg, 0, dialog_x + ui(16), dialog_y + ui(44), dialog_w - ui(32), ui(112));
	var grid_size  = ui(64);
	var grid_space = ui(16);
	var grid_width = grid_size + grid_space;
	
	for(var i = 0; i < array_length(nodes); i++) {
		var _node = nodes[i];
		var xx    = dialog_x + ui(32) + i * grid_width;
		var yy    = dialog_y + ui(60);
		
		PANEL_GRAPH.stepBegin();
		var nx = PANEL_GRAPH.mouse_grid_x;
		var ny = PANEL_GRAPH.mouse_grid_y;
		
		draw_sprite_stretched(THEME.node_bg, 0, xx, yy, grid_size, grid_size);
		if(sHOVER && point_in_rectangle(mouse_mx, mouse_my, xx, yy, xx + grid_width, yy + grid_size)) {
			draw_sprite_stretched_ext(THEME.node_active, 0, xx, yy, grid_size, grid_size, COLORS._main_accent, 1);
			if(mouse_press(mb_left, sFOCUS)) {
				var path_arr = path_search(paths, dir_recursive, dir_filter);
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
					
		draw_sprite_ui_uniform(_node.spr, 0, xx + grid_size / 2, yy + grid_size / 2, 0.5);
				
		draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text);
		draw_text(xx + grid_size / 2, yy + grid_size + 4, _node.name);	
	}
#endregion

#region directory option
	if(is_dir) {
		var dir_y = dialog_y + ui(172);
		
		cb_recursive.setFocusHover(sFOCUS, sHOVER);
		cb_recursive.draw(dialog_x + dialog_w - ui(48), dir_y, dir_recursive, mouse_ui);
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
		draw_text(dialog_x + ui(24), dir_y + ui(14), __txtx("add_images_recursive", "Recursive"));
		
		dir_y += ui(40);
		tb_filter.setFocusHover(sFOCUS, sHOVER);
		tb_filter.draw(dialog_x + ui(100), dir_y, dialog_w - ui(120), ui(36), dir_filter, mouse_ui);
		
		draw_set_text(f_p1, fa_left, fa_center, COLORS._main_text);
		draw_text(dialog_x + ui(24), dir_y + ui(18), __txtx("add_images_filter", "Filter"));
	}
#endregion