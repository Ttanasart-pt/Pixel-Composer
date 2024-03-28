function Node_Print(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Print";
	setDimension(96, 32 + 24 * 1); 
	
	draw_padding = 8;
	
	inputs[| 0] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 1] = nodeValue("Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	static update = function() { 
		var act = getInputData(0);
		var txt = getInputData(1);
		
		if(act) noti_status(txt);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var txt  = getInputData(1);
		
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, txt);
	}
}