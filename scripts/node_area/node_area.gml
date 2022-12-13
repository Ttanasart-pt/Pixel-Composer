function Node_Area(_x, _y) : Node_Value_Processor(_x, _y) constructor {
	name = "Area";
	color = COLORS.node_blend_number;
	previewable   = false;
	
	w = 96;
	min_h = 0;
	
	inputs[| 0] = nodeValue(0, "Postion", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, true);
	inputs[| 1] = nodeValue(1, "Size", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 16, 16 ] )
		.setDisplay(VALUE_DISPLAY.vector)
		.setVisible(true, true);
	
	inputs[| 2] = nodeValue(2, "Shape", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, AREA_SHAPE.rectangle )
		.setDisplay(VALUE_DISPLAY.enum_scroll, ["Rectangle", "Elipse"]);
	
	outputs[| 0] = nodeValue(0, "Area", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, [ 0, 0, 0, 0, AREA_SHAPE.rectangle ])
		.setDisplay(VALUE_DISPLAY.vector);
	
	static drawOverlay = function(active, _x, _y, _s, _mx, _my) {
		var _pos	= inputs[| 0].getValue();
		var _span	= inputs[| 1].getValue();
		var _shape	= inputs[| 2].getValue();
		var px = _x + _pos[0] * _s;
		var py = _y + _pos[1] * _s;
		var ex = _span[0] * _s;
		var ey = _span[1] * _s;
		
		draw_set_color(COLORS._main_accent);
		switch(_shape) {
			case AREA_SHAPE.rectangle :
				draw_rectangle(px - ex, py - ey, px + ex, py + ey, true);
				break;
			case AREA_SHAPE.elipse :
				draw_ellipse(px - ex, py - ey, px + ex, py + ey, true);
				break;
		}
		
		inputs[| 0].drawOverlay(active, _x, _y, _s, _mx, _my);
		inputs[| 1].drawOverlay(active, px, py, _s, _mx, _my);
	}
	
	function process_value_data(_data, index = 0) { 
		return [_data[0][0], _data[0][1], _data[1][0], _data[1][1], _data[2]];
	}
	
	doUpdate();
	
	static onDrawNode = function(xx, yy, _mx, _my, _s) {
		draw_sprite_ui_uniform(THEME.node_draw_area, 0, xx + w * _s / 2, yy + 10 + (h - 10) * _s / 2, _s, c_white);
	}
}