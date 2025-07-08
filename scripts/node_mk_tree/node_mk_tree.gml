function Node_MK_Tree(_x, _y, _group = noone) : Node_Processor(_x, _y, _group) constructor {
	name = "MK Tree";
	
	newInput(0, nodeValueSeed());
	
	////- =Branches
	
	
	////- =Leaf
	
	
	newOutput(0, nodeValue_Output("Surface Out", VALUE_TYPE.surface, noone));
	
	input_display_list = [ new Inspector_Sprite(s_MKFX), 0, 
	
	];
	
	////- Nodes
	
	static drawOverlay = function(hover, active, _x, _y, _s, _mx, _my, _snx, _sny) {
		
	}
	
	static processData = function(_outSurf, _data, _array_index) {
		
	}
	
	
}