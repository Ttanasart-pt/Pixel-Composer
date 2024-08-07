function Node_Array_Shift(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Array Shift";
	setDimension(96, 32 + 24);
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setArrayDepth(99)
		.setVisible(true, true);
		
	inputs[| 1] = nodeValue_Int("Shift", self, 0)
	
	outputs[| 0] = nodeValue_Output("Array", self, VALUE_TYPE.any, 0);
	
	static processData = function(_outSurf, _data, _output_index, _array_index) {
		var _arr = _data[0];
		var _shf = _data[1];
		
		inputs[|  0].setType(VALUE_TYPE.any);
		outputs[| 0].setType(VALUE_TYPE.any);
		
		if(!is_array(_arr)) return [];
		
		if(inputs[| 0].value_from != noone) {
			var type = inputs[| 0].value_from.type;
			inputs[|  0].setType(type);
			outputs[| 0].setType(type);
		}
		
		var arr = [];
		for( var i = 0, n = array_length(_arr); i < n; i++ )
			arr[i] = array_safe_get(_arr, i - _shf,, ARRAY_OVERFLOW.loop);
		
		return arr;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_shift, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}