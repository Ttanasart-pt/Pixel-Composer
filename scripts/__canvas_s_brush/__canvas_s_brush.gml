enum CANVAS_BRUSH_SHAPE {
	circle,
	rectangle,
	surface
}

function canvas_s_brush() constructor {
	size    = 1;
	tile    = [0,0];
	tileDim = [1,1];
	
	canvas  = undefined;
	shape   = CANVAS_BRUSH_SHAPE.circle;
	
	asset_index = 0;
	surface     = undefined;
	surface_use = false;
	surface_w   = 1;
	surface_h   = 1;
	
	shape_array = [ s_node_shape_circle, s_node_shape_rectangle, THEME.panel_preview_icon ];
	settings = [
		new __Simple_Editor( "", new buttonGroup(shape_array, function(i) /*=>*/ { 
				shape = i; 
				if(shape == 2 && canvas) {
					dialogPanelCall(new Panel_Canvas_Asset_Selector(canvas.node, function(i) /*=>*/ { asset_index = i; }),
						mouse_mx + ui(8), mouse_my + ui(8), { anchor: ANCHOR.left | ANCHOR.top })
				}
			}
		), function() /*=>*/ {return shape}, function(b) /*=>*/ { shape = b; } ),
			
		new __Simple_Editor( "", textBox_Number(function(s) /*=>*/ { size = round(s); }), function() /*=>*/ {return size}, function(b) /*=>*/ { size = round(b); } ),
	]
	
	////- Draw
	
	function step(_canvas, _dim) {
		canvas  = _canvas;
		tile    = _canvas.tile;
		tileDim = _dim;
		
		setSurface(_canvas.getResource(asset_index));
		
		// shape_array[2] = surface_use? surface : THEME.panel_preview_icon;
	}
	
	function drawBrush(_brushSurface) { 
		if(shape == CANVAS_BRUSH_SHAPE.surface) {
			if(!surface_use) return undefined;
			
			_brushSurface = surface_verify(_brushSurface, surface_w, surface_h);
			surface_set_target(_brushSurface);
				DRAW_CLEAR
				BLEND_OVERRIDE
				draw_surface(surface, 0, 0);
			surface_reset_target();
			return _brushSurface;
		}
		
		var siz = size;
		
		var dx = floor(siz/2);
		_brushSurface = surface_verify(_brushSurface, siz + 1, siz + 1);
		surface_set_target(_brushSurface);
			DRAW_CLEAR
			draw_set_color(c_white);
			drawPixel(dx, dx);
		surface_reset_target();
		
		return _brushSurface;
	}
		
	function setSurface(_s) {
		surface     = _s;
		surface_use = is_surface(surface);
		surface_w   = surface_use? surface_get_width(surface)  : 1;
		surface_h   = surface_use? surface_get_height(surface) : 1;
	}
	
	static drawPixel = function(_x, _y) {
		if(shape == CANVAS_BRUSH_SHAPE.surface) {
			if(surface_use) draw_surface(surface, _x - surface_w / 2 + 1, _y - surface_h / 2 + 1);
			return 1;
		}
		
		if(size <= 1) {
			draw_point(_x, _y);
				
			if(tile[0]) draw_point(pmod(_x, tileDim[0]), _y);
			if(tile[1]) draw_point(_x, pmod(_y, tileDim[1]));
			return 1;
		}
		
		switch(shape) {
			case CANVAS_BRUSH_SHAPE.circle : 
				if(size < global.FIX_POINTS_AMOUNT) { 
					var fx = global.FIX_POINTS[size];
					for( var i = 0, n = array_length(fx); i < n; i++ ) {
						var px = _x + fx[i][0];
						var py = _y + fx[i][1];
						draw_point(px, py);
							
						if(tile[0]) draw_point(pmod(px, tileDim[0]), py);
						if(tile[1]) draw_point(px, pmod(py, tileDim[1]));
						
					}
							
				} else {
					var s = size / 2;
					draw_circle_prec(_x, _y, s, 0);
				
					if(tile[0]) {
						var px = pmod(_x, tileDim[0]);
						draw_circle_prec(px, _y, s, 0);
						draw_circle_prec(px - tileDim[0], _y, s, 0);
						draw_circle_prec(px + tileDim[0], _y, s, 0);
					}
					
					if(tile[1]) {
						var py = pmod(_y, tileDim[1]);
						draw_circle_prec(_x, py, s, 0);
						draw_circle_prec(_x, py - tileDim[1], s, 0);
						draw_circle_prec(_x, py + tileDim[1], s, 0);
					}
					
				}
				break;
				
			case CANVAS_BRUSH_SHAPE.rectangle : 
				var s0 = floor(size / 2);
				var s1 = ceil(size / 2);
				draw_rectangle(_x-s0, _y-s0, _x+s1, _y+s1, false);
				break;
		}
		
		return 1;
	}

	static drawLine = function(_x0, _y0, _x1, _y1) { 
		if(shape == CANVAS_BRUSH_SHAPE.surface) {
			drawLinePx(round(_x0), round(_y0), round(_x1), round(_y1));
			return 1;
		}
		
		if(size < global.FIX_POINTS_AMOUNT) {
			if(_x1 > _x0) _x0--;
			if(_x1 < _x0) _x1--;
			
			if(_y1 > _y0) _y0--;
			if(_y1 < _y0) _y1--;
		}
			
		if(size < global.FIX_POINTS_AMOUNT) { 
			var fx = global.FIX_POINTS[size];
			for( var i = 0, n = array_length(fx); i < n; i++ ) {
				var px0 = _x0 + fx[i][0];
				var py0 = _y0 + fx[i][1];
				var px1 = _x1 + fx[i][0];
				var py1 = _y1 + fx[i][1];
				
				draw_line(px0, py0, px1, py1);
				
				if(tile[0]) {
					draw_line(px0 - tileDim[0], py0, px1 - tileDim[0], py1);
					draw_line(px0 + tileDim[0], py0, px1 + tileDim[0], py1);
				} 
				
				if(tile[1]) {
					draw_line(px0, py0 - tileDim[1], px1, py1 - tileDim[1]);
					draw_line(px0, py0 + tileDim[1], px1, py1 + tileDim[1]);
				}
				
				if(tile[0] && tile[1]) {
					draw_line(px0 - tileDim[0], py0 - tileDim[1], px1 - tileDim[0], py1 - tileDim[1]);
					draw_line(px0 - tileDim[0], py0 + tileDim[1], px1 - tileDim[0], py1 + tileDim[1]);
					
					draw_line(px0 + tileDim[0], py0 - tileDim[1], px1 + tileDim[0], py1 - tileDim[1]);
					draw_line(px0 + tileDim[0], py0 + tileDim[1], px1 + tileDim[0], py1 + tileDim[1]);
					
				}
			}
					
		} else {
			draw_line_width(_x0, _y0, _x1, _y1, size);
			drawPixel(_x0, _y0);
			drawPixel(_x1, _y1);
		}
		
	}
	
	static drawLinePx = function(_x0, _y0, _x1, _y1) {
		var dx =  abs(_x1 - _x0);
	    var dy = -abs(_y1 - _y0);
	
	    var sx = sign(_x1 - _x0);
	    var sy = sign(_y1 - _y0);
	
	    var err = dx + dy;
	
	    while (true) {
	        drawPixel(_x0, _y0);
			if (_x0 == _x1 && _y0 == _y1) break;
	
	        var e2 = 2 * err;
	
	        if (e2 >= dy) {
	        	if(_x0 == _x1) break;
	        	
	            err += dy;
	            _x0 += sx;
	        }
	
	        if (e2 <= dx) {
	        	if(_y0 == _y1) break;
	        	
	            err += dx;
	            _y0 += sy;
	        }
	    }
	}
	
}