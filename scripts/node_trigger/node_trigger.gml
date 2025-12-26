function Node_Trigger(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Trigger";
	always_pad        = true;
	reactive_on_hover = true;
	setDimension(96, 56);
	
	newInput(0, nodeValue_Trigger("Trigger" ))
		.setDisplay(VALUE_DISPLAY.button, { name: "Trigger" });
	
	newOutput(0, nodeValue_Output("Trigger", VALUE_TYPE.trigger, false ));
	
	insp1button = button(function() /*=>*/ { inputs[0].setAnim(true); inputs[0].setValue(true); }).setTooltip(__txt("Trigger"))
		.setIcon(THEME.sequence_control, 1, COLORS._main_value_positive).iconPad(ui(6)).setBaseSprite(THEME.button_hide_fill);
	
	static update = function() { 
		var _val = inputs[0].getValue();
		outputs[0].setValue(_val);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = draw_bbox;
		var bx = bbox.x0 + 4 * _s; 
		var by = bbox.y0 + 4 * _s; 
		var bw = bbox.w  - 8 * _s;
		var bh = bbox.h  - 8 * _s;
		
		var _hov = _hover && !PANEL_GRAPH.node_dragging;
		var b = buttonInstant(THEME.button_def, bx, by, bw, bh, [_mx,_my], _hov, _focus)
		
		if(b) draggable = false;
		if(b == 2) {
			inputs[0].setAnim(true); 
			inputs[0].setValue(true);
		}
		
		var ts = .2 * _s;
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_transformed(bbox.xc, bbox.yc, __txt("Trigger"), ts, ts, 0);
	}
}
