#macro CHECK_PANEL_PREVIEW_WINDOW if(!is_instanceof(FOCUS_CONTENT, Panel_Preview_Window)) return;

function panel_preview_window_reset()	{ CHECK_PANEL_PREVIEW_WINDOW CALL("preview_window_reset");		FOCUS_CONTENT.reset();													}
function panel_preview_window_inspect()	{ CHECK_PANEL_PREVIEW_WINDOW CALL("preview_window_inspect");	PANEL_GRAPH.nodes_selecting = [ FOCUS_CONTENT.node_target ];			}
function panel_preview_window_preview()	{ CHECK_PANEL_PREVIEW_WINDOW CALL("preview_window_preview");	PANEL_PREVIEW.setNodePreview(FOCUS_CONTENT.node_target);				}

function __fnInit_Preview_Window() {
	registerFunction("Preview Window", "Reset view",	"",	   MOD_KEY.none,	panel_preview_window_reset   ).setMenu("preview_window_reset_view")
	registerFunction("Preview Window", "Inspect",		"",	   MOD_KEY.none,	panel_preview_window_inspect ).setMenu("preview_window_inspect")
	registerFunction("Preview Window", "Preview",		"",	   MOD_KEY.none,	panel_preview_window_preview ).setMenu("preview_window_preview")
}

function Panel_Preview_Window() : PanelContent() constructor {
	min_w   = ui(64);
	min_h   = ui(64);
	
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
		panx  = 0;
		pany  = 0;
	}
	
	function changeChannel(_index) {
		var channel = 0;
		
		for( var i = 0; i < array_length(node_target.outputs); i++ ) {
			var o = node_target.outputs[i];
			if(o.type != VALUE_TYPE.surface) continue;
			
			if(channel++ == _index)
				preview_channel = i;
		}
	}
	
	content_surface = noone;
	surfaceCheck();
	
	menu = [
		MENU_ITEMS.preview_window_reset_view,
		-1,
		MENU_ITEMS.preview_window_inspect,
		MENU_ITEMS.preview_window_preview,
		-1,
	]

	function drawContent(panel) {
		if(node_target == noone) return;
		title = node_target.getFullName();
		surfaceCheck();
	
		surface_set_target(content_surface);
			draw_clear(COLORS.panel_bg_clear);
			draw_sprite_tiled_ext(s_transparent, 0, 0, 0, 1, 1, COLORS.panel_preview_transparent, 1);
			
			var surf = node_target.getPreviewValues();
			    surf = is_array(surf)? array_spread(surf) : [ surf ];
		
			var dx  = 0;
			var dy  = 0;
			var ind = 0;
			var col = round(sqrt(array_length(surf)));
		
			for( var i = 0, n = array_length(surf); i < n; i++ ) {
				var s  = surf[i];
				var sw = surface_get_width_safe(s);
				var sh = surface_get_height_safe(s);
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
		draw_surface_safe(content_surface);
	
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
			
			//if(WINDOW_ACTIVE != noone) print($"{winwin_mouse_wheel_down(WINDOW_ACTIVE)} : {winwin_mouse_wheel_up(WINDOW_ACTIVE)} : {random(1)}");
			
			var s = scale;
			if(mouse_wheel_down()) {
				for( var i = 0, n = array_length(scale_levels) - 1; i < n; i++ ) {
					if(s > scale_levels[i] && s <= scale_levels[i + 1]) {
						scale = scale_levels[i];
						break;
					}
				}
			}
			
			if(mouse_wheel_up()) {
				for( var i = 0, n = array_length(scale_levels) - 1; i < n; i++ ) {
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
			var _chan = 0;
			
			for( var i = 0; i < array_length(node_target.outputs); i++ ) {
				var o = node_target.outputs[i];
				if(o.type != VALUE_TYPE.surface) continue;
			
				array_push(_menu, menuItem(o.name, function(_dat) { changeChannel(_dat.index); }, noone, noone, noone, { index: _chan }));
				_chan++;
			}
			
			menuCall("preview_window_menu", _menu, 0, 0, fa_left);
		}
	}
}