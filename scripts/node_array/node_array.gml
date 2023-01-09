function Node_Array(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Array";
	previewable = false;
	
	w = 96;
	min_h = 0;
	
	static createNewInput = function() {
		var index = ds_list_size(inputs);
		inputs[| index] = nodeValue( index, "Input", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1 )
			.setVisible(true, true);
	}
	if(!LOADING && !APPENDING) createNewInput();
	
	input_fix_len = 0;
	data_length = 1;
	
	outputs[| 0] = nodeValue(0, "Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, []);
	
	static refreshDynamicInput = function() {
		var _l = ds_list_create();
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(inputs[| i].value_from)
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
	
	static update = function() {
		var res = array_create(ds_list_size(inputs) - 1);
		
		for( var i = 0; i < ds_list_size(inputs) - 1; i++ ) {
			res[i] = inputs[| i].getValue();
			inputs[| i].type = inputs[| i].value_from? inputs[| i].value_from.type : VALUE_TYPE.any;
			
			if(i == 0)
				outputs[| 0].type = inputs[| i].value_from? inputs[| i].value_from.type : VALUE_TYPE.any;
		}
		
		outputs[| 0].setValue(res);
	}
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = input_fix_len; i < ds_list_size(_inputs); i += data_length)
			createNewInput();
	}
}