#region enum
	enum PB_AXIS_ANCHOR {
		center  = 0b00,
		minimum = 0b10,
		maximum = 0b01,
		bounded = 0b11,
	}
	
	enum PB_DIM_BOUND {
		unbounded, 
	}
#endregion

function __pbBox() constructor {
	
	#region ---- bbox ----
		base_bbox = [ 0, 0, 32, 32 ];
		fixed_box = 0;
	#endregion
	
	#region ---- anchors ----
		_anchor_x_type = PB_AXIS_ANCHOR.minimum;
		_anchor_y_type = PB_AXIS_ANCHOR.minimum;
		
		anchor_x_type  = PB_AXIS_ANCHOR.minimum;
		anchor_y_type  = PB_AXIS_ANCHOR.minimum;
		
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
	#endregion
	
	////- Setters
	
	static set_w = function(v) /*=>*/ { anchor_w = anchor_w_fract? v / (base_bbox[2] - base_bbox[0]) : v; }
	static set_h = function(v) /*=>*/ { anchor_h = anchor_h_fract? v / (base_bbox[3] - base_bbox[1]) : v; }
	
	static set_l = function(v) /*=>*/ { v -= base_bbox[0]; anchor_l = anchor_l_fract? v / (base_bbox[2] - base_bbox[0]) : v; }
	static set_t = function(v) /*=>*/ { v -= base_bbox[1]; anchor_t = anchor_t_fract? v / (base_bbox[3] - base_bbox[1]) : v; }
	
	static _set_l = function(v) /*=>*/ { anchor_l = anchor_l_fract? v / (base_bbox[2] - base_bbox[0]) : v; }
	static _set_t = function(v) /*=>*/ { anchor_t = anchor_t_fract? v / (base_bbox[3] - base_bbox[1]) : v; }
	
	static set_r = function(v) /*=>*/ { anchor_r = anchor_r_fract? v / (base_bbox[2] - base_bbox[0]) : v; }
	static set_b = function(v) /*=>*/ { anchor_b = anchor_b_fract? v / (base_bbox[3] - base_bbox[1]) : v; }
	
	////- Draw
	
	drag_anchor    = noone;
	drag_anchor_sv = [ 0, 0, 0, 0 ];
	drag_anchor_mx = 0;
	drag_anchor_my = 0;
	
	static drawOverlayBBOX = function(hover, active, _x, _y, _s, _mx, _my, _node) {
		var _bbox = getBBOX();
		
		var _x0 = _x + _bbox[0] * _s;
		var _y0 = _y + _bbox[1] * _s;
		var _x1 = _x + _bbox[2] * _s;
		var _y1 = _y + _bbox[3] * _s;
		
		draw_rectangle(_x0, _y0, _x1, _y1, true);
	}
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _node = undefined) {
		static snap_dist = 8;
		
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
		
		var xx0 = base_bbox[0], dx0 = _x + xx0 * _s;
		var yy0 = base_bbox[1], dy0 = _y + yy0 * _s;
		var xx1 = base_bbox[2], dx1 = _x + xx1 * _s;
		var yy1 = base_bbox[3], dy1 = _y + yy1 * _s;
		var _ww = xx1 - xx0;
		var _hh = yy1 - yy0;
		
		var _mdx = (_mx - drag_anchor_mx) / _s;
		var _mdy = (_my - drag_anchor_my) / _s;
		
		switch(drag_anchor) {
			case 0 : draw_anchor(1, _x0, _y0, ui(8), 2); break;
			case 1 : draw_anchor(1, _x1, _y0, ui(8), 2); break;
			case 2 : draw_anchor(1, _x0, _y1, ui(8), 2); break;
			case 3 : draw_anchor(1, _x1, _y1, ui(8), 2); break;
			case 9 : draw_anchor_cross(_h9, (_x0 + _x1) / 2, (_y0 + _y1) / 2, ui(8), 1);
		}
		
		draw_set_color(COLORS._main_icon_light);
		
		if(drag_anchor == 9) {
			var _bw = drag_anchor_sv[2] - drag_anchor_sv[0];
			var _bh = drag_anchor_sv[3] - drag_anchor_sv[1];
			
			var _bl = round(drag_anchor_sv[0] + _mdx);
			var _bt = round(drag_anchor_sv[1] + _mdy);
			
			var _br = round(drag_anchor_sv[2] + _mdx);
			var _bb = round(drag_anchor_sv[3] + _mdy);
			
			// snap x
			if(abs(_bl - xx0) < snap_dist) { 
				_bl = xx0; _br = _bl + _bw; 
				draw_line_width(_x + _bl * _s, dy0, _x + _bl * _s, dy1, 1);
				
			} else if(abs(_br - xx1) < snap_dist) { 
				_br = xx1; _bl = _br - _bw; 
				draw_line_width(_x + _br * _s, dy0, _x + _br * _s, dy1, 1);
			}
			
			// snap y
			if(abs(_bt - yy0) < snap_dist) { 
				_bt = yy0; _bb = _bt + _bh; 
				draw_line_width(dx0, _y + _bt * _s, dx1, _y + _bt * _s, 1);
				
			} else if(abs(_bb - yy1) < snap_dist) { 
				_bb = yy1; _bt = _bb - _bh; 
				draw_line_width(dx0, _y + _bb * _s, dx1, _y + _bb * _s, 1);
			}
			
			// snap cx
			var cx = (xx0 + xx1) / 2;
			if(abs((_bl + _br) / 2 - cx) < snap_dist) { 
				_bl = round(cx - _bw / 2); _br = _bl + _bw; 
				draw_line_width(_x + cx * _s, dy0, _x + cx * _s, dy1, 1);
			}
			
			// snap cy
			var cy = (yy0 + yy1) / 2;
			if(abs((_bt + _bb) / 2 - cy) < snap_dist) { 
				_bt = round(cy - _bh / 2); _bb = _bt + _bh; 
				draw_line_width(dx0, _y + cy * _s, dx1, _y + cy * _s, 1);
			}
			
			setBBOX([ _bl, _bt, _br, _bb ]);
			
		} else {
			if(drag_anchor == 0 || drag_anchor == 2) {
				var _bx = round(drag_anchor_sv[0] + _mdx);
				var _bw = _bbox[2] - _bx;
				
				switch(anchor_x_type) {
					case PB_AXIS_ANCHOR.minimum : set_l(_bx); set_w(_bw); break;
					case PB_AXIS_ANCHOR.maximum : set_w(_bw);             break;
					case PB_AXIS_ANCHOR.bounded : set_l(_bx);             break;
					case PB_AXIS_ANCHOR.center  : set_w(_bw);             break;
				}
			}
			
			if(drag_anchor == 0 || drag_anchor == 1) {	
				var _by = round(drag_anchor_sv[1] + _mdy);
				var _bh = _bbox[3] - _by;
				
				switch(anchor_y_type) {
					case PB_AXIS_ANCHOR.minimum : set_t(_by); set_h(_bh); break;
					case PB_AXIS_ANCHOR.maximum : set_h(_bh);             break;
					case PB_AXIS_ANCHOR.bounded : set_t(_by);             break;
					case PB_AXIS_ANCHOR.center  : set_h(_bh);             break;
				}
			}
			
			if(drag_anchor == 3 || drag_anchor == 1) {
				var _bx = round(drag_anchor_sv[2] + _mdx);
				var _bw = _bx - _bbox[0];
				
				switch(anchor_x_type) {
					case PB_AXIS_ANCHOR.minimum : set_w(_bw);                   break;
					case PB_AXIS_ANCHOR.maximum : set_r(_ww - _bx); set_w(_bw); break;
					case PB_AXIS_ANCHOR.bounded : set_r(_ww - _bx);             break;
					case PB_AXIS_ANCHOR.center  : set_w(_bw);                   break;
				}
			}
			
			if(drag_anchor == 3 || drag_anchor == 2) {
				var _by = round(drag_anchor_sv[3] + _mdy);
				var _bh = _by - _bbox[1];
				
				switch(anchor_y_type) {
					case PB_AXIS_ANCHOR.minimum : set_h(_bh);                   break;
					case PB_AXIS_ANCHOR.maximum : set_b(_hh - _by); set_h(_bh); break;
					case PB_AXIS_ANCHOR.bounded : set_b(_hh - _by);             break;
					case PB_AXIS_ANCHOR.center  : set_h(_bh);                   break;
				}
			}
		}
		
		if(_node) _node.w_hovering = true;
		if(_node) _node.triggerRender();
		if(mouse_release(mb_left)) drag_anchor = noone;
		
		return true;
	}
	
	////- BBOX
	
	static setBase = function(baseBbox) {
		base_bbox[0] = baseBbox[0];
		base_bbox[1] = baseBbox[1];
		base_bbox[2] = baseBbox[2];
		base_bbox[3] = baseBbox[3];
		return self;
	}
	
	static setBBOX = function(_bbox) {
		var x0 = base_bbox[0]; 
		var y0 = base_bbox[1];
		var x1 = base_bbox[2];
		var y1 = base_bbox[3];
		var ww = base_bbox[2] - base_bbox[0];
		var hh = base_bbox[3] - base_bbox[1];
		
		var _l = anchor_l_fract? ww * anchor_l : anchor_l;
		var _t = anchor_t_fract? hh * anchor_t : anchor_t;
		
		var _r = anchor_r_fract? ww * anchor_r : anchor_r;
		var _b = anchor_b_fract? hh * anchor_b : anchor_b;
		
		var _bl =      _bbox[0];
		var _br = x1 - _bbox[2];
		var _bt =      _bbox[1];
		var _bb = y1 - _bbox[3];
		var _bw = _bbox[2] - _bbox[0];
		var _bh = _bbox[3] - _bbox[1];
		
		switch(anchor_x_type) {
			case PB_AXIS_ANCHOR.minimum : set_l(_bl); set_w(_bw); break;
			case PB_AXIS_ANCHOR.maximum : set_r(_br); set_w(_bw); break;
			case PB_AXIS_ANCHOR.bounded : set_l(_bl); set_r(_br); break;
			case PB_AXIS_ANCHOR.center  : set_w(_bw);
				var cx  = (_bbox[0] + _bbox[2]) / 2;
				var px0 = x0 + _l;
				var px1 = x1 - _r;
				
				if(_anchor_x_type == PB_AXIS_ANCHOR.minimum) _set_l((cx - (px1 - cx)) - x0);
				if(_anchor_x_type == PB_AXIS_ANCHOR.maximum)  set_r(x1 - (cx + (cx - px0)));
				if(_anchor_x_type == PB_AXIS_ANCHOR.center) {
					var pxc = (px0 + px1) / 2;
					var del = cx - pxc;
					
					_set_l(_l + del);
					 set_r(_r - del);
				}
				break;
		}
		
		switch(anchor_y_type) {
			case PB_AXIS_ANCHOR.minimum : set_t(_bt); set_h(_bh); break;
			case PB_AXIS_ANCHOR.maximum : set_b(_bb); set_h(_bh); break;
			case PB_AXIS_ANCHOR.bounded : set_t(_bt); set_b(_bb); break;
			case PB_AXIS_ANCHOR.center  : set_h(_bh); 
				var cy  = (_bbox[1] + _bbox[3]) / 2;
				var py0 = y0 + _t;
				var py1 = y1 - _b;
				
				if(_anchor_y_type == PB_AXIS_ANCHOR.minimum) _set_t((cy - (py1 - cy)) - y0);
				if(_anchor_y_type == PB_AXIS_ANCHOR.maximum)  set_b(y1 - (cy + (cy - py0)));
				if(_anchor_y_type == PB_AXIS_ANCHOR.center) {
					var pyc = (py0 + py1) / 2;
					var del = cy - pyc;
					
					_set_t(_t + del);
					 set_b(_b - del);
				}
				break;
		}
		
		_anchor_x_type = anchor_x_type;
		_anchor_y_type = anchor_y_type;
		
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
	
	static serialize   = function( ) /*=>*/ {return variable_clone(self)};
	static deserialize = function(m) /*=>*/ { struct_override(self, m); return self; }
	
	static uiScale = function(_div = false) {
		var _sca = _div? 1 / UI_SCALE : UI_SCALE;
		
		if(!anchor_l_fract) anchor_l *= _sca;
		if(!anchor_t_fract) anchor_t *= _sca;
		
		if(!anchor_r_fract) anchor_r *= _sca;
		if(!anchor_b_fract) anchor_b *= _sca;
		
		if(!anchor_w_fract) {
			anchor_w     *= _sca;
			anchor_w_min *= _sca;
			anchor_w_max *= _sca;
		}
			
		if(!anchor_h_fract) {
			anchor_h     *= _sca;
			anchor_h_min *= _sca;
			anchor_h_max *= _sca;
		}
		
		return self;
	}
	
	static clone = function() /*=>*/ {return variable_clone(self)};
	
}