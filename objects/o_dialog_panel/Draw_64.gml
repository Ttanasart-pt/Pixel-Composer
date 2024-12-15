/// @description 
if !ready exit;

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
		
		WINDOW_ACTIVE = window;
		content.drawContent(panel);
		WINDOW_ACTIVE = noone;
		
		gpu_set_blendmode(bm_subtract);
		draw_surface_safe(mask_surface);
		gpu_set_blendmode(bm_normal);
	surface_reset_target();
	DIALOG_PREDRAW
	
	content.drawGUI();
	draw_surface(panel, cx, cy);
}

if(content.showHeader) {
	var _tx = window == noone? dialog_x + ui(32) : dialog_x + ui(10);
	
	draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, dialog_x + 3, dialog_y + 3, dialog_w - 6, title_height + 2, COLORS._main_icon_light, 1);
	draw_set_text(f_p2, fa_left, fa_top, COLORS._main_text_sub);
	draw_text_cut(_tx, dialog_y + ui(8), content.title, dialog_w - ui(32 + 32));
	
	var _bx = dialog_x + dialog_w - ui(28);
	var _by = dialog_y + ui(8);
	var _bs = ui(20);
	
	if(instanceof(content) != "Panel_Menu")
	if(buttonInstant(THEME.button_hide, _bx, _by, _bs, _bs, [ mouse_mx, mouse_my ], sFOCUS, sHOVER, "", THEME.window_exit) == 2) {
		DIALOG_POSTDRAW
		onDestroy();
		instance_destroy();
	}
	
	_bx -= ui(8);
	// draw_set_color(COLORS.panel_toolbar_separator);
	// draw_line_width(_bx + ui(4), _by, _bx + ui(4), _by + _bs, 2);
	
	for (var i = 0, n = array_length(content.title_actions); i < n; i++) {
		var _b = content.title_actions[i];
		
		_bx -= _bs;
		_b.setFocusHover(sFOCUS, sHOVER);
		_b.draw(_bx, _by, _bs, _bs, [ mouse_mx, mouse_my ], THEME.button_hide);
		_bs -= ui(4);
	}
} 

var bx  = content.showHeader? dialog_x + ui(8) : dialog_x + ui(24);
var by  = content.showHeader? dialog_y + ui(8) : dialog_y + ui(18);
var txt = destroy_on_click_out? __txt("Pin") : __txt("Unpin");
var cc  = destroy_on_click_out? COLORS._main_icon : COLORS._main_icon_light;
var ind = !destroy_on_click_out;
var ss  = content.showHeader? ui(20) : ui(28);
var sc  = content.showHeader? 0.75 : 1;

if(window == noone && instanceof(content) != "Panel_Menu") {
	var b = buttonInstant(THEME.button_hide, bx, by, ss, ss, [ mouse_mx, mouse_my ], sFOCUS, sHOVER, txt, THEME.pin, ind, cc, 1, sc);
	if(b == 2) destroy_on_click_out = !destroy_on_click_out;
}

if(sFOCUS) {
	DIALOG_DRAW_FOCUS
	
	if(window == noone && !m_in && m_ot) {
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
}

DIALOG_POSTDRAW