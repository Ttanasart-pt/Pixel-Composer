function Node_Print(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name		= "Print";
	
	w = 96;
	min_h = 32 + 24 * 1;
	draw_padding = 8;
	
	inputs[| 0] = nodeValue("Active", self, JUNCTION_CONNECT.input, VALUE_TYPE.boolean, true);
	
	inputs[| 1] = nodeValue("Text", self, JUNCTION_CONNECT.input, VALUE_TYPE.text, "");
	
	//inputs[| 2] = nodeValue("Icon", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone);
	
	static update = function() { 
		var act = inputs[| 0].getValue();
		var txt = inputs[| 1].getValue();
		
		if(act) noti_status(txt);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		var txt  = inputs[| 1].getValue();
		
		draw_set_text(f_p0, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, txt);
	}
}