function graph_export_image(allList, nodeList, settings = {}) {
	var amo = array_length(nodeList);
	if(amo < 1) return;
	
	var scale       = settings[$ "scale"]       ?? 1;
	var padding     = settings[$ "padding"]     ?? 0;
	
	var bgEnable    = settings[$ "bgEnable"]    ?? false;
	var bgColor     = settings[$ "bgColor"]     ?? c_black;
	
	var gridEnable  = settings[$ "gridEnable"]  ?? false;
	var gridColor   = settings[$ "gridColor"]   ?? c_white;
	var gridAlpha   = settings[$ "gridAlpha"]   ?? 0;
	
	var borderPad   = settings[$ "borderPad"]   ?? 0;
	var borderColor	= settings[$ "borderColor"] ?? c_white;
	var borderAlpha	= settings[$ "borderAlpha"] ?? 0.5;
	
	var bbox_x0 = nodeList[0].x * scale;
	var bbox_y0 = nodeList[0].y * scale;
	var bbox_x1 = bbox_x0 + nodeList[0].w * scale;
	var bbox_y1 = bbox_y0 + nodeList[0].h * scale;
	
	for( var i = 0; i < array_length(nodeList); i++ ) {
		var _node = nodeList[i];
		_node.draw_graph_culled = false;
		
		var _x = _node.x * scale;
		var _y = _node.y * scale;
		var _w = _node.w * scale;
		var _h = _node.h * scale;
		
		bbox_x0 = min(bbox_x0, _x - padding);
		bbox_y0 = min(bbox_y0, _y - padding);
		bbox_x1 = max(bbox_x1, _x + _w + padding);
		bbox_y1 = max(bbox_y1, _y + _h + padding);
	}
	
	var _lim_s = 16384 - borderPad * 2;
	
	var bbox_w = min(_lim_s, bbox_x1 - bbox_x0);
	var bbox_h = min(_lim_s, bbox_y1 - bbox_y0);
	
	if(bbox_w == _lim_s || bbox_h == _lim_s) noti_warning("Maximum surface size reached. Reduce scale to prevent cropping.");
	
	var s  = surface_create(bbox_w, bbox_h);
	var cs = surface_create(bbox_w, bbox_h);
	
	var gr_x = -bbox_x0;
	var gr_y = -bbox_y0;
	var mx = gr_x, my = gr_y;
	
	surface_set_target(s); //draw nodes
		if(bgEnable) draw_clear(bgColor);
		else		 draw_clear_alpha(0, 0);
		
		if(gridEnable) {
			var gls = 32;
			var gr_ls = gls * scale;
			var xx = -gr_ls, xs = safe_mod(gr_x, gr_ls);
			var yy = -gr_ls, ys = safe_mod(gr_y, gr_ls);
		
			draw_set_color(gridColor);
			draw_set_alpha(gridAlpha);
			while(xx < bbox_w + gr_ls) {
				draw_line(xx + xs, 0, xx + xs, bbox_h);
				if(xx + xs - gr_x == 0)
					draw_line_width(xx + xs, 0, xx + xs, bbox_h, 3);
				xx += gr_ls;
			}
		
			while(yy < bbox_h + gr_ls) {
				draw_line(0, yy + ys, bbox_w, yy + ys);
				if(yy + ys - gr_y == 0)
					draw_line_width(0, yy + ys, bbox_w, yy + ys, 3);
				yy += gr_ls;
			}
			
			draw_set_alpha(1);
		}
		
		for( var i = 0, n = array_length(allList); i < n; i++ )
			allList[i].preDraw(gr_x, gr_y, mx, my, scale);
		
		for( var i = 0, n = array_length(nodeList); i < n; i++ )
			nodeList[i].drawNodeBG(gr_x, gr_y, mx, my, scale);
		
		#region draw conneciton
			surface_set_target(cs);
				DRAW_CLEAR
				var param = new connectionParameter();
				
				param.setPos(gr_x, gr_y, scale, mx, my);
				param.setProp(1, false);
				param.setDraw(1, c_black);
				
				param.show_dimension  = true;
				param.show_compute    = true;
				param.avoid_label     = true;
				param.preview_scale   = 100;
				
				for( var i = 0, n = array_length(nodeList); i < n; i++ )
					nodeList[i].drawConnections(param, true);
			surface_reset_target();
			
			draw_surface_safe(cs);
		#endregion
			
		#region draw node
			for( var i = 0, n = array_length(nodeList); i < n; i++ )
				nodeList[i].onDrawNodeBehind(gr_x, gr_y, mx, my, scale);
			
			for( var i = 0, n = array_length(nodeList); i < n; i++ )
				nodeList[i].drawNode(true, gr_x, gr_y, mx, my, scale, param);
				
			for( var i = 0, n = array_length(nodeList); i < n; i++ )
				nodeList[i].drawNodeFG(gr_x, gr_y, mx, my, scale, param);
		#endregion
		
	surface_reset_target();
	
	var _sg = surface_create(bbox_w + borderPad * 2, bbox_h + borderPad * 2);
	
	if(borderPad == 0) {
		surface_set_target(_sg);
			DRAW_CLEAR
			
			if(bgEnable) {
				draw_clear(bgColor);
				gpu_set_colorwriteenable(1, 1, 1, 0);
			}
			
			BLEND_OVERRIDE
			draw_surface_safe(s);
			BLEND_NORMAL
			
			gpu_set_colorwriteenable(1, 1, 1, 1);
		surface_reset_target();
		
	} else {
		surface_set_target(_sg);
			DRAW_CLEAR
			
			if(bgEnable) {
				draw_clear(bgColor);
				gpu_set_colorwriteenable(1, 1, 1, 0);
			}
			
			BLEND_OVERRIDE
			draw_surface(s, borderPad, borderPad);
			
			BLEND_ALPHA_MULP
			draw_set_color(borderColor);
			draw_set_alpha(borderAlpha);
				draw_rectangle(borderPad, borderPad, bbox_w + borderPad, bbox_h + borderPad, 1);
			draw_set_alpha(1);
			BLEND_NORMAL
			
			gpu_set_colorwriteenable(1, 1, 1, 1);
		surface_reset_target();
	}
	
	surface_free(cs);
	surface_free(s);
	
	return _sg;
}