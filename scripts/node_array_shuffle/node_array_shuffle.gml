function Node_Array_Shuffle(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Shuffle Array";
	setDimension(96, 48);
	setDrawIcon();
	
	newInput( 0, nodeValue_Any( "Array" )).setVisible(true, true);
	newInput( 1, nodeValueSeed()).rejectArray();
	// 2
	
	newOutput(0, nodeValue_Output("Shuffled array", VALUE_TYPE.any, []));
	
	input_display_list = [  1, 
		[ "Array", false ],  0,
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var arr = getInputData(0);
			var sed = getInputData(1);
			
			var type = inputs[0].getType();
			var isig = inputs[0].getTypeSignature();
			
			inputs[0].setType(type);
			inputs[0].setTypeSignature(isig);
			
			outputs[0].setType(type);
			
			if(!is_array(arr)) return;
		#endregion
		
		random_set_seed(sed);
		var len = array_length(arr);
		var ind = array_create_ext(len, function(i) /*=>*/ {return i});
		array_shuffle_ext(ind);
		
		var res = array_create(len);
		var sig = array_create(len);
		
		for( var i = 0; i < len; i++ ) {
			var si = ind[i];
			
			res[i] = arr[si];
			sig[i] = array_safe_get_fast(isig, si, VALUE_TYPE.float, isig);
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