function Node_Array_Shift(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Array Shift";
	setDimension(96, 48);
	setDrawIcon();
	
	////- =Array
	newInput( 0, nodeValue_Any(     "Array",    0 )).setArrayDepth(99).setVisible(true, true);
	
	////- =Shift
	newInput( 1, nodeValue_Int(     "Shift",    0 ));
	newInput( 2, nodeValue_EScroll( "Overflow", 0, [ "Wrap", "Zero", "Ignore" ]));
	// 3
	
	newOutput(0, nodeValue_Output("Array", VALUE_TYPE.any, 0));
	
	input_display_list = [ 
		[ "Array", false ],  0,
		[ "Shift", false ],  1,  2,  
	];
	
	////- Node
	
	static processData = function(_outSurf, _data, _array_index) {
		#region data
			var _arr = _data[0];
			var _shf = _data[1];
			var _ovf = _data[2];
			
			var type = inputs[0].getType();
			var isig = inputs[0].getTypeSignature();
			
			inputs[0].setType(type);
			inputs[0].setTypeSignature(isig);
			
			outputs[0].setType(type);
			
			if(!is_array(_arr)) return [];
		#endregion
		
		var len = array_length(_arr);
		
		var arr = [];
		var sig = [];
		
		switch(_ovf) {
			case 0 :
				for( var i = 0, n = len; i < n; i++ ) {
					var ind = pfract(i - _shf, len);
					arr[i] = array_safe_get_fast(_arr, ind);
					sig[i] = array_safe_get_fast(isig, ind, VALUE_TYPE.float, isig);
				}
				break;
					
			case 1 :
				for( var i = 0, n = len; i < n; i++ ) {
					var ind = i - _shf;
					
					arr[i] = array_safe_get_fast(_arr, ind, 0);
					sig[i] = array_safe_get_fast(isig, ind, VALUE_TYPE.float, isig);
				}
				break;
					
			case 2 :
				for( var i = 0, n = len; i < n; i++ ) {
					var ind = i - _shf;
					if(ind < 0 || ind >= len) continue;
					
					array_push(arr, array_safe_get_fast(_arr, ind));
					array_push(sig, array_safe_get_fast(isig, ind, VALUE_TYPE.float, isig));
				}
				break;
		}
		
		outputs[0].setTypeSignature(sig);
		return arr;
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