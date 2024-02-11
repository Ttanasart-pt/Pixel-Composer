function Node_Argument(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Argument";
	w     = 96;
	min_h = 32 + 24 * 1;
	
	draw_padding = 8;
	
	inputs[| 0] = nodeValue("Tag", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	inputs[| 1] = nodeValue("Type", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "String", "Number" ]);
	
	outputs[| 0] = nodeValue("Value", self, JUNCTION_CONNECT.output, VALUE_TYPE.text, "");
	
	static step = function() { 
		var typ = getInputData(1);
		
		switch(typ) {
			case 0 : outputs[| 0].setType(VALUE_TYPE.text);  break;
			case 1 : outputs[| 0].setType(VALUE_TYPE.float); break;
		}
	}
	
	static update = function() { 
		var tag = getInputData(0);
		var typ = getInputData(1);
		var val = struct_try_get(PROGRAM_ARGUMENTS, tag, "");
		
		switch(typ) {
			case 0 : outputs[| 0].setValue(val);			break;
			case 1 : outputs[| 0].setValue(toNumber(val));	break;
		}
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var tag  = getInputData(0);
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, $"-{tag}");
	}
}