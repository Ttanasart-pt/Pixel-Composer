function Node_Array_Split(_x, _y, _group = noone) : Node(_x, _y, _group) constructor { 
	name  = "Array Split";
	setDimension(96, 0);
	
	newInput(0, nodeValue_Any( "Array", [])).setVisible(true, true);
	newInput(1, nodeValue_Int( "Minimum Outputs", 0 ));
	
	newOutput(0, nodeValue_Output("val 0", VALUE_TYPE.any, 0));
	
	////- Nodes
	
	attributes.output_amount = 1;
	io_pool = [];
	
	static update = function() {
		var _inp = getInputData(0);
		var _min = getInputData(1);
		
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
		
		var iamo = max(_min, array_safe_length(_inp));
		var oamo = array_length(outputs);
		attributes.output_amount = iamo;
		
		if(iamo == 0) return;
		if(iamo == oamo) {
			for (var i = 0; i < iamo; i++) {
				if(outputs[i].type != type) {
					outputs[i].setType(type);
					outputs[i].resetDisplay();
				}
				
				outputs[i].setValue(array_safe_get(_inp, i, 0));
			}
			return;
		}
		
		for (var i = 0; i < iamo; i++) {
			if(i >= oamo) {
				var _pl = array_safe_get(io_pool, i, 0);
				if(_pl == 0) _pl = nodeValue_Output($"val {i}", type, 0);
					
				newOutput(i, _pl);
				io_pool[i] = _pl;
			}
			
			outputs[i].index = i;
			if(outputs[i].type != type) {
				outputs[i].setType(type);
				outputs[i].resetDisplay();
			}
			
			outputs[i].setValue(array_safe_get(_inp, i, 0));
		}
		
		for(var i = iamo; i < oamo; i++) {
			var _to = outputs[i].getJunctionTo();
			for( var j = 0, m = array_length(_to); j < m; j++ ) 
				_to[j].removeFrom();
		}
		
		array_resize(outputs, iamo);
		__preDraw_data.force = true;
	}
	
	static preApplyDeserialize = function() {
		if(!struct_has(attributes, "output_amount")) return;
		
		var _amo = attributes.output_amount;
		var _ind = 0;
		
		repeat(_amo) {
			var _pl = nodeValue_Output($"val {_ind}", VALUE_TYPE.any, 0);
			newOutput(_ind, _pl);
			io_pool[_ind] = _pl;
			_ind++;
		}
	}
} 