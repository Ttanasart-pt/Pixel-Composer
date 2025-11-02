/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
	
	draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
	draw_text(dialog_x + ui(20), dialog_y + ui(8), __txtx("add_images_title_single", "Import image as"));
#endregion

#region nodes
	draw_sprite_stretched(THEME.ui_panel_bg, 1, dialog_x + ui(12), dialog_y + title_h, dialog_w - ui(24), ui(120));
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
			if(mouse_press(mb_left, sFOCUS)) {
				
				switch(_node.node) {
					case Node_Image          : Node_create_Image_path(nx, ny, path).skipDefault();                 break;
					case Node_Image_Sequence : Node_create_Image_Sequence_path(nx, ny, [ path ]).skipDefault();	   break;
					case Node_Canvas         : nodeBuild("Node_Canvas", nx, ny).skipDefault().loadImagePath(path); break;
				}
				instance_destroy();
			}
		}
					
		draw_sprite_uniform(_node.spr, 0, xx + grid_size / 2, yy + grid_size / 2, 0.5 * UI_SCALE);
				
		draw_set_text(f_p3, fa_center, fa_top, COLORS._main_text);
		draw_text_ext(xx + grid_size / 2, yy + grid_size + 4, _node.name, -1, grid_size + grid_space / 2);	
	}
#endregion