function Node_Array_Insert(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Insert";
	always_pad = true;
	setDimension(96, 48);
	
	////- =Array
	newInput( 0, nodeValue_Any(  "Array"    )).setVisible(true, true);
	
	////- =Insert
	newInput( 1, nodeValue_Int(  "Index", 0 ));
	newInput( 2, nodeValue_Any(  "Value"    )).setVisible(true, true);
	newInput( 3, nodeValue_Bool( "Spread Array", false )).rejectArray();
	// 4
		
	newOutput( 0, nodeValue_Output("Array", VALUE_TYPE.any, 0));
	
	input_display_list = [ 
		[ "Array",  false ],  0, 
		[ "Insert", false ],  1,  2,  3,  
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _arr  = getInputData(0);
			var index = getInputData(1);
			var value = getInputData(2);
			var spred = getInputData(3);
			
			var type = inputs[0].getType();
			var isig = inputs[0].getTypeSignature();
			var nsig = inputs[2].getTypeSignature();
			
			inputs[0].setType(type);
			inputs[0].setTypeSignature(isig);
			
			inputs[2].setType(inputs[2].value_from == noone? type : inputs[2].value_from.type);
			inputs[2].setTypeSignature(nsig);
			
			outputs[0].setType(type);
			outputs[0].setTypeSignature(isig);
			
			if(!is_array(_arr)) return;
		#endregion
		
		var arr = array_clone(_arr);
		var sig = array_clone(isig);
		
		var len = array_length(arr);
		
		if(is_array(index)) {
			if(!is_array(value)) value = [ value ];
			for( var i = 0, n = array_length(index); i < n; i++ ) {
				var _pos = index[i];
				if(_pos < 0) _pos = len - 1 + _pos;
				
				array_insert(arr, _pos, array_safe_get(value, i,, ARRAY_OVERFLOW.loop));
				array_insert(sig, _pos, nsig);
			}
			
		} else {
			if(index < 0) index = len + index;
			
			if(is_array(value) && spred) {
				for( var i = 0, n = array_length(value); i < n; i++ ) {
					array_insert(arr, index + i, value[i]);
					array_insert(sig, index + i, array_safe_get(nsig, i, VALUE_TYPE.float, nsig));
				}
					
			} else {
				array_insert(arr, index, value);
				array_insert(sig, index, nsig);
			}
		}
		
		outputs[0].setTypeSignature(sig);
		outputs[0].setValue(arr);
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
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, string(getInputData(1)));
	}
}