function Node_Boolean(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Boolean";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 64;
	min_h = 64;
	hover_state = 0;
	hover_state_to = 0;
	
	wd_checkBox = new checkBox( function() { inputs[| 0].setValue(!getInputData(0)); } );
	wd_checkBox.spr = THEME.node_checkbox;
	
	inputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Hide Background", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 2] = nodeValue("Name location", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 1)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Top", "Bottom" ]);
	
	outputs[| 0] = nodeValue("Boolean", self, JUNCTION_CONNECT.output, VALUE_TYPE.boolean, false);
	
	input_display_list = [ 0, 
		["Display",	false], 1, 2, 
	]
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {  
		return _data[0]; 
	}
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var align = getInputData(2);
		var xx = x * _s + _x;
		var yy = (y - (!align * 20)) * _s + _y;
		
		return point_in_rectangle(_mx, _my, xx, yy, xx + w * _s, yy + (h + 20) * _s);
	}
	
	static onDrawHover = function(xx, yy, _mx, _my, _s, _hover = false, _focus = false) {
		hover_state_to = 1;
	}
	
	static drawNodeBase = function(xx, yy, _s) {
		if(!active) return;
		var hid = getInputData(1);
		
		if(hid) {
			hover_state = lerp_float(hover_state, hover_state_to, 3);
			hover_state_to = 0;
		} else 
			hover_state = 1;
			
		var aa = (0.25 + 0.5 * renderActive) * hover_state;
		draw_sprite_stretched_ext(bg_spr, 0, xx, yy, w * _s, h * _s, color, aa);
	}
	
	static drawNodeName = function(xx, yy, _s) {
		draw_name = false; 
		if(!active) return;
		if(_s < 0.75) return;
		
		var _name = display_name == ""? name : display_name;
		if(_name == "") return;
		
		var hid   = getInputData(1);
		var align = getInputData(2);
		
		if(align == 0) {
			draw_set_text(f_p2, fa_center, fa_bottom, COLORS._main_text);
			draw_text_ext_add(xx + w * _s / 2, yy - 2 + hid * ((1 - hover_state) * 8), _name, -1, 128 * _s);
		} else if(align == 1) {
			draw_set_text(f_p2, fa_center, fa_top, COLORS._main_text);
			draw_text_ext_add(xx + w * _s / 2, yy + h * _s - hid * ((1 - hover_state) * 8), _name, -1, 128 * _s);
		}
	}
	
	static drawDimension = function(xx, yy, _s) {}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var val	 = getInputData(0);
		var bbox = drawGetBbox(xx, yy, _s);
		
		wd_checkBox.setFocusHover(_focus, _hover);
		wd_checkBox.draw(bbox.xc, bbox.yc, val, [ _mx, _my ], bbox.h - 8 * _s, fa_center, fa_center);
	}
}
