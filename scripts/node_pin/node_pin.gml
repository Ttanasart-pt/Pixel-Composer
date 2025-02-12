function Node_Pin(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Pin";
	setDimension(32, 32);
	
	auto_height      = false;
	junction_shift_y = 16;
	// custom_grid      = 8;
	
	isHovering     = false;
	hover_scale    = 0;
	hover_scale_to = 0;
	hover_alpha    = 0;
	hover_junction = noone;
	
	bg_spr_add = 0;
	
	newInput(0, nodeValue("In", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 ))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Out", self, VALUE_TYPE.any, 0));
	
	inputs[0].setColor = function(_color) {
		inputs[0].color = color_real(_color); outputs[0].color = color_real(_color);
		inputs[0].updateColor();              outputs[0].updateColor();
		
		return inputs[0];
	}
	
	outputs[0].setColor = function(_color) {
		inputs[0].color = color_real(_color); outputs[0].color = color_real(_color);
		inputs[0].updateColor();              outputs[0].updateColor();
		
		return outputs[0];
	}
	
	static update = function() {
		if(inputs[0].value_from != noone) {
		
			inputs[0].setType(inputs[0].value_from.type);
			outputs[0].setType(inputs[0].value_from.type);
			
			inputs[0].color_display  = inputs[0].value_from.color_display;
			outputs[0].color_display = inputs[0].color_display;
		}
		
		var _val = getInputData(0);
		outputs[0].setValue(_val);
	}
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		return point_in_circle(_mx, _my, xx, yy, _s * 24);
	}
	
	static preDraw = function(_x, _y, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		inputs[0].x = xx;
		inputs[0].y = yy;
		
		outputs[0].x = xx;
		outputs[0].y = yy;
	}
	
	static drawBadge = function(_x, _y, _s) {}
	static drawJunctionNames = function(_x, _y, _mx, _my, _s, _panel = noone) {}
	
	static drawJunctions = function(_draw, _x, _y, _mx, _my, _s) {
		var _dval = PANEL_GRAPH.value_dragging;
		var hover = _dval == noone || _dval.connect_type == CONNECT_TYPE.input? outputs[0] : inputs[0];
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		isHovering     = point_in_circle(_mx, _my, xx, yy, _s * 24);
		hover_junction = noone;
		
		var jhov = hover.drawJunction(_draw, _s, _mx, _my);
		
		if(!isHovering) return noone;
		if(!jhov) draw_sprite_ext(THEME.view_pan, 0, _mx + ui(16), _my + ui(24), 1, 1, 0, COLORS._main_accent);
		
		hover_junction = jhov? hover : noone; 
		hover_scale_to = 1;
		
		return hover_junction;
	}
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s) {
		if(!_draw) return drawJunctions(_draw, _x, _y, _mx, _my, _s);
		
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		hover_alpha = 0.5;
		
		if(active_draw_index > -1) {
			hover_alpha		  =  1;
			hover_scale_to	  =  1;
			active_draw_index = -1;
		} 
		
		if(hover_scale > 0) {
			var _r = _s * 16;
			shader_set(sh_node_circle);
				shader_set_color("color", COLORS._main_accent, hover_alpha);
				shader_set_f("radius", .5 * hover_scale);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				shader_set_f("radius", 0);
			shader_reset();
		}
		
		hover_scale    = lerp_float(hover_scale, hover_scale_to, 3);
		hover_scale_to = 0;
		
		if(renamed && display_name != "" && display_name != "Pin") {
			draw_set_text(f_sdf, fa_center, fa_bottom, COLORS._main_text);
			draw_text_transformed(xx, yy - 12 * _s, display_name, _s * 0.4, _s * 0.4, 0);
		}
		
		return drawJunctions(_draw, _x, _y, _mx, _my, _s);
	}
}