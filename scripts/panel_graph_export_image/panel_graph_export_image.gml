function graph_export_image(allList, nodeList, settings = {}) {
	var amo = ds_list_size(nodeList);
	if(amo < 1) return;
	
	var scale    = struct_try_get(settings, "scale", 1);
	var padding  = struct_try_get(settings, "padding", 0);
	
	var bgEnable = struct_try_get(settings, "bgEnable", false);
	var bgColor  = struct_try_get(settings, "bgColor", c_black);
	
	var gridEnable  = struct_try_get(settings, "gridEnable", false);
	var gridColor   = struct_try_get(settings, "gridColor", c_white);
	var gridAlpha   = struct_try_get(settings, "gridAlpha", 0);
	
	var borderPad	= struct_try_get(settings, "borderPad", 0);
	var borderColor	= struct_try_get(settings, "borderColor", c_white);
	var borderAlpha	= struct_try_get(settings, "borderAlpha", 0.5);
	
	var bbox_x0 = nodeList[| 0].x * scale;
	var bbox_y0 = nodeList[| 0].y * scale;
	var bbox_x1 = bbox_x0 + nodeList[| 0].w * scale;
	var bbox_y1 = bbox_y0 + nodeList[| 0].h * scale;
	
	for( var i = 0; i < ds_list_size(nodeList); i++ ) {
		var _node = nodeList[| i];
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
	
	var bbox_w = bbox_x1 - bbox_x0;
	var bbox_h = bbox_y1 - bbox_y0;
	
	var aa = PREFERENCES.connection_line_aa;
	var s  = surface_create(bbox_w, bbox_h);
	var cs = surface_create(bbox_w * aa, bbox_h * aa);
	
	surface_set_target(s); //draw nodes
		if(bgEnable) draw_clear(bgColor);
		else		 draw_clear_alpha(0, 0);
		
		var gr_x = -bbox_x0;
		var gr_y = -bbox_y0;
		var mx = gr_x, my = gr_y;
		
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
		
		for(var i = 0; i < ds_list_size(allList); i++)
			allList[| i].preDraw(gr_x, gr_y, scale);
		
		#region draw frame
			for(var i = 0; i < ds_list_size(nodeList); i++) {
				if(instanceof(nodeList[| i]) != "Node_Frame") continue;
				nodeList[| i].drawNode(gr_x, gr_y, mx, my, scale);
			}
		#endregion
		
		#region draw conneciton
			surface_set_target(cs);
				DRAW_CLEAR
				var param = new connectionParameter();
				
				param.setPos(gr_x, gr_y, scale, mx, my);
				param.setProp(1, false);
				param.setDraw(aa, c_black);
			
				param.show_dimension  = true;
				param.show_compute    = true;
				param.avoid_label     = false;
				param.preview_scale   = 100;
				
				for(var i = 0; i < ds_list_size(nodeList); i++)
					nodeList[| i].drawConnections(param, true);
			surface_reset_target();
		
			shader_set(sh_downsample);
			shader_set_f("down", aa);
			shader_set_f("dimension", surface_get_width_safe(cs), surface_get_height_safe(cs));
			draw_surface(cs, 0, 0);
			shader_reset();
			surface_free(cs);
		#endregion
		
		#region draw node
			for(var i = 0; i < ds_list_size(nodeList); i++)
				nodeList[| i].onDrawNodeBehind(gr_x, gr_y, mx, my, scale);
			
			for(var i = 0; i < ds_list_size(nodeList); i++) {
				var _node = nodeList[| i];
				if(instanceof(_node) == "Node_Frame") continue;
				var val = _node.drawNode(gr_x, gr_y, mx, my, scale, param);
			}
		#endregion
		
	surface_reset_target();
	
	if(borderPad == 0) return s;
	
	var _sg = surface_create(bbox_w + borderPad * 2, bbox_h + borderPad * 2);
	
	surface_set_target(_sg);
		if(bgEnable) draw_clear(bgColor);
		else		 draw_clear_alpha(0, 0);
		
		BLEND_ALPHA_MULP
		draw_surface(s, borderPad, borderPad);
		
		draw_set_color(borderColor);
		draw_set_alpha(borderAlpha);
			draw_rectangle(borderPad, borderPad, bbox_w + borderPad, bbox_h + borderPad, 1);
		draw_set_alpha(1);
		BLEND_NORMAL
	surface_reset_target();
	
	
	surface_free(s);
	return _sg;
}