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
	
	outputs[| 0] = nodeValue(0, "Array", self, JUNCTION_CONNECT.output, VALUE_TYPE.any, []);
	
	static updateValueFrom = function(index) {
		if(LOADING || APPENDING) return;
		
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
	
	static update = function() {
		var res = array_create(ds_list_size(inputs) - 1);
		
		for( var i = 0; i < ds_list_size(inputs) - 1; i++ ) {
			res[i] = inputs[| i].getValue();
		}
		
		outputs[| 0].setValue(res);
	}
	doUpdate();
	
	static postDeserialize = function() {
		var _inputs = load_map[? "inputs"];
		
		for(var i = 0; i < ds_list_size(_inputs); i++)
			createNewInput();
	}
}