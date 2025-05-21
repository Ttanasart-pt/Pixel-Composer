function Node_Array_Convolute(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Convolute";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Float("Array", []))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newInput(1, nodeValue_Float("Kernel", []))
		.setArrayDepth(1)
		.setVisible(true, true);
	
	newInput(2, nodeValue_Enum_Scroll("Boundary", 0, [ "Zero", "Wrap", "Skip" ]))
		.setArrayDepth(1);
	
	newOutput(0, nodeValue_Output("Array", VALUE_TYPE.float, 0))
		.setArrayDepth(1);
		
	static convolute = function(arr, ker) {
		var _bnd = getInputData(2);
		
		var _len = array_length(ker);
		var _arn = array_length(arr);
		var _st  = floor((_len - 1) / 2);
		var r, _a;
		
		if(_bnd == 2) {
			var _ll = _arn - _len + 1;
			_a = array_create(_ll);
			
			for(var i = 0; i < _ll; i++ ) {
				r = 0;
				
				for(var j = 0; j < _len; j++) {
					var _ind = i + j;
					if(_ind < 0 || _ind >= _arn) continue;
					
					r += arr[_ind] * ker[j];
				}
				
				_a[i] = r;
			}
			
		} else {
			_a = array_create(_arn);
			
			for( var i = 0; i < _arn; i++ ) {
				r = 0;
				
				for(var j = 0; j < _len; j++) {
					var _ind = i + j - _st;
					if(_ind < 0 || _ind >= _arn) {
						if(_bnd == 0) continue;
						_ind = safe_mod(_ind + _arn, _arn);
					}
					
					r += arr[_ind] * ker[j];
				}
				
				_a[i] = r;
			}
		}
		
		return _a;
	}
		
	static update = function(frame = CURRENT_FRAME) {
		var _arr = getInputData(0);
		var _ker = getInputData(1);
		
		if(!is_array(_arr) || !is_array(_ker))     return;
		if(array_empty(_arr) || array_empty(_ker)) return;
		
		var res;
		
		if(is_array(_arr[0])) {
			for( var i = 0, n = array_length(_arr); i < n; i++ ) 
				res[i] = convolute(_arr[i], _ker);
		} else 
			res = convolute(_arr, _ker);
			
		outputs[0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_convolute, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}