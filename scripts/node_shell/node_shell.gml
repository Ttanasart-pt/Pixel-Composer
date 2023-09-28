function Node_Shell(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Execute Shell";
	
	w = 96;
	min_h = 32 + 24 * 1;
	draw_padding = 8;
	
	inputs[| 0] = nodeValue("Path", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	inputs[| 1] = nodeValue("Script", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	insp1UpdateTooltip   = "Run";
	insp1UpdateIcon      = [ THEME.sequence_control, 1, COLORS._main_value_positive ];
	
	static onInspector1Update = function() { update(); }
	
	static update = function() { 
		var _pro = inputs[| 0].getValue();
		var _scr = inputs[| 1].getValue();
		if(_pro == "") return;
		
		shell_execute(_pro, _scr);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var txt  = inputs[| 0].getValue();
		
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, txt);
	}
}