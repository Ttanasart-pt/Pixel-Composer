/// @description init
if !ready exit;

#region base UI
	DIALOG_DRAW_BG
	if(DIALOG_SHOW_FOCUS) DIALOG_DRAW_FOCUS
#endregion

#region content
	var m   = mouse_ui;
	var foc = sFOCUS;
	var hov = sHOVER;
	
	var icx = dialog_x + ui(56);
	var icy = dialog_y + ui(56);
	draw_sprite_ui_uniform(THEME.icon_64, 0, icx, icy);
	draw_sprite_ui_uniform(s_title, 0, dialog_x + ui(56 + 48 - 4), dialog_y + ui(56 + 4 - 32), .4 * THEME_SCALE);
	
	var bx  = dialog_x + ui(56 + 48);
	var by  = dialog_y + ui(56 +  4);
	draw_set_text(f_p0, fa_left, fa_top, COLORS._main_text);
	draw_text(bx, by, PREFERENCES.video_title);
	
	var bx  = dialog_x + dialog_w - ui(16);
	var by  = dialog_y + ui(16);
	draw_set_text(f_p0, fa_right, fa_top, COLORS._main_text_sub);
	draw_text(bx, by, $"recorded on v.{VERSION_STRING}");
#endregion

#region node covered
	var nx = dialog_x + ui( 16);
	var ny = dialog_y + ui(104);
	var nw = dialog_w - ui( 32);
	var nh = dialog_h - ui(104 + 16);
	
	draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, nx, ny, nw, nh);
	draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text_sub);
	draw_text_add(nx + nw/2, ny + ui(8), "Nodes covered");
			
	var tw = nw - ui(16);
	
	var topics = PREFERENCES.video_topics;
	var tps = ui(96);
	var amo = array_safe_length(topics);
	var col = min(amo, floor(tw / tps));
	var row = amo == 0? 0 : ceil(amo / col);
	
	tps = tw / col;
	
	var ty = ny + ui(32);
	var tw = ui(80);
	var th = ui(96);
	var ic = tw - ui(24);
	
	for( var r = 0; r < row; r++ ) {
		var _coll = min(amo, col, amo - r * col);
		var tx = nx + nw / 2 - (_coll - 1) / 2 * tps;
		
		for( var c = 0; c < col; c++ ) {
			var i = r * col + c;
			if(i >= amo) break;
			
			var topic = topics[i];
			var c = i % col;
			var r = floor(i / col);
			
			var txx = tx + c * tps;
			var tyy = ty + r * (th + ui(8));
			
			var _data  = topic;
			var _title = "";
			var _spr   = noone;
			
			var _node = ALL_NODES[$ _data];
			if(_node) {
				_title = _node.getName();
				_spr   = _node.spr;
			}
			
			draw_set_font(f_p3);
			var _ttw = clamp(string_width(_title) + ui(8), tw, tps - ui(8));
			
			// draw_sprite_stretched_ext(THEME.ui_panel, 1, txx - _ttw / 2, tyy, _ttw, th, COLORS.panel_frame);
			
			if(_spr) {
				gpu_set_tex_filter(true);
				draw_sprite_fit(_spr, 0, txx, tyy + ui(8) + ic / 2, ic, ic);
				gpu_set_tex_filter(false);
			}
			
			draw_set_text(f_p3, fa_center, fa_bottom, COLORS._main_text);
			draw_text_add(txx, tyy + th - ui(4), _title);
		}
	}
	
	var bs = ui(20);
	var bx = nx + nw - bs - ui(2);
	var by = ny + ui(2);
	var bc = COLORS._main_icon_light;
	
	if(buttonInstant_Pad(noone, bx, by, bs, bs, m, hov, foc, "", THEME.gear, 0, bc, .5) == 2) getCoveredNodes(); bx -= bs + ui(2);
	if(buttonInstant_Pad(noone, bx, by, bs, bs, m, hov, foc, "", THEME.add,  0, bc, .5) == 2) addCoveredNodes(); bx -= bs + ui(2);
		
	dialog_h = ui(104 + 16 + 32) + row * (th + ui(8));
	dialog_x = WIN_W / 2 - dialog_w / 2;
	dialog_y = WIN_H / 2 - dialog_h / 2;
#endregion