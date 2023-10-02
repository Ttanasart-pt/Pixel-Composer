function Node_Trigger(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Trigger";
	previewable   = false;
	update_on_frame = true;
	
	w = 96;
	min_h = 32 + 24 * 1;
	
	inputs[| 0] = nodeValue("Trigger", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, false)
		.setVisible(false, false);
	
	inputs[| 1] = nodeValue("Trigger", self, JUNCTION_CONNECT.input, VALUE_TYPE.trigger, false)
		.setVisible(true, true)
		.setDisplay(VALUE_DISPLAY.button, { name: "Trigger", onClick: function() { onInspector2Update(); } });
	
	outputs[| 0] = nodeValue("Trigger", self, JUNCTION_CONNECT.output, VALUE_TYPE.trigger, false);
	
	insp2UpdateTooltip   = "Trigger";
	insp2UpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	doTrigger = 0;
	
	static onInspector2Update = function() {
		inputs[| 0].setAnim(true);
		inputs[| 0].setValue(true);
	}
	
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
		var trg = getInputData(0);
		if(trg) doTrigger = 1;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var bbox = drawGetBbox(xx, yy, _s);
		var trg  = outputs[| 0].getValue();
		
		var cc = trg? COLORS._main_accent : COLORS._main_icon;
		var rr = min(bbox.w, bbox.h) / 2 - 6;
		
		draw_set_color(cc);
		
		draw_set_circle_precision(32);
		draw_circle_border(bbox.xc, bbox.yc, rr, 4);
		
		draw_set_circle_precision(32);
		if(trg) draw_circle(bbox.xc, bbox.yc, rr - 6, false);
	}
}
