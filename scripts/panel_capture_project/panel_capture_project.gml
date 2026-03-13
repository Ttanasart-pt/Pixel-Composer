globalvar CAPTURING; CAPTURING = false;

function Panel_Capture_Project() : PanelContent() constructor {
	w = ui(240);
	h = ui(56 + (28 + 6) * 4);
	
	title      = "Capture Project";
	auto_pin   = true;
	
	cap_path   = "";
	cap_name   = "";
	cap_vers   = VERSION_STRING;
	
	gif_d  = 2;
	gif_w  = 1;
	gif_h  = 1;
	gif_s  = noone;
	gif    = noone;
	
	gif_scal  = .5;
	gif_step  =  1;
	gif_fps   = 30;
	show_text = false;
	
	tb_scale = textBox_Number( function(v) /*=>*/ { gif_scal = v;           } ).setHide(1).setLabel("Scale");
	tb_step  = textBox_Number( function(v) /*=>*/ { gif_step = round(v);    } ).setHide(1).setLabel("Step");
	tb_fps   = textBox_Number( function(v) /*=>*/ { gif_fps  = v;           } ).setHide(1).setLabel("FPS");
	tb_ver   = textBox_Text(   function(v) /*=>*/ { cap_vers = v;           } ).setHide(1).setLabel("vers.").setAlign(fa_right);
	cb_text  = new checkBox(   function( ) /*=>*/ { show_text = !show_text; } );
	
	function doCapture() {
		if(!PROJECT.animator.is_playing) {
			CAPTURING = false;
			gif_save(gif, cap_path);
			return;
		} 
		if(!PROJECT.animator.frame_progress) return;
		
		if(CAPTURING > 1 && GLOBAL_CURRENT_FRAME % gif_step == 0) {
			gif_s  = surface_verify(gif_s, gif_w, gif_h);
			
			var _p, _s;
			var _sx = gif_d;
			var _sy = gif_d;
			var _pd = THEME_VALUE.panel_margin;
			
			surface_set_target(gif_s);
				draw_clear(COLORS.bg);
				
				_p = PANEL_PREVIEW;
				_s = _p.panel.content_surface;
				draw_surface_ext(_s, _sx, _sy, gif_scal, gif_scal, 0, c_white, 1);
				draw_sprite_stretched_ext(THEME.ui_panel, 1, _sx + _pd, _sy + _pd, _p.w * gif_scal - 3, _p.h * gif_scal - 3, COLORS.panel_frame);
				_sx += _p.w * gif_scal;
				
				_p = PANEL_GRAPH;
				_s = _p.panel.content_surface;
				draw_surface_ext(_s, _sx, _sy, gif_scal, gif_scal, 0, c_white, 1);
				draw_sprite_stretched_ext(THEME.ui_panel, 1, _sx + _pd, _sy + _pd, _p.w * gif_scal - 3, _p.h * gif_scal - 3, COLORS.panel_frame);
				
				if(show_text) {
				// BLEND_ADD
					var _tx = gif_w - 24;
					var _ty = 16;
					draw_set_text(_f_sdf, fa_right, fa_top, COLORS._main_text_accent, .5);
					draw_text_transformed(_tx, _ty, cap_name, 1.5, 1.5, 0);
					_ty += string_height(cap_name) * 1.5 - 16;
					
					draw_set_text(_f_sdf, fa_right, fa_top, COLORS._main_text_sub, .4);
					draw_text_transformed(_tx, _ty, cap_vers, 1, 1, 0);
					draw_set_alpha(1);
				// BLEND_NORMAL
				}
			surface_reset_target();
			
			gif_add_surface(gif, gif_s, 100 / gif_fps);
		}
		
		CAPTURING++;
	}
	
	function drawContent(panel) {
		if(CAPTURING) doCapture();
		
		draw_clear_alpha(COLORS.panel_bg_clear, 1);
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2 - ui(28);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		var _pd = padding;
		
		var tx = _pd;
		var ty = _pd;
		var tw = w - _pd - _pd;
		var th = ui(28);
		
		// ty += th + ui(6);
		draw_sprite_stretched_ext(THEME.textbox, 3, tx, ty, tw, th, c_white, 1);
		var param = new widgetParam(tx, ty, tw, th, gif_scal, {}, [ mx, my ]);
		tb_scale.setFocusHover(pHOVER, pFOCUS);
		tb_scale.drawParam(param);
		
		ty += th + ui(6);
		draw_sprite_stretched_ext(THEME.textbox, 3, tx, ty, tw, th, c_white, 1);
		var param = new widgetParam(tx, ty, tw / 2, th, gif_step, {}, [ mx, my ]);
		tb_step.setFocusHover(pHOVER, pFOCUS);
		tb_step.drawParam(param);
		
		var param = new widgetParam(tx + tw / 2, ty, tw / 2, th, gif_fps, {}, [ mx, my ]);
		tb_fps.setFocusHover(pHOVER, pFOCUS);
		tb_fps.drawParam(param);
		
		ty += th + ui(6);
		draw_sprite_stretched_ext(THEME.textbox, 3, tx, ty, tw, th, c_white, 1);
		var param = new widgetParam(tx, ty, tw, th, cap_vers, {}, [ mx, my ]);
		tb_ver.setFocusHover(pHOVER, pFOCUS);
		tb_ver.drawParam(param);
		
		ty += th + ui(6);
		draw_sprite_stretched_ext(THEME.textbox, 3, tx, ty, tw, th, c_white, 1);
		var param = new widgetParam(tx + ui(64), ty, tw - ui(64), th, show_text, {}, [ mx, my ]).setS(ui(20))
			.setHalign(fa_center).setValign(fa_center);
		cb_text.setFocusHover(pHOVER, pFOCUS);
		cb_text.drawParam(param);
		
		draw_set_text(f_p3, fa_left, fa_center, COLORS._main_text_sub);
		draw_text_add(tx + ui(8), ty + th / 2, "Title");
		
		var pp = ui(4);
		var bw = w - pp * 2;
		var bh = ui(24);
		var bx = pp;
		var by = h - pp - bh;
		
		if(buttonInstant(THEME.button_def, bx, by, bw, bh, [ mx, my ], pHOVER, pFOCUS) == 2) {
			var _p = get_save_filename_compat("GIF|*.gif", string_replace(PROJECT.path, ".pxc", ""));
			if(!CAPTURING && _p != "") {
				cap_path  = _p;
				cap_name  = filename_name_only(_p); 
				CAPTURING = 1;
				
				gif_w = gif_d * 2 + gif_scal * (PANEL_PREVIEW.w + PANEL_GRAPH.w);
				gif_h = gif_d * 2 + gif_scal * (PANEL_PREVIEW.h);
				gif   = gif_open(gif_w, gif_h, 0);
				
				run_in(1, function() /*=>*/ {return PROJECT.animator.render()});
			}
		}
		
		draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
		draw_text_add(bx + bw / 2, by + bh / 2, CAPTURING? "Capturing..." : "Capture");
	}
}