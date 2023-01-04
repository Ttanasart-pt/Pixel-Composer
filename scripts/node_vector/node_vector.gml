function Node_Number(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Number";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 1;
	
	inputs[| 0] = nodeValue(0, "Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Number", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		inputs[| 0].drawOverlay(active, _x, _y, _s, _mx, _my, _snx, _sny);
	}
	
	function process_data(_output, _data, index = 0) { 
		return _data[0]; 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var str	= string(outputs[| 0].getValue());
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}

function Node_Vector2(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Vector2";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 2;
	
	inputs[| 0] = nodeValue(0, "x", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 1] = nodeValue(1, "y", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Vector", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	drag_type = 0;
	drag_mx   = 0;
	drag_my   = 0;
	drag_sx   = 0;
	drag_sy   = 0;
				
	static drawOverlay = function(active, _x, _y, _s, _mx, _my, _snx, _sny) {
		var __ax = inputs[| 0].getValue();
		var __ay = inputs[| 1].getValue();
						
		var _ax = __ax * _s + _x;
		var _ay = __ay * _s + _y;
		var _val;
		
		draw_sprite_ui_uniform(THEME.anchor_selector, 0, _ax, _ay);
						
		if(drag_type) {
			draw_sprite_ui_uniform(THEME.anchor_selector, 1, _ax, _ay);
			var _nx = value_snap((drag_sx + (_mx - drag_mx) - _x) / _s, _snx);
			var _ny = value_snap((drag_sy + (_my - drag_my) - _y) / _s, _sny);
			if(key_mod_press(CTRL)) {
				_val[0] = round(_nx);
				_val[1] = round(_ny);
			} else {
				_val[0] = _nx;
				_val[1] = _ny;
			}
			
			var s0 = inputs[| 0].setValue(_val[0]);
			var s1 = inputs[| 1].setValue(_val[1]);
			
			if(s0 || s1)
				UNDO_HOLDING = true;
							
			if(mouse_release(mb_left)) {
				drag_type = 0;
				UNDO_HOLDING = false;
			}
		}
						
		if(point_in_circle(_mx, _my, _ax, _ay, 8)) {
			hover = 1;
			draw_sprite_ui_uniform(THEME.anchor_selector, 1, _ax, _ay);
			if(mouse_press(mb_left, active)) {
				drag_type = 1;
				drag_mx   = _mx;
				drag_my   = _my;
				drag_sx   = _ax;
				drag_sy   = _ay;
			}
		} 
	}
	
	function process_data(_output, _data, index = 0) { 
		var vec = [ _data[0], _data[1] ];
		return vec;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		var vec = outputs[| 0].getValue();
		var str	= string(vec[0]) + "\n" + string(vec[1]);
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}

function Node_Vector3(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Vector3";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 3;
	
	inputs[| 0] = nodeValue(0, "x", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 1] = nodeValue(1, "y", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 2] = nodeValue(2, "z", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Vector", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	function process_data(_output, _data, index = 0) { 
		var vec = [ _data[0], _data[1], _data[2] ];
		return vec; 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		var vec = outputs[| 0].getValue();
		var str	= string(vec[0]) + "\n" + string(vec[1]) + "\n" + string(vec[2]);
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}

function Node_Vector4(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Vector4";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 4;
	
	inputs[| 0] = nodeValue(0, "x", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 1] = nodeValue(1, "y", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 2] = nodeValue(2, "z", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	inputs[| 3] = nodeValue(3, "w", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "Vector", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	function process_data(_output, _data, index = 0) { 
		var vec = [ _data[0], _data[1], _data[2], _data[3] ];
		return vec; 
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		var vec = outputs[| 0].getValue();
		var str	= string(vec[0]) + "\n" + string(vec[1]) + "\n" + string(vec[2]) + "\n" + string(vec[3]);
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}

function Node_Vector_Split(_x, _y, _group = -1) : Node_Processor(_x, _y, _group) constructor {
	name = "Vector split";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 32 + 24 * 4;
	
	inputs[| 0] = nodeValue(0, "Vector", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue(0, "x", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 1] = nodeValue(1, "y", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 2] = nodeValue(2, "z", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 3] = nodeValue(3, "w", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	function process_data(_output, _data, _index = 0) { 
		if(array_length(_data[0]) > _index)
			return _data[0][_index]; 
		return 0;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		var str	= string(outputs[| 0].getValue()) + "\n" + string(outputs[| 1].getValue()) 
			+ "\n" + string(outputs[| 2].getValue()) + "\n" + string(outputs[| 3].getValue());
			
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}