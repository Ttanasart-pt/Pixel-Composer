function Node_Array_Remove(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Remove";
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Enum_Button("Type", self,  0, [ "Index", "Value" ]))
		.rejectArray();
	
	newInput(2, nodeValue_Int("Index", self, 0));
	
	newInput(3, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newInput(4, nodeValue_Bool("Spread array", self, false ))
		.rejectArray();
		
	newOutput(0, nodeValue_Output("Array", self, VALUE_TYPE.any, 0));
	
	static update = function(frame = CURRENT_FRAME) {
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
		inputs[3].setType(type);
		outputs[0].setType(type);
		
		var _arr  = getInputData(0);
		var type  = getInputData(1);
		var index = getInputData(2);
		var value = getInputData(3);
		var spred = getInputData(4);
		
		inputs[2].setVisible(type == 0, type == 0);
		inputs[3].setVisible(type == 1, type == 1);
		
		if(!is_array(_arr)) return;
		_arr = array_clone(_arr);
		
		if(type == 0) {
			if(!is_array(index)) index = [ index ];
			array_sort(index, false);
			
			for( var i = 0, n = array_length(index); i < n; i++ ) {
				if(index[i] < 0) index[i] = array_length(_arr) + index[i];
				array_delete(_arr, index[i], 1);
			}
		} else {
			if(!spred || !is_array(value)) value = [ value ];
			
			for( var i = 0, n = array_length(value); i < n; i++ )
				array_remove(_arr, value[i]);
		}
		
		outputs[0].setValue(_arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(outputs[0].type == VALUE_TYPE.color) {
			var pal = outputs[0].getValue();
			if(array_empty(pal)) return;
			if(is_array(pal[0])) pal = pal[0];
			
			drawPaletteBBOX(pal, bbox);
			return;
		}
		
		draw_sprite_fit(s_node_array_remove, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}