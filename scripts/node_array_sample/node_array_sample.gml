function Node_Array_Sample(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Sample";
	setDimension(96, 48);
	setDrawIcon();
	
	newInput( 0, nodeValue_Any( "Array" )).setVisible(true, true);
	newInput( 4, nodeValueSeed());
	
	////- =Sampling
	newInput( 2, nodeValue_EScroll( "Mode",      0, [ "Uniform", "Random" ] ));
	newInput( 6, nodeValue_Int(     "Dimension", 0 ));
	newInput( 1, nodeValue_Float(   "Step",      2 ));
	newInput( 3, nodeValue_Int(     "Shift",     0 ));
	
	////- =Amount
	newInput( 7, nodeValue_EScroll( "Amount Type", 0, [ "Input Range", "Custom" ] ));
	newInput( 5, nodeValue_Int(     "Amount",      4 ));
	// 8
	
	newOutput(0, nodeValue_Output("Array", VALUE_TYPE.any, 0))
		.setArrayDepth(1);
		
	input_display_list = [  0,  4, 
		[ "Sampling", false ],  2,  6,  1,  3, 
		[ "Amount",   false ],  7,  5, 
	];
	
	////- Node
	
	static sample = function(_arr, isig) {
		var _len = array_length(_arr);
		var _sig = [];
		var _res = [];
			
		if(__mod == 0) { 
			var _stp = __stp;
			var _shf = safe_mod(__shf, __stp);
			
			var _res = [];
			var _ind = 0;
			
			if(__amoTyp == 0) {
				for( var i = _shf; i < _len; i += _stp ) {
					_res[_ind] = _arr[i]; 
					_sig[_ind] = array_safe_get_fast(isig, i, VALUE_TYPE.float, isig);
					_ind++;
				}
					
			} else if(__amoTyp == 1) {
				repeat(__amoCus) {
					_res[_ind] = _arr[_shf]; 
					_sig[_ind] = array_safe_get_fast(isig, _shf, VALUE_TYPE.float, isig);
					_ind++;
					
					_shf = safe_mod(_shf + _stp, _len);
				}
			}
			
			return [_res,_sig];
			
		} else if(__mod == 1) {
			var _amo = __amoTyp == 1? __amoCus : _len;
			var _res = array_create(_amo);
			
			random_set_seed(__sed);
			for( var i = 0; i < _amo; i++ ) {
				var ind = irandom(_len - 1);
				_res[i] = _arr[ind];
				_sig[i] = array_safe_get_fast(isig, ind, VALUE_TYPE.float, isig);
			}
			
			return [_res,_sig];
		}
		
		return [_res,_sig];
	}
	
	static sampleArray = function(_arr, isig, _dim = 0) {
		if(_dim <= 0) return sample(_arr, isig);
		
		var _res = [];
		var _sig = [];
		
		for( var i = 0, n = array_length(_arr); i < n; i++ ) {
			var a = _arr[i];
			var s = array_safe_get_fast(isig, i, VALUE_TYPE.float, isig);
			
			var samp = sampleArray(a, s, _dim - 1);
			_res[i] = samp[0];
			_sig[i] = samp[1];
		}
			
		return [_res,_sig];
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			__sed = getInputData(4);
			
			__arr = getInputData(0);
			
			__mod = getInputData(2);
			__dim = getInputData(6);
			__stp = getInputData(1);
			__shf = getInputData(3);
			
			__amoTyp = getInputData(7);
			__amoCus = getInputData(5);
			
			var type = inputs[0].getType();
			var isig = inputs[0].getTypeSignature();
			
			inputs[0].setType(type);
			inputs[0].setTypeSignature(isig);
			
			outputs[0].setType(type);
			
			inputs[1].setVisible(__mod == 0);
			inputs[3].setVisible(__mod == 0);
			inputs[5].setVisible(__amoTyp == 1);
			
			var _d = array_get_depth(_arr);
			if(_d == 0) return;
		#endregion
		
		var _res = sampleArray(_arr, isig, _dim);
		
		outputs[0].setTypeSignature(_res[1]);
		outputs[0].setValue(_res[0]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		
		if(outputs[0].type == VALUE_TYPE.color) {
			var pal = outputs[0].getValue();
			if(array_empty(pal)) return;
			if(is_array(pal[0])) pal = pal[0];
			
			drawPaletteBBOX(pal, bbox);
			return;
		}
		
	}
}