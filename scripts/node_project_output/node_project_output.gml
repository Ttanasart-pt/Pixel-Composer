function Node_Project_Output(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name = "Project Output";
	
	newInput(0, nodeValue_Surface("Surface In"));
	
	input_display_list = [ 0 ];
	
	////- Nodes
	
	static update = function() {
		project.outputNode = self;
	}
}