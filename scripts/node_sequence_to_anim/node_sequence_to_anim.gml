function Node_Sequence_Anim(_x, _y, _group = -1) : Node(_x, _y, _group) constructor {
	name = "Array to Anim";
	update_on_frame = true;
	
	inputs[| 0] = nodeValue("Surface in", self, JUNCTION_CONNECT.input, VALUE_TYPE.surface, 0);
	
	inputs[| 1] = nodeValue("Speed", self, JUNCTION_CONNECT.input, VALUE_TYPE.float, 1)
		.rejectArray();
	
	outputs[| 0] = nodeValue("Surface out", self, JUNCTION_CONNECT.output, VALUE_TYPE.surface, noone);
	
	static update = function(frame = ANIMATOR.current_frame) {
		var seq = inputs[| 0].getValue();
		var spd = inputs[| 1].getValue();
		
		if(!is_array(seq)) {
			outputs[| 0].setValue(seq);
			return;
		}
		
		var _frame = safe_mod(floor(ANIMATOR.current_frame / spd), array_length(seq));
		outputs[| 0].setValue(array_safe_get(seq, _frame));
	}
}