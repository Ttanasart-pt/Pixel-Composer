function Node_Sequence_Anim(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array to Anim";
	update_on_frame = true;
	setAlwaysTimeline(new timelineItemNode_Sequence_Anim(self));
	
	inputs[0] = nodeValue_Surface("Surface in", self, [])
		.setArrayDepth(1);
	
	inputs[1] = nodeValue_Float("Speed", self, 1)
		.rejectArray();
		
	inputs[2] = nodeValue_Int("Sequence", self, [])
		.setVisible(true, true)
		.setArrayDepth(1);
		
	inputs[3] = nodeValue_Enum_Scroll("Overflow", self,  0, [ "Hold", "Loop", "Ping Pong", "Empty" ]);
	
	outputs[0] = nodeValue_Output("Surface out", self, VALUE_TYPE.surface, noone);
	
	sequence_surface = noone;
	sequence_renderer = new Inspector_Custom_Renderer(function(_x, _y, _w, _m, _hover, _focus) {
		var _seq = getInputData(0);
		var _ord = getInputData(2);
		var _h = ui(64);
		
		if(!is_array(_seq)) return _h;
		
		if(array_length(_ord) == 0) {
			_ord = array_create(array_length(_seq));
			for( var i = 0, n = array_length(_seq); i < n; i++ ) 
				_ord[i] = i;
		}
		
		draw_sprite_stretched_ext(THEME.ui_panel_bg, 1, _x, _y, _w, _h, COLORS.node_composite_bg_blend, 1);
		
		if(_hover && point_in_rectangle(_m[0], _m[1], _x, _y, _x + _w, _y + _h) && inputs[2].value_from == noone) {
			draw_sprite_stretched_add(THEME.ui_panel, 1, _x, _y, _w, _h, c_white, 0.2);
			
			if(mouse_press(mb_left, _focus)) 
				dialogPanelCall(new Panel_Array_Sequence(self));
		}
		
		var pd = ui(2);
		var x0 = _x + pd;
		var y0 = _y + pd;
		var x1 = _x + _w - pd - ui(32);
		var y1 = _y + _h - pd;
		var sw = x1 - x0;
		var sh = y1 - y0;
		var nn = sh;
		
		// draw_sprite_stretched(THEME.ui_panel_bg, 1, x0, y0, sw, sh);
		
		sequence_surface = surface_verify(sequence_surface, sw, sh - pd * 2);
		surface_set_target(sequence_surface);
			DRAW_CLEAR
			for( var i = 0, n = array_length(_ord); i < n; i++ ) {
				var o = _ord[i];
				if(o == noone) continue;
				var s = array_safe_get_fast(_seq, o);
				
				if(!is_surface(s)) continue;
				
				var xx = nn * i;
				
				var _sw = surface_get_width_safe(s);
				var _sh = surface_get_height_safe(s);
				var _ss = nn / max(_sw, _sh);
				var _sx = xx + nn / 2 - _sw * _ss / 2;
				var _sy =      nn / 2 - _sh * _ss / 2;
				
				draw_surface_ext_safe(s, _sx, _sy, _ss, _ss);
			}
		surface_reset_target();
		
		draw_surface_safe(sequence_surface, x0, y0 + pd);
		draw_sprite_ui(THEME.gear, 0, x1 + ui(16), _y + _h / 2,,,, COLORS._main_icon);
		
		return _h;
	});
	
	input_display_list = [ 0,
		["Frames",		false], sequence_renderer, 2, 3, 
		["Animation",	false], 1, 
	];
	
	static update = function(frame = CURRENT_FRAME) {
		var _sur = getInputData(0);
		if(!is_array(_sur)) {
			outputs[0].setValue(_sur);
			return;
		}
		
		var _spd = getInputData(1);
		var _seq = getInputData(2);
		var _ovf = getInputData(3);
		
		var frm = floor(CURRENT_FRAME / _spd);
		var ind = frm;
		
		if(array_length(_seq) == 0) {
			_seq = array_create(array_length(_sur));
			for( var i = 0, n = array_length(_sur); i < n; i++ ) 
				_seq[i] = i;
		}
		
		if(_ovf == 0)
			ind = clamp(ind, 0, array_length(_seq) - 1);
		else if(_ovf == 2) {
			var _slen = array_length(_seq);
			var _slpp = _slen * 2 - 2;
			ind = abs(ind % _slpp);
			if(ind >= _slen)
				ind = _slpp - ind;
		} else if(_ovf == 3 && ind >= array_length(_seq)) {
			outputs[0].setValue(noone);
			return;
		}
			
		ind = array_safe_get(_seq, ind,, ARRAY_OVERFLOW.loop);
		
		if(ind == noone) {
			outputs[0].setValue(noone);
			return;
		}
		
		outputs[0].setValue(array_safe_get_fast(_sur, ind));
	}
}

function timelineItemNode_Sequence_Anim(node) : timelineItemNode(node) constructor {
	
	static drawDopesheet = function(_x, _y, _s, _msx, _msy) {
		if(!is_instanceof(node, Node_Sequence_Anim)) return;
		if(!node.attributes.show_timeline) return;
		
		var _surfs = node.getInputData(0);
		var _seq   = node.getInputData(2);
		var _useq  = !array_empty(_seq);
		var _arr   = _useq? _seq : _surfs;
		var _surf, _rx;
		
		var _h  = h - 2;
		var _ry = h / 2 + _y;
		
		for (var i = 0, n = array_length(_arr); i < n; i++) {
			_surf = _arr[i];
			if(_useq) {
				if(_surf < 0) continue;
				_surf = _surfs[_surf];
			}
			
			if(!surface_exists(_surf)) continue;
			
			_rx = _x + (i + 1) * _s;
			
			var _sw = surface_get_width_safe(_surf);
			var _sh = surface_get_height_safe(_surf);
			var _ss = _h / max(_sw, _sh);
			
			draw_surface_ext(_surf, _rx - _sw * _ss / 2, _ry - _sh * _ss / 2, _ss, _ss, 0, c_white, .5);
		}
	}
	
	static drawDopesheetOver = function(_x, _y, _s, _msx, _msy, _hover, _focus) {
		if(!is_instanceof(node, Node_Sequence_Anim)) return;
		if(!node.attributes.show_timeline) return;
		
		drawDopesheetOutput(_x, _y, _s, _msx, _msy);
	}
	
	static onSerialize = function(_map) {
		_map.type = "timelineItemNode_Sequence_Anim";
	}
}