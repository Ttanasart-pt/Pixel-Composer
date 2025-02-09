function Node_Array_Length(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Array Length";
	setDimension(96, 48);
	
	newInput(0, nodeValue("Array", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Size", self, VALUE_TYPE.integer, 0));
	
	static step = function() { #region
		inputs[0].setType(inputs[0].value_from == noone? VALUE_TYPE.any : inputs[0].value_from.type);
	} #endregion
	
	static update = function(frame = CURRENT_FRAME) { #region
		var _arr = getInputData(0);
		
		if(!is_array(_arr) || array_length(_arr) == 0) {
			outputs[0].setValue(0);
			return 0;
		}
		
		outputs[0].setValue(array_length(_arr));
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str	= string(outputs[0].getValue());
		
		var bbox = drawGetBbox(xx, yy, _s);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	} #endregion
}