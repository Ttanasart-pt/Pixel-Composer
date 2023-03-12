function Panel_Preview_Window() : PanelContent() constructor {
	min_w = ui(64);
	min_h = ui(64);
	padding = 8;
	title_height = 32;
	
	w = ui(200);
	h = ui(200);
	
	node_target = noone;
	preview_channel = 0;
	
	title_show = 0;
	
	scale = 0;
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
		var px = 0;
		var py = 0;
		var pw = w;
		var ph = h;
		
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
					scale = min(pw / sw, ph / sh);
				var sx = dx + pw / 2 - (sw * scale) / 2 + panx;
				var sy = dy + ph / 2 - (sh * scale) / 2 + pany;
		
				draw_surface_ext(s, sx, sy, scale, scale, 0, c_white, 1);
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
		draw_surface(content_surface, px, py);
	
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
			if(scale > 16)		inc = 2;
			else if(scale > 8)	inc = 1;
			
			var s = scale;
			if(mouse_wheel_down()) scale = max(round(scale / inc) * inc - inc, 0.25);
			if(mouse_wheel_up())   scale = min(round(scale / inc) * inc + inc, 32);
		
			var ds = scale - s;
			panx = panx / s * scale;
			pany = pany / s * scale;
		}
	
		if(mouse_click(mb_right, pFOCUS)) {
			var _menu = array_clone(menu);
			for( var i = 0; i < ds_list_size(node_target.outputs); i++ ) {
				var o = node_target.outputs[| i];
				if(o.type != VALUE_TYPE.surface) continue;
			
				array_push(_menu, menuItem(o.name, function(_x, _y, _d, _n, index) { changeChannel(index); }));
			}
			menuCall(,, _menu);
		}
	}
}