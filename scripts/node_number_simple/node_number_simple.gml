function Node_Number_Simple(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name     = "Number";
	color    = COLORS.node_blend_number;
	doUpdate = doUpdateLite;
	setDimension(96, 48);
	
	newInput( 0, nodeValue_Float( "Value", 0 )).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Number", VALUE_TYPE.float, 0));
	
	input_display_list = [ 0 ];
	
	////- Node
	
	static update = function() {
		outputs[0].setValue(inputs[0].getValue());
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var bbox = drawGetBbox(xx, yy, _s);
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, string(outputs[0].getValue()));
	}
	
}