function Node_Array_Shift(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "Array Shift";
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setArrayDepth(99)
		.setVisible(true, true);
		
	newInput(1, nodeValue_Int("Shift", self, 0));
	
	newInput(2, nodeValue_Enum_Scroll("Overflow", self, 0, [ "Wrap", "Zero", "Ignore" ]));
	
	newOutput(0, nodeValue_Output("Array", self, VALUE_TYPE.any, 0));
	
	static processData = function(_outSurf, _data, _array_index) {
		var type = inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type;
		inputs[ 0].setType(type);
		outputs[0].setType(type);
		
		var _arr = _data[0];
		var _shf = _data[1];
		var _ovf = _data[2];
		if(!is_array(_arr)) return [];
		
		var arr = [];
		var len = array_length(_arr);
		
		if(_ovf == 0) {
			for( var i = 0, n = len; i < n; i++ )
				arr[i] = array_safe_get(_arr, i - _shf,, ARRAY_OVERFLOW.loop);
				
		} else if(_ovf == 1) {
			for( var i = 0, n = len; i < n; i++ ) {
				var _i = i - _shf;
				arr[i] = array_safe_get(_arr, _i, 0);
			}
				
		} else if(_ovf == 2) {
			for( var i = 0, n = len; i < n; i++ ) {
				var _i = i - _shf;
				if(_i < 0 || _i >= len) continue;
				
				array_push(arr, array_safe_get(_arr, _i));
			}
		}
		
		return arr;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		if(outputs[0].type == VALUE_TYPE.color) {
			var pal = outputs[0].getValue();
			if(array_empty(pal)) return;
			if(is_array(pal[0])) pal = pal[0];
			
			drawPaletteBBOX(pal, bbox);
			return;
		}
		
		draw_sprite_fit(s_node_array_shift, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}