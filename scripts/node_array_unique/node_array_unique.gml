function Node_Array_Unique(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Unique";
	setDimension(96, 48);
	setDrawIcon();
	
	////- Array
	newInput( 0, nodeValue_Any( "Array" )).setVisible(true, true);
	// 1
	
	newOutput( 0, nodeValue_Output("Unique Array", VALUE_TYPE.any, []));
	
	input_display_list = [ 
		[ "Array", false ],  0,
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var arr = getInputData(0);
			
			var type = inputs[0].getType();
			var isig = inputs[0].getTypeSignature();
			
			inputs[0].setType(type);
			inputs[0].setTypeSignature(isig);
			
			outputs[0].setType(type);
			
			if(!is_array(arr)) return;
		#endregion
		
		var len = array_length(arr);
		var map = {};
		var sig = [];
		var res = [];
		
		for( var i = 0; i < len; i++ ) {
			var a = arr[i];
			if(has(map, a)) continue;
			
			array_push(res, a);
			array_push(sig, array_safe_get_fast(isig, i, VALUE_TYPE.float, isig));
			
			map[$ a] = 1;
		}
		
		outputs[0].setTypeSignature(sig);
		outputs[0].setValue(res);
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