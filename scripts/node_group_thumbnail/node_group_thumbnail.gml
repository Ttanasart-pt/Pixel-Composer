function Node_Group_Thumbnail(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Thumbnail";
	destroy_when_upgroup = true;
	color = COLORS.node_blend_collection;
	
	newInput(0, nodeValue_Surface("Input")).setVisible(true, true);
	
	newOutput(0, nodeValue_Output("Out", VALUE_TYPE.surface, noone)).setVisible(false, false);
		
	static update = function() {
		var _val = getInputData(0);
		group.thumbnail = _val;
		outputs[0].setValue(_val);
	}
}