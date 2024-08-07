function Node_Array_Split(_x, _y, _group = noone) : Node(_x, _y, _group) constructor { 
	name  = "Array Split";
	setDimension(96, 0);
	
	draw_padding = 4;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, [])
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue_Output("val 0", self, VALUE_TYPE.any, 0);
	
	attributes.output_amount = 1;
	
	static update = function() {
		var _inp = getInputData(0);
		var type = inputs[| 0].value_from == noone? VALUE_TYPE.any : inputs[| 0].value_from.type;
		inputs[| 0].setType(type);
		inputs[| 0].resetDisplay();
		
		if(!is_array(_inp)) {
			ds_list_clear(outputs);
			attributes.output_amount = 0;
			return;
		}
		
		var amo = array_length(_inp);
		
		for (var i = 0; i < amo; i++) {
			if(i >= ds_list_size(outputs))
				outputs[| i] = nodeValue_Output($"val {i}", self, type, 0)
			
			outputs[| i].setValue(_inp[i]);
		}
		
		while(ds_list_size(outputs) > amo)
			ds_list_delete(outputs, ds_list_size(outputs) - 1);
		
		for (var i = 0, n = amo; i < n; i++) {
			outputs[| i].setType(type);
			outputs[| i].resetDisplay();
		}
		
		attributes.output_amount = amo;
	}
	
	static preApplyDeserialize = function() {
		if(!struct_has(attributes, "output_amount")) return;
		
		var _outAmo = attributes.output_amount;
		var _ind = 0;
		
		ds_list_clear(outputs);
		repeat(_outAmo) {
			ds_list_add(outputs, nodeValue_Output($"val {_ind}", self, VALUE_TYPE.any, 0));
			_ind++;
		}
	}
} 