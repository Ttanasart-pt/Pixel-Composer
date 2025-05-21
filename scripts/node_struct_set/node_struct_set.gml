function Node_Struct_Set(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Struct Set";
	
	setDimension(96, 48);
	
	newInput(0, nodeValue_Struct("Struct"))
		.setVisible(true, true);
	
	newInput(1, nodeValue_Text("Key"));
	
	newInput(2, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0))
		.setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Struct", VALUE_TYPE.struct, {}));
	
	static update = function() { 
		var str = getInputData(0);
		var key = getInputData(1);
		var val = getInputData(2);
		
		var _str = variable_clone(str, 1);
		if(key != "") _str[$ key] = val;
		
		inputs[2].setType(inputs[2].value_from == noone? VALUE_TYPE.any : inputs[2].value_from.type);
		outputs[0].setValue(_str)
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var str  = getInputData(1);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var ss	= string_scale(str, bbox.w, bbox.h);
		draw_text_transformed(bbox.xc, bbox.yc, str, ss, ss, 0);
	}
}