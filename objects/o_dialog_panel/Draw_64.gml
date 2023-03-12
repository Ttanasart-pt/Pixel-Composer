/// @description 
if !ready exit;

#region base UI
	var p = ui(8);
	var m_in = point_in_rectangle(mouse_mx, mouse_my, dialog_x + p, dialog_y + p, dialog_x + dialog_w - p, dialog_y + dialog_h - p);
	var m_ot = point_in_rectangle(mouse_mx, mouse_my, dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h);
	
	draw_sprite_stretched(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, dialog_h);
#endregion

#region content	
	if(!is_undefined(content) && content != noone) {
		var cx = dialog_x + content.showHeader * padding;
		var cy = dialog_y + content.showHeader * (padding + title_height);
		content.x = cx;
		content.y = cy;
		content.onStepBegin();

		content.pFOCUS = sFOCUS;
		content.pHOVER = sHOVER;
		
		panel = surface_verify(panel, dialog_w - content.showHeader * padding * 2, 
									  dialog_h - content.showHeader * (padding * 2 + title_height));
		if(!is_surface(mask_surface))
			resetMask();
		
		surface_set_target(panel);
			draw_clear_alpha(0, 0);
			content.drawContent(panel);
			
			gpu_set_blendmode(bm_subtract);
			draw_surface_safe(mask_surface, 0, 0);
			gpu_set_blendmode(bm_normal);
		surface_reset_target();
		
		draw_surface(panel, cx, cy);
	}
#endregion

#region overlay
	if(content.showHeader) {
		draw_sprite_stretched_ext(THEME.dialog_bg, 0, dialog_x, dialog_y, dialog_w, title_height + ui(8), COLORS._main_icon_light, 1);
		draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
		draw_text_cut(dialog_x + ui(32), dialog_y + ui(8), content.title, dialog_w - ui(32 + 32));
		
		if(instanceof(content) != "Panel_Menu")
		if(buttonInstant(THEME.button_hide, dialog_x + dialog_w - ui(28), dialog_y + ui(8), ui(20), ui(20), mouse_ui, sFOCUS, sHOVER, "", THEME.window_exit) == 2)
			instance_destroy();
	} 
	
	var bx  = content.showHeader? dialog_x + ui(8) : dialog_x + ui(24);
	var by  = content.showHeader? dialog_y + ui(8) : dialog_y + ui(18);
	var txt = destroy_on_click_out? get_text("pin", "Pin") : get_text("unpin", "Unpin");
	var cc  = destroy_on_click_out? COLORS._main_icon : COLORS._main_icon_light;
	var ind = !destroy_on_click_out;
	var ss  = content.showHeader? ui(20) : ui(28);
	var sc  = content.showHeader? 0.75 : 1;
	
	if(instanceof(content) != "Panel_Menu")
	if(buttonInstant(THEME.button_hide, bx, by, ss, ss, mouse_ui, sFOCUS, sHOVER, txt, THEME.pin, ind, cc,, sc) == 2)
		destroy_on_click_out = !destroy_on_click_out;
	
	if(sFOCUS)
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, COLORS._main_accent, 1);
		
	if(!m_in && m_ot) {
		draw_sprite_stretched_ext(THEME.dialog_active, 0, dialog_x, dialog_y, dialog_w, dialog_h, c_white, 0.4);
				
		if(DOUBLE_CLICK) {
			content.dragSurface = surface_clone(panel);
			o_main.panel_dragging = content;
			content.in_dialog = false;
			
			instance_destroy();
		} else if(mouse_press(mb_right)) {
			menuCall(,, [
				menuItem("Move",    function() { 
					content.dragSurface = surface_clone(panel);
					o_main.panel_dragging = content;
					content.in_dialog = false;
					panel_mouse = 1;
					
					instance_destroy();
				}),
			]);
		}
	}
#endregion