function Node_Array_Copy(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Copy";
	always_pad = true;
	setDimension(96, 48);
	
	////- =Array
	newInput( 0, nodeValue_Any( "Array",          0 )).setArrayDepth(1).setVisible(true, true);
	
	////- =Copy
	newInput( 1, nodeValue_Int( "Starting Index", 0 ));
	newInput( 2, nodeValue_Int( "Size",           1 ));
	// 3
	
	newOutput(0, nodeValue_Output("Array", VALUE_TYPE.any, 0)).setArrayDepth(1);
	
	input_display_list = [ 
		[ "Array", false ],  0,
		[ "Copy",  false ],  1,  2,  
	];
	
	////- Node
		
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _arr = getInputData(0);
			var _ind = getInputData(1);
			var _siz = getInputData(2);
			
			var _typ = inputs[0].getType();
			var isig = inputs[0].getTypeSignature();
			
			inputs[0].setType(_typ);
			inputs[0].setTypeSignature(isig);
			
			outputs[0].setType(_typ);
			
			if(!is_array(_arr)) return;
		#endregion
		
		var res = [];
		var sig = [];
		
		if(_siz < 0) _siz = array_length(_arr) + _siz;
		if(_ind < 0) _ind = array_length(_arr) + _ind;
		
		for( var i = 0; i < _siz; i++ ) {
			var ind = _ind + i;
			
			res[i] = array_safe_get_fast(_arr, ind, 0);
			sig[i] = array_safe_get_fast(isig, ind, VALUE_TYPE.float, isig);
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
		
		var _st = getInputData(1);
		var _sz = getInputData(2);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, $"{_st}...{_st + _sz - 1}");
	}
}