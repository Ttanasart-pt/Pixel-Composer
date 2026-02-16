function Node_To_Text(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "To Text";
	always_pad = true;
	setDimension(96, 48);
	
	newInput( 0, nodeValue("Value", self, CONNECT_TYPE.input, VALUE_TYPE.any, 0)).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Text", VALUE_TYPE.text, ""));
	
	input_display_list = [ 0 ];
	
	////- Node
	
	static processData = function(_output, _data, _array_index = 0, _frame = CURRENT_FRAME) {  
		return string(_data[0]);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		var str  = outputs[0].getValue();
		var bbox = draw_bbox;
		draw_text_bbox(bbox, str);
	}
}