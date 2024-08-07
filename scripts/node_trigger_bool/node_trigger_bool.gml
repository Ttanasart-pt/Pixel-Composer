function Node_Trigger_Bool(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Boolean Trigger";
	update_on_frame = true;
	setDimension(96, 32 + 24 * 1);
	
	inputs[| 0] = nodeValue("Boolean", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, false);
	
	inputs[| 1] = nodeValue_Enum_Scroll("Trigger condition", self,  0, [ new scrollItem("True frame",    s_node_trigger_cond, 0), 
												 new scrollItem("False to True", s_node_trigger_cond, 1), 
												 new scrollItem("True to False", s_node_trigger_cond, 2), 
												 new scrollItem("Value changed", s_node_trigger_cond, 3), ]);
	
	outputs[| 0] = nodeValue("Trigger", self, JUNCTION_CONNECT.output, VALUE_TYPE.trigger, false);
	
	prevVal = false;
	preview = false;
	
	doTrigger = 0;
	
	static update = function() {  
		
		var val = getInputData(0);
		var con = getInputData(1);
		
		switch(con) {
			case 0 : doTrigger = val;				break;
			case 1 : doTrigger = !prevVal &&  val;	break;
			case 2 : doTrigger =  prevVal && !val;	break;
			case 3 : doTrigger =  prevVal !=  val;	break;
		}
		
		outputs[| 0].setValue(doTrigger);
		
		preview = doTrigger;
		prevVal = val;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var bbox = drawGetBbox(xx, yy, _s);
		draw_sprite_fit(THEME.node_trigger_icon, preview, bbox.xc, bbox.yc, bbox.w, bbox.h, preview? COLORS._main_accent : COLORS._main_icon);
	}
}
