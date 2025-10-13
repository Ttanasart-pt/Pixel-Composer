function Node_Array_Get(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Get";
	setDimension(96, 48);
	
	newInput(0, nodeValue_Any(     "Array",    0 )).setVisible(true, true);
	newInput(1, nodeValue_Int(     "Index",    0 ));
	newInput(2, nodeValue_EScroll( "Overflow", 0, [ "Clamp", "Loop", "Ping Pong" ] )).rejectArray();
	
	newOutput(0, nodeValue_Output("Value", VALUE_TYPE.any, 0));
	
	static getArray = function(_arr, index, _ovf) {
		if(!is_array(_arr)) return;
		if(is_array(index)) return;
		
		var _len  = array_length(_arr);
		
		switch(_ovf) {
			case 0 :
				if(index < 0) index = _len + index;
				index = clamp(index, 0, _len - 1);
				break;
				
			case 1 :
				index = safe_mod(index, _len);
				if(index < 0) index = _len + index;
				break;
				
			case 2 :
				var _pplen = (_len - 1) * 2;
				index = safe_mod(abs(index), _pplen);
				if(index >= _len) 
					index = _pplen - index;
				break;
		}
		
		return array_safe_get_fast(_arr, index);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[0].setType(type);
		outputs[0].setType(type);
		
		var _arr  = getInputData(0);
		var index = getInputData(1);
		var _ovf  = getInputData(2);
		if(!is_array(_arr)) return;
		
		var res = is_array(index)? array_create(array_length(index)) : 0;
		
		if(is_array(index)) {
			for( var i = 0, n = array_length(index); i < n; i++ )
				res[i] = getArray(_arr, index[i], _ovf);
		} else 
			res = getArray(_arr, index, _ovf);
		
		outputs[0].setValue(res);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
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