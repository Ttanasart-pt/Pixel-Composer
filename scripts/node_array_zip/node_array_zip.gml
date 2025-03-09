function Node_Array_Zip(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Zip";
	setDimension(96, 48);
	
	newInput(0, nodeValue_b("Spread Content", self, false));
	
	newOutput(0, nodeValue_Output("Output", self, VALUE_TYPE.integer, 0));
	
	static createNewInput = function() {
		var index = array_length(inputs);
		
		newInput(index, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, -1 ))
			.setVisible(true, true);
		
		return inputs[index];
	} setDynamicInput(1);
	
	static step = function() {
		var _typ = VALUE_TYPE.any;
		
		for( var i = 0; i < array_length(inputs); i += data_length ) {
			inputs[i].setType(inputs[i].value_from == noone? VALUE_TYPE.any : inputs[i].value_from.type);
			_typ = inputs[i].type;
		}
			
		outputs[0].setType(_typ);
	}
	
	static update = function(frame = CURRENT_FRAME) {
		var _spr = getInputData(0);
		var  amo = getInputAmount();
		if(amo == 0) return;
		
		var len = 1;
		var val = [];
		
		for( var i = 0; i < amo; i++ ) {
			val[i] = getInputData(input_fix_len + i);
			
			if(!is_array(val[i])) {
				val[i] = [ val[i] ];
				continue;
			}
			
			len = max(len, array_length(val[i]));
		}
		
		var _out = array_create(len);
		
		if(_spr) {
			for( var i = 0; i < len; i++ ) {
				_out[i] = [];
				
				for( var j = 0; j < amo; j++ )
					array_append(_out[i], array_safe_get_fast(val[j], i, 0));
			}
			
		} else {
			for( var i = 0; i < len; i++ ) {
				for( var j = 0; j < amo; j++ )
					_out[i][j] = array_safe_get_fast(val[j], i, 0);
			}
		}
		
		outputs[0].setValue(_out);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_zip, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	}
}