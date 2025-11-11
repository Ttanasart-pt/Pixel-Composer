function Node_Trigger(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Trigger";
	setDimension(96, 56);
	
	newInput(0, nodeValue_Trigger("Trigger" ))
		.setDisplay(VALUE_DISPLAY.button, { name: "Trigger" });
	
	newOutput(0, nodeValue_Output("Trigger", VALUE_TYPE.trigger, false ));
	
	setTrigger(2, "Trigger", [ THEME.sequence_control, 1, COLORS._main_value_positive ]);
	
	static onInspector2Update = function() { inputs[0].setAnim(true); inputs[0].setValue(true); }
	
	static update = function() { 
		
		var _val = inputs[0].getValue();
		outputs[0].setValue(_val);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var bbox = draw_bbox;
		var trg  = outputs[0].getValue();
		
		var cc = trg? COLORS._main_accent : COLORS._main_icon;
		var rr = min(bbox.w, bbox.h) / 2 - 6;
		
		draw_set_color(cc);
		
		draw_set_circle_precision(32);
		draw_circle_border(bbox.xc, bbox.yc, rr, 4);
		
		draw_set_circle_precision(32);
		if(trg) draw_circle(bbox.xc - 1, bbox.yc - 1, rr - 6, false);
	} #endregion
}
