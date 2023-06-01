function Panel_Preview_Window() : PanelContent() constructor {
	min_w = ui(64);
	min_h = ui(64);
	padding = 8;
	title_height = 24;
	
	w = ui(200);
	h = ui(200);
	
	node_target = noone;
	preview_channel = 0;
	
	title_show = 0;
	
	scale = 0;
	scale_levels = [ 1/32, 1/24, 1/16, 1/12, 1/8, 1/4, 1/3, 1/2, 2/3, 1, 1.5, 2, 3, 4, 6, 8, 12, 16, 24, 32];
	panx  = 0;
	pany  = 0;
	
	panning = false;
	pan_mx = 0;
	pan_my = 0;
	pan_sx = 0;
	pan_sy = 0;
	
	function surfaceCheck() {
		content_surface = surface_verify(content_surface, w, h);
	}
	
	function reset() {
		scale = 0;
		panx = 0;
		pany = 0;
	}
	
	function changeChannel(index) {
		var channel = index - array_length(menu);
		for( var i = 0; i < ds_list_size(node_target.outputs); i++ ) {
			var o = node_target.outputs[| i];
			if(o.type != VALUE_TYPE.surface) continue;
			if(channel-- == 0) {
				preview_channel = i;
				return;
			}
		}
	}
	
	content_surface = noone;
	surfaceCheck();
	
	menu = [
		menuItem(get_text("reset_view", "Reset view"), function() { reset(); }), 
		-1,
		menuItem(get_text("preview_win_inspect", "Inspect"), function() { PANEL_GRAPH.node_focus = node_target; }), 
		menuItem(get_text("panel_graph_send_to_preview", "Send to preview"), function() { PANEL_PREVIEW.setNodePreview(node_target); }), 
		-1,
	]

	function drawContent(panel) {
		if(node_target == noone) return;
		title = node_target.getFullName();
		surfaceCheck();
	
		surface_set_target(content_surface);
			draw_clear(COLORS.panel_bg_clear);
			draw_sprite_tiled_ext(s_transparent, 0, 0, 0, 1, 1, c_white, 0.75);
			
			var surf = node_target.outputs[| preview_channel].getValue();
			if(is_array(surf))
				surf = array_spread(surf);
			else 
				surf = [ surf ];
		
			var dx  = 0;
			var dy  = 0;
			var ind = 0;
			var col = round(sqrt(array_length(surf)));
		
			for( var i = 0; i < array_length(surf); i++ ) {
				var s  = surf[i];
				var sw = surface_get_width(s);
				var sh = surface_get_height(s);
				if(scale == 0)
					scale = min(w / sw, h / sh);
				var sx = dx + w / 2 - (sw * scale) / 2 + panx;
				var sy = dy + h / 2 - (sh * scale) / 2 + pany;
		
				draw_surface_ext_safe(s, sx, sy, scale, scale, 0, c_white, 1);
				draw_set_color(COLORS._main_icon);
				draw_rectangle(sx, sy, sx + sw * scale, sy + sh * scale, true);
			
				if(++ind >= col) {
					ind = 0;
					dx  = 0;
					dy += (sh + 2) * scale;
				} else
					dx += (sw + 2) * scale;
			}
		surface_reset_target();
		draw_surface_safe(content_surface, 0, 0);
	
		if(panning) {
			panx = pan_sx + (mouse_mx - pan_mx);
			pany = pan_sy + (mouse_my - pan_my);
		
			if(mouse_release(mb_middle)) 
				panning = false;
		}
	
		if(mouse_press(mb_middle, pFOCUS)) {
			panning = true;
			pan_mx = mouse_mx;
			pan_my = mouse_my;
			pan_sx = panx;
			pan_sy = pany;
		}
		
		if(pHOVER) {
			var inc = 0.5;
			if(scale > 64)			inc = 4;
			else if(scale > 16)		inc = 2;
			else if(scale > 8)		inc = 1;
			else if(scale > 2)		inc = 0.5;
			else if(scale > 0.25)	inc = 0.25;
			else					inc = 0.05;
			
			var s = scale;
			if(mouse_wheel_down()) {
				for( var i = 0; i < array_length(scale_levels) - 1; i++ ) {
					if(s > scale_levels[i] && s <= scale_levels[i + 1]) {
						scale = scale_levels[i];
						break;
					}
				}
			}
			
			if(mouse_wheel_up()) {
				for( var i = 0; i < array_length(scale_levels) - 1; i++ ) {
					if(s >= scale_levels[i] && s < scale_levels[i + 1]) {
						scale = scale_levels[i + 1];
						break;
					}
				}
			}
			
			var ds = scale - s;
			panx = panx / s * scale;
			pany = pany / s * scale;
		}
	
		if(mouse_click(mb_right, pFOCUS)) {
			var _menu = array_clone(menu);
			for( var i = 0; i < ds_list_size(node_target.outputs); i++ ) {
				var o = node_target.outputs[| i];
				if(o.type != VALUE_TYPE.surface) continue;
			
				array_push(_menu, menuItem(o.name, function(_dat) { changeChannel(_dat.index); }));
			}
			menuCall("preview_window_menu",,, _menu,, node_target);
		}
	}
}