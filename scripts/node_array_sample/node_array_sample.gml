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
	
	newInput(6, nodeValue_Int("Dimension", self, 0))
	
	newInput(7, nodeValue_Enum_Scroll("Amount Type", self, 0, [ "Input Range", "Custom" ]))
	
	newOutput(0, nodeValue_Output("Array", self, VALUE_TYPE.any, 0))
		.setArrayDepth(1);
		
	input_display_list = [ 0, 4, 
		["Sampling", false], 2, 6, 1, 3, 
		["Amount",   false], 7, 5, 
	];
	
	static sample = function(_arr) {
		__temp_arr = _arr;
		
		var _mod    = getInputData(2);
		var _amoTyp = getInputData(7);
		var _amoCus = getInputData(5);
		var _len    = array_length(_arr);
			
		if(_mod == 0) { 
			
			var _stp = getInputData(1);
			var _shf = getInputData(3);
			    _shf = safe_mod(_shf, _stp);
			
			var _res = [];
			var _ind = 0;
			
			if(_amoTyp == 0) {
				for( var i = _shf; i < _len; i += _stp )
					_res[_ind++] = _arr[i]; 
					
			} else if(_amoTyp == 1) {
				repeat(_amoCus) {
					_res[_ind++] = _arr[_shf]; 
					_shf = safe_mod(_shf + _stp, _len);
				}
			}
			
			return _res;
			
		} else if(_mod == 1) {
			
			var _sed = getInputData(4);
			var _amo = _amoTyp == 1? _amoCus : _len;
			var _res = array_create(_amo);
			
			random_set_seed(_sed);
			for( var i = 0; i < _amo; i++ )
				_res[i] = _arr[irandom(_len - 1)];
			
			return _res;
		}
		
		return [];
	}
	
	static sampleArray = function(_arr, _dim = 0) {
		if(_dim <= 0) return sample(_arr);
		
		var _res = [];
		for( var i = 0, n = array_length(_arr); i < n; i++ )
			_res[i] = sampleArray(_arr[i], _dim - 1);
		return _res;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
		outputs[0].setType(type);
		
		var _arr = getInputData(0);
		var _mod = getInputData(2);
		var _dim = getInputData(6);
		var _amt = getInputData(7);
		
		inputs[1].setVisible(_mod == 0);
		inputs[3].setVisible(_mod == 0);
		inputs[5].setVisible(_amt == 1);
		
		var _d = array_get_depth(_arr);
		if(_d == 0) return;
		
		var _res = sampleArray(_arr, _dim);
		outputs[0].setValue(_res);
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
		
		draw_sprite_fit(s_node_array_sample, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}