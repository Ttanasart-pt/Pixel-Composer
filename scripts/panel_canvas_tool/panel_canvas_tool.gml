function Panel_Canvas_Tool() : PanelContent() constructor {
	context_str = "Canvas";
	title       = "Canvas Tool";
	auto_pin    = true;
	
	mouse_overflow = true;
	
	min_w  = ui(32);
	min_h  = ui(40);
	
	tool_h = ui(32);
	
	canvas = undefined;
	
	#region panel
		_hovering_subtool = undefined;
		 hovering_subtool = undefined;
	#endregion
	
	#region tools
		tSelRect = new canvas_s_selector_shape_rectangle();
		tSelElip = new canvas_s_selector_shape_ellipse();
		tSelPenc = new canvas_s_selector_pencil();
		
		tSelFree = new canvas_s_selector_shape_freeform();
		tSelPoly = new canvas_s_selector_shape_freeform_polygon();
		
		tSelMagi = new canvas_s_selector_magic();
		
		tPencil  = new canvas_s_tool_pencil();
		tEraser  = new canvas_s_tool_eraser();
		
		tLine    = new canvas_s_tool_line();
		tCurve   = new canvas_s_tool_curve();
		
		tRect    = new canvas_s_tool_shape_rectangle(false);
		tRectF   = new canvas_s_tool_shape_rectangle(true);
		
		tElip    = new canvas_s_tool_shape_ellipse(false);
		tElipF   = new canvas_s_tool_shape_ellipse(true);
		
		tFill    = new canvas_s_tool_fill();
		tGrad    = new canvas_s_tool_gradient();
		
		tFree    = new canvas_s_tool_freeform();
		tFreeP   = new canvas_s_tool_freeform_polygon();
		
		tIso0   = new canvas_s_tool_shape_iso(0);
		tIso1   = new canvas_s_tool_shape_iso(1);
		tIso2   = new canvas_s_tool_shape_iso(2);
		
		tNode   = new canvas_s_tool_node();
		
		tools = [ 
			[ tSelRect, tSelElip, tSelPenc, tSelFree, tSelPoly, tSelMagi ], 
			
			tPencil,
			tEraser,
			
			[ tLine, tCurve ],
			[ tRect, tRectF ],
			[ tElip, tElipF ],
			[ tIso0, tIso1, tIso2 ], 
			[ tFree, tFreeP ], 
			
			[ tFill, tGrad  ],
			
			-1, 
			
			tNode, 
		];
	#endregion
	
	function postCheckMouse() {
		if(_hovering_subtool != undefined)
			HOVER = self;
	}

	function drawContent(panel) {
		if(!is(canvas, Panel_Canvas)) return;
		
		var pd = ui(2);
		var tw = w - pd * 2;
		var th = tool_h;
		
		var tx = pd;
		var ty = pd;
		
		var ttw = tw;
		var tth = th - 1;
			
		var p  = ui(2);
		var p2 = p * 2;
			
		_hovering_subtool = hovering_subtool;
		 hovering_subtool = undefined;
		
		resizable = _hovering_subtool == undefined;
		
		var _pressing = [];
		var _spFrm = THEME_VALUE.panel_separation_type == "frame";
		
		var __tool_show_key = key_mod_press(ALT);
		
		for( var i = 0, n = array_length(tools); i < n; i++ ) {
			var tol = tools[i];
			
			if(tol == -1) {
        		ty += ui(2);
				draw_set_color(COLORS.panel_separator);
				if(_spFrm) draw_line_width( ui(4), ty, w - ui(4), ty, 2);
        		else       draw_line(       -1,    ty, w - 1,     ty);
        		ty += ui(2);
				continue;
			}
			
			var ttx = tx;
			var tty = ty;
			var isa = is_array(tol);
			
			if(isa) {
				var _indx = 0;
				
				for( var j = 0, m = array_length(tol); j < m; j++ ) {
					if(tol[j].hotkey && tol[j].hotkey.isPressing())
						array_push(_pressing, tol[j]);
					
					if(canvas.tool_current == tol[j])
						_indx = j;
				}
				
				tol = tol[_indx];
				
			} else {
				if(tol.hotkey && tol.hotkey.isPressing())
					array_push(_pressing, tol);
			}
			
			var sel = canvas.tool_current == tol;
			if(sel) draw_sprite_stretched_ext(THEME.button_hide, 3, ttx+p, tty+p, ttw-p2, tth-p2, COLORS._main_accent);
			
			var hv = pHOVER && point_in_rectangle(mx, my, ttx, tty, ttx + ttw, tty + tth);
			if(hv) {
				hovering_subtool = i;
				setTOOLTIP(tol.hotkey? new tooltipHotkey(tol.tooltip).setHotkey(tol.hotkey) : tol.tooltip);
				
				draw_sprite_stretched_add(THEME.button_hide, 1, ttx+p, tty+p, ttw-p2, tth-p2);
				
				if(!isa) {
					if(mouse_lclick(pFOCUS))
						draw_sprite_stretched_add(THEME.button_hide, 3, ttx+p, tty+p, ttw-p2, tth-p2);
					
					if(mouse_lpress(pFOCUS))
						canvas.setTool(sel? undefined : tol)
				}
			}
			
			var icn = tol.icon;
			draw_sprite_colored(icn, 0, ttx + ttw/2, tty + tth/2, 1, 0, COLORS._main_accent, sel);
			
            if(tol.hotkey && __tool_show_key) {
            	var _hkstr = tol.hotkey.getKeyName();
            	
            	draw_set_text(f_p4, fa_right, fa_bottom, COLORS._main_text);
            	var hkw = string_width(_hkstr)  + ui(4);
            	var hkh = string_height(_hkstr) + ui(0);
            	
            	var _hkx0 = ttx + ttw - hkw;
            	var _hky0 = tty + tth - hkh;
            	
            	draw_sprite_stretched_ext(THEME.ui_panel, 0, _hkx0, _hky0, hkw, hkh, COLORS.panel_bg_clear_inner);
            	draw_text_add(_hkx0 + hkw - ui(2), _hky0 + hkh - ui(0), _hkstr);
            }
            
			ty += th;
		}
		
		if(!array_empty(_pressing)) {
			var _actInd = -1;
			
			for( var i = 0, n = array_length(_pressing); i < n; i++ ) {
				var _ptol = _pressing[i];
				if(canvas.tool_current == _ptol)
					_actInd = i;
			}
			
			_actInd++;
			canvas.setTool(_actInd < n? _pressing[_actInd] : undefined);
		}
	}
	
	static drawGUI = function() {
		var pd = ui(2);
		var tw = w - pd * 2;
		var th = tool_h;
		
		var tx = x + pd;
		var ty = y + pd;
		
		var ttw = tw;
		var tth = th - 1;
		
		var p  = ui(2);
		var p2 = p * 2;
			
		var msx = x + mx;
		var msy = y + my;
		
		var __tool_show_key = key_mod_press(ALT);
		
		for( var i = 0, n = array_length(tools); i < n; i++ ) {
			var tolg = tools[i];
			
			var ttx = tx;
			var tty = ty;
			
			if(!is_array(tolg)) {
				ty += th;
				continue;
			}
			
			if(_hovering_subtool == i) {
				var _len = array_length(tolg);
				draw_sprite_stretched_ext(THEME.ui_panel_bg, 3, ttx, tty, ttw * _len, tth);
				
				var hv = point_in_rectangle(msx, msy, ttx, tty, ttx + ttw * _len, tty + tth);
				if(hv) hovering_subtool = i;
				
				for( var j = 0; j < _len; j++ ) {
					var tol = tolg[j];
							
					var sel = canvas.tool_current == tol;
					if(sel) draw_sprite_stretched_ext(THEME.button_hide, 3, ttx+p, tty+p, ttw-p2, tth-p2, COLORS._main_accent);
					
					var hv = pHOVER && point_in_rectangle(msx, msy, ttx, tty, ttx + ttw, tty + tth);
					if(hv) {
						setTOOLTIP(tol.hotkey? new tooltipHotkey(tol.tooltip).setHotkey(tol.hotkey) : tol.tooltip);
						draw_sprite_stretched_add(THEME.button_hide, 1, ttx+p, tty+p, ttw-p2, tth-p2);
						
						if(mouse_lclick(pFOCUS))
							draw_sprite_stretched_add(THEME.button_hide, 3, ttx+p, tty+p, ttw-p2, tth-p2);
						
						if(mouse_lpress(pFOCUS))
							canvas.setTool(sel? undefined : tol);
					}
					
					var icn = tol.icon;
					draw_sprite_colored(icn, 0, ttx + ttw/2, tty + tth/2, 1, 0, COLORS._main_accent, sel);
			
		            if(tol.hotkey && __tool_show_key) {
		            	var _hkstr = tol.hotkey.getKeyName();
		            	
		            	draw_set_text(f_p4, fa_right, fa_bottom, COLORS._main_text);
		            	var hkw = string_width(_hkstr)  + ui(4);
		            	var hkh = string_height(_hkstr) + ui(0);
		            	
		            	var _hkx0 = ttx + ttw - hkw;
		            	var _hky0 = tty + tth - hkh;
		            	
		            	draw_sprite_stretched_ext(THEME.ui_panel, 0, _hkx0, _hky0, hkw, hkh, COLORS.panel_bg_clear_inner);
		            	draw_text_add(_hkx0 + hkw - ui(2), _hky0 + hkh - ui(0), _hkstr);
		            }
	            
					ttx += tw;
				}
				
			}
			
			ty += th;
		}
	}
}