function Node_Array_Get(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Get";
	always_pad = true;
	setDimension(96, 48);
	
	////- =Array
	newInput( 0, nodeValue_Any(     "Array",    0 )).setVisible(true, true);
	
	////- =Get
	newInput( 3, nodeValue_EScroll( "Mode",     0, [ "Index", "Random" ]            ));
	newInput( 1, nodeValue_Int(     "Index",    0                                   ));
	newInput( 2, nodeValue_EScroll( "Overflow", 0, [ "Clamp", "Loop", "Ping Pong" ] )).rejectArray();
	newInput( 4, nodeValueSeed());
	// 5
	
	newOutput(0, nodeValue_Output("Value", VALUE_TYPE.any, 0));
	
	input_display_list = [ 
		[ "Array", false ],  0, 
		[ "Get",   false ],  3,  1,  2,  4, 
	]
	
	////- Node
	
	static getArray = function(_arr, _ind, _ovf) {
		if(!is_array(_arr)) return 0;
		if(!is_real(_ind))  return 0;
		
		var _len  = array_length(_arr);
		
		switch(_ovf) {
			case 0 : 
				if(_ind < 0) _ind = _len + _ind;
				_ind = clamp(_ind, 0, _len - 1);
				break;
				
			case 1 :
				_ind = safe_mod(_ind, _len);
				if(_ind < 0) _ind = _len + _ind;
				break;
				
			case 2 :
				var _pplen = (_len - 1) * 2;
				_ind = safe_mod(abs(_ind), _pplen);
				if(_ind >= _len) 
					_ind = _pplen - _ind;
				break;
		}
		
		return _ind;
	}
	
	static update = function(frame = CURRENT_FRAME) {
		#region data
			var _arr = getInputData( 0);
			
			var _typ = getInputData( 3);
			var _ind = getInputData( 1);
			var _ovf = getInputData( 2);
			var _sed = getInputData( 4);
			
			var type = inputs[0].getType();
			var isig = inputs[0].getTypeSignature();
			
			inputs[0].setType(type);
			inputs[0].setTypeSignature(isig);
			
			inputs[ 1].setVisible(_typ == 0);
			inputs[ 2].setVisible(_typ == 0);
			inputs[ 4].setVisible(_typ == 1);
			
			outputs[0].setType(type);
			
			if(!is_array_safe(_arr)) return;
		#endregion
		
		var res = 0;
		var sig = array_clone(isig);
		
		if(_typ == 0) {
			if(is_array(_ind)) {
				res = array_create(array_length(_ind));
				for( var i = 0, n = array_length(_ind); i < n; i++ ) {
					var i = getArray(_arr, _ind[i], _ovf);
					res[i] = array_safe_get_fast(_arr, i);
					sig[i] = array_safe_get_fast(isig, i);
				}
				
			} else {
				var i = getArray(_arr, _ind, _ovf);
				res = array_safe_get_fast(_arr, i);
				sig = array_safe_get_fast(isig, i);
			}
				
		} else if(_typ == 1) {
			random_set_seed(_sed);
			var i = array_safe_get_random_index(_arr);
			
			sig = isig[i];
			res = _arr[i];
		}
		
		outputs[0].setTypeSignature(sig);
		outputs[0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var type = outputs[0].type;
		var show = true;
		
		if(type == VALUE_TYPE.color) {
			var pal = outputs[0].getValue();
			if(is_array(pal)) drawPaletteBBOX(pal, bbox);
			else              drawColorBBOX(pal, bbox);
			show = false;
			
		} else if(type == VALUE_TYPE.surface) {
			show = false;
		}
		
		if(show) {
			draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
			draw_text_bbox(bbox, string(getInputData(1)));
			
		} else {
			draw_set_text(f_sdf, fa_left, fa_bottom, COLORS._main_text_sub);
			draw_text_add(bbox.x0 + 6 * _s, bbox.y1, string(getInputData(1)), .25 * _s);
		}
		
	}
}