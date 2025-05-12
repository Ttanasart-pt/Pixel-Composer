function Node_Rotation_Random_Data(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name  = "Rotation Random";
	color = COLORS.node_blend_number;
	setDimension(96, 48);
	
	types = [
		__txt("Single"),
		__txtx("widget_rotator_random_range",        "Range"), 
		__txtx("widget_rotator_random_span",         "Span"), 
		__txtx("widget_rotator_random_double_range", "Double Range"), 
		__txtx("widget_rotator_random_double_span",  "Double Span")
	];
	
	////- Rotation
	
	newInput(0, nodeValue_Enum_Scroll( "Type", self,   0, types ));
	
	newInput(1, nodeValue_Rotation( "Range Start",   self, 0 ));
	newInput(2, nodeValue_Rotation( "Range End",     self, 360 ));
	newInput(3, nodeValue_Rotation( "Range 2 Start", self, 0 ));
	newInput(4, nodeValue_Rotation( "Range 2 End",   self, 360 ));
	
	// inputs 5
	
	newOutput(0, nodeValue_Output("Rotation Random", self, VALUE_TYPE.float, [ 0, 0, 360, 0, 0 ])).setDisplay(VALUE_DISPLAY.rotation_random);
	
	input_display_list = [ 0, 
		["Rotation", false], 1, 2, 3, 4, 
	]
	
	static processData = function(_output, _data, _array_index = 0) {
		var _type = _data[0];
		
		var _rn1s = _data[1];
		var _rn1e = _data[2];
		var _rn2s = _data[3];
		var _rn2e = _data[4];
		
		if(_type == 0) {
			inputs[1].setName("Angle");
			inputs[2].setVisible(false, false);
			inputs[3].setVisible(false, false);
			inputs[4].setVisible(false, false);
			
			return [ 0, _rn1s, _rn1s, _rn1s, _rn1s ];
		}
		
		_type--;
		
		switch(_type) {
			case 0 :
			case 2 : 
				inputs[1].setName("Range Start");
				inputs[2].setName("Range End");
				inputs[3].setName("Range 2 Start");
				inputs[4].setName("Range 2 End");
				break;
				
			case 1 :
			case 3 : 
				inputs[1].setName("Span Center");
				inputs[2].setName("Span Range");
				inputs[3].setName("Span 2 Center");
				inputs[4].setName("Span 2 Range");
				break;
		}
		
		inputs[3].setVisible(_type == 2 || _type == 3);
		inputs[4].setVisible(_type == 2 || _type == 3);
		
		return [ _type, _rn1s, _rn1e, _rn2s, _rn2e ];
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_bbox_uniform(s_node_rotation_random_data, 0, bbox);
	}
}