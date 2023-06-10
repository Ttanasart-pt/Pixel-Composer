function Node_Sequence_Anim(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array to Anim";
	update_on_frame = true;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.rejectArray();
		
	inputs[| 2] = nodeValue("Sequence", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, [])
		.setArrayDepth(1);
		
	inputs[| 3] = nodeValue("Overflow", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "Hold", "Loop", "Empty" ]);
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	sequence_surface = noone;
	sequence_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _seq = inputs[| 0].getValue();
		var _ord = inputs[| 2].getValue();
		var _h = ui(64);
		
		if(_hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h)) {
			draw_sprite_stretched(THEME.button, mouse_click(mb_left, _focus)? 2 : 1, _x, _y, _w, _h);
			if(mouse_press(mb_left, _focus)) 
				dialogPanelCall(new Panel_Array_Sequence(self));
		} else
			draw_sprite_stretched(THEME.button, 0, _x, _y, _w, _h);
		
		var x0 = _x + ui(4);
		var y0 = _y + ui(4);
		var x1 = _x + _w - ui(4 + 32);
		var y1 = _y + _h - ui(4);
		var sw = x1 - x0;
		var sh = y1 - y0;
		var nn = sh;
		
		draw_sprite_stretched(THEME.ui_panel_bg, 1, x0, y0, sw, sh);
		
		sequence_surface = surface_verify(sequence_surface, sw, sh - ui(8));
		surface_set_target(sequence_surface);
			DRAW_CLEAR
			for( var i = 0; i < array_length(_ord); i++ ) {
				var o = _ord[i];
				if(o == noone) continue;
				var s = array_safe_get(_seq, o);
				
				if(!is_surface(s)) continue;
				
				var xx = nn * i;
				
				var _sw = surface_get_width(s);
				var _sh = surface_get_height(s);
				var _ss = (nn - ui(4)) / max(_sw, _sh);
				var _sx = xx + nn / 2 - _sw * _ss / 2;
				var _sy =      nn / 2 - _sh * _ss / 2;
				
				draw_surface_ext_safe(s, _sx, _sy, _ss, _ss);
				
				//draw_set_color(COLORS.panel_toolbar_outline);
				//draw_rectangle(xx, 0, xx + nn, nn, true);
			}
		surface_reset_target();
		
		draw_surface(sequence_surface, x0, y0 + ui(4));
		
		draw_sprite_ui(THEME.gear, 0, x1 + ui(16), _y + _h / 2,,,, COLORS._main_icon);
		
		return _h;
	});
	
	input_display_list = [ 0,
		["Frames",		false], sequence_renderer, 3, 
		["Animation",	false], 1, 
	];
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _seq = inputs[| 0].getValue();
		var _spd = inputs[| 1].getValue();
		var _ord = inputs[| 2].getValue();
		var _ovf = inputs[| 3].getValue();
		
		if(!is_array(_seq)) {
			outputs[| 0].setValue(_seq);
			return;
		}
		
		var frm = floor(ANIMATOR.current_frame / _spd);
		var ind = frm;
		
		if(array_length(_ord) > 0) {
			if(_ovf == 0)
				ind = clamp(ind, 0, array_length(_ord) - 1);
			else if(_ovf == 2 && ind >= array_length(_ord)) {
				outputs[| 0].setValue(noone);
				return;
			}
			
			ind = array_safe_get(_ord, ind,, ARRAY_OVERFLOW.loop);
		} else 
			ind = safe_mod(floor(ANIMATOR.current_frame / _spd), array_length(_seq));
		
		if(ind == noone) {
			outputs[| 0].setValue(noone);
			return;
		}
		
		outputs[| 0].setValue(array_safe_get(_seq, ind));
	}
}