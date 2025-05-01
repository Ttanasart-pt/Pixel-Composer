/// @description 
if !ready exit;

if(!is_undefined(content) && content != noone)
	content.preDraw();
	
DIALOG_PREDRAW
DIALOG_WINCLEAR

title = content.title;
var p = ui(8);
var m_in = point_in_rectangle(mouse_mxs, mouse_mys, dialog_x + p, dialog_y + p, dialog_x + dialog_w - p, dialog_y + dialog_h - p);
var m_ot = point_in_rectangle(mouse_mxs, mouse_mys, dialog_x, dialog_y, dialog_x + dialog_w, dialog_y + dialog_h);

DIALOG_DRAW_BG

if(!is_undefined(content) && content != noone) { // content
	content.panel = self;
	
	var cx = dialog_x + content.showHeader * padding;
	var cy = dialog_y + content.showHeader * (padding + title_height);
	content.x = cx;
	content.y = cy;
	
	content.onStepBegin();
	
	content.pFOCUS = sFOCUS && m_in;
	content.pHOVER = sHOVER && m_in;
	
	panel = surface_verify(panel, dialog_w - content.showHeader * padding * 2, 
								  dialog_h - content.showHeader * (padding * 2 + title_height));
	if(!is_surface(mask_surface))
		resetMask();
	
	DIALOG_POSTDRAW
	surface_set_target(panel);
		draw_clear(COLORS.panel_bg_clear);
		
		content.drawContent(panel);
		
		gpu_set_blendmode(bm_subtract);
		draw_surface_safe(mask_surface);
		gpu_set_blendmode(bm_normal);
	surface_reset_target();
	DIALOG_PREDRAW
	
	content.drawGUI();
	draw_surface(panel, cx, cy);
}

if(content.showHeader) {
	var _tx = dialog_x + ui(32);
	
	draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, dialog_x + 3, dialog_y + 3, dialog_w - 6, title_height + 2, COLORS._main_icon_light, 1);
	draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
	draw_text_cut(_tx, dialog_y + ui(8), content.title, dialog_w - ui(32 + 32));
	
	var _bx = dialog_x + dialog_w - ui(8);
	var _by = dialog_y + ui(6);
	var _bs = ui(20);
	
	if(instanceof(content) != "Panel_Menu" && array_empty(content.title_actions)) {
		if(buttonInstant(THEME.button_hide_fill, _bx - _bs, _by, _bs, _bs, [ mouse_mx, mouse_my ], sHOVER, sFOCUS, "", THEME.window_exit_icon) == 2) {
			DIALOG_POSTDRAW
			onDestroy();
			instance_destroy();
		}
		
		_bx -= _bs + ui(4);
	}
	
	for (var i = 0, n = array_length(content.title_actions); i < n; i++) {
		var _b   = content.title_actions[i];
		var _txt = _b[0];
		var _spr = _b[1];
		var _act = _b[2];
		
		if(buttonInstant(THEME.button_hide_fill, _bx - _bs, _by, _bs, _bs, [ mouse_mx, mouse_my ], sHOVER, sFOCUS, _txt, _spr[0], _spr[1], _spr[2]) == 2)
			_act();
		
		_bx -= _bs + ui(4);
	}
	
	var bx  = dialog_x + ui(8);
	var by  = dialog_y + ui(6);
	var txt = destroy_on_click_out? __txt("Pin") : __txt("Unpin");
	var cc  = destroy_on_click_out? COLORS._main_icon : COLORS._main_icon_light;
	var ind = !destroy_on_click_out;
	var ss  = ui(20);
	var sc  = 0.75;
	
	if(instanceof(content) != "Panel_Menu") {
		var b = buttonInstant(THEME.button_hide_fill, bx, by, ss, ss, [ mouse_mx, mouse_my ], sHOVER, sFOCUS, txt, THEME.pin, ind, cc, 1, sc);
		if(b == 2) destroy_on_click_out = !destroy_on_click_out;
	}

} else {
	var bx  = dialog_x + ui(24);
	var by  = dialog_y + ui(18);
	var txt = destroy_on_click_out? __txt("Pin") : __txt("Unpin");
	var cc  = destroy_on_click_out? COLORS._main_icon : COLORS._main_icon_light;
	var ind = !destroy_on_click_out;
	var ss  = ui(28);
	var sc  = 1;
	
	if(instanceof(content) != "Panel_Menu") {
		var b = buttonInstant(THEME.button_hide_fill, bx, by, ss, ss, [ mouse_mx, mouse_my ], sHOVER, sFOCUS, txt, THEME.pin, ind, cc, 1, sc);
		if(b == 2) destroy_on_click_out = !destroy_on_click_out;
	}
}

if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS

if(sFOCUS && !m_in && m_ot) {
	var p  = DIALOG_PAD;
	var p2 = DIALOG_PAD * 2;
	draw_sprite_stretched_ext(THEME.dialog, 1, dialog_x - p, dialog_y - p, dialog_w + p2, dialog_h + p2, c_white, 0.4);
		
	if(DOUBLE_CLICK) {
		content.dragSurface = surface_clone(panel);
		o_main.panel_dragging = content;
		content.in_dialog = false;
	
		instance_destroy();
		
	} else if(mouse_press(mb_right)) {
		menuCall("panel_window_menu", [
			menuItem(__txt("Move"), function() { 
				content.dragSurface   = surface_clone(panel);
				o_main.panel_dragging = content;
				content.in_dialog     = false;
				panel_mouse           = 1;
				
				instance_destroy();
			}),
		]);
	}
}

DIALOG_POSTDRAW