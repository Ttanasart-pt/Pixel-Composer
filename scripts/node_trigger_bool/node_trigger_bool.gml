function Node_Trigger_Bool(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Boolean Trigger";
	previewable = false;
	update_on_frame = true;
	
	w = 96;
	min_h = 32 + 24 * 1;
	
	inputs[| 0] = nodeValue("Boolean", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 1] = nodeValue("Trigger condition", self, JUNCTION_CONNECT.input, VALUE_TYPE.integer, 0)
		.setDisplay(VALUE_DISPLAY.enum_scroll, [ "True frame", "False to True", "True to False", "Value changed" ]);
	
	outputs[| 0] = nodeValue("Trigger", self, JUNCTION_CONNECT.output, VALUE_TYPE.trigger, false);
	
	prevVal = false;
	preview = false;
	
	function update() {  
		var val = inputs[| 0].getValue();
		var con = inputs[| 1].getValue();
		
		switch(con) {
			case 0 : 
				outputs[| 0].setValue(val);			  
				preview = val;
				break;
			case 1 : 
				outputs[| 0].setValue(!prevVal &&  val); 
				preview = !prevVal && val;
				break;
			case 2 : 
				outputs[| 0].setValue( prevVal && !val); 
				preview = prevVal && !val;
				break;
			case 3 : 
				outputs[| 0].setValue( prevVal !=  val); 
				preview = prevVal != val;
				break;
		}
		
		prevVal = val;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(THEME.node_trigger, preview, bbox.xc, bbox.yc, bbox.w, bbox.h, preview? COLORS._main_accent : COLORS._main_icon);
	}
}
