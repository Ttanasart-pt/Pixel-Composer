function pbBoxBox(_junction = undefined) : widget() constructor {
	always_break_line = true;
	curr_pbbox = new __pbBox();
	node       = _junction? _junction.node : undefined;
	
	locked = false;
	linked = false;
	
	#region textboxes
		setBBOX    = function(b) /*=>*/ { curr_pbbox.setBBOX(b); trigRender(); }
		trigRender = function( ) /*=>*/ { if(node) node.triggerRender(); }
		
		tb_anchor_w = textBox_Number(function(v) /*=>*/ { curr_pbbox.anchor_w = v; trigRender(); }).setLabel("w");
		tb_anchor_h = textBox_Number(function(v) /*=>*/ { curr_pbbox.anchor_h = v; trigRender(); }).setLabel("h");
		tb_anchor_l = textBox_Number(function(v) /*=>*/ { if(linked) setLinked(v); else { curr_pbbox.anchor_l = v; trigRender(); } });
		tb_anchor_t = textBox_Number(function(v) /*=>*/ { if(linked) setLinked(v); else { curr_pbbox.anchor_t = v; trigRender(); } });
		tb_anchor_r = textBox_Number(function(v) /*=>*/ { if(linked) setLinked(v); else { curr_pbbox.anchor_r = v; trigRender(); } });
		tb_anchor_b = textBox_Number(function(v) /*=>*/ { if(linked) setLinked(v); else { curr_pbbox.anchor_b = v; trigRender(); } });
		
		//// L
		tb_anchor_l.setFrontButton(button(function() /*=>*/ {
			var b = curr_pbbox.getBBOX();
            curr_pbbox.anchor_x_type ^= 0b10;
            setBBOX(b);
            
		}).setIcon(THEME.lock_12, function() /*=>*/ {return !bool(curr_pbbox.anchor_x_type & 0b10)},
		                          function() /*=>*/  {return bool(curr_pbbox.anchor_x_type & 0b10)? COLORS._main_accent : c_white}).iconPad());
		
		tb_anchor_l.setSideButton(button(function() /*=>*/ {
			var b = curr_pbbox.getBBOX(); 
	        curr_pbbox.anchor_l_fract = !curr_pbbox.anchor_l_fract;
	        setBBOX(b);
	        
		}).setIcon(THEME.unit_ref, function() /*=>*/ {return curr_pbbox.anchor_l_fract}).iconPad());
		
		//// T
		tb_anchor_t.setFrontButton(button(function() /*=>*/ {
			var b = curr_pbbox.getBBOX();
            curr_pbbox.anchor_y_type ^= 0b10;
            setBBOX(b);
            
		}).setIcon(THEME.lock_12, function() /*=>*/ {return !bool(curr_pbbox.anchor_y_type & 0b10)},
		                          function() /*=>*/  {return bool(curr_pbbox.anchor_y_type & 0b10)? COLORS._main_accent : c_white}).iconPad());
		
		tb_anchor_t.setSideButton(button(function() /*=>*/ {
			var b = curr_pbbox.getBBOX();
	        curr_pbbox.anchor_t_fract = !curr_pbbox.anchor_t_fract;
	        setBBOX(b);
	        
		}).setIcon(THEME.unit_ref, function() /*=>*/ {return curr_pbbox.anchor_t_fract}).iconPad());
		
		//// R
		tb_anchor_r.setFrontButton(button(function() /*=>*/ {
			var b = curr_pbbox.getBBOX();
            curr_pbbox.anchor_x_type ^= 0b01;
            setBBOX(b);
            
		}).setIcon(THEME.lock_12, function() /*=>*/ {return !bool(curr_pbbox.anchor_x_type & 0b01)},
		                          function() /*=>*/  {return bool(curr_pbbox.anchor_x_type & 0b01)? COLORS._main_accent : c_white}).iconPad());
		
		tb_anchor_r.setSideButton(button(function() /*=>*/ {
			var b = curr_pbbox.getBBOX();
	        curr_pbbox.anchor_r_fract = !curr_pbbox.anchor_r_fract;
	        setBBOX(b);
	        
		}).setIcon(THEME.unit_ref, function() /*=>*/ {return curr_pbbox.anchor_r_fract}).iconPad());
		
		//// B
		tb_anchor_b.setFrontButton(button(function() /*=>*/ {
			var b = curr_pbbox.getBBOX();
            curr_pbbox.anchor_y_type ^= 0b01;
            setBBOX(b);
            
		}).setIcon(THEME.lock_12, function() /*=>*/ {return !bool(curr_pbbox.anchor_y_type & 0b01)},
		                          function() /*=>*/  {return bool(curr_pbbox.anchor_y_type & 0b01)? COLORS._main_accent : c_white}).iconPad());
		
		tb_anchor_b.setSideButton(button(function() /*=>*/ {
			var b = curr_pbbox.getBBOX();
	        curr_pbbox.anchor_b_fract = !curr_pbbox.anchor_b_fract;
	        setBBOX(b);
	        
		}).setIcon(THEME.unit_ref, function() /*=>*/ {return curr_pbbox.anchor_b_fract}).iconPad());
		
		//// DIM
		tb_anchor_w.setSideButton(button(function() /*=>*/ {
			var b = curr_pbbox.getBBOX();
	        curr_pbbox.anchor_w_fract = !curr_pbbox.anchor_w_fract;
	        setBBOX(b);
	        
		}).setIcon(THEME.unit_ref, function() /*=>*/ {return curr_pbbox.anchor_w_fract}).iconPad());
		
		tb_anchor_h.setSideButton(button(function() /*=>*/ {
			var b = curr_pbbox.getBBOX();
	        curr_pbbox.anchor_h_fract = !curr_pbbox.anchor_h_fract;
	        setBBOX(b);
	        
		}).setIcon(THEME.unit_ref, function() /*=>*/ {return curr_pbbox.anchor_h_fract}).iconPad());
		
		tbs = [ tb_anchor_w, tb_anchor_h, tb_anchor_l, tb_anchor_t, tb_anchor_r, tb_anchor_b ];
		array_foreach(tbs, function(t) /*=>*/ { t.setFont(f_p3).setAlign(fa_center).setAutoUpdate(); });
		
		tb_draw = [];
	#endregion
		
	setLinked = function(v) /*=>*/ {
		curr_pbbox.anchor_l = v;
		curr_pbbox.anchor_t = v;
		curr_pbbox.anchor_r = v;
		curr_pbbox.anchor_b = v; 
		trigRender();
	}
		
	static trigger = function() { }
	
	static register = function(parent = noone) {
		for( var i = 0; i < array_length(tb_draw); i++ ) 
			tb_draw[i].register(parent);
	}
	
	static onSetParam = function(params) {
		for( var i = 0, n = array_length(tbs); i < n; i++ ) 
			tbs[i].setParam(params);
	}
	
	static fetchHeight = function(params) { return ui(240); }
	static drawParam   = function(params) {
		setParam(params);
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _pbbox, _m) {
		tb_draw = [];
		
		x = _x;
		y = _y + ui(8);
		w = _w;
		h = ui(148);
		
		if(!is(_pbbox, __pbBox)) return 0;
		curr_pbbox = _pbbox;
        
        #region bg
            var _xc = x + w / 2;
            var _yc = y + h / 2;
            var _x0 = _xc - w / 2;
            var _x1 = _xc + w / 2;
            var _y0 = _yc - h / 2;
            var _y1 = _yc + h / 2;
            
            draw_sprite_stretched_ext(THEME.ui_panel, 1, _x0, _y0, w, h, COLORS._main_icon, .75);
            
            var _bs  = ui(20);
            var _iw  = ui(96);
            var _ih  = ui(68);
            var _ix0 = _xc - _iw / 2;
            var _ix1 = _xc + _iw / 2;
            var _iy0 = _yc - _ih / 2;
            var _iy1 = _yc + _ih / 2;
            
            var _tbw = ui(96);
            var _tdw = _iw - ui(16);
            var _tbh = line_get_height(font, 4);
            
            draw_sprite_stretched_ext(THEME.ui_panel, 1, _ix0, _iy0, _iw, _ih, COLORS._main_icon_light, .75);
        #endregion
        
        #region link
        	var bs = ui(24);
			var bx = _x0 + ui(8);
			var by = _y0 + ui(8);
			var bb = linked? COLORS._main_accent : COLORS._main_icon;
			
			var b  = buttonInstant_Pad(THEME.button_hide_fill, bx, by, bs, bs, _m, hover, active, "", THEME.value_link, linked, bb, 1, ui(6));
			if(b == 2) linked = !linked;
        #endregion
        
        #region width
            draw_set_color(_pbbox.anchor_x_type != PB_AXIS_ANCHOR.bounded? COLORS._main_icon_light : CDEF.main_dark);
            draw_line(_ix0, _iy0, _ix1, _iy0);
            
            tb_anchor_w.setInteract(_pbbox.anchor_x_type != PB_AXIS_ANCHOR.bounded);    
            tb_anchor_w.setFocusHover(active, hover);
            tb_anchor_w.draw(_xc - _tdw/2, _yc - (_tbh / 2 + ui(2)) - _tbh/2, _tdw, _tbh, _pbbox.anchor_w, _m);
            array_push(tb_draw, tb_anchor_w);
        #endregion
        
        #region height
            draw_set_color(_pbbox.anchor_y_type != PB_AXIS_ANCHOR.bounded? COLORS._main_icon_light : CDEF.main_dark);
            draw_line(_ix0, _iy0, _ix0, _iy1);
            
            tb_anchor_h.setInteract(_pbbox.anchor_y_type != PB_AXIS_ANCHOR.bounded);
            tb_anchor_h.setFocusHover(active, hover);
            tb_anchor_h.draw(_xc - _tdw/2, _yc + (_tbh / 2 + ui(2)) - _tbh/2, _tdw, _tbh, _pbbox.anchor_h, _m);
            array_push(tb_draw, tb_anchor_h);
        #endregion
        
        #region top
            draw_set_color(_pbbox.anchor_y_type != PB_AXIS_ANCHOR.maximum? COLORS._main_icon_light : CDEF.main_dark);
            draw_line(_xc, _y0, _xc, _iy0);
            
            tb_anchor_t.setInteract(_pbbox.anchor_y_type != PB_AXIS_ANCHOR.maximum);
            tb_anchor_t.setFocusHover(active, hover);
            tb_anchor_t.draw(_xc - _tbw/2, (_y0 + _iy0) / 2 - _tbh/2, _tbw, _tbh, _pbbox.anchor_t, _m);
            array_push(tb_draw, tb_anchor_t);
        #endregion
        
        #region left
            draw_set_color(_pbbox.anchor_x_type != PB_AXIS_ANCHOR.maximum? COLORS._main_icon_light : CDEF.main_dark);
            draw_line(_x0, _yc, _ix0, _yc);
            
            tb_anchor_l.setInteract(_pbbox.anchor_x_type != PB_AXIS_ANCHOR.maximum);
            tb_anchor_l.setFocusHover(active, hover);
            tb_anchor_l.draw((_x0 + _ix0) / 2 - _tbw/2, _yc - _tbh/2, _tbw, _tbh, _pbbox.anchor_l, _m);
            array_push(tb_draw, tb_anchor_l);
        #endregion
        
        #region right
            draw_set_color(_pbbox.anchor_x_type != PB_AXIS_ANCHOR.minimum? COLORS._main_icon_light : CDEF.main_dark);
            draw_line(_ix1, _yc, _x1, _yc);
            
        	tb_anchor_r.setInteract(_pbbox.anchor_x_type != PB_AXIS_ANCHOR.minimum);
            tb_anchor_r.setFocusHover(active, hover);
            tb_anchor_r.draw((_x1 + _ix1) / 2 - _tbw/2, _yc - _tbh/2, _tbw, _tbh, _pbbox.anchor_r, _m);
            array_push(tb_draw, tb_anchor_r);
        #endregion
        
        #region bottom
            draw_set_color(_pbbox.anchor_y_type != PB_AXIS_ANCHOR.minimum? COLORS._main_icon_light : CDEF.main_dark);
            draw_line(_xc, _iy1, _xc, _y1);
            
        	tb_anchor_b.setInteract(_pbbox.anchor_y_type != PB_AXIS_ANCHOR.minimum);
            tb_anchor_b.setFocusHover(active, hover);
            tb_anchor_b.draw(_xc - _tbw/2, (_y1 + _iy1) / 2 - _tbh/2, _tbw, _tbh, _pbbox.anchor_b, _m);
            array_push(tb_draw, tb_anchor_b);
        #endregion
        
		return h + ui(16);
	}
	
	static clone = function() { return new meshBox(); }
}
