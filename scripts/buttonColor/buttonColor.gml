function buttonColor(_onModify, dialog = noone) : widget() constructor {
	onModify      = _onModify;
	parentDialog  = dialog;
	triggered     = false;
	show_alpha    = true;
	simple        = false;
	padding       = ui(2);
	
	is_picking    = false;
	current_color = c_black;
	
	expanded      = false;
	expandHeight  = ui(200);
	
	editing_hue_color = undefined;
	editing_hue  = false;
	editing_sat  = false;
	edit_sat_hue = undefined;
	
	b_picker      = button(function(ctx) /*=>*/ {
		var _dia = colorSelectorCall(undefined, function(c) /*=>*/ {return onModify(c)});
		_dia.selector.dropper_active = true;
		_dia.selector.dropper_close  = true;
		_dia.drop_target = ctx;
	}).setParam(self).setIcon(THEME.color_picker_dropper, 0, COLORS._main_icon).iconPad(ui(6));
	
	b_quick_pick  = button(function() /*=>*/ {
		var pick = instance_create(mouse_mx, mouse_my, o_dialog_color_quick_pick);
		array_insert(pick.palette, 0, current_color);
		pick.onModify = onModify;
	}).setIcon(THEME.color_wheel).iconPad(ui(6)).setActivatePress();
	
	tb_hex   = textBox_Text(function(txt) /*=>*/ {return onModify(color_from_hex(txt))}).setFont(f_p4).setAlign(fa_right).setHide(1);
	tb_alpha = slider(0, 1, .01, function(a) /*=>*/ { 
		current_color = cola(current_color, clamp(a,0,1));
		onModify(current_color);
	}).setFont(f_p4).setAlign(fa_center).setIncrement(false);
	
	static isSimple  = function() /*=>*/ { show_alpha = false; simple = true; return self; };
	static hideAlpha = function() /*=>*/ { show_alpha = false;                return self; };
	
	static isTriggered = function() {
		var t = triggered;
		triggered = false;
		return t;
	}
	
	static trigger = function() { 
		var colr   = is_array(current_color)? array_safe_get(current_color, 0, 0) : current_color;
		var dialog = colorSelectorCall(colr, function(c) /*=>*/ {return onModify(c)});
		
		dialog.interactable     = interactable;
		dialog.drop_target      = self;
		
		if(parentDialog == noone) return;
		
		if(is(parentDialog, PanelContent)) {
			var _dia = parentDialog.panel? parentDialog.panel.dialog : noone;
			if(_dia && instance_exists(_dia)) 
				_dia.addChildren(dialog);
			
		} else if(instance_exists(parentDialog))
			parentDialog.addChildren(dialog);
	}
	
	////- Draw
	
	static fetchHeight = function(params) { return expanded? expandHeight : params.h; }
	static drawParam   = function(params) { return draw(params.x, params.y, params.w, params.h, params.data, params.m); }
	
	static draw = function(_x, _y, _w, _h, _color, _m) {
		x = _x;
		y = _y;
		w = _w;
		h = expanded? expandHeight : _h;
		current_color = _color;
		hovering      = hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + h);
		
		var _cw = _w;
		var  bs = min(_h, ui(32));
		
		draw_sprite_stretched_ext(THEME.button_def, 0, x, y, w, h, boxColor);
		
		if(_w - bs > ui(128) && interactable) {
			var bx = _x + _cw - bs;
			_cw -= bs;
			
			draw_sprite_stretched_ext(THEME.button_def, 2, bx - bs, _y, bs * 2, _h, CDEF.main_mdwhite, 1);
			
			b_quick_pick.setFocusHover(active, hover);
			b_quick_pick.draw(bx, _y + _h / 2 - bs / 2, bs, bs, _m, THEME.button_hide_fill);
			
			bx  -= bs;
			_cw -= bs;
			
			var _sel  = o_dialog_color_selector;
			var _drop = instance_exists(_sel) && _sel.selector.dropper_active && _sel.drop_target == self;
			
			b_picker.setFocusHover(active && !instance_exists(_sel), hover);
			b_picker.icon_blend = _drop? COLORS._main_accent : COLORS._main_icon;
			b_picker.icon_index = _drop;
			b_picker.draw(bx, _y + _h / 2 - bs / 2, bs, bs, _m, THEME.button_hide_fill);
		}
		
		var _bx  = _x  + padding;
		var _by  = _y  + padding;
		var _bw  = _cw - padding * 2;
		var _bh  = _h  - padding * 2;
		
		var hoverRect = ihover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _bw, _y + _h);
		if(!simple && _m[0] < _x + _h && _m[1] < _y + _h) hoverRect = false;
		
		if(hoverRect) {
			draw_sprite_stretched_ext(THEME.button_def, 3, x, y, w, h, CDEF.main_grey);	
			
			if(mouse_lpress(iactive)) 
				trigger();
			
			if(mouse_lclick(iactive)) {
				draw_sprite_stretched_ext(THEME.button_def, 2, x, y, w, h, boxColor);
				draw_sprite_stretched_ext(THEME.button_def, 3, x, y, w, h, COLORS._main_accent);
			}
			
		} else if(mouse_lpress()) deactivate();
		
		if(is_array(current_color)) 
			drawPalette(current_color, _bx, _by, _bw, _bh);
			
		else if(is_numeric(current_color)) {
			if(!simple) {
				var _bs = _h;
				_bx += _bs;
				_bw -= _bs;
				
				var _bbx = _x + _bs / 2;
				var _bby = _y + _bs / 2;
				
				var _bba = .4 + .4 * interactable;
				var _bbc = COLORS._main_icon;
				var _foc = active;
				
				if(hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _bs, _y + _h)) {
					_bbc = COLORS._main_icon_light;
					
					if(mouse_lpress()) {
						expanded = !expanded;
						_foc = false;
					}
				}
				
				draw_sprite_stretched_ext(THEME.button_def, 0, _x, _y, _bs, _h, CDEF.main_mdwhite, 1);
				draw_sprite_ui(THEME.arrow, expanded? 3 : 0, _bbx, _bby, 1, 1, 0, _bbc, _bba);
				
				if(expanded) {
					var _clx = _x + ui(2);
					var _cly = _y + _h  + ui(2);
					
					var _clw = _w - ui(4);
					var _clh =  h - _h  - ui(6);
					
					draw_sprite_stretched_ext(THEME.box_r2, 0, _clx, _cly, _clw, _clh, CDEF.main_mdblack, 1);
					
					_clh -= ui(24);
					
					var cx = _clx + _clw / 2;
					var cy = _cly + _clh / 2;
					
					var _sls = min(_clw, _clh) - ui(8);
					var _slx = cx - _sls / 2;
					var _sly = cy - _sls / 2;
					
					var hrad = .45 * _sls;
					var srad = .35 * _sls;
					var stri = .4  * _sls;
					var tri  = dsin(30) * stri;
					var vtri = sqrt(stri * stri - tri * tri);
					
					if(editing_hue_color != current_color) edit_sat_hue = undefined;
					
					var _hsl = color_rgb_to_hsl_array(current_color);
					if(edit_sat_hue != undefined)
						_hsl[0] = edit_sat_hue;
						
					var H = _hsl[0];
					var S = _hsl[1];
					var V = _hsl[2];
					var hAng = H * 360;
					
					#region editing
						var hoverArea = 0;
						var mouseDist = point_distance(cx, cy, _m[0], _m[1]) / _sls * 2.;
						
						if(hover && mouseDist > .8 && mouseDist < 1) { // ring
							if(mouse_lpress(active)) editing_hue = true;
							hoverArea = 1;
						}
						
						if(editing_hue) {
							hoverArea = 1;
							var hh  = point_direction(cx, cy, _m[0], _m[1]) / 360;
							_hsl[0] = hh;
							edit_sat_hue = hh;
							
							var cc = color_hsl_array_to_rgb(_hsl, _color_get_alpha(current_color));
							editing_hue_color = cc;
							
							if(onModify(cc))
								UNDO_HOLDING = true;
								
							if(mouse_lrelease()) {
								editing_hue  = false;
								UNDO_HOLDING = false;
							}
						}
						
						var tri_x0 = cx + lengthdir_x(stri, hAng +   0);
						var tri_y0 = cy + lengthdir_y(stri, hAng +   0);
						
						var tri_x1 = cx + lengthdir_x(stri, hAng + 120);
						var tri_y1 = cy + lengthdir_y(stri, hAng + 120);
						
						var tri_x2 = cx + lengthdir_x(stri, hAng + 240);
						var tri_y2 = cy + lengthdir_y(stri, hAng + 240);
						
						if(hover && point_in_triangle(_m[0], _m[1], tri_x0, tri_y0, tri_x1, tri_y1, tri_x2, tri_y2)) {
							if(mouse_lpress(active)) {
								editing_sat  = true;
								edit_sat_hue = H;
							}
							hoverArea = 2;
						}
						
						if(editing_sat) {
							hoverArea = 2;
							
							var px = _m[0];
							var py = _m[1];
							
							var _in = point_in_triangle(_m[0], _m[1], tri_x0, tri_y0, tri_x1, tri_y1, tri_x2, tri_y2);
							if(!_in) {
								var p01 = distance_to_line(_m[0], _m[1], tri_x0, tri_y0, tri_x1, tri_y1);
								var p02 = distance_to_line(_m[0], _m[1], tri_x0, tri_y0, tri_x2, tri_y2);
								var p12 = distance_to_line(_m[0], _m[1], tri_x1, tri_y1, tri_x2, tri_y2);
								
								var pMin = min(p01, p02, p12);
								if(pMin == p01) pp = point_to_line(_m[0], _m[1], tri_x0, tri_y0, tri_x1, tri_y1);
								if(pMin == p02) pp = point_to_line(_m[0], _m[1], tri_x0, tri_y0, tri_x2, tri_y2);
								if(pMin == p12) pp = point_to_line(_m[0], _m[1], tri_x1, tri_y1, tri_x2, tri_y2);
								
								px = pp[0];
								py = pp[1];
							}
							
							var pp = point_rotate(px, py, cx, cy, -hAng);
							px = pp[0];
							py = pp[1];
							
							var vv  = (py - (cy - vtri)) / (vtri * 2);
							_hsl[2] = 1 - clamp(vv, 0, 1);
							
							var ss  = (px - (cx - tri)) / (tri + stri);
							_hsl[1] = clamp(ss, 0, 1);
							
							var cc = color_hsl_array_to_rgb(_hsl, _color_get_alpha(current_color));
							editing_hue_color = cc;
							
							if(onModify(cc))
								UNDO_HOLDING = true;
								
							if(mouse_lrelease()) {
								editing_sat  = false;
								UNDO_HOLDING = false;
							}
						}
					#endregion
					
					shader_set(__sh_color_selector_wheel);
						shader_set_f( "size",   _sls );
						shader_set_f( "hue",    H    );
						shader_set_f( "hover",  hoverArea );
						
						draw_sprite_stretched(s_fx_pixel, 0, _slx, _sly, _sls, _sls);
					shader_reset();
					
					var huex = cx + lengthdir_x(hrad, hAng);
					var huey = cy + lengthdir_y(hrad, hAng);
					
					draw_set_circle_precision(32);
					draw_set_color(c_white); draw_circle_border(huex, huey, _sls * .04, 3 );
					draw_set_color(c_black); draw_circle_border(huex, huey, _sls * .04, 1 );
					
					var svx = lerp(cx -  tri, cx + srad, S);
					    svx = V > .5? clamp(svx, cx - tri, cx - tri + (tri + srad) * (1-V) * 2 ) : 
					                  clamp(svx, cx - tri, cx - tri + (tri + srad) *    V  * 2 );
					var svy = lerp(cy + vtri, cy - vtri, V);
					
					var pp  = point_rotate(svx, svy, cx, cy, hAng);
					
					draw_set_circle_precision(32);
					draw_set_color(c_white); draw_circle_border(pp[0], pp[1], _sls * .04, 3 );
					draw_set_color(c_black); draw_circle_border(pp[0], pp[1], _sls * .04, 1 );
					
					var tbp = ui(4 + 2);
					var tbw = ui(68);
					var tbh = ui(24 - 4);
					var tbx = _x + _w - tbp - tbw;
					var tby = _cly + _clh + ui(2);
					
					tb_hex.setFocusHover(_foc, hover);
					tb_hex.draw(tbx, tby, tbw, tbh, color_get_hex(current_color), _m);
					
					if(show_alpha) {
						tbw = _w - tbw - tbp * 2 - ui(4);
						tbx = _x + tbp;
						
						tb_alpha.setFocusHover(_foc, hover);
						tb_alpha.draw(tbx, tby, tbw, tbh, _color_get_a(current_color), _m);
					}
				}
			}
			
			var _a = _color_get_alpha(current_color);
			
			if(_a == 1 || !show_alpha) {
				draw_sprite_stretched_ext(THEME.palette_mask, 1, _bx, _by, _bw, _bh, current_color, 1);
			} else {
				draw_sprite_stretched_ext(THEME.button_backdroup, 4, _bx, _by, _bw, _bh, boxColor, 1);
				draw_sprite_stretched_ext(THEME.palette_mask,     4, _bx, _by, _bw, _bh - ui(8), current_color, 1);
			
				draw_sprite_stretched_ext(THEME.palette_mask, 5, _bx, _by + _bh - ui(6), _bw,      ui(6), c_black, 1);
				draw_sprite_stretched_ext(THEME.palette_mask, 5, _bx, _by + _bh - ui(6), _bw * _a, ui(6), c_white, 1);
			}
		}	
		
		if(hoverRect) draw_sprite_stretched_ext(THEME.button_def, 3, x, y, w, h, CDEF.main_grey);	
		else          draw_sprite_stretched_ext(THEME.button_def, 3, x, y, w, h, CDEF.main_grey, .2 + .3 * interactable);
		
		if(WIDGET_CURRENT == self || (instance_exists(o_dialog_color_selector) && o_dialog_color_selector.drop_target == self))
			draw_sprite_stretched_ext(THEME.widget_selecting, 0, x, y, w, h, COLORS._main_accent, 1);
		
		if(DRAGGING && DRAGGING.type == "Color" && hover && hoverRect) {
			draw_sprite_stretched_ext(THEME.ui_panel, 1, x, y, w, h, COLORS._main_value_positive, 1);	
			if(mouse_lrelease())
				onModify(DRAGGING.data);
		}
		
		resetFocus();
		return h;
	}
	
}

function drawColorBBOX(_color, _bbox, _alp = true, _ind = 1) { drawColor(_color, _bbox.x0, _bbox.y0, _bbox.w, _bbox.h, _alp, _ind); }
	
function drawColor(color, _x, _y, _w, _h, _alp = true, _ind = 1) {
	
	if(is_real(color) || !_alp) {
		draw_sprite_stretched_ext(THEME.palette_mask, _ind, _x, _y, _w, _h, color, 1);
		return;
	}
		
	var _a = _color_get_alpha(color);
		
	if(_a == 1) {
		draw_sprite_stretched_ext(THEME.palette_mask, _ind, _x, _y, _w, _h, color, 1);
		return;
	}
		
	draw_sprite_stretched_ext(THEME.palette_mask, _ind, _x, _y, _w, _h - ui(8), color, 1);
	
	draw_sprite_stretched_ext(THEME.palette_mask,         1, _x, _y + _h - ui(6), _w, ui(6), c_black, 1.);
	draw_sprite_stretched_ext(THEME.palette_mask_outline, 1, _x, _y + _h - ui(6), _w, ui(6), c_white, 1.);
	
	draw_sprite_stretched_ext(THEME.palette_mask, 1, _x, _y + _h - ui(6), _w * _a, ui(6), c_white, 1);
	
		
}