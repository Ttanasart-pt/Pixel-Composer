function Node_Argument(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Argument";
	w     = 96;
	min_h = 32 + 24 * 1;
	
	draw_padding = 8;
	
	inputs[| 0] = nodeValue("Tag", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	inputs[| 1] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "String", "Number" ]);
	
	inputs[| 2] = nodeValue("Default value", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	outputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	static step = function() { #region
		var typ = getInputData(1);
		
		switch(typ) {
			case 0 : 
				inputs[| 2].setType(VALUE_TYPE.text);  
				outputs[| 0].setType(VALUE_TYPE.text);  
				break;
			case 1 : 
				inputs[| 2].setType(VALUE_TYPE.float);  
				outputs[| 0].setType(VALUE_TYPE.float); 
				break;
		}
	} #endregion
	
	static update = function() { #region
		var tag = getInputData(0);
		var typ = getInputData(1);
		var def = getInputData(2);
		var val = struct_try_get(PROGRAM_ARGUMENTS, tag, def);
		
		switch(typ) {
			case 0 : outputs[| 0].setValue(val);			break;
			case 1 : outputs[| 0].setValue(toNumber(val));	break;
		}
	} #endregion
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		var bbox = drawGetBbox(xx, yy, _s);
		var tag  = getInputData(0);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, $"--{tag}");
	} #endregion
}