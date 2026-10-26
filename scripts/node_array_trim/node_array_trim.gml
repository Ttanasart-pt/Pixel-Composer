function Node_Array_Trim(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Trim";
	always_pad = true;
	setDimension(96, 48);
	
	////- Array
	newInput( 0, nodeValue_Any( "Array"         )).setArrayDepth(1).setVisible(true, true);
	
	////- Trim
	newInput( 1, nodeValue_Int( "Trim Start", 0 ));
	newInput( 2, nodeValue_Int( "Trim End",   0 ));
	// 3
	
	newOutput( 0, nodeValue_Output("Array", VALUE_TYPE.any, 0)).setArrayDepth(1);
		
	input_display_list = [ 
		[ "Array", false ],  0,
		[ "Trim",  false ],  1,  2,  
	];
	
	////- Node
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _arr = getInputData(0);
			var _tst = getInputData(1);
			var _ted = getInputData(2);
			
			var _typ = inputs[0].getType();
			var isig = inputs[0].getTypeSignature();
			
			inputs[0].setType(_typ);
			inputs[0].setTypeSignature(isig);
			
			outputs[0].setType(_typ);
			
			if(!is_array(_arr)) return;
		#endregion
		
		_tst = max(0, _tst);
		_ted = max(0, _ted);
		
		var res = [];
		var sig = [];
		
		for( var i = _tst, n = array_length(_arr) - _ted; i < n; i++ ) {
			array_push(res, _arr[i]);
			array_push(sig, array_safe_get_fast(isig, i, VALUE_TYPE.float, isig));
		}
		
		outputs[0].setTypeSignature(sig);
		outputs[0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		if(bbox.h < 1) return;
		
		if(outputs[0].type == VALUE_TYPE.color) {
			var pal = outputs[0].getValue();
			if(array_empty(pal)) return;
			if(is_array(pal[0])) pal = pal[0];
			
			drawPaletteBBOX(pal, bbox);
			return;
		}
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, $"{getInputData(1)}..{getInputData(2)}");
	}
}