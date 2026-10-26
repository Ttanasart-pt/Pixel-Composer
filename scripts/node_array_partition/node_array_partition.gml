function Node_Array_Partition(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Partition";
	always_pad = true;
	setDimension(96, 48);
	
	////- =Array
	newInput( 0, nodeValue_Any( "Array" )).setArrayDepth(1).setVisible(true, true);
	
	////- =Partition
	newInput( 1, nodeValue_EScroll( "Type",   0, [ "Fix Length", "Fix Amount" ] ));
	newInput( 2, nodeValue_Int(     "Length", 1 ));
	// 3
	
	newOutput( 0, nodeValue_Output("Array", VALUE_TYPE.any, 0)).setArrayDepth(1);
	
	input_display_list = [
		[ "Array",     false ],  0, 
		[ "Partition", false ],  1,  2, 
	]
	
	////- Node
		
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _arr = getInputData( 0);
			
			var _typ = getInputData( 1);
			var _siz = getInputData( 2); _siz = max(_siz, 1);
			
			var _typ = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
			var isig = inputs[0].getTypeSignature();
			
			inputs[0].setType(_typ);
			inputs[0].setTypeSignature(isig);
			
			inputs[2].setName(_typ? "Amount" : "Length");
			
			outputs[0].setType(_typ);
			
			if(!is_array(_arr)) return;
		#endregion
		
		var res = [];
		var sig = [];
		var len = array_length(_arr);
		
		switch(_typ) {
			case 0 :
				var _amo = ceil(len / _siz);
				for( var i = 0; i < _amo; i++ ) {
					res[i] = [];
					sig[i] = [];
					
					array_copy(res[i], 0, _arr, i * _siz, _siz);
					for( var j = 0; j < _siz; j++ ) 
						sig[i][j] = is_array(isig)? array_safe_get_fast(isig, i * _siz + j) : isig;
				}
				break;
				
			case 1 :
				var _step = len / _siz;
				var _fsiz = 0, _fend;
				var _isiz = 0;
				var _cstp = floor(_step);
				
				for( var i = 0; i < _siz; i++ ) {
					res[i] = [];
					sig[i] = [];
					
					_fend  = _fsiz + _step;
					_cstp  = floor(_fend) - _isiz;
					array_copy(res[i], 0, _arr, _isiz, _cstp);
					
					for( var j = 0; j < _cstp; j++ ) 
						sig[i][j] = is_array(isig)? array_safe_get_fast(isig, _isiz + j) : isig;
						
					_fsiz  = _fend;
					_isiz += _cstp;
				}
				break;
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
		draw_text_bbox(bbox, $"{_sz}");
	}
}