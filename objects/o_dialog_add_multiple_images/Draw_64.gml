/// @description init
if !ready exit;

DIALOG_DRAW_BG
	
#region base UI
	draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
	draw_text(dialog_x + ui(20), dialog_y + ui(8), __txt("add_images_title_images", "Import multiple images as"));
#endregion

#region nodes
	draw_sprite_stretched(THEME.ui_panel_bg, 1, dialog_x + ui(12), dialog_y + title_h, dialog_w - ui(24), content_h);
	var grid_size  = ui(64);
	var grid_space = ui(16);
	var grid_width = grid_size + grid_space;
	
	for(var i = 0; i < array_length(nodes); i++) {
		var _node = nodes[i];
		var xx    = dialog_x + ui(32) + i * grid_width;
		var yy    = dialog_y + title_h + ui(16);
		
		PANEL_GRAPH.stepBegin();
		
		var nx = PANEL_GRAPH.graph_cx;
		var ny = PANEL_GRAPH.graph_cy;
		
		draw_sprite_stretched_ext(THEME.node_bg, 0, xx, yy, grid_size, grid_size, COLORS.node_base_bg);
		draw_sprite_stretched_ext(THEME.node_bg, 1, xx, yy, grid_size, grid_size, CDEF.main_dark);
		
		if(sHOVER && point_in_rectangle(mouse_mx, mouse_my, xx, yy, xx + grid_width, yy + grid_size)) {
			draw_sprite_stretched_ext(THEME.node_bg, 1, xx, yy, grid_size, grid_size, COLORS._main_accent, 1);
			
			if(mouse_lpress(sFOCUS)) {
				
				var path_arr = dir_recursive? path_dirs_get_files(paths, dir_filter, true) : paths_to_array_ext(paths, dir_filter);
				array_sort(path_arr, true);
				
				switch(_node.node) {
					case Node_Image :
						for( var i = 0, n = array_length(path_arr); i < n; i++ )  {
							var path = path_arr[i];
							var _n   = Node_create_Image_path(nx, ny, path);
							    _n.skipDefault();
							ny += 160;
						}
						break;
						
					case Node_Canvas :
						for( var i = 0, n = array_length(path_arr); i < n; i++ )  {
							var path = path_arr[i];
							var _canvas = nodeBuild("Node_Canvas", nx, ny);
							_canvas.skipDefault();
							_canvas.loadImagePath(path);
							ny += 160;
						}
						break;
						
					case Node_Image_Sequence   : 
						var _n = Node_create_Image_Sequence_path(nx, ny, path_arr);
						    _n.skipDefault();
						break;
						
					case Node_Image_Animated   : 
						var _n = Node_create_Image_Animated_path(nx, ny, path_arr);
						    _n.skipDefault();
						break;
						
					case Node_Directory_Search : 
						var _n = Node_create_Directory_path(nx, ny, paths[0]);
						    _n.skipDefault();
						break;
						
				}
				instance_destroy();
			}
		}
					
		draw_sprite_uniform(_node.spr, 0, xx + grid_size / 2, yy + grid_size / 2, 0.5 * UI_SCALE);
				
		draw_set_text(f_p3, fa_center, fa_top, COLORS._main_text);
		draw_text_ext(xx + grid_size / 2, yy + grid_size + 4, _node.name, -1, grid_size + grid_space / 2);	
	}
#endregion

#region directory option
	if(is_dir) {
		var dw = dialog_w - ui(160);
		var dh = ui(32);
		
		var dx = dialog_x + dialog_w - dw - ui(16);
		var dy = dialog_y + title_h + content_h + ui(8);
		
		cb_recursive.setFocusHover(sFOCUS, sHOVER);
		cb_recursive.draw(dx, dy, dw, dh, dir_recursive, mouse_ui);
		
		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
		draw_text(dialog_x + ui(24), dy + dh/2, __txt("add_images_recursive", "Recursive"));
		
		dy += dh + ui(8);
		tb_filter.setFocusHover(sFOCUS, sHOVER);
		tb_filter.draw(dx, dy, dw, dh, dir_filter, mouse_ui);
		
		draw_set_text(f_p2, fa_left, fa_center, COLORS._main_text);
		draw_text(dialog_x + ui(24), dy + dh/2, __txt("add_images_filter", "Filter"));
	}
#endregion

DIALOG_DRAW_FOCUS