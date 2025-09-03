function Node_Area(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Area";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	newInput(3, nodeValue_Enum_Scroll( "Type", 0, [ "Center Span", "Two Point" ]));
	newInput(0, nodeValue_Vec2(        "Position", [ 0, 0 ]   )).setVisible(true, true);
	newInput(1, nodeValue_Vec2(        "Span", [ 16, 16 ] )).setVisible(true, true);
	newInput(2, nodeValue_Enum_Scroll( "Shape", AREA_SHAPE.rectangle, [ 
		new scrollItem("Rectangle", s_node_shape_rectangle, 0), 
		new scrollItem("Elipse",	s_node_shape_circle,	0) 
	]));
	
	// inputs 4
	
	newOutput(0, nodeValue_Output("Area", VALUE_TYPE.float, [ 0, 0, 0, 0, AREA_SHAPE.rectangle ]))
		.setDisplay(VALUE_DISPLAY.area);
	
	input_display_list = [ 3, 
		["Positions", false], 0, 1, 2, 
	]
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny, _params) { 
		PROCESSOR_OVERLAY_CHECK
		
		var _shape = current_data[2];
		var _type  = current_data[3];
		
		if(_type == 0) {
			var _pos	= current_data[0];
			var _span	= current_data[1];
		
			var px = _x + _pos[0] * _s;
			var py = _y + _pos[1] * _s;
			var ex = _span[0] * _s;
			var ey = _span[1] * _s;
			
			draw_set_color(COLORS._main_accent);
			switch(_shape) {
				case AREA_SHAPE.rectangle : draw_rectangle(px - ex, py - ey, px + ex, py + ey, true); break;
				case AREA_SHAPE.elipse :    draw_ellipse(px - ex, py - ey, px + ex, py + ey, true);   break;
			}
			
			InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
			InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, px, py, _s, _mx, _my, _snx, _sny));
			
		} else if(_type == 1) {
			var _v0 = current_data[0];
			var _v1	= current_data[1];
			
			var px = _x + _v0[0] * _s;
			var py = _y + _v0[1] * _s;
			var ex = _x + _v1[0] * _s;
			var ey = _y + _v1[1] * _s;
			
			draw_set_color(COLORS._main_accent);
			switch(_shape) {
				case AREA_SHAPE.rectangle : draw_rectangle(px, py, ex, ey, true); break;
				case AREA_SHAPE.elipse :    draw_ellipse(px, py, ex, ey, true);   break;
			}
			
			InputDrawOverlay(inputs[0].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
			InputDrawOverlay(inputs[1].drawOverlay(w_hoverable, active, _x, _y, _s, _mx, _my, _snx, _sny));
		}
			
		return w_hovering;
	}
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {
		var _v0   = _data[0];
		var _v1   = _data[1];
		var _shap = _data[2];
		var _type = _data[3];
		
		if(_type == 0) {
			inputs[0].setName("Position");
			inputs[1].setName("Span");
			
			return [ _v0[0], _v0[1], _v1[0], _v1[1], _shap ];
			 	
		} else if(_type == 1) {
			inputs[0].setName("Point 1");
			inputs[1].setName("Point 2");
			
			var xc = ( _v0[0] + _v1[0] ) / 2;
			var yc = ( _v0[1] + _v1[1] ) / 2;
			var ww = abs(_v1[0] - _v0[0]) / 2;
			var hh = abs(_v1[1] - _v0[1]) / 2;
			
			return [ xc, yc, ww, hh, _shap ];
		}
		
		return [ _v0[0], _v0[1], _v1[0], _v1[1], _shap ];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(THEME.node_draw_area, 0, bbox);
	}
}