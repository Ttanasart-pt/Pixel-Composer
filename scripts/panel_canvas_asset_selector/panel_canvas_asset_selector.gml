function Panel_Canvas_Asset_Selector(_node, _onSelect) : PanelContent() constructor {
	title    = "Canvas Assets";
	node     = _node;
	onSelect = _onSelect;
	assets   = node.resources;
	title_height = 0;
	
	resSize = ui(48);
	
	w = resSize                        + padding * 2;
	h = resSize * array_length(assets) + padding * 2;
	
	function drawContent(panel) {
		if(!is(node, Node_Canvas_S)) return;
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		for( var i = 0, n = array_length(assets); i < n; i++ ) {
			var _x = px;
			var _y = py + i * resSize;
			
			var _as = assets[i];
			if(is_surface(_as)) {
				var sw = surface_get_width(_as);
				var sh = surface_get_height(_as);
				var rs = resSize - ui(8);
				
				var ss = min(rs / sw, rs / sh);
				var sx = _x + resSize / 2 - sw * ss / 2;
				var sy = _y + resSize / 2 - sh * ss / 2;
				
				draw_surface_ext(_as, sx, sy, ss, ss, 0, c_white, 1);
			}
			
			var hv = pHOVER && point_in_rectangle(mx, my, _x, _y, _x + resSize, _y + resSize);
			
			draw_sprite_stretched_ext(THEME.box_r2, 1, _x, _y, resSize, resSize, COLORS._main_icon);
			if(hv) {
				draw_sprite_stretched_add(THEME.box_r2, 1, _x, _y, resSize, resSize, COLORS._main_icon);
				
				if(mouse_lpress(pFOCUS)) {
					onSelect(i);
					close();
				}
			}
		}
	}
	
}