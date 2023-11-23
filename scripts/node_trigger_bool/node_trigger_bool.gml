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
	
	doTrigger = 0;
	
	static step = function() {
		if(doTrigger == 1) {
			outputs[| 0].setValue(true);
			doTrigger = -1;
		} else if(doTrigger == -1) {
			outputs[| 0].setValue(false);
			doTrigger = 0;
		}
	}
	
	static update = function() {  
		var val = getInputData(0);
		var con = getInputData(1);
		
		switch(con) {
			case 0 : doTrigger = val;				break;
			case 1 : doTrigger = !prevVal &&  val;	break;
			case 2 : doTrigger =  prevVal && !val;	break;
			case 3 : doTrigger =  prevVal !=  val;	break;
		}
		
		preview = doTrigger;
		prevVal = val;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(THEME.node_trigger, preview, bbox.xc, bbox.yc, bbox.w, bbox.h, preview? COLORS._main_accent : COLORS._main_icon);
	}
}
