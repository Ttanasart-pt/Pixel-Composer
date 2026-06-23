globalvar PREVIEW_WINDOW_PANEL; PREVIEW_WINDOW_PANEL = noone;

#macro CHECK_PANEL_PREVIEW_WINDOW if(PREVIEW_WINDOW_PANEL == noone) return;

function panel_preview_window_reset()       { CHECK_PANEL_PREVIEW_WINDOW CALL("preview_window_reset");       PREVIEW_WINDOW_PANEL.resetView();      }
function panel_preview_window_inspect()     { CHECK_PANEL_PREVIEW_WINDOW CALL("preview_window_inspect");     PANEL_GRAPH.nodes_selecting = [ PREVIEW_WINDOW_PANEL.node_target ]; }
function panel_preview_window_preview()     { CHECK_PANEL_PREVIEW_WINDOW CALL("preview_window_preview");     PANEL_PREVIEW.setNodePreview(PREVIEW_WINDOW_PANEL.node_target);     }
function panel_preview_window_lock_toggle() { CHECK_PANEL_PREVIEW_WINDOW CALL("preview_window_lock_toggle"); PREVIEW_WINDOW_PANEL.toggleNodeLock(); }

function __fnInit_Preview_Window() {
	registerFunction("Preview Window", "Reset view", "F", MOD_KEY.none, panel_preview_window_reset   ).setMenu( "preview_window_reset_view" )
	registerFunction("Preview Window", "Inspect",    "",  MOD_KEY.none, panel_preview_window_inspect ).setMenu( "preview_window_inspect"    )
	registerFunction("Preview Window", "Preview",    "",  MOD_KEY.none, panel_preview_window_preview ).setMenu( "preview_window_preview"    )
	
	registerFunction("Preview Window", "Lock",       "",  MOD_KEY.none, panel_preview_window_lock_toggle )
		.setMenu( "preview_window_lock" ).setToggle(function() /*=>*/ {return PREVIEW_WINDOW_PANEL? PREVIEW_WINDOW_PANEL.node_lock : false});
}

function Panel_Preview_Window() : PanelContent() constructor {
	#region ---- Dimension ----
		context_str = "Preview Window";
		title = __txt("Preview window");
		icon  = THEME.panel_preview_window_icon;
		
		min_w = ui(64);
		min_h = ui(64);
		
		w = ui(200);
		h = ui(200);
		
		static onFocusBegin = function() /*=>*/ { PREVIEW_WINDOW_PANEL = self; }
	#endregion
	
	#region ---- Node ----
		node_lock       = false;
		node_target     = noone;
		preview_channel = 0;
		content_surface = noone;
		
		function toggleNodeLock() { node_lock = !node_lock; return self; }
		function setPreview(_node, _channel = 0) {
			node_target     = _node;
			preview_channel = _channel;
			return self;
		}
		
		content_surface = noone;
	#endregion
	
	#region ---- Preview ----
		scale = 0;
		panx  = 0;
		pany  = 0;
		
		panning = false;
		pan_mx = 0;
		pan_my = 0;
		pan_sx = 0;
		pan_sy = 0;
		
		function resetView() {
			scale = 0;
			panx  = 0;
			pany  = 0;
		}
	#endregion
	
	#region ---- Menu ----
		global.menuItems_preview_window = [
			"preview_window_lock",
			"preview_window_reset_view",
			-1,
			"preview_window_inspect",
			"preview_window_preview",
			-1,
		]
	
	#endregion
	
	function surfaceCheck() { content_surface = surface_verify(content_surface, w, h); }
	
	function changeChannel(_index) {
		var channel = 0;
		
		for( var i = 0; i < array_length(node_target.outputs); i++ ) {
			var o = node_target.outputs[i];
			if(o.type != VALUE_TYPE.surface) continue;
			
			if(channel++ == _index)
				preview_channel = i;
		}
	}
	
	function drawSurface() {
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
				if(scale == 0) scale = min((w - ui(32)) / sw, (h - ui(32)) / sh);
				var sx = dx + w / 2 - (sw * scale) / 2 + panx;
				var sy = dy + h / 2 - (sh * scale) / 2 + pany;
		
				draw_surface_ext_safe(s, sx, sy, scale, scale, 0, c_white, 1);
				draw_set_color(COLORS.panel_preview_surface_outline);
				draw_rectangle(sx, sy, sx + sw * scale - 1, sy + sh * scale - 1, true);
			
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
			var s = scale;
			if(MOUSE_WHEEL != 0) {
				var inc = .1;
	                 if(scale > 16) inc =  2;
	            else if(scale >  8) inc =  1;
	            else if(scale >  3) inc = .50;
	            else if(scale >  1) inc = .25;
	            
	            if(!key_mod_press_any() && MOUSE_WHEEL != 0) {
	            	if(frac(MOUSE_WHEEL) == 0) scale = clamp(value_snap(scale + MOUSE_WHEEL * inc, inc), 0.10, 1024);
	            	else                       scale = clamp(scale + MOUSE_WHEEL * inc, 0.10, 1024);
	            }
			}
			
			var ds = scale - s;
			panx = panx / s * scale;
			pany = pany / s * scale;
		}
	
		if(mouse_rclick(pFOCUS)) {
			var _menu = menuItems_gen("preview_window");
			var _chan = 0;
			
			for( var i = 0; i < array_length(node_target.outputs); i++ ) {
				var o = node_target.outputs[i];
				if(o.type != VALUE_TYPE.surface) continue;
			
				array_push(_menu, menuItem(o.name, function(_dat) { changeChannel(_dat.index); }, noone, noone, noone, { index: _chan }));
				_chan++;
			}
			
			menuCall("preview_window", _menu, 0, 0, fa_left);
		}
	}
	
	surfaceCheck();
	function drawContent(panel) {
		if(!node_lock) {
			var _node = PANEL_PREVIEW.getNodePreview();
			if(_node != node_target) setPreview(_node);
		}
		
		if(node_target == noone) { 
			title = __txt("Preview window");
			if(mouse_rclick(pFOCUS)) 
				menuCallGen("preview_window");
		} else 
			drawSurface();
		
		var bs = ui(24);
		var bx = w - ui(4) - bs;
		var by = h - ui(4) - bs;
		
		if(buttonInstant_Pad(THEME.button_def, bx, by, bs, bs, [mx,my], pHOVER, pFOCUS, __txt("Lock"), THEME.lock, !node_lock) == 2)
			node_lock = !node_lock;
	}
	
    ////- Serialize
    
    static serialize   = function() { 
        return { node_lock }; 
    }
    
    static deserialize = function(data) { 
        node_lock = data[$ "node_lock"] ?? node_lock;
        return self; 
    }
    
}