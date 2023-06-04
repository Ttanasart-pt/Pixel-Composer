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
		.setDisplay(VALUE_DISPLAY.button, [ function() { onInspector2Update(); }, "Trigger"]);
	
	outputs[| 0] = nodeValue("Trigger", self, JUNCTION_CONNECT.output, VALUE_TYPE.trigger, false);
	
	insp2UpdateTooltip   = "Trigger";
	insp2UpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	doTrigger = false;
	
	static onInspector2Update = function() {
		inputs[| 0].setAnim(true);
		inputs[| 0].setValue(true);
	}
	
	function step() {
		if(doTrigger) {
			outputs[| 0].setValue(true);
			doTrigger = false;
		} else
			outputs[| 0].setValue(false);
	}
	
	function update() {
		var trg = inputs[| 0].getValue();
		if(trg) doTrigger = true;
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		var bbox = drawGetBbox(xx, yy, _s);
		var trg  = outputs[| 0].getValue();
		
		draw_sprite_fit(THEME.node_trigger, trg, bbox.xc, bbox.yc, bbox.w, bbox.h, trg? COLORS._main_accent : COLORS._main_icon);
	}
}
