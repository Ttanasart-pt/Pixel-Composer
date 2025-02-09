function Node_Array_Sample(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Sample";
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Float("Step", self, 1));
	
	newInput(2, nodeValue_Enum_Scroll("Mode", self, 0, [ "Uniform", "Random" ]))
	
	newInput(3, nodeValue_Int("Shift", self, 0))
	
	newInput(4, nodeValueSeed(self));
	
	newInput(5, nodeValue_Int("Amount", self, 4))
	
	newOutput(0, nodeValue_Output("Array", self, VALUE_TYPE.any, 0))
		.setArrayDepth(1);
		
	input_display_list = [ 0, 2, 
		1, 3, 
		4, 5, 
	];
		
	static step = function() {
		inputs[0].setType(VALUE_TYPE.any);
		outputs[0].setType(VALUE_TYPE.any);
		
		if(inputs[0].value_from != noone) {
			inputs[0].setType(inputs[0].value_from.type);
			outputs[0].setType(inputs[0].type);
		}
	}
	
	static sample = function(arr) {
		__temp_arr = arr;
		
		var _mod = getInputData(2);
		var _len = array_length(arr);
			
		if(_mod == 0) { 
			
			var _stp = getInputData(1);
			var _shf = getInputData(3);
			    _shf = safe_mod(_shf, _stp);
			
			var _res = [];
			var _ind = 0;
			
			for( var i = _shf; i < _len; i += _stp )
				_res[_ind++] = arr[i]; 
			
			return _res;
			
		} else if(_mod == 1) {
			
			var _sed = getInputData(4);
			var _amo = getInputData(5);
			
			var _res = array_create(_amo);
			
			random_set_seed(_sed);
			for( var i = 0; i < _amo; i++ )
				_res[i] = arr[irandom(_len - 1)];
			
			return _res;
		}
		
		return [];
	}
		
	static update = function(frame = CURRENT_FRAME) {
		var _arr = getInputData(0);
		var _mod = getInputData(2);
		
		inputs[1].setVisible(_mod == 0);
		inputs[3].setVisible(_mod == 0);
		
		inputs[4].setVisible(_mod == 1);
		inputs[5].setVisible(_mod == 1);
		
		if(array_empty(_arr)) return;
		
		var res;
		
		if(is_array(_arr[0])) {
			for( var i = 0, n = array_length(_arr); i < n; i++ ) 
				res[i] = sample(_arr[i]);
		} else 
			res = sample(_arr);
		
		outputs[0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_sample, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}