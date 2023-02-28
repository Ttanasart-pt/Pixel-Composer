function Node_Array_Add(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Add";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0);
	
	input_fix_len = ds_list_size(inputs);
	data_length = 1;
	
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
	
	static update = function(frame = ANIMATOR.current_frame) {
		var _arr = inputs[| 0].getValue();
		
		if(inputs[| 0].value_from == noone) {
			inputs[| 0].type  = VALUE_TYPE.any;
			outputs[| 0].type = VALUE_TYPE.any;
			return;
		}
		
		if(!is_array(_arr)) return;
		var _type = inputs[| 0].value_from.type;
		inputs[| 0].type  = _type;
		outputs[| 0].type = _type;
		
		var _out = array_clone(_arr);
		for( var i = input_fix_len; i < ds_list_size(inputs) - 1; i += data_length ) {
			var _val = inputs[| i].getValue();
			inputs[| i].type  = _type;
			
			if(is_array(_val))
				array_append(_out, _val);
			else 
				array_push(_out, _val);
		}
		
		outputs[| 0].setValue(_out);
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = input_fix_len; i < ds_list_size(_inputs); i += data_length )
			createNewInput();
	}
	
}