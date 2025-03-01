function pbBoxBox(_junction) : widget() constructor {
	junction = _junction;
	node     = junction.node;
	
	curr_pbbox = noone;
	locked     = false;
	var t = TEXTBOX_INPUT.number;
	
	tb_anchor_w = new textBox(t, function(v) /*=>*/ { curr_pbbox.anchor_w = v; node.triggerRender(); }).setLabel("w").setFont(f_p3).setAlign(fa_center).setAutoUpdate();
	tb_anchor_h = new textBox(t, function(v) /*=>*/ { curr_pbbox.anchor_h = v; node.triggerRender(); }).setLabel("h").setFont(f_p3).setAlign(fa_center).setAutoUpdate();
	tb_anchor_l = new textBox(t, function(v) /*=>*/ { curr_pbbox.anchor_l = v; node.triggerRender(); }).setFont(f_p3).setAlign(fa_center).setAutoUpdate();
	tb_anchor_t = new textBox(t, function(v) /*=>*/ { curr_pbbox.anchor_t = v; node.triggerRender(); }).setFont(f_p3).setAlign(fa_center).setAutoUpdate();
	tb_anchor_r = new textBox(t, function(v) /*=>*/ { curr_pbbox.anchor_r = v; node.triggerRender(); }).setFont(f_p3).setAlign(fa_center).setAutoUpdate();
	tb_anchor_b = new textBox(t, function(v) /*=>*/ { curr_pbbox.anchor_b = v; node.triggerRender(); }).setFont(f_p3).setAlign(fa_center).setAutoUpdate();
	
	tb_draw = [];
	
	static trigger = function() { }
	
	static register = function(parent = noone) {
		for( var i = 0; i < array_length(tb_draw); i++ ) 
			tb_draw[i].register(parent);
	}
	
	static drawParam = function(params) {
		setParam(params);
		
		tb_anchor_w.setParam(params);
        tb_anchor_h.setParam(params);
        tb_anchor_l.setParam(params);
        tb_anchor_t.setParam(params);
        tb_anchor_r.setParam(params);
        tb_anchor_b.setParam(params);
		
		return draw(params.x, params.y, params.w, params.data, params.m);
	}
	
	static draw = function(_x, _y, _w, _pbbox, _m) {
		tb_draw = [];
		
		x = _x;
		y = _y + ui(8);
		w = _w;
		h = ui(240);
		
		if(!is(_pbbox, __pbBox)) return 0;
		curr_pbbox = _pbbox;
        
        #region bg
            var _xc = x + w / 2;
            var _yc = y + h / 2;
            var _x0 = _xc - w / 2;
            var _x1 = _xc + w / 2;
            var _y0 = _yc - h / 2;
            var _y1 = _yc + h / 2;
            
            draw_set_color(COLORS._main_icon);
            draw_rectangle_dashed(_x0, _y0, _x1, _y1, 2, ui(8));
            
            var _iw  = ui(128);
            var _ih  = ui(96);
            var _ix0 = _xc - _iw / 2;
            var _ix1 = _xc + _iw / 2;
            var _iy0 = _yc - _ih / 2;
            var _iy1 = _yc + _ih / 2;
            
            var _tbcx = _xc - ui(8);
            var _tbw  = ui(64);
            var _tbh  = line_get_height(f_p3, 8);
            
            var _8  = ui(8);
            var _bs = ui(20);
            
            draw_set_color(COLORS._main_icon_light);
            draw_rectangle_border(_ix0, _iy0, _ix1, _iy1, 2);
        #endregion
        
        #region width
            draw_set_color(_pbbox.anchor_x_type != PB_AXIS_ANCHOR.bounded? COLORS._main_icon_light : CDEF.main_dark);
            draw_line_cap_T(_ix0 + _8, _iy0 + _8, _ix1 - _8, _iy0 + _8, ui(4));
                
            if(_pbbox.anchor_x_type != PB_AXIS_ANCHOR.bounded) {
                tb_anchor_w.setFocusHover(active, hover);
                tb_anchor_w.draw(_tbcx, _yc - (_tbh / 2 + ui(4)), _tbw, _tbh, _pbbox.anchor_w, _m, fa_center, fa_center);
                array_push(tb_draw, tb_anchor_w);
                
                var _bx = _tbcx + _tbw / 2 + ui(8);
                var _by = _yc - (_tbh / 2 + ui(4));
                if(buttonInstant(noone, _bx, _by - _bs / 2, _bs, _bs, _m, hover, active, "", THEME.unit_ref, _pbbox.anchor_w_fract, c_white, .8) == 2) {
                    var _bbox = _pbbox.getBBOX();
                        _pbbox.anchor_w_fract = !_pbbox.anchor_w_fract;
                    _pbbox.setBBOX(_bbox);
                    
                    node.triggerRender();
                }
                    
            }
        #endregion
        
        #region height
            draw_set_color(_pbbox.anchor_y_type != PB_AXIS_ANCHOR.bounded? COLORS._main_icon_light : CDEF.main_dark);
            draw_line_cap_T(_ix0 + _8, _iy0 + _8, _ix0 + _8, _iy1 - _8, ui(4));
            
            if(_pbbox.anchor_y_type != PB_AXIS_ANCHOR.bounded) {
                tb_anchor_h.setFocusHover(active, hover);
                tb_anchor_h.draw(_tbcx, _yc + (_tbh / 2 + ui(4)), _tbw, _tbh, _pbbox.anchor_h, _m, fa_center, fa_center);
                array_push(tb_draw, tb_anchor_h);
                
                var _bx = _tbcx + _tbw / 2 + ui(8);
                var _by = _yc + (_tbh / 2 + ui(4));
                if(buttonInstant(noone, _bx, _by - _bs / 2, _bs, _bs, _m, hover, active, "", THEME.unit_ref, _pbbox.anchor_h_fract, c_white, .8) == 2) {
                    var _bbox = _pbbox.getBBOX();
                        _pbbox.anchor_h_fract = !_pbbox.anchor_h_fract;
                    _pbbox.setBBOX(_bbox);
                    
                    node.triggerRender();
                }
            }
        #endregion
        
        #region top
            draw_set_color(_pbbox.anchor_y_type != PB_AXIS_ANCHOR.maximum? COLORS._main_icon_light : CDEF.main_dark);
            draw_line_cap_T(_xc, _y0 + _8, _xc, _iy0 - _8, ui(4));
            
            if(_pbbox.anchor_y_type != PB_AXIS_ANCHOR.maximum) {
                tb_anchor_t.setFocusHover(active, hover);
                tb_anchor_t.draw(_xc, (_y0 + _iy0) / 2, _tbw, _tbh, _pbbox.anchor_t, _m, fa_center, fa_center);
                array_push(tb_draw, tb_anchor_t);
                
                ////////////////////////////////////////////////////////////////////////////////
                
                var _bx = _xc + _tbw / 2 + ui(8);
                var _by = (_y0 + _iy0) / 2;
                if(buttonInstant(noone, _bx, _by - _bs / 2, _bs, _bs, _m, hover, active, "", THEME.unit_ref, _pbbox.anchor_t_fract, c_white, .8) == 2) {
                    var _bbox = _pbbox.getBBOX();
                        _pbbox.anchor_t_fract = !_pbbox.anchor_t_fract;
                    _pbbox.setBBOX(_bbox);
                    
                    node.triggerRender();
                }
            }
                
            var _bx = _xc - _tbw / 2 - ui(8);
            var _by = (_y0 + _iy0) / 2;
            var _vv = bool(_pbbox.anchor_y_type & 0b10);
            if(buttonInstant(noone, _bx - _bs, _by - _bs / 2, _bs, _bs, _m, hover, active, "", THEME.lock_12, !_vv, _vv? COLORS._main_accent : c_white, .8) == 2) {
                var _bbox = _pbbox.getBBOX();
                    _pbbox.anchor_y_type ^= 0b10;
                _pbbox.setBBOX(_bbox);
                
                node.triggerRender();
            }
            
        #endregion
        
        #region left
            draw_set_color(_pbbox.anchor_x_type != PB_AXIS_ANCHOR.maximum? COLORS._main_icon_light : CDEF.main_dark);
            draw_line_cap_T(_x0 + _8, _yc, _ix0 - _8, _yc, ui(4));
            
            if(_pbbox.anchor_x_type != PB_AXIS_ANCHOR.maximum) {
                tb_anchor_l.setFocusHover(active, hover);
                tb_anchor_l.draw((_x0 + _ix0) / 2, _yc, _tbw, _tbh, _pbbox.anchor_l, _m, fa_center, fa_center);
                array_push(tb_draw, tb_anchor_l);
                
                ////////////////////////////////////////////////////////////////////////////////
                
                var _bx = (_x0 + _ix0) / 2;
                var _by = _yc + _tbh / 2 + ui(4);
                if(buttonInstant(noone, _bx - _bs / 2, _by, _bs, _bs, _m, hover, active, "", THEME.unit_ref, _pbbox.anchor_l_fract, c_white, .8) == 2) {
                    var _bbox = _pbbox.getBBOX();
                        _pbbox.anchor_l_fract = !_pbbox.anchor_l_fract;
                    _pbbox.setBBOX(_bbox);
                    
                    node.triggerRender();
                }
            }
            
            var _bx = (_x0 + _ix0) / 2;
            var _by = _yc - _tbh / 2 - ui(4);
            var _vv = bool(_pbbox.anchor_x_type & 0b10);
            if(buttonInstant(noone, _bx - _bs / 2, _by - _bs, _bs, _bs, _m, hover, active, "", THEME.lock_12, !_vv, _vv? COLORS._main_accent : c_white, .8) == 2) {
                var _bbox = _pbbox.getBBOX();
                    _pbbox.anchor_x_type ^= 0b10;
                _pbbox.setBBOX(_bbox);
                
                node.triggerRender();
            }
                
        #endregion
        
        #region right
            draw_set_color(_pbbox.anchor_x_type != PB_AXIS_ANCHOR.minimum? COLORS._main_icon_light : CDEF.main_dark);
            draw_line_cap_T(_ix1 + _8, _yc, _x1 - _8, _yc, ui(4));
            
            if(_pbbox.anchor_x_type != PB_AXIS_ANCHOR.minimum) {
                tb_anchor_r.setFocusHover(active, hover);
                tb_anchor_r.draw((_x1 + _ix1) / 2, _yc, _tbw, _tbh, _pbbox.anchor_r, _m, fa_center, fa_center);
                array_push(tb_draw, tb_anchor_r);
                
                ////////////////////////////////////////////////////////////////////////////////
                
                var _bx = (_x1 + _ix1) / 2;
                var _by = _yc + _tbh / 2 + ui(4);
                if(buttonInstant(noone, _bx - _bs / 2, _by, _bs, _bs, _m, hover, active, "", THEME.unit_ref, _pbbox.anchor_r_fract, c_white, .8) == 2) {
                    var _bbox = _pbbox.getBBOX();
                        _pbbox.anchor_r_fract = !_pbbox.anchor_r_fract;
                    _pbbox.setBBOX(_bbox);
                    
                    node.triggerRender();
                }
            }
                
            var _bx = (_x1 + _ix1) / 2;
            var _by = _yc - _tbh / 2 - ui(4);
            var _vv = bool(_pbbox.anchor_x_type & 0b01);
            if(buttonInstant(noone, _bx - _bs / 2, _by - _bs, _bs, _bs, _m, hover, active, "", THEME.lock_12, !_vv, _vv? COLORS._main_accent : c_white, .8) == 2) {
                var _bbox = _pbbox.getBBOX();
                    _pbbox.anchor_x_type ^= 0b01;
                _pbbox.setBBOX(_bbox);
                
                node.triggerRender();
            }
            
        #endregion
        
        #region bottom
            draw_set_color(_pbbox.anchor_y_type != PB_AXIS_ANCHOR.minimum? COLORS._main_icon_light : CDEF.main_dark);
            draw_line_cap_T(_xc, _iy1 + _8, _xc, _y1 - _8, ui(4));
            
            if(_pbbox.anchor_y_type != PB_AXIS_ANCHOR.minimum) {
                tb_anchor_b.setFocusHover(active, hover);
                tb_anchor_b.draw(_xc, (_y1 + _iy1) / 2, _tbw, _tbh, _pbbox.anchor_b, _m, fa_center, fa_center);
                array_push(tb_draw, tb_anchor_b);
                
                ////////////////////////////////////////////////////////////////////////////////
                
                var _bx = _xc + _tbw / 2 + ui(8);
                var _by = (_y1 + _iy1) / 2;
                if(buttonInstant(noone, _bx, _by - _bs / 2, _bs, _bs, _m, hover, active, "", THEME.unit_ref, _pbbox.anchor_b_fract, c_white, .8) == 2) {
                    var _bbox = _pbbox.getBBOX();
                        _pbbox.anchor_b_fract = !_pbbox.anchor_b_fract;
                    _pbbox.setBBOX(_bbox);
                    
                    node.triggerRender();
                }
            }
                
            var _bx = _xc - _tbw / 2 - ui(8);
            var _by = (_y1 + _iy1) / 2;
            var _vv = bool(_pbbox.anchor_y_type & 0b01);
            if(buttonInstant(noone, _bx - _bs, _by - _bs / 2, _bs, _bs, _m, hover, active, "", THEME.lock_12, !_vv, _vv? COLORS._main_accent : c_white, .8) == 2) {
                var _bbox = _pbbox.getBBOX();
                    _pbbox.anchor_y_type ^= 0b01;
                _pbbox.setBBOX(_bbox);
                
                node.triggerRender();
            }
                
        #endregion
        
		return h + ui(16);
	}
	
	static clone = function() { return new meshBox(); }
}
