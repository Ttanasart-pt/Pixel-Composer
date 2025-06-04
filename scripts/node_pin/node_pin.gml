function Node_Pin(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Pin";
	setDimension(32, 32);
	
	auto_height      = false;
	junction_shift_y = 16;
	
	newInput(0, nodeValue( "In", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 )).setVisible(true, true);
	
	////- =Display
	
	newInput(1, nodeValue_Enum_Button( "Label Position", 0, [ "T", "B", "L", "R" ] ));
	newInput(2, nodeValue_Float(       "Label Scale",    1 ));
	newInput(3, nodeValue_Color(       "Label Color",    COLORS._main_text ));
	
	// input 4
	
	newOutput(0, nodeValue_Output("Out", VALUE_TYPE.any, 0));
	
	input_display_list = [ 0, 
		["Display", false], 1, 2, 3, 
	];
	
	inputs[0].setColor  = function(_c) /*=>*/ {
		inputs[0].color = color_real(_c); 
		inputs[0].updateColor();              
		
		outputs[0].color = color_real(_c);
		outputs[0].updateColor();

		return inputs[0];
	}
	
	outputs[0].setColor = function(_c) /*=>*/ {
		inputs[0].color = color_real(_c); 
		inputs[0].updateColor();              
		
		outputs[0].color = color_real(_c);
		outputs[0].updateColor();

		return outputs[0];
	}
	
	isHovering       = false;
	hover_scale      = 0;
	hover_scale_to   = 0;
	hover_alpha      = 0;
	hover_junction   = noone;
	
	bg_spr_add  = 0;
	label_ori   = 0;
	label_scale = 1;
	label_color = ca_white;
	
	////- Nodes
	
	static update = function() {
		if(inputs[0].value_from != noone) {
		
			inputs[0].setType(inputs[0].value_from.type);
			outputs[0].setType(inputs[0].value_from.type);
			
			inputs[0].color_display  = inputs[0].value_from.color_display;
			outputs[0].color_display = inputs[0].color_display;
		}
		
		var _val    = getInputData(0);
		label_ori   = getInputData(1);
		label_scale = getInputData(2);
		label_color = getInputData(3);
		
		outputs[0].setValue(_val);
	}
	
	////- Draw
	
	static pointIn = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		return point_in_circle(_mx, _my, xx, yy, _s * 24);
	}
	
	static preDraw = function(_x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		inputs[0].x  = xx;
		inputs[0].y  = yy;
		inputs[0].rx = x;
		inputs[0].ry = y + 8;
		
		outputs[0].x  = xx;
		outputs[0].y  = yy;
		outputs[0].rx = x;
		outputs[0].ry = y + 8;
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
		if(!jhov) draw_sprite_ui(THEME.view_pan, 0, _mx + ui(16), _my + ui(24), 1, 1, 0, COLORS._main_accent);
		
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
			var aa = _color_get_alpha(label_color);
			var ss = _s * .4 * label_scale;
			var tt = display_name;
			
			switch(label_ori) {
				case 0 : 
					draw_set_text(f_sdf, fa_center, fa_bottom, label_color, aa);
					draw_text_transformed(xx, yy - 12 * _s, tt, ss, ss, 0);
					break;
					
				case 1 : 
					draw_set_text(f_sdf, fa_center, fa_top, label_color, aa);
					draw_text_transformed(xx, yy + 12 * _s, tt, ss, ss, 0);
					break;
					
				case 2 : 
					draw_set_text(f_sdf, fa_right, fa_center, label_color, aa);
					draw_text_transformed(xx - 12 * _s, yy, tt, ss, ss, 0);
					break;
					
				case 3 : 
					draw_set_text(f_sdf, fa_left, fa_center, label_color, aa);
					draw_text_transformed(xx + 12 * _s, yy, tt, ss, ss, 0);
					break;
			}
			
			draw_set_alpha(1);
		
		}
		
		return drawJunctions(_draw, _x, _y, _mx, _my, _s);
	}
}