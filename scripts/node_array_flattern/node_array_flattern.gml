function Node_Array_Flattern(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Flatten";
	setDimension(96, 48);
	setDrawIcon();
	
	////- =Array
	newInput( 0, nodeValue_Any( "Array in" )).setVisible(true, true);
	
	////- =Flatten
	newInput( 1, nodeValue_Int( "Depth", 0 ));
	// 2
	
	newOutput(0, nodeValue_Output("Flattened Array", VALUE_TYPE.any, []));
	
	input_display_list = [ 
		[ "Array",   false ],  0,
		[ "Flatten", false ],  1,
	];
	
	////- Node
	
	function __array_spread(arr, _arr = [], isig = [], osig = [], _minDepth = 0) {
		if(array_get_depth(arr) == _minDepth) { 
			array_push(_arr, arr); 
			array_push(osig, isig); 
			return _arr;
		}
		
		for( var i = 0, n = array_safe_length(arr); i < n; i++ ) {
			var a = array_safe_get_fast( arr, i);
			var s = array_safe_get_fast(isig, i);
			__array_spread(a, _arr, s, osig, _minDepth);
		}
			
		return _arr;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _arr = getInputData(0);
			var _dep = getInputData(1);
			
			var type = inputs[0].getType();
			var isig = inputs[0].getTypeSignature();
			
			inputs[0].setType(type);
			inputs[0].setTypeSignature(isig);
			
			outputs[0].setType(type);
			
			if(!is_array(_arr)) return;
		#endregion
		
		var _arrOut = [];
		var _sigOut = [];
		var _arrSpr = __array_spread(_arr, _arrOut, isig, _sigOut, _dep);
		
		outputs[0].setTypeSignature(_sigOut);
		outputs[0].setValue(_arrSpr);
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