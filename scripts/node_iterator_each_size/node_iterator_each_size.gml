function Node_Iterator_Each_Length(_x, _y, _group = noone) : Node(_x, _y, _group) constructor {
	name  = "Array Length";
	color = COLORS.node_blend_loop;
	destroy_when_upgroup = true;
	setDrawIcon(s_node_iterator_amount);
	setDimension(96, 48);
	
	newOutput(0, nodeValue_Output("Length", VALUE_TYPE.integer, 0));
	
	static update = function(frame = CURRENT_FRAME) { 
		if(!variable_struct_exists(group, "iterated")) return;
		var val = group.getInputData(0);
		outputs[0].setValue(array_length(val));
	}
	
	static onLoadGroup = function() {
		if(group == noone) destroy();
	}
}