function Node_Argument(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Argument";
	setDimension(96, 32 + 24 * 1);
	
	draw_padding = 8;
	
	newInput(0, nodeValue_Text("Tag", self, ""));
	
	newInput(1, nodeValue_Enum_Scroll("Type", self, 0, [ "String", "Number" ]));
	
	newInput(2, nodeValue_Text("Default value", self, ""));
	
	outputs[0] = nodeValue_Output("Value", self, VALUE_TYPE.text, "");
	
	static step = function() { #region
		var typ = getInputData(1);
		
		switch(typ) {
			case 0 : 
				inputs[2].setType(VALUE_TYPE.text);  
				outputs[0].setType(VALUE_TYPE.text);  
				break;
			case 1 : 
				inputs[2].setType(VALUE_TYPE.float);  
				outputs[0].setType(VALUE_TYPE.float); 
				break;
		}
	} #endregion
	
	static update = function() { #region
		var tag = getInputData(0);
		var typ = getInputData(1);
		var def = getInputData(2);
		var val = struct_try_get(PROGRAM_ARGUMENTS, tag, def);
		
		switch(typ) {
			case 0 : outputs[0].setValue(val);			break;
			case 1 : outputs[0].setValue(toNumber(val));	break;
		}
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		var tag  = getInputData(0);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, $"--{tag}");
	} #endregion
}