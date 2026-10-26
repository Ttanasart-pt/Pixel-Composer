function Node_Array_Boolean_Opr(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Boolean Opr";
	always_pad = true;
	setDimension(96, 48);
	
	////- =Operator
	newInput( 2, nodeValue_EScroll( "Operation", 0, [ "Union", "Subtract", "Intersect", "XOR" ] ));
	
	////- =Arrays
	newInput( 0, nodeValue_Any( "Array 1" )).setVisible(true, true);
	newInput( 1, nodeValue_Any( "Array 2" )).setVisible(true, true);
	// 3
	
	newOutput(0, nodeValue_Output("Array out", VALUE_TYPE.any, []));
	
	input_display_list = [ 
		[ "Operator", false ],  2, 
		[ "Arrays",   false ],  0,  1 
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var opr  = getInputData(2);
			
			var arr1 = getInputData(0);
			var arr2 = getInputData(1);
			
			var type0 = inputs[0].getType();
			var isig0 = inputs[0].getTypeSignature();
			
			inputs[0].setType(type0);
			inputs[0].setTypeSignature(isig0);
			
			var type1 = inputs[1].getType();
			var isig1 = inputs[1].getTypeSignature();
			inputs[1].setType(type1);
			inputs[1].setTypeSignature(isig1);
			
			outputs[0].setType(type0);
			
			if(!is_array(arr1) || !is_array(arr2)) return;
		#endregion
		
		var arr = [];
		var sig = [];
		var map = {}
		
		switch(opr) {
		    case 0 : // Union
		    	for( var i = 0, n = array_length(arr1); i < n; i++ ) {
		    		var a = arr1[i];
		    		
		    		array_push(arr, a);
		    		array_push(sig, array_safe_get_fast(isig0, i, VALUE_TYPE.float, isig0));
		    		map[$ a] = 1;
		    	}
		    	
		    	for( var i = 0, n = array_length(arr2); i < n; i++ ) {
		    		var a = arr2[i];
		    		if(has(map, a)) continue;
		    		
		    		array_push(arr, a);
		    		array_push(sig, array_safe_get_fast(isig1, i, VALUE_TYPE.float, isig1));
		    		map[$ a] = 1;
		    	}
		    	break;
		    	
	        case 1 : // Subtract
	        	for( var i = 0, n = array_length(arr2); i < n; i++ )
		    		map[$ arr2[i]] = 1;
		    	
	        	for( var i = 0, n = array_length(arr1); i < n; i++ ) {
		    		var a = arr1[i];
		    		if(has(map, a)) continue;
		    		
		    		array_push(arr, a);
		    		array_push(sig, array_safe_get_fast(isig0, i, VALUE_TYPE.float, isig0));
		    	}
	        	break;
	        	
	        case 2 : // Intersect
	        	for( var i = 0, n = array_length(arr1); i < n; i++ )
		    		map[$ arr1[i]] = 1;
		    	
	        	for( var i = 0, n = array_length(arr2); i < n; i++ ) {
		    		var a = arr2[i];
		    		if(!has(map, a)) continue;
		    		
		    		array_push(arr, a);
		    		array_push(sig, array_safe_get_fast(isig1, i, VALUE_TYPE.float, isig1));
		    	}
	        	break;
	        	
	        case 3 : // XOR
	        	for( var i = 0, n = array_length(arr1); i < n; i++ )
		    		map[$ arr1[i]] = 1;
		    	
		    	for( var i = 0, n = array_length(arr2); i < n; i++ )
		    		map[$ arr2[i]] = (map[$ arr2[i]] ?? 0) | 0b10;
		    	
	        	for( var i = 0, n = array_length(arr1); i < n; i++ ) {
		    		var a = arr1[i];
		    		if(map[$ a] == 3) continue;
		    		
		    		array_push(arr, a);
		    		array_push(sig, array_safe_get_fast(isig0, i, VALUE_TYPE.float, isig0));
		    	}
		    	
	        	for( var i = 0, n = array_length(arr2); i < n; i++ ) {
		    		var a = arr2[i];
		    		if(map[$ a] == 0b11) continue;
		    		
		    		array_push(arr, a);
		    		array_push(sig, array_safe_get_fast(isig1, i, VALUE_TYPE.float, isig1));
		    	}
	        	break;
	        	
		}
		
		outputs[0].setTypeSignature(sig);
		outputs[0].setValue(arr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var opr  = getInputData(2);
		var str  = "";
		
		switch(opr) {
		    case 0 : str = "union"        break;
	        case 1 : str = "substract"    break;
	        case 2 : str = "intersection" break;
	        case 3 : str = "xor"          break;
		}
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}