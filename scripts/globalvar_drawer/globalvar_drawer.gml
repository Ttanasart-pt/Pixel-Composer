function GlobalVarDrawer() constructor {
	editing = false;
	ID = UUID_generate();
	
	drawWidgetInit();
	
	dragging    = noone;
	drag_disp   = noone;
	drag_insert = 0;
	
	edit_y    = {};
	edit_y_to = {};
	
	static drawEdit = function(xx, yy, ww, _m, focus, hover, _scrollPane, rx, ry) {
		var hh   = 0;
		var chov = false; 
		
		var _node = PROJECT.globalNode;
		if(array_empty(_node.inputs)) return [ 0, false ];
		
		var _font = viewMode == INSP_VIEW_MODE.spacious? f_p0 : f_p2;
		var  del  = noone;
		
		yy += ui(8);
		hh += ui(8);
		
		var wd_x = xx;
		var wd_w = ww;
		
		var _len = array_length(_node.inputs);
		drag_insert = infinity;
		
		var _hov  = hover && (dragging == noone);
		var _foc  = focus && (dragging == noone);
		var _wd_h = viewMode == INSP_VIEW_MODE.spacious? ui(32) : ui(24);
		var _pd_h = viewMode == INSP_VIEW_MODE.spacious? ui(4)  : ui(2)
		
		for( var j = 0; j < _len; j++ ) {
			var _inpu = _node.inputs[j];
			var _edit = _inpu.editor;
			var _wd_x = wd_x;
			
			_edit.setFont(_font);
			
			if(j) { yy += _pd_h; hh += _pd_h; }
			
			var _k = _inpu.name;
			edit_y_to[$ _k] = yy;
			edit_y[$ _k]    = lerp_float(edit_y[$ _k] ?? yy, edit_y_to[$ _k], 10);
			var _yy = edit_y[$ _k];
			
			_edit.tb_name.setFocusHover(_foc, _hov);
			_edit.sc_type.setFocusHover(_foc, _hov);
			_edit.sc_disp.setFocusHover(_foc, _hov);
			
			if(_foc) _edit.tb_name.register(_scrollPane);
			
			var _wd_xx = _wd_x + ui(32);
			var _wd_ww = wd_w - _wd_h - ui(32 + 4);
			
			_edit.tb_name.draw(_wd_xx + ui(22), _yy, _wd_ww - ui(22), _wd_h, _inpu.name, _m, TEXTBOX_INPUT.text);
			gpu_set_texfilter(true);
			draw_sprite_ui(THEME.rename, 0, _wd_xx + ui(10), _yy + _wd_h / 2, -.6, .6, 0, COLORS._main_icon, .75);
			gpu_set_texfilter(false);
			
			if(buttonInstant(noone, _wd_x + wd_w - _wd_h, _yy, _wd_h, _wd_h, _m, _hov, _foc, "", 
				THEME.icon_delete, 0, [ COLORS._main_icon, COLORS._main_value_negative ]) == 2) del = j;
			
			var _hg = 0;
			var _hh = _wd_h + ui(4);
			_yy += _hh; 
			_hg += _hh;
			
			var _wd_ww = (wd_w - ui(32)) / 2 - ui(2);
			_edit.sc_type.draw(_wd_xx, _yy, _wd_ww, _wd_h, global.GLOBALVAR_TYPES_NAME[_edit.type_index], _m, rx, ry);
			
			var _wd_xx2 = _wd_xx + _wd_ww + ui(4);
			_edit.sc_disp.draw(_wd_xx2, _yy, _wd_ww, _wd_h, _edit.sc_disp.data_list[_edit.disp_index], _m, rx, ry);
				
			var _hh = _wd_h + _pd_h;
			_yy += _hh; 
			_hg += _hh;
			
			var wdh = _inpu.editor.draw(_wd_xx, _yy, wd_w - ui(32), _m, _foc, _hov, viewMode);
			var _hh = wdh + _pd_h;
			_yy += _hh; 
			_hg += _hh;
			
			if(dragging != noone) {
				if(j < dragging && _m[1] < yy + ui(48))       drag_insert = min(drag_insert, j);
				if(j > dragging && _m[1] > yy + _hg - ui(48)) drag_insert = min(drag_insert, j);
			}
			
			yy += _hg; 
			hh += _hg;
			
			if(dragging != noone && dragging != j) continue;
			
			var bs = ui(32);
			var bx = xx - ui(8);
			var by = edit_y[$ _k];
			var aa = dragging == j? 1 : .25;
			
			if(dragging == noone && hover && point_in_rectangle(_m[0], _m[1], bx, by, bx + bs, by + _hg)) {
				chov = true;
				aa   = 1;
				
				if(mouse_press(mb_left, _foc)) {
					drag_disp   = j;
					dragging    = j;
					drag_insert = j;
				}
			} 
			
			gpu_set_texfilter(true);
			draw_sprite_ext_add(THEME.hamburger, 0, bx + bs / 2, by + _hg / 2, .6, .6, 0, COLORS._main_icon_light, aa);
			gpu_set_texfilter(false);
			
		}
		
		if(dragging != noone) {
			if(drag_insert != infinity && drag_insert != dragging) {
				var _inp = _node.inputs[dragging];
				array_delete(_node.inputs, dragging, 1);
				array_insert(_node.inputs, drag_insert, _inp);
				
				dragging  = drag_insert;
				drag_disp = drag_insert;
			}
			
			if(mouse_release(mb_left)) dragging = noone;
		}
					
		if(del != noone) array_delete(_node.inputs, del, 1);
			
		return [ hh, chov ];
	}
	
	static drawValue = function(xx, yy, ww, _m, focus, hover, _scrollPane, rx, ry) {
		var hh   = 0;
		var chov = false; 
		
		var lb_h  = line_get_height(f_p0) + ui(8);
		var _node = PROJECT.globalNode;
		var _font = viewMode == INSP_VIEW_MODE.spacious? f_p0 : f_p2;
		var _padd = viewMode == INSP_VIEW_MODE.spacious? ui(8) : ui(4);
		
		if(viewMode == INSP_VIEW_MODE.compact) { 
			yy += ui(4); 
			hh += ui(4); 
		}
		
		for( var j = 0; j < array_length(_node.inputs); j++ ) {
			var widg    = drawWidget(xx, yy, ww, _m, _node.inputs[j], true, hover, focus, _scrollPane, rx, ry, ID);
			var widH    = widg[0];
			var mbRight = widg[1];
			var widHov  = widg[2];
						
			if(hover && point_in_rectangle(_m[0], _m[1], xx, yy, xx + ww, yy + widH))
				_HOVERING_ELEMENT = _node.inputs[j];
			
			yy += lb_h + widH + _padd;
			hh += lb_h + widH + _padd;
		}
		
		return [ hh, chov ];
	}
	
	static draw = function(xx, yy, ww, _m, focus, hover, _scrollPane, rx, ry) {
		if(editing) return drawEdit(xx, yy, ww, _m, focus, hover, _scrollPane, rx, ry);
		return drawValue(xx, yy, ww, _m, focus, hover, _scrollPane, rx, ry);
	}
}
