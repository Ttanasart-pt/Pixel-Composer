function Node_Trigger(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Trigger";
	update_on_frame = true;
	setDimension(96, 32 + 24 * 1);
	
	inputs[| 0] = nodeValue("Trigger", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, false )
		.setDisplay(VALUE_DISPLAY.button, { name: "Trigger" });
	
	outputs[| 0] = nodeValue("Trigger", self, JUNCTION_CONNECT.output, VALUE_TYPE.trigger, false );
	
	insp2UpdateTooltip   = "Trigger";
	insp2UpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	static onInspector2Update = function() { inputs[| 0].setAnim(true); inputs[| 0].setValue(true); }
	
	static update = function() { 
		var _val = inputs[| 0].getValue();
		
		//print($"{CURRENT_FRAME}: {ds_list_to_array(inputs[| 0].animator.values)} | {inputs[| 0].animator.getValue(CURRENT_FRAME)}");
		
		outputs[| 0].setValue(_val);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) { #region
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var bbox = drawGetBbox(xx, yy, _s);
		var trg  = outputs[| 0].getValue();
		
		var cc = trg? COLORS._main_accent : COLORS._main_icon;
		var rr = min(bbox.w, bbox.h) / 2 - 6;
		
		draw_set_color(cc);
		
		draw_set_circle_precision(32);
		draw_circle_border(bbox.xc, bbox.yc, rr, 4);
		
		draw_set_circle_precision(32);
		if(trg) draw_circle(bbox.xc - 1, bbox.yc - 1, rr - 6, false);
	} #endregion
}
