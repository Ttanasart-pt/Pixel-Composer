function Node_Array_Rearrange(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Rearrange";
	
	draw_pad_w  = 10;
	setDimension(96, 48);
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setArrayDepth(1)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue_Int("Orders", self, [])
		.setArrayDepth(1);
	
	outputs[| 0] = nodeValue_Output("Array", self, VALUE_TYPE.any, 0)
		.setArrayDepth(1);
	
	type     = VALUE_TYPE.any;
	ordering = noone;
	order_i  = noone;
	order_y  = 0;
	
	rearranger = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) { #region
		var _arr = inputs[| 0].getValue();
		var _ord = inputs[| 1].getValue();
		
		var amo  = array_length(_arr);
		var _fx  = _x;
		var _fy  = _y + ui(8);
		var _fh  = inputs[| 0].type == VALUE_TYPE.surface? ui(48) : ui(32);
		var _fsh = _fh - ui(8);
		var _h   = amo * (_fh + ui(4));
		
		var _hov = 0;
		
		for( var i = 0; i < amo; i++ ) {
			var _ind = _ord[i];
			var _val = _arr[_ind];
			
			_fx = _x;
			if(order_i == _ind) _fx += ui(16) * order_y;
			
			var _ffx = _fx + ui(32 + 4);
			var _ffy = _fy + ui(4);
			
			draw_sprite_stretched_ext(THEME.ui_panel, 0, _fx, _fy, _w, _fh, CDEF.main_dkblack, 1);
			var hv = ordering == noone && _hover && point_in_rectangle(_m[0], _m[1], _fx, _fy, _fx + ui(32), _fy + _fh);
			var cc = hv? COLORS._main_icon : COLORS.node_composite_bg;
			draw_sprite_ext(THEME.hamburger_s, 0, _fx + ui(16), _fy + _fh / 2, 1, 1, 0, cc, 1);
			
			if(_m[1] > _ffy) _hov = i;
			
			var _ffcx = _fx + _w / 2;
			
			switch(inputs[| 0].type) {
				case VALUE_TYPE.surface :
					var _sw = surface_get_width_safe(_val);
					var _sh = surface_get_height_safe(_val);
					
					var _ss = min( _fsh / _sw, _fsh / _sh );
					    _sw *= _ss;
					    _sh *= _ss;
					
					var _sx = _ffcx            - _sw / 2;
					var _sy = _ffy  + _fsh / 2 - _sh / 2;
					
					draw_sprite_stretched_ext(THEME.ui_panel, 0, _ffcx - _fsh / 2, _ffy, _fsh, _fsh, merge_color(COLORS._main_icon_dark, COLORS.node_composite_bg, 0.25), 1);
					draw_surface_ext_safe(_val, _sx, _sy, _ss, _ss);
					draw_set_color(COLORS.node_composite_bg);
					break;
					
				default :
					draw_set_text(f_p2, fa_center, fa_center, COLORS._main_text);
					draw_text(_ffcx, _ffy + _fsh / 2, string(_val));
					break;
			}
			
			if(hv && mouse_press(mb_left, _focus)) {
				ordering = _ind;
				order_i  = _ind;
			}
			
			_fy += _fh + ui(4);
		}
		
		if(ordering != noone) {
			order_y = lerp_float(order_y, 1, 5);
			
			array_remove(_ord, ordering);
			array_insert(_ord, _hov, ordering);
			inputs[| 1].setValue(_ord);
			
			if(mouse_release(mb_left)) {
				ordering = noone;
				order_i  = noone;
			}
		} else 
			order_y = lerp_float(order_y, 0, 5);
		
		return _h;
	}); #endregion
	
	input_display_list = [ 0, ["Rearranger", false], rearranger ];
	
	static onValueFromUpdate = function(index = 0) { #region
		if(LOADING || APPENDING) return;
		
		var _arr = inputs[| 0].getValue();
		var _val = array_create(array_length(_arr));
		for( var i = 0, n = array_length(_arr); i < n; i++ ) 
			_val[i] = i;
		inputs[| 1].setValue(_val);
	} #endregion
	
	static step = function() { #region
		var _typ = VALUE_TYPE.any;
		if(inputs[| 0].value_from != noone) _typ = inputs[| 0].value_from.type;
		
		inputs[| 0].setType(_typ);
		outputs[| 0].setType(_typ);
		
		if(type != _typ) {
			if(_typ == VALUE_TYPE.surface)
				setDimension(128, 128);
			else
				setDimension(96, 32 + 24);
			
			type = _typ;
			will_setHeight = true;
		}
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _arr = getInputData(0);
		var _ord = getInputData(1);
		
		if(!is_array(_arr)) return;
		var res = [];
		
		for( var i = 0; i < array_length(_arr); i++ ) {
			var _ind = array_safe_get_fast(_ord, i, i);
			res[i]   = array_safe_get_fast(_arr, _ind);
		}
		
		outputs[| 0].setValue(res);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str  = outputs[| 0].getValue();
		var bbox = drawGetBbox(xx, yy, _s);
		draw_text_bbox(bbox, str);
	} #endregion
	
}