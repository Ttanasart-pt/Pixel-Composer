enum PB_AXIS_ANCHOR {
	center  = 0b00,
	minimum = 0b10,
	maximum = 0b01,
	bounded = 0b11,
}

enum PB_DIM_BOUND {
	unbounded, 
}

function __pbBox() constructor {
	
	base_bbox = [ 0, 0, 32, 32 ];
	fixed_box = 0;
	
	anchor_x_type = PB_AXIS_ANCHOR.minimum;
	anchor_y_type = PB_AXIS_ANCHOR.minimum;
	
	anchor_l = 0; anchor_l_fract = false;
	anchor_t = 0; anchor_t_fract = false;
	
	anchor_r = 0; anchor_r_fract = false;
	anchor_b = 0; anchor_b_fract = false;
	
	anchor_w = 1; anchor_w_fract =  true;
	anchor_h = 1; anchor_h_fract =  true;
	
	anchor_w_type = PB_DIM_BOUND.unbounded;
	anchor_h_type = PB_DIM_BOUND.unbounded;
	
	anchor_w_min = 0; anchor_w_max = 0;
	anchor_h_min = 0; anchor_h_max = 0;
	
	static set_w = function(v) /*=>*/ { anchor_w = anchor_w_fract? v / (base_bbox[2] - base_bbox[0]) : v; }
	static set_h = function(v) /*=>*/ { anchor_h = anchor_h_fract? v / (base_bbox[3] - base_bbox[1]) : v; }
	
	static set_l = function(v) /*=>*/ { v -= base_bbox[0]; anchor_l = anchor_l_fract? v / (base_bbox[2] - base_bbox[0]) : v; }
	static set_t = function(v) /*=>*/ { v -= base_bbox[1]; anchor_t = anchor_t_fract? v / (base_bbox[3] - base_bbox[1]) : v; }
	
	static set_r = function(v) /*=>*/ { anchor_r = anchor_r_fract? v / (base_bbox[2] - base_bbox[0]) : v; }
	static set_b = function(v) /*=>*/ { anchor_b = anchor_b_fract? v / (base_bbox[3] - base_bbox[1]) : v; }
	
	////- Draw
	
	drag_anchor    = noone;
	drag_anchor_sv = [ 0, 0, 0, 0 ];
	drag_anchor_mx = 0;
	drag_anchor_my = 0;
	
	static drawOverlayBBOX = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _node) {
		var _bbox = getBBOX();
		
		var _x0 = _x + _bbox[0] * _s;
		var _y0 = _y + _bbox[1] * _s;
		var _x1 = _x + _bbox[2] * _s;
		var _y1 = _y + _bbox[3] * _s;
		
		draw_rectangle(_x0, _y0, _x1, _y1, true);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx = 0, _sny = 0, _node = undefined) {
		if(fixed_box) return;
		var _bbox = getBBOX();
		var _hov  = false;
		
		var _x0 = _x + _bbox[0] * _s;
		var _y0 = _y + _bbox[1] * _s;
		var _x1 = _x + _bbox[2] * _s;
		var _y1 = _y + _bbox[3] * _s;
		
		var _h0 = 0, _h1 = 0, _h2 = 0, _h3 = 0, _h9 = 0;
	
		draw_set_color(COLORS._main_accent);
		draw_rectangle(_x0, _y0, _x1, _y1, true);
		
		if(drag_anchor == noone) {
			     if(hover && point_in_circle(_mx, _my, _x0, _y0, 12)) { _h0 = 1; if(mouse_lpress(active)) drag_anchor = 0; } 
			else if(hover && point_in_circle(_mx, _my, _x1, _y0, 12)) { _h1 = 1; if(mouse_lpress(active)) drag_anchor = 1; } 
			else if(hover && point_in_circle(_mx, _my, _x0, _y1, 12)) { _h2 = 1; if(mouse_lpress(active)) drag_anchor = 2; } 
			else if(hover && point_in_circle(_mx, _my, _x1, _y1, 12)) { _h3 = 1; if(mouse_lpress(active)) drag_anchor = 3; } 
			else if(hover && point_in_rectangle(_mx, _my, _x0, _y0, _x1, _y1)) { _h9 = 1; if(mouse_lpress(active)) drag_anchor = 9; } 
			
			draw_anchor(_h0, _x0, _y0, ui(8), 2);
			draw_anchor(_h1, _x1, _y0, ui(8), 2);
			draw_anchor(_h2, _x0, _y1, ui(8), 2);
			draw_anchor(_h3, _x1, _y1, ui(8), 2);
			draw_anchor_cross(_h9, (_x0 + _x1) / 2, (_y0 + _y1) / 2, ui(8), 1);
			
			if(drag_anchor != noone) {
				_hov = true;
				drag_anchor_sv = variable_clone(_bbox);
				drag_anchor_mx = _mx;
				drag_anchor_my = _my;
				
				if(_node) _node.w_hovering = true;
			}
			
			return _hov || _h0 || _h1 || _h2 || _h3 || _h9;
		}
		
		var _xx = base_bbox[0]; 
		var _yy = base_bbox[1];
		var _ww = base_bbox[2] - base_bbox[0];
		var _hh = base_bbox[3] - base_bbox[1];
		
		var _mdx = (_mx - drag_anchor_mx) / _s;
		var _mdy = (_my - drag_anchor_my) / _s;
		
		switch(drag_anchor) {
			case 0 : draw_anchor(1, _x0, _y0, ui(8), 2); break;
			case 1 : draw_anchor(1, _x1, _y0, ui(8), 2); break;
			case 2 : draw_anchor(1, _x0, _y1, ui(8), 2); break;
			case 3 : draw_anchor(1, _x1, _y1, ui(8), 2); break;
			case 9 : draw_anchor_cross(_h9, (_x0 + _x1) / 2, (_y0 + _y1) / 2, ui(8), 1);
		}
		
		if(drag_anchor == 9) {
			var _bl = round(drag_anchor_sv[0] + _mdx);
			var _br = round(drag_anchor_sv[2] + _mdx);
			var _bt = round(drag_anchor_sv[1] + _mdy);
			var _bb = round(drag_anchor_sv[3] + _mdy);
			
			setBBOX([ _bl, _bt, _br, _bb ]);
			
		} else {
			if(drag_anchor == 0 || drag_anchor == 2) {
				var _bx = round(drag_anchor_sv[0] + _mdx);
				var _bw = _bbox[2] - _bx;
				
				switch(anchor_x_type) {
					case PB_AXIS_ANCHOR.minimum : set_l(_bx); set_w(_bw); break;
					case PB_AXIS_ANCHOR.maximum : set_w(_bw);             break;
					case PB_AXIS_ANCHOR.bounded : set_l(_bx);             break;
				}
			}
			
			if(drag_anchor == 0 || drag_anchor == 1) {	
				var _by = round(drag_anchor_sv[1] + _mdy);
				var _bh = _bbox[3] - _by;
				
				switch(anchor_y_type) {
					case PB_AXIS_ANCHOR.minimum : set_t(_by); set_h(_bh); break;
					case PB_AXIS_ANCHOR.maximum : set_h(_bh);             break;
					case PB_AXIS_ANCHOR.bounded : set_t(_by);             break;
				}
			}
			
			if(drag_anchor == 3 || drag_anchor == 1) {
				var _bx = round(drag_anchor_sv[2] + _mdx);
				var _bw = _bx - _bbox[0];
				
				switch(anchor_x_type) {
					case PB_AXIS_ANCHOR.minimum : set_w(_bw);                   break;
					case PB_AXIS_ANCHOR.maximum : set_r(_ww - _bx); set_w(_bw); break;
					case PB_AXIS_ANCHOR.bounded : set_r(_ww - _bx);             break;
				}
			}
			
			if(drag_anchor == 3 || drag_anchor == 2) {
				var _by = round(drag_anchor_sv[3] + _mdy);
				var _bh = _by - _bbox[1];
				
				switch(anchor_y_type) {
					case PB_AXIS_ANCHOR.minimum : set_h(_bh);                   break;
					case PB_AXIS_ANCHOR.maximum : set_b(_hh - _by); set_h(_bh); break;
					case PB_AXIS_ANCHOR.bounded : set_b(_hh - _by);             break;
				}
			}
		}
		
		if(_node) _node.w_hovering = true;
		if(_node) _node.triggerRender();
		if(mouse_release(mb_left)) drag_anchor = noone;
		
		return true;
	}
	
	////- BBOX
	
	static setBBOX = function(_bbox) {
		var _x0 = base_bbox[0]; 
		var _y0 = base_bbox[1];
		var _x1 = base_bbox[2];
		var _y1 = base_bbox[3];
		
		var _bl =       _bbox[0];
		var _br = _x1 - _bbox[2];
		var _bt =       _bbox[1];
		var _bb = _y1 - _bbox[3];
		var _bw = _bbox[2] - _bbox[0];
		var _bh = _bbox[3] - _bbox[1];
		
		switch(anchor_x_type) {
			case PB_AXIS_ANCHOR.minimum : set_l(_bl); set_w(_bw); break;
			case PB_AXIS_ANCHOR.maximum : set_r(_br); set_w(_bw); break;
			case PB_AXIS_ANCHOR.bounded : set_l(_bl); set_r(_br); break;
			case PB_AXIS_ANCHOR.center  : set_w(_bw);             break;
		}
		
		switch(anchor_y_type) {
			case PB_AXIS_ANCHOR.minimum : set_t(_bt); set_h(_bh); break;
			case PB_AXIS_ANCHOR.maximum : set_b(_bb); set_h(_bh); break;
			case PB_AXIS_ANCHOR.bounded : set_t(_bt); set_b(_bb); break;
			case PB_AXIS_ANCHOR.center  : set_h(_bh);             break;
		}
		
		return self;
	}
	
	static getBBOX = function(_bbox = undefined) {
		_bbox = _bbox ?? [0,0,1,1];
		
		if(fixed_box != 0) {
			_bbox[0] = fixed_box[0];
			_bbox[1] = fixed_box[1];
			_bbox[2] = fixed_box[2];
			_bbox[3] = fixed_box[3];
			return _bbox;
		}
		
		var _xx = base_bbox[0]; 
		var _yy = base_bbox[1];
		var _ww = base_bbox[2] - base_bbox[0];
		var _hh = base_bbox[3] - base_bbox[1];
		
		var _w = anchor_w_fract? _ww * anchor_w : anchor_w;
		var _h = anchor_h_fract? _hh * anchor_h : anchor_h;
		
		var _l = anchor_l_fract? _ww * anchor_l : anchor_l;
		var _t = anchor_t_fract? _hh * anchor_t : anchor_t;
		
		var _r = anchor_r_fract? _ww * anchor_r : anchor_r;
		var _b = anchor_b_fract? _hh * anchor_b : anchor_b;
		
		var _x0 = _xx,       _y0 = _yy;
		var _x1 = _xx + _ww, _y1 = _yy + _hh;
		
		_x0 = _xx + _l; 
		_x1 = _xx + _ww - _r;
		_y0 = _yy + _t;
		_y1 = _yy + _hh - _b;
		
		var _cx = (_x0 + _x1) / 2;
		var _cy = (_y0 + _y1) / 2;
		
		////////////////////////////////////////////
		
		switch(anchor_x_type) {
			case PB_AXIS_ANCHOR.minimum : _x1 = _x0 + _w; break;
			case PB_AXIS_ANCHOR.maximum : _x0 = _x1 - _w; break;
			case PB_AXIS_ANCHOR.center :  
				_w  = min(_w, _x1 - _x0);
				_x0 = _cx - _w / 2;
				_x1 = _cx + _w / 2; 
				break;
		}
		
		switch(anchor_y_type) {
			case PB_AXIS_ANCHOR.minimum : _y1 = _y0 + _h; break;
			case PB_AXIS_ANCHOR.maximum : _y0 = _y1 - _h; break;
			case PB_AXIS_ANCHOR.center :  
				_h  = min(_h, _y1 - _y0);
				_y0 = _cy - _h / 2;
				_y1 = _cy + _h / 2; 
				break;
		}
		
		_bbox[0] = floor(_x0);
		_bbox[1] = floor(_y0);
		_bbox[2] = ceil(_x1);
		_bbox[3] = ceil(_y1);
		
		return _bbox;
	}
	
	////- Lerp
	
	static lerpTo = function(target, amount) {
		var nb = clone();
		
		nb.anchor_l = lerp(nb.anchor_l, target.anchor_l, amount);
		nb.anchor_t = lerp(nb.anchor_t, target.anchor_t, amount);
		nb.anchor_r = lerp(nb.anchor_r, target.anchor_r, amount);
		nb.anchor_b = lerp(nb.anchor_b, target.anchor_b, amount);
		nb.anchor_w = lerp(nb.anchor_w, target.anchor_w, amount);
		nb.anchor_h = lerp(nb.anchor_h, target.anchor_h, amount);
		
		return nb;
	}
	
	////- Actions
	
	static serialize   = function(   ) { return variable_clone(self); }
	static deserialize = function(map) { struct_override(self, map); return self; }
	
	static clone = function() /*=>*/ {return variable_clone(self)};
	
}