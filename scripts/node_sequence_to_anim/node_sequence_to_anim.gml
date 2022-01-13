function Node_create_Sequence_Anim(_x, _y) {
	var node = new Node_Sequence_Anim(_x, _y);
	ds_list_add(PANEL_GRAPH.nodes_list, node);
	return node;
}

function Node_Sequence_Anim(_x, _y) : Node(_x, _y) constructor {
	name = "Sequence to Anim";
	update_on_frame = true;
	
	inputs[| 0] = nodeValue(0, "Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	inputs[| 1] = nodeValue(1, "Speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1);
	
	outputs[| 0] = nodeValue(0, "Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, surface_create(1, 1));
	
	function update() {
		var seq = inputs[| 0].getValue();
		var spd = inputs[| 1].getValue();
		
		if(!is_array(seq)) {
			outputs[| 0].setValue(seq);
			return;
		}
		
		var frame = safe_mod(floor(ANIMATOR.current_frame / spd), array_length(seq));
		outputs[| 0].setValue(seq[frame]);
	}
}