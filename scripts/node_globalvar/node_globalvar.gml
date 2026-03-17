function Node_Globalvar(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Globalvar";
	color = COLORS._main_accent;
	always_pad = true;
	setDimension(96, 48);
	
	newInput(0, nodeValue_Text("Globalvar"));
	
	newOutput(0, nodeValue_Output("Value", VALUE_TYPE.any, noone));
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static update = function() {
		var _key = inputs[0].getValue();
		
		var _globalInput = project.globalNode.getInputKey(_key);
		if(_globalInput == noone) return;
		
		var val = _globalInput.getValue();
		outputs[0].setType(_globalInput.type);
		outputs[0].setDisplay(_globalInput.display_type);
		outputs[0].setValue(val);
	}
	
	static onDrawNode = function(xx, yy, _mx, _my, _s, _hover, _focus) {
		var str  = getInputData(0);
		var bbox = draw_bbox;
		
		draw_set_text(f_sdf, fa_center, fa_center, COLORS._main_text);
		draw_text_bbox(bbox, str);
	}
}
