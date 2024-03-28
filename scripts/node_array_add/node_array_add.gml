function Node_Array_Add(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Add";
	setDimension(96, 32 + 24);
	min_h = h;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	inputs[| 1] = nodeValue("Spread array", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false )
		.rejectArray();
	
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0);
	
	setIsDynamicInput(1);
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		
		inputs[| index] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1 )
			.setVisible(true, true);
		
		return inputs[| index];
	}
	if(!LOADING && !APPENDING) createNewInput();
	
	static refreshDynamicInput = function() {
		var _l = ds_list_create();
		
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(i < input_fix_len || inputs[| i].value_from)
				ds_list_add(_l, inputs[| i]);
			else
				delete inputs[| i];	
		}
		
		for( var i = 0; i < ds_list_size(_l); i++ )
			_l[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _l;
		
		createNewInput();
	}
	
	static onValueFromUpdate = function(index) {
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _arr = getInputData(0);
		
		if(inputs[| 0].isLeaf()) {
			inputs[| 0].setType(VALUE_TYPE.any);
			outputs[| 0].setType(VALUE_TYPE.any);
			return;
		}
		
		if(!is_array(_arr)) return;
		var _type = inputs[| 0].value_from.type;
		var spd   = getInputData(1);
		
		inputs[| 0].setType(_type);
		outputs[| 0].setType(_type);
		
		var _out = array_clone(_arr);
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i += data_length ) {
			var _val = getInputData(i);
			inputs[| i].setType(_type);
			
			if(is_array(_val) && spd)
				array_append(_out, _val);
			else 
				array_push(_out, _val);
		}
		
		outputs[| 0].setValue(_out);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_add, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}