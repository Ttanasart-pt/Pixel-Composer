function Node_Pin(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name     = "Pin";
	doUpdate = doUpdateLite;
	setDimension(32, 32);
	
	auto_height      = false;
	junction_shift_y = 16;
	
	newInput(0, nodeValue( "In", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0 )).setVisible(true, true);
	
	////- =Display
	newInput(1, nodeValue_Enum_Button( "Label Position", 0, [ "T", "B", "L", "R" ] )).rejectArray();
	newInput(2, nodeValue_Float(       "Label Scale",    1 )).rejectArray();
	newInput(3, nodeValue_Color(       "Label Color",    COLORS._main_text )).rejectArray();
	
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
	hover_junction   = noone;
	
	bg_spr_add  = 0;
	label_ori   = 0;
	label_scale = 1;
	label_color = ca_white;
	
	////- Nodes
	
	static onValueFromUpdate = function() { onValueUpdate(); }
	static onValueUpdate     = function() {
		label_ori   = inputs[1].getValue();
		label_scale = inputs[2].getValue();
		label_color = inputs[3].getValue();
		
		if(inputs[0].value_from != noone) {
			inputs[0].setType(inputs[0].value_from.type);
			outputs[0].setType(inputs[0].value_from.type);
			
			inputs[0].color_display  = inputs[0].value_from.color_display;
			outputs[0].color_display = inputs[0].color_display;
		}
	}
	
	static update = function() {
		outputs[0].setValue(inputs[0].getValue());
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
	
	static checkJunctions = function(_x, _y, _mx, _my, _s, _fast = false) {
		isHovering = point_in_circle(_mx, _my, _x, _y, _s * 24);
		if(!isHovering) return noone;
		
		CURSOR_SPRITE = THEME.view_pan;
		var _dy = junction_draw_hei_y * _s / 2;
		var _dx = _fast? 6  * _s : _dy;
		
		var dval = PANEL_GRAPH.value_dragging;
		var junc = dval == noone || dval.connect_type == CONNECT_TYPE.input? outputs[0] : inputs[0];
		
		var _hov = junc.isHovering(_s, _dx, _dy, _mx, _my);
		inputs[0].hover_in_graph  = _hov;
		outputs[0].hover_in_graph = _hov;
		
		return _hov? junc : noone;
		
	}
	
	static drawJunctions = function(_x, _y, _mx, _my, _s) {
		var junc = isHovering? inputs[0] : outputs[0];
		junc.drawJunction(_s, _mx, _my);
	}
	
	static drawNode = function(_draw, _x, _y, _mx, _my, _s) {
		var xx =  x      * _s + _x;
		var yy = (y + 8) * _s + _y;
		
		if(active_draw_index > -1) {
			var _r = _s * 16;
			shader_set(sh_node_circle);
				shader_set_color("color", COLORS._main_accent, 1);
				shader_set_f("radius", .5);
				draw_sprite_stretched(s_fx_pixel, 0, xx - _r, yy - _r, _r * 2, _r * 2);
				shader_set_f("radius", 0);
			shader_reset();
			active_draw_index = -1;
		}
		
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
	}

	static drawDimension = undefined;
}