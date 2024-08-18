function Node_Group_Thumbnail(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Thumbnail";
	destroy_when_upgroup = true;
	color = COLORS.node_blend_collection;
	
	newInput(0, nodeValue_Surface("Input", self))
		.setVisible(true, true);
	
	outputs[0] = nodeValue_Surface("Output", self)
		.setVisible(false, false);
		
	static getGraphPreviewSurface = function() { #region
		return getInputData(0);
	} #endregion
}