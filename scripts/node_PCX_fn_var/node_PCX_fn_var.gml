function Node_PCX_fn_var(_x, _y, _group = noone) : Node_PCX(_x, _y, _group) constructor {
	name = "Fn Variable";
	w    = 64;
	
	inputs[| 0] = nodeValue("Default Value", self, JUNCTION_CONNECT.input, VALUE_TYPE.any, 0);
	
	outputs[| 0] = nodeValue("PCX", self, JUNCTION_CONNECT.output, VALUE_TYPE.PCXnode, noone);
	
	static update = function() {
		var _def  = inputs[| 0].getValue();
		
		outputs[| 0].setValue(new __funcTree("≔", display_name, _def));
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		
		draw_set_text(f_h5, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, display_name);
	}
}