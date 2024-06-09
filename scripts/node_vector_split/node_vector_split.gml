function Node_Vector_Split(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor { #region
	name  = "Vector Split";
	color = COLORS.node_blend_number;
	setDimension(96, 0);
	
	draw_padding = 4;
	
	inputs[| 0] = nodeValue("Vector", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, [ 0, 0, 0, 0 ])
		.setDisplay(VALUE_DISPLAY.vector)
		.setArrayDynamic()
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("x", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 1] = nodeValue("y", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 2] = nodeValue("z", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	outputs[| 3] = nodeValue("w", self, JUNCTION_CONNECT.output, VALUE_TYPE.float, 0);
	
	static step = function() {
		if(inputs[| 0].value_from == noone) return;
		
		var type = VALUE_TYPE.float;
		if(inputs[| 0].value_from.type == VALUE_TYPE.integer)
			type = VALUE_TYPE.integer;
		
		inputs[| 0].setType(type);
		for( var i = 0; i < 4; i++ )
			outputs[| i].setType(type);
	}
	
	static processData = function(_output, _data, _output_index, _array_index = 0) {
		var _arr = _data[0];
		if(!is_array(_arr)) return _arr;
		
		if(_output_index < array_length(_arr))
			return _arr[_output_index];
			
		return 0;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str = "";
		for( var i = 0; i < 4; i++ )
			if(outputs[| i].visible) str += $"{outputs[| i].getValue()}\n";
		
		str = string_trim(str);
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	 = string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
} #endregion