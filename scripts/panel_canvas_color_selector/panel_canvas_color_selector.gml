function Panel_Canvas_Color() : PanelContent() constructor {
	context_str = "Canvas";
	title = "Canvas Color";
	auto_pin = true;
	
	w = ui(32);
	h = ui(800);
	
	min_w  = ui(160);
	
	canvas = undefined;
	
	hue = 0;
	col = undefined;
	
	bColor    = new buttonColor(  function(c) /*=>*/ { canvas.tool_color     = col; });
	bColorSub = new buttonColor(  function(c) /*=>*/ { canvas.tool_color_sub = col; });
	
	sbar = undefined;
	scon = undefined;
	
	function drawContent(panel) {
		if(!is(canvas, Panel_Canvas)) return;
		
		var px = padding;
		var py = padding;
		var pw = w - padding * 2;
		var ph = h - padding * 2;
		
		var wdw = pw + ui(16);
		var wdh = TEXTBOX_HEIGHT;
		
		var wdx = px - ui(8);
		var wdy = h  - padding + ui(8) - wdh;
		
		bColorSub.setFocusHover(pFOCUS, pHOVER);
		bColorSub.drawParam(new widgetParam(wdx, wdy, wdw, wdh, canvas.tool_color_sub, undefined, [mx,my], x, y));
		wdy -= wdh + ui(4);
		ph  -= wdh + ui(4);
		
		bColor.setFocusHover(pFOCUS, pHOVER);
		bColor.drawParam(new widgetParam(wdx, wdy, wdw, wdh, canvas.tool_color, undefined, [mx,my], x, y));
		wdy -= wdh + ui(4);
		ph  -= wdh + ui(4);
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, px - ui(8), py - ui(8), pw + ui(16), ph + ui(16));
		
		if(canvas.tool_color != col) {
			col = canvas.tool_color;
			hue = _color_get_h(canvas.tool_color);
		}
		
		var sh = ui(24);
		var sy = py + ph;
		
		////- =Alpha Selector
		
		sbar = surface_verify(sbar, pw, sh)
		surface_set_target(sbar);
			DRAW_CLEAR
			draw_sprite_stretched(THEME.box_r5, 0, ui(2), ui(2), pw - ui(4), sh - ui(4));
		surface_reset_target();
		
		shader_set(sh_canvas_color_display_2d);
			shader_set_f( "hue",  hue );
			shader_set_c( "col",  canvas.tool_color );
			
			shader_set_i( "type", 1   );
			sy -= sh; 
			draw_surface(sbar, px, sy);
		shader_reset();
		
		var hv = pHOVER && point_in_rectangle(mx, my, px, sy, px + pw, sy + sh);
		var ppx = px + ui(2);
		var ppy = sy + ui(2);
		var ppw = pw - ui(4);
		var pph = sh - ui(4);
		
		draw_sprite_stretched_add(THEME.box_r5, 1, ppx, ppy, ppw, pph, c_white, .25);
		if(hv) {
			draw_sprite_stretched_add(THEME.box_r5, 1, ppx, ppy, ppw, pph, c_white, .25);
			
			if(mouse_lclick(pFOCUS)) {
				var alp = (mx - ppx) / ppw;
				    alp = clamp(alp, 0, 1);
				    
				canvas.tool_color = cola(canvas.tool_color, alp);
				col = canvas.tool_color;
			}
		}
		
		var _alp = _color_get_a(canvas.tool_color);
		
		var bs = ui(10);
		var bx = lerp(ppx, ppx + ppw, _alp);
		var by = sy + sh / 2;
		
		draw_sprite_stretched_ext(THEME.box_r2, 2, bx-bs/2, by-bs/2, bs, bs, c_white);
		draw_sprite_stretched_ext(THEME.box_r2, 1, bx-bs/2, by-bs/2, bs, bs, c_black);
		
		ph -= sh;
	
		////- =Hue Selector
		
		shader_set(sh_canvas_color_display_2d);
			shader_set_i( "type", 2 );
			sy -= sh; 
			draw_surface(sbar, px, sy);
		shader_reset();
		
		var hv = pHOVER && point_in_rectangle(mx, my, px, sy, px + pw, sy + sh);
		var ppx = px + ui(2);
		var ppy = sy + ui(2);
		var ppw = pw - ui(4);
		var pph = sh - ui(4);
		
		draw_sprite_stretched_add(THEME.box_r5, 1, ppx, ppy, ppw, pph, c_white, .25);
		if(hv) {
			draw_sprite_stretched_add(THEME.box_r5, 1, ppx, ppy, ppw, pph, c_white, .25);
			
			if(mouse_lclick(pFOCUS)) {
				var _hue = (mx - ppx) / ppw;
				    _hue = clamp(_hue, 0, 1);
			    
			    var _sat = _color_get_s(canvas.tool_color);
			    var _val = _color_get_v(canvas.tool_color);
			    var _alp = _color_get_a(canvas.tool_color);
			    
				canvas.tool_color = _make_color_hsva(_hue, _sat, _val, _alp);
				col = canvas.tool_color;
				hue = _hue;
			}
		}
		
		var bx = lerp(ppx, ppx + ppw, hue);
		var by = sy + sh / 2;
		
		draw_sprite_stretched_ext(THEME.box_r2, 2, bx-bs/2, by-bs/2, bs, bs, c_white);
		draw_sprite_stretched_ext(THEME.box_r2, 1, bx-bs/2, by-bs/2, bs, bs, c_black);
		
		ph -= sh;
		
		////- =Sat Val Selector
		
		if(ph > ui(4)) {
			scon = surface_verify(scon, pw, ph)
			surface_set_target(scon);
				DRAW_CLEAR
				draw_sprite_stretched(THEME.box_r5, 0, ui(2), ui(2), pw - ui(4), ph - ui(4));
			surface_reset_target();
			
			shader_set(sh_canvas_color_display_2d);
				shader_set_i( "type", 0 );
				draw_surface(scon, px, py);
			shader_reset();
			
			var hv = pHOVER && point_in_rectangle(mx, my, px, py, px + pw, py + ph);
			var ppx = px + ui(2);
			var ppy = py + ui(2);
			var ppw = pw - ui(4);
			var pph = ph - ui(4);
			
			draw_sprite_stretched_add(THEME.box_r5, 1, ppx, ppy, ppw, pph, c_white, .25);
			if(hv) {
				draw_sprite_stretched_add(THEME.box_r5, 1, ppx, ppy, ppw, pph, c_white, .25);
				
				if(mouse_lclick(pFOCUS)) {
					var _sat = (mx - ppx) / ppw;
					    _sat = clamp(_sat, 0, 1);
				    
				    var _val = 1 - (my - ppy) / pph;
					    _val = clamp(_val, 0, 1);
				    
				    var _alp = _color_get_a(canvas.tool_color);
				    
					canvas.tool_color = _make_color_hsva(hue, _sat, _val, _alp);
					col = canvas.tool_color;
				}
			}
			
			var _sat = _color_get_s(canvas.tool_color);
			var _val = _color_get_v(canvas.tool_color);
			
			var bx = lerp(ppx, ppx + ppw, _sat);
			var by = lerp(ppy, ppy + pph, 1 - _val);
			
			draw_sprite_stretched_ext(THEME.box_r2, 2, bx-bs/2, by-bs/2, bs, bs, c_white);
			draw_sprite_stretched_ext(THEME.box_r2, 1, bx-bs/2, by-bs/2, bs, bs, c_black);
		}
	}
}