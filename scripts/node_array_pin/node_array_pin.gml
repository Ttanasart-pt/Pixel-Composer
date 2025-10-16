function Node_Array_Pin(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Pin";
	setDimension(32, 32);
	
	auto_height      = false;
	junction_shift_y = 16;
	
	isHovering     = false;
	hover_scale    = 0;
	hover_scale_to = 0;
	hover_alpha    = 0;
	
	bg_spr_add = 0;
	
	newOutput(0, nodeValue_Output("Array", VALUE_TYPE.any, []));
	
	function createNewInput(index = array_length(inputs)) {
		var inAmo = array_length(inputs);
		
		newInput(index, nodeValue("Input", self, CONNECT_TYPE.input, VALUE_TYPE.any, -1 ))
			.setVisible(true, true);
							
		return inputs[index];
	} 
	
	setDynamicInput(1);
	
	static update = function(frame = CURRENT_FRAME) {
		var res  = [];
		var ind  = 0;
		
		for( var i = input_fix_len; i < array_length(inputs); i++ ) {
			if(!inputs[i].value_from) continue;
			
			var val = getInputData(i);
			array_push(res, val);
			
			inputs[ i].setType(inputs[i].value_from.type);
			outputs[0].setType(inputs[i].value_from.type);
		}
		
		outputs[0].setValue(res);
	}
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		return point_in_circle(_mx, _my, xx, yy, _s * 24);
	}
	
	static preDraw = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		for( var i = input_fix_len; i < array_length(inputs); i++ ) {
			inputs[i].x = xx;
			inputs[i].y = yy;
			inputs[i].rx = x;
			inputs[i].ry = y + 8;
		}
		
		dummy_input.x = xx;
		dummy_input.y = yy;
		dummy_input.rx = x;
		dummy_input.ry = y + 8;
		
		outputs[0].x = xx;
		outputs[0].y = yy;
		outputs[0].rx = x;
		outputs[0].ry = y + 8;
	}
	
	static drawBadge = function(_x, _y, _s) {}
	static drawJunctionNames = function(_x, _y, _mx, _my, _s, _panel = noone) {}
	
	static drawJunctions = function(_draw, _x, _y, _mx, _my, _s) {
		var _dval = PANEL_GRAPH.value_dragging;
		var hover = _dval == noone || _dval.connect_type == CONNECT_TYPE.input? outputs[0] : dummy_input;
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		isHovering = point_in_circle(_mx, _my, xx, yy, _s * 24);
		
		var jhov = hover.drawJunction(_draw, _s, _mx, _my);
		
		if(!isHovering) return noone;
		
		hover_scale_to = 1;
		return jhov? hover : noone;
	}
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		hover_alpha = 0.5;
		if(active_draw_index > -1) {
			hover_alpha		  =  1;
			hover_scale_to	  =  1;
			active_draw_index = -1;
		}
		
		if(hover_scale > 0) {
			var _r = hover_scale * _s * 16;
			shader_set(sh_node_circle);
				shader_set_color("color", COLORS._main_accent, hover_alpha);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
			shader_reset();
		}
		
		hover_scale    = lerp_float(hover_scale, hover_scale_to, 3);
		hover_scale_to = 0;
		
		if(renamed && display_name != "" && display_name != "Array Pin") {
			draw_set_text(f_sdf, fa_center, fa_bottom, COLORS._main_text);
			draw_text_transformed(xx, yy - 12 * _s, display_name, _s * 0.4, _s * 0.4, 0);
		}
		
		return drawJunctions(_draw, _x, _y, _mx, _my, _s);
	}
}