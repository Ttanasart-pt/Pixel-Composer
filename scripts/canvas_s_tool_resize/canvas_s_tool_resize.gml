function canvas_s_tool_resize(_canvas) : canvas_s_tool() constructor {
	icon    = THEME.resize;
	tooltip = "Resize";
	
	cavnas = _canvas;
	
	resize_dimension = [ cavnas.node_dimension[0],   cavnas.node_dimension[1]   ];
	resize_anchor    = [ 0, 0 ];
	anchor_index     = 4;
	
	dragging = 0;
	drag_mx  = 0; drag_my  = 0;
	drag_sx  = 0; drag_sy  = 0;
	drag_px  = 0; drag_py  = 0;
	 
	anchor_widget = new buttonAnchor(noone, function(i) /*=>*/ { 
		var dw = resize_dimension[0];
		var dh = resize_dimension[1];
		
		var sw = canvas.node_dimension[0];
		var sh = canvas.node_dimension[1];
		
		var cx = sw / 2 - dw / 2;
		var cy = sh / 2 - dh / 2;
		
		var x1 = sw - dw;
		var y1 = sh - dh;
		anchor_index = i;
		
		switch(i) {
			case 0 : resize_anchor = [ 0,  0]; break;
			case 1 : resize_anchor = [cx,  0]; break;
			case 2 : resize_anchor = [x1,  0]; break;
			
			case 3 : resize_anchor = [ 0, cy]; break;
			case 4 : resize_anchor = [cx, cy]; break;
			case 5 : resize_anchor = [x1, cy]; break;
			
			case 6 : resize_anchor = [ 0, y1]; break;
			case 7 : resize_anchor = [cx, y1]; break;
			case 8 : resize_anchor = [x1, y1]; break;
			
		}
	});
	anchor_widget.alpha = .5;
	
	settings = [
		new __Simple_Editor( "", anchor_widget, function() /*=>*/ {return resize_anchor}, function(b) /*=>*/ { resize_anchor = b; } ),
			
		new __Simple_Editor( "", new vectorBox(2, function(v,i) /*=>*/ { 
			var ox = resize_dimension[0];
			var oy = resize_dimension[1];
			
			var nx = i == 0? round(v) : resize_dimension[0];
			var ny = i == 1? round(v) : resize_dimension[1];
			
			var dx = nx - ox;
			var dy = ny - oy;
			
			var hx = round(dx / 2);
			var hy = round(dy / 2);
			
			resize_dimension = [nx,ny];
			
			switch(anchor_index) {
				case 0 :                                                 break;
				case 1 : resize_anchor[0] -= hx;                         break;
				case 2 : resize_anchor[0] -= dx;                         break;
				
				case 3 :                         resize_anchor[1] -= hy; break;
				case 4 : resize_anchor[0] -= hx; resize_anchor[1] -= hy; break;
				case 5 : resize_anchor[0] -= dx; resize_anchor[1] -= hy; break;
				
				case 6 :                         resize_anchor[1] -= dy; break;
				case 7 : resize_anchor[0] -= hx; resize_anchor[1] -= dy; break;
				case 8 : resize_anchor[0] -= dx; resize_anchor[1] -= dy; break;
			}
			
		}).setMinWidth(ui(160)), 
			function() /*=>*/ {return resize_dimension}, function(b) /*=>*/ { resize_dimension = b; } ),
		
		-1, 
		
		new __Simple_Editor( "", button(function() /*=>*/ {return apply()}).setTooltip("Apply").setBaseSprite(THEME.button_hide_fill)
			.setIcon(THEME.accept, 0, COLORS._main_value_positive, .75), function() /*=>*/ {return 0}, function() /*=>*/ {} ),
			
		new __Simple_Editor( "", button(function() /*=>*/ {return canvas.resetTool()}).setTooltip("Cancel").setBaseSprite(THEME.button_hide_fill)
			.setIcon(THEME.cross, 0, COLORS._main_value_negative, .75), function() /*=>*/ {return 0}, function() /*=>*/ {} ),
	]
	
	function drawing(_drawingSurface) {
		var sx0 = resize_anchor[0];
		var sy0 = resize_anchor[1];
		var sx1 = resize_anchor[0] + resize_dimension[0];
		var sy1 = resize_anchor[1] + resize_dimension[1];
		
		var x0 = preview_x + sx0 * preview_s;
		var y0 = preview_y + sy0 * preview_s;
		var x1 = preview_x + sx1 * preview_s;
		var y1 = preview_y + sy1 * preview_s;
		
		anchor_widget.index = anchor_index;
		
		var w  = canvas.w;
		var h  = canvas.h;
		
		draw_set_color_alpha(c_black, .5);
			draw_rectangle( 0,  0,  w, y0, false);
			draw_rectangle( 0, y1,  w,  h, false);
			draw_rectangle( 0, y0, x0, y1, false);
			draw_rectangle(x1, y0,  w, y1, false);
		draw_set_alpha(1);
		
		var hov = 0;
		
		if(hover) {
			if(point_in_rectangle(mx, my, x0, y0, x1, y1))     hov = 9;
			
			if(distance_to_line(mx, my, x0, 0, x0, h) < ui(6)) hov = 1; 
			if(distance_to_line(mx, my, x1, 0, x1, h) < ui(6)) hov = 2; 
			if(distance_to_line(mx, my, 0, y0, w, y0) < ui(6)) hov = 3; 
			if(distance_to_line(mx, my, 0, y1, w, y1) < ui(6)) hov = 4; 
			
			if(point_in_circle(mx, my, x0, y0, ui(8)))         hov = 5; 
			if(point_in_circle(mx, my, x1, y0, ui(8)))         hov = 6; 
			if(point_in_circle(mx, my, x0, y1, ui(8)))         hov = 7; 
			if(point_in_circle(mx, my, x1, y1, ui(8)))         hov = 8; 
		}
		
		if(dragging) {
			hov = dragging;
			
			var dx = round((mx - drag_mx) / preview_s);
			var dy = round((my - drag_my) / preview_s);
			
			switch(dragging) {
				case 1 : 
					resize_dimension[0] = drag_sx - dx;
					resize_anchor[0]    = drag_px + dx;
					break;
				
				case 2 : 
					resize_dimension[0] = drag_sx + dx;
					break;
				
				case 3 : 
					resize_dimension[1] = drag_sy - dy;
					resize_anchor[1]    = drag_py + dy;
					break;
					
				case 4 : 
					resize_dimension[1] = drag_sy + dy;
					break;
					
				case 5 :
					resize_dimension[0] = drag_sx - dx;
					resize_dimension[1] = drag_sy - dy;
					
					resize_anchor[0]    = drag_px + dx;
					resize_anchor[1]    = drag_py + dy;
					break;
					
				case 6 :
					resize_dimension[0] = drag_sx - dx;
					resize_dimension[1] = drag_sy + dy;
					
					resize_anchor[0]    = drag_px + dx;
					resize_anchor[1]    = drag_py - dy;
					break;
					
				case 7 :
					resize_dimension[0] = drag_sx + dx;
					resize_dimension[1] = drag_sy - dy;
					
					resize_anchor[0]    = drag_px - dx;
					resize_anchor[1]    = drag_py + dy;
					break;
					
				case 8 :
					resize_dimension[0] = drag_sx + dx;
					resize_dimension[1] = drag_sy + dy;
					break;
					
				case 9 : 
					resize_anchor[0]    = drag_px + dx;
					resize_anchor[1]    = drag_py + dy;
					break;
			}
			
			if(mouse_lrelease()) 
				dragging = 0;
			
		} else if(hov && mouse_lpress(focus)) {
			dragging = hov;
			drag_mx  = mx;
			drag_my  = my;
			
			drag_sx  = resize_dimension[0]; 
			drag_sy  = resize_dimension[1];
			
			drag_px  = resize_anchor[0]; 
			drag_py  = resize_anchor[1];
	
		}
		
		draw_set_color(COLORS._main_accent);
		draw_line_width(x0, 0, x0, h, 1 + (hov == 1) * 2);
		draw_line_width(x1, 0, x1, h, 1 + (hov == 2) * 2);
		draw_line_width(0, y0, w, y0, 1 + (hov == 3) * 2);
		draw_line_width(0, y1, w, y1, 1 + (hov == 4) * 2);
		if(hov == 9) draw_rectangle_width(x0, y0, x1, y1, 3);
		
		draw_anchor(hov == 5, x0, y0);
		draw_anchor(hov == 6, x1, y0);
		draw_anchor(hov == 7, x0, y1);
		draw_anchor(hov == 8, x1, y1);
	}
	
	function apply() {
		var dim = resize_dimension;
		var anc = resize_anchor;
		
		var nod = canvas.node;
		
		var _resized  = surface_create(max(1, dim[0]), max(1, dim[1]));
		var _origSurf = nod.outputs[0].getValue();
		
		surface_set_target(_resized);
			BLEND_OVERRIDE
			draw_surface(_origSurf, -anc[0], -anc[1]);
			BLEND_NORMAL
		surface_reset_target();
		
		nod.inputs[0].setValue(dim);
		nod.attributes.dimension = dim;
		
		var buff = buffer_create(1, buffer_grow, 1);
		buffer_get_surface(buff, _resized, 0);
		nod.pixel_data = buff;
		
		nod.update();
		nod.triggerRender();
		
		canvas.getSurface();
		canvas.tool_current = undefined;
		canvas.preview_x   += anc[0] * preview_s;
		canvas.preview_y   += anc[1] * preview_s;
		
	}
}