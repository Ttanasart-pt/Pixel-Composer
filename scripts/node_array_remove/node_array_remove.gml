function Node_Array_Remove(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Array Remove";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_button, [ "Index", "Value" ])
		.rejectArray();
	
	inputs[| 2] = nodeValue("Index", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0);
	
	inputs[| 3] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	inputs[| 4] = nodeValue("Spread array", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
		.rejectArray();
		
	outputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, 0);
	
	static step = function() {
		var type  = inputs[| 1].getValue();
		
		inputs[| 2].setVisible(type == 0, type == 0);
		inputs[| 3].setVisible(type == 1, type == 1);
		
		inputs[| 0].type  = VALUE_TYPE.any;
		inputs[| 3].type  = VALUE_TYPE.any;
		outputs[| 0].type = VALUE_TYPE.any;
		
		if(inputs[| 0].value_from != noone) {
			var type = inputs[| 0].value_from.type;
			inputs[| 0].type  = type;
			inputs[| 3].type  = type;
			outputs[| 0].type = type;
		}
		
	}
	
	static update = function(frame = PROJECT.animator.current_frame) {
		var _arr = inputs[| 0].getValue();
		
		if(!is_array(_arr)) return;
		
		var type  = inputs[| 1].getValue();
		var index = inputs[| 2].getValue();
		var value = inputs[| 3].getValue();
		var spred = inputs[| 4].getValue();
		
		var arr = array_clone(_arr);
		
		if(type == 0) {
			if(!is_array(index)) index = [ index ];
			array_sort(index, false);
			
			for( var i = 0; i < array_length(index); i++ ) {
				if(index[i] < 0) index[i] = array_length(arr) + index[i];
				array_delete(arr, index[i], 1);
			}
		} else {
			if(!spred || !is_array(value)) value = [ value ];
			
			for( var i = 0; i < array_length(value); i++ )
				array_remove(arr, value[i]);
		}
		
		outputs[| 0].setValue(arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_remove, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}