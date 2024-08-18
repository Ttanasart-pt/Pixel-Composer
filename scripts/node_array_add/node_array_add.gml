function Node_Array_Add(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Add";
	setDimension(96, 32 + 24);
	
	newInput(0, nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Bool("Spread array", self, false ))
		.rejectArray();
	
	outputs[0] = nodeValue_Output("Output", self, VALUE_TYPE.integer, 0);
	
	input_display_list = [ 1, 0 ];
	
	static createNewInput = function() {
		var index = array_length(inputs);
		
		newInput(index, nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1 ))
			.setVisible(true, true);
		
		array_push(input_display_list, index);
		
		return inputs[index];
	} 
	
	setDynamicInput(1);
	
	static update = function(frame = CURRENT_FRAME) {
		var _arr = getInputData(0);
		
		if(inputs[0].value_from == noone) {
			inputs[0].setType(VALUE_TYPE.any);
			outputs[0].setType(VALUE_TYPE.any);
			return;
		}
		
		if(!is_array(_arr)) return;
		var _type = inputs[0].value_from.type;
		var spd   = getInputData(1);
		
		inputs[0].setType(_type);
		outputs[0].setType(_type);
		
		var _out = array_clone(_arr);
		for( var i = input_fix_len; i < array_length(inputs); i += data_length ) {
			var _val = getInputData(i);
			inputs[i].setType(_type);
			
			if(is_array(_val) && spd) array_append(_out, _val);
			else                      array_push(_out, _val);
		}
		
		outputs[0].setValue(_out);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_add, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}