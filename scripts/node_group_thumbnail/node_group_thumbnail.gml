function Node_Group_Thumbnail(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Thumbnail";
	destroy_when_upgroup = true;
	color = COLORS.node_blend_collection;
	
	inputs[| 0] = nodeValue("Input", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(true, true);
	
	outputs[| 0] = nodeValue("Output", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, noone)
		.setVisible(false, false);
		
	static getGraphPreviewSurface = function() { #region
		return getInputData(0);
	} #endregion
}