function Node_Array_Sort(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Sort Array";
	setDimension(96, 48);
	setDrawIcon();
	
	////- =Array
	newInput( 0, nodeValue_Any( "Array" )).setTypeBitmask( 1 << VALUE_TYPE.float   | 
	                                                       1 << VALUE_TYPE.integer | 
	                                                       1 << VALUE_TYPE.color ).setVisible(true, true);
	
	////- =Sorting
	newInput( 1, nodeValue_EButton( "Order",  0, [ "Ascending", "Descending" ]  )).rejectArray();
	// 2
	
	newOutput( 0, nodeValue_Output("Sorted Array", VALUE_TYPE.any,     [] ));
	newOutput( 1, nodeValue_Output("Sorted Index", VALUE_TYPE.integer, [] )).setVisible(false);
	
	input_display_list = [ 
		[ "Array",   false ],  0,
		[ "Sorting", false ],  1,
	];
	
	////- Node
	
	sortable_types = [ VALUE_TYPE.float, VALUE_TYPE.integer, VALUE_TYPE.color, ]
	
	static sortAcs = function(v1, v2) { return v2.val - v1.val; }
	static sortDes = function(v1, v2) { return v1.val - v2.val; }
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var arr = getInputData(0);
			var asc = getInputData(1);
			
			var type = inputs[0].getType();
			var isig = inputs[0].getTypeSignature();

			if(!array_exists(sortable_types, type)) { 
				noti_warning($"Cannot sort {value_type_to_string(type)} data");
				return;
			}
			
			inputs[0].setType(type);
			inputs[0].setTypeSignature(isig);
			
			outputs[0].setType(type);
			
			if(!is_array(arr)) return;
		#endregion
		
		var len = array_length(arr);
		
		var _arr = array_map(arr, function(v, i) { return { index: i, val: v }; });
		array_sort(_arr, asc? sortAcs : sortDes);
		
		var resV = array_verify(outputs[0].getValue(), len);
		var resO = array_verify(outputs[1].getValue(), len);
		
		for( var i = 0; i < len; i++ ) {
			resV[i] = _arr[i].val;
			resO[i] = _arr[i].index;
		}
		
		var sig = array_create(len);
		for( var i = 0; i < len; i++ ) {
			var si = resO[i];
			sig[i] = array_safe_get_fast(isig, si, VALUE_TYPE.float, isig);
		}
		
		outputs[0].setTypeSignature(sig);
		outputs[0].setValue(resV);
		outputs[1].setValue(resO);
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