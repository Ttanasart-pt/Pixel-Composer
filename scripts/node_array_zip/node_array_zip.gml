function Node_Array_Zip(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Zip";
	previewable = false;
	
	w = 96;
	h = 32 + 24;
	min_h = h;
	
	inputs[| 0] = nodeValue("Array", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.output, VALUE_TYPE.integer, 0);
	
	setIsDynamicInput(1);
	
	static createNewInput = function() { #region
		var index = ds_list_size(inputs);
		
		inputs[| index] = nodeValue("Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, -1 )
			.setVisible(true, true);
		
		return inputs[| index];
	} if(!LOADING && !APPENDING) createNewInput(); #endregion
	
	static refreshDynamicInput = function() { #region
		var _l = ds_list_create();
		
		for( var i = 0; i < ds_list_size(inputs); i++ ) {
			if(i < input_fix_len || inputs[| i].value_from)
				ds_list_add(_l, inputs[| i]);
			else
				delete inputs[| i];	
		}
		
		for( var i = 0; i < ds_list_size(_l); i++ )
			_l[| i].index = i;
		
		ds_list_destroy(inputs);
		inputs = _l;
		
		createNewInput();
	} #endregion
	
	static onValueFromUpdate = function(index) { #region
		if(LOADING || APPENDING) return;
		
		refreshDynamicInput();
	} #endregion
	
	static step = function() { #region
		if(inputs[| 0].isLeaf()) {
			inputs[| 0].setType(VALUE_TYPE.any);
			outputs[| 0].setType(VALUE_TYPE.any);
		} else {
			inputs[| 0].setType(inputs[| 0].value_from.type);
			outputs[| 0].setType(inputs[| 0].value_from.type);
		}
		
		for( var i = 0; i < ds_list_size(inputs) - 1; i += data_length )
			inputs[| i].setType(inputs[| i].isLeaf()? VALUE_TYPE.any : inputs[| i].value_from.type);
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _arr = getInputData(0);
		
		if(!is_array(_arr)) return;
		var len = 1;
		var val = [];
		for( var i = 0; i < ds_list_size(inputs) - 1; i += data_length ) {
			val[i] = getInputData(i);
			
			if(!is_array(val[i])) {
				val[i] = [ val[i] ];
				continue;
			}
			len = max(len, array_length(val[i]));
		}
		
		var _out = array_create(len);
		
		for( var i = 0; i < len; i++ ) {
			for( var j = 0; j < ds_list_size(inputs) - 1; j += data_length )
				_out[i][j] = array_safe_get(val[j], i, 0);
		}
		
		outputs[| 0].setValue(_out);
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(s_node_array_zip, 0, bbox.xc, bbox.yc, bbox.w, bbox.h);
	} #endregion
}