function Node_Array_Split(_x, _y, _group = noone) : Node(_x, _y, _group) constructor { 
	name  = "Array Split";
	setDimension(96, 0);
	
	draw_padding = 4;
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, []))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("val 0", self, VALUE_TYPE.any, 0));
	
	attributes.output_amount = 1;
	
	io_pool = [];
	
	static update = function() {
		var _inp = getInputData(0);
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
		
		if(!is_array(_inp)) {
			attributes.output_amount = 0;
			return;
		}
		
		var amo = array_length(_inp);
		
		for (var i = 0; i < amo; i++) {
			if(i >= array_length(outputs)) {
				var _pl = array_safe_get(io_pool, i, 0);
				if(_pl == 0) _pl = nodeValue_Output($"val {i}", self, type, 0);
				
				newOutput(i, _pl);
				io_pool[i] = _pl;
			}
			
			outputs[i].setType(type);
			outputs[i].setValue(_inp[i]);
		}
		
		var _rem = array_length(outputs);
		for(var i = amo; i < _rem; i++) {
			var _to = outputs[i].getJunctionTo();
			
			for( var j = 0, m = array_length(_to); j < m; j++ ) 
				_to[j].removeFrom();
		}
		
		array_resize(outputs, amo);
		
		for (var i = 0, n = amo; i < n; i++) {
			outputs[i].index = i;
			outputs[i].setType(type);
			outputs[i].resetDisplay();
		}
		
		attributes.output_amount = amo;
	}
	
	static preApplyDeserialize = function() {
		if(!struct_has(attributes, "output_amount")) return;
		
		var _amo = attributes.output_amount;
		var _ind = 0;
		
		repeat(_amo) {
			var _pl = nodeValue_Output($"val {_ind}", self, VALUE_TYPE.any, 0);
			newOutput(_ind, _pl);
			io_pool[_ind] = _pl;
			_ind++;
		}
	}
} 